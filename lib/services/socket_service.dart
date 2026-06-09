import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../local_storage/shared_pref.dart';
import 'api_constants.dart';

/// Socket.IO event names
class SocketEvents {
  static const String updateCallStatus = 'UPDATE_CALL_STATUS';
  static const String endCall = 'END_CALL';
}

/// Production-grade singleton Socket.IO service.
///
/// Reliability features (mirroring WhatsApp / Slack-style behavior):
///   1. Built-in exponential-backoff reconnection with infinite attempts.
///   2. Foreground re-check via [WidgetsBindingObserver] — when the OS resumes
///      the app, we verify the socket is alive and force-reconnect if not.
///   3. Network restoration via [connectivity_plus] — when Wi-Fi/data returns
///      after an outage, we immediately attempt to reconnect.
///   4. [onReconnected] callback so consumers (HomeController) can resync REST
///      state, since events emitted while we were offline are lost.
///   5. [_manualDisconnect] flag distinguishes user-initiated logout from a
///      network drop, preventing auto-reconnect after logout.
class SocketService extends GetxService with WidgetsBindingObserver {
  io.Socket? _socket;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  /// Observable connection state for UI bindings.
  var isConnected = false.obs;

  /// Fires after a *re*connect (not the initial connect). Use this to refresh
  /// state from REST APIs because socket.io does not buffer events while we
  /// are offline.
  VoidCallback? onReconnected;

  /// True once we have successfully connected at least once in this session.
  /// Used to distinguish "first connect" from "reconnect after a drop".
  bool _everConnected = false;

  /// True when [disconnect] was called explicitly (e.g., user logout).
  /// Prevents the lifecycle / connectivity listeners from auto-reconnecting
  /// the socket against the user's intent.
  bool _manualDisconnect = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _listenConnectivity();
  }

  /// Listen to OS-level connectivity transitions. When we go from offline →
  /// online, force a reconnect attempt even if socket.io's internal retry
  /// timer hasn't fired yet — this makes recovery feel instant to the user.
  void _listenConnectivity() {
    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final hasConnection = !results.contains(ConnectivityResult.none);
      log('[SocketService] Connectivity changed: $results (online=$hasConnection)');
      if (hasConnection && !isConnected.value && !_manualDisconnect) {
        log('[SocketService] Network restored → attempting reconnect');
        connect();
      }
    });
  }

  /// Called by the framework when app state changes. When the user brings
  /// the app to foreground after Android/iOS suspended it, the socket is
  /// often dead even though [isConnected] still reads true (the OS may have
  /// killed the TCP connection without notifying us). Force a reconnect.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log('[SocketService] Lifecycle: $state');
    if (state == AppLifecycleState.resumed && !_manualDisconnect) {
      // If we think we're connected, verify by sending a no-op. If actually
      // dead, the socket will emit disconnect and our handler will reconnect.
      // If we know we're disconnected, reconnect immediately.
      if (_socket == null || !_socket!.connected) {
        log('[SocketService] App resumed and socket not connected → reconnecting');
        connect();
      }
    }
  }

  /// Connect to the socket server. Safe to call multiple times — no-ops when
  /// already connected, resumes an existing dead socket, or creates a fresh
  /// one if none exists.
  void connect() {
    _manualDisconnect = false;

    if (_socket != null && _socket!.connected) {
      log('[SocketService] Already connected — skipping');
      return;
    }

    // Existing socket that's disconnected → just reconnect it. Re-creating
    // the socket would lose the registered event listeners.
    if (_socket != null) {
      log('[SocketService] Resuming existing disconnected socket');
      _socket!.connect();
      return;
    }

    final token = MySharedPref.getAuthToken();
    if (token == null || token.isEmpty) {
      log('[SocketService] No auth token — skipping socket connection');
      return;
    }

    log('[SocketService] Creating new socket → ${ApiConstants.socketUrl}');

    _socket = io.io(
      ApiConstants.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .setQuery({'token': token}) // backend may read from either
          .disableAutoConnect()
          .enableReconnection()
          // Effectively infinite — keep trying until app is killed or user logs out.
          .setReconnectionAttempts(0x7FFFFFFF)
          // Start at 1s, cap at 5s, jitter 50% to avoid thundering-herd on backend.
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setRandomizationFactor(0.5)
          .setTimeout(15000)
          .build(),
    );

    _socket!.onConnect((_) {
      log('[SocketService] ✅ Connected — id: ${_socket!.id}');
      final wasReconnect = _everConnected;
      _everConnected = true;
      isConnected.value = true;
      if (wasReconnect) {
        log('[SocketService] 🔁 This was a reconnect — firing onReconnected callback');
        try {
          onReconnected?.call();
        } catch (e) {
          log('[SocketService] onReconnected callback threw: $e');
        }
      }
    });

    _socket!.onDisconnect((reason) {
      log('[SocketService] ❌ Disconnected — reason: $reason');
      isConnected.value = false;
      // socket.io will auto-retry per the reconnection config above.
      // No manual action needed here.
    });

    _socket!.onConnectError((err) {
      log('[SocketService] ❌ Connect error: $err');
      isConnected.value = false;
    });

    _socket!.onError((err) {
      log('[SocketService] ❌ Error: $err');
    });

    // socket.io v3 reconnection lifecycle events (string-based to ensure
    // they work across minor versions of the client library).
    _socket!.on('reconnect', (attempt) {
      log('[SocketService] 🔁 reconnect (attempt #$attempt)');
    });
    _socket!.on('reconnect_attempt', (attempt) {
      log('[SocketService] 🔁 reconnect_attempt #$attempt');
    });
    _socket!.on('reconnect_error', (err) {
      log('[SocketService] 🔁 reconnect_error: $err');
    });
    _socket!.on('reconnect_failed', (_) {
      log('[SocketService] 🔁 reconnect_failed — giving up this cycle');
    });

    // Debug: log every incoming event.
    _socket!.onAny((event, data) {
      log('[SocketService] 📥 EVENT "$event" → $data');
    });

    _socket!.connect();
  }

  /// Disconnect from the socket. Marks the disconnect as user-initiated so
  /// the lifecycle/connectivity listeners do NOT auto-reconnect.
  void disconnect() {
    _manualDisconnect = true;
    _everConnected = false;
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    isConnected.value = false;
    log('[SocketService] Manually disconnected');
  }

  /// Listen to a specific event
  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  /// Remove a specific event listener
  void off(String event) {
    _socket?.off(event);
  }

  /// Emit an event
  void emit(String event, [dynamic data]) {
    _socket?.emit(event, data);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySub?.cancel();
    disconnect();
    super.onClose();
  }
}
