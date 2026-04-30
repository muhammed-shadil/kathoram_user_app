import 'dart:developer';

import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../local_storage/shared_pref.dart';
import 'api_constants.dart';

/// Socket.IO event names
class SocketEvents {
  static const String updateCallStatus = 'UPDATE_CALL_STATUS';
  static const String endCall = 'END_CALL';
}

/// Singleton Socket.IO service
class SocketService extends GetxService {
  io.Socket? _socket;

  var isConnected = false.obs;

  /// Connect to socket server with auth token
  void connect() {
    if (_socket != null && _socket!.connected) {
      log('[SocketService] Already connected — skipping');
      return;
    }

    // Dispose any stale socket before creating a new one
    _socket?.dispose();
    _socket = null;

    final token = MySharedPref.getAuthToken();
    if (token == null || token.isEmpty) {
      log('[SocketService] No auth token, skipping socket connection');
      return;
    }

    final url = '${ApiConstants.socketUrl}?token=$token';
    log('[SocketService] Connecting to: ${ApiConstants.socketUrl}');

    _socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .disableReconnection() // we handle reconnect manually
          .build(),
    );

    _socket!.onConnect((_) {
      log('[SocketService] ✅ Connected — socket id: ${_socket!.id}');
      isConnected.value = true;
    });

    _socket!.onDisconnect((reason) {
      log('[SocketService] ❌ Disconnected — reason: $reason');
      isConnected.value = false;
    });

    _socket!.onConnectError((error) {
      log('[SocketService] ❌ Connection Error: $error');
      isConnected.value = false;
    });

    _socket!.onError((error) {
      log('[SocketService] ❌ Socket Error: $error');
    });

    // DEBUG: Log ALL incoming events from backend
    _socket!.onAny((event, data) {
      log('[SocketService] 📥 EVENT: "$event" → $data');
    });

    _socket!.connect();
  }

  /// Disconnect from socket server
  void disconnect() {
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
    disconnect();
    super.onClose();
  }
}
