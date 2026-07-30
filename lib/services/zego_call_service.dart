import 'dart:async';
import 'dart:developer';
import 'dart:io' show Platform;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import '../features/authentication/controller/auth_controller.dart';
import '../features/home/controller/home_controller.dart';

/// Singleton service managing ZegoCloud call invitations.
///
/// Usage:
///  1. Call [initialSetUp] BEFORE runApp().
///  2. Call [onUserLogin] AFTER successful backend login (user profile available).
///  3. Call [sendAudioCallToStaff] to initiate an outgoing call invitation.
///  4. Call [onUserLogout] on logout.
///
/// ## Why this class tracks the signaling connection
///
/// [ZegoUIKitPrebuiltCallInvitationService.init] logs the user into ZIM
/// (Zego's signaling layer) over the network. A plain "did we call init()"
/// boolean says nothing about whether that socket is still alive: the OS kills
/// it after a long background, a Wi-Fi↔mobile switch drops it, and ZIM kicks
/// this device if the same userID logs in elsewhere. When that happened the
/// old flag stayed `true`, [onUserLogin] skipped the re-init, and every
/// [sendAudioCallToStaff] failed with a generic toast until the user killed
/// the app.
///
/// So the real state is now read from two authoritative sources, never from a
/// flag alone:
///  * `ZegoUIKitPrebuiltCallInvitationService().isInit` — SDK-side init state.
///  * `ZegoUIKit().getSignalingPlugin().getConnectionState()` — live ZIM socket.
///
/// [_isInitialized] survives only as a fast "our init attempt succeeded" hint;
/// the connection-state listener clears it the moment ZIM disconnects so the
/// next login/resume is allowed through to a real re-init.
///
/// Mirrors the recovery pattern `SocketService` already uses (its own
/// lifecycle observer + reconnect-on-resume) rather than piggybacking on
/// `HomeController`'s payment-reconciliation observer, so call recovery keeps
/// working even when that controller is disposed.
class ZegoCallService with WidgetsBindingObserver {
  ZegoCallService._();
  static final ZegoCallService instance = ZegoCallService._();

  /// TODO: Replace with your actual ZegoCloud credentials from https://console.zegocloud.com/
  static const int appID = 1989024957;
  static const String appSign =
      'e6d8e11e47a3d184fefe93bf57948f147bd6a4d36c3e41e1ecf60b59682a0d4d';

  /// Resource ID configured in Zego Console push certificate.
  /// MUST match exactly in both User & Staff apps AND Zego Console.
  static const String _resourceID = 'zego_audio_call';

  /// How long [_ensureSignalingReady] waits for ZIM to reach `connected`
  /// before giving up and letting the caller show the failure toast.
  static const Duration _connectionWaitTimeout = Duration(seconds: 8);

  /// Grace period before the first proactive reconnect attempt. ZIM runs its
  /// own reconnect loop, and a hard re-init fired the instant a blip is seen
  /// would abort a recovery that was already in progress. Two seconds is long
  /// enough for ZIM to win on a transient drop and short enough that the user
  /// never reaches the call button first. Set to [Duration.zero] for a truly
  /// immediate attempt.
  static const Duration _reconnectGrace = Duration(seconds: 2);

  /// Cap on consecutive proactive reconnects. Some causes never heal at
  /// runtime (Zego balance exhausted, appSign rejected, kicked out by the same
  /// userID on another device); without a cap those turn into an endless
  /// uninit/init loop that burns battery and floods Crashlytics.
  static const int _maxReconnectAttempts = 5;

  /// Longest backoff between reconnect attempts.
  static const Duration _maxReconnectDelay = Duration(seconds: 30);

  /// Our own "init() completed without throwing" hint. NOT the source of
  /// truth — see the class doc. Cleared by [_onConnectionStateChanged] on
  /// disconnect so a re-init can happen.
  bool _isInitialized = false;

  /// Guards against two concurrent init attempts (e.g. a resume and a tab
  /// switch firing at the same moment), which would race inside the SDK.
  bool _loginInFlight = false;

  /// True while [onUserLogout] is tearing the session down.
  ///
  /// Critical for the proactive reconnect: `uninit()` makes ZIM emit
  /// `disconnected`, and `AuthController._clearSessionAndNavigate` only nulls
  /// `userProfile` *after* awaiting our logout — so without this flag the
  /// reconnect would resolve the still-populated profile and silently log the
  /// user back into Zego mid-logout.
  bool _isLoggingOut = false;

  /// Pending proactive reconnect, and how many consecutive attempts have been
  /// made since the last time signaling was healthy.
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;

  /// Credentials of the logged-in user, cached on [onUserLogin]. Lets the
  /// resume/recovery path re-init without depending on `AuthController` still
  /// being registered.
  String? _cachedUserID;
  String? _cachedUserName;

  /// Timestamp of the last init() that completed without throwing. Reported
  /// with call failures so we can tell "never connected" apart from "was fine
  /// for two hours then died".
  DateTime? _lastSuccessfulInitAt;

  /// Last state seen on the connection stream, and when. Reported with call
  /// failures; also used to avoid tearing down an in-progress reconnect.
  ZegoSignalingPluginConnectionState? _lastConnectionState;
  DateTime? _lastConnectionStateAt;

  StreamSubscription<ZegoSignalingPluginConnectionStateChangedEvent>?
      _connectionStateSub;

  /// Temporarily stores the staff ID between call-sent and call-accepted
  String? _pendingStaffId;

  /// When [_pendingStaffId] was set. It is cleared by the decline/busy/
  /// timeout/cancel callbacks — the very callbacks that can go missing when
  /// signaling dies mid-invitation. Without an age cap a leaked pending ID
  /// would make [_isInCall] permanently true and disable reconnect for the
  /// rest of the process.
  DateTime? _pendingCallStartedAt;

  /// Upper bound on the ringing window (invite timeout is 30s). Past this a
  /// pending invitation is treated as stale, not as an active call. An
  /// *accepted* call outlives this but is covered by `HomeController.isInCall`.
  static const Duration _pendingCallMaxAge = Duration(seconds: 90);

  // ═══════════════════════════════════════════════════════════════════════════
  // SETUP — call BEFORE runApp()
  // ═══════════════════════════════════════════════════════════════════════════

  /// Must be called BEFORE runApp() to enable system calling UI (CallKit/ConnectionService).
  Future<void> initialSetUp(GlobalKey<NavigatorState> navigatorKey) async {
    ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
    await ZegoUIKit().initLog();
    // Installs the signaling plugin into ZegoPluginAdapter — must run before
    // _listenConnectionState(), which reaches through that adapter.
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
      [ZegoUIKitSignalingPlugin()],
    );

    _listenConnectionState();
    WidgetsBinding.instance.addObserver(this);

    log('[ZegoCallService] Initial setup complete (before runApp)');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CONNECTION STATE — the real source of truth for "can we call?"
  // ═══════════════════════════════════════════════════════════════════════════

  /// Subscribe to ZIM connection transitions for the whole app lifetime.
  ///
  /// This is what makes recovery possible: the moment the socket drops we
  /// clear [_isInitialized], so the next [onUserLogin] (from a tab switch, a
  /// resume, or [sendAudioCallToStaff]) performs a genuine re-init instead of
  /// short-circuiting on a stale flag.
  void _listenConnectionState() {
    if (_connectionStateSub != null) return;

    try {
      _connectionStateSub = ZegoUIKit()
          .getSignalingPlugin()
          .getConnectionStateStream()
          .listen(_onConnectionStateChanged);
      log('[ZegoCallService] Listening to signaling connection state');
    } catch (e, s) {
      // getConnectionStateStream() force-unwraps the installed plugin; if the
      // plugin ever fails to install we must not take the whole app down.
      log('[ZegoCallService] Could not attach connection listener: $e');
      _recordNonFatal(e, s, reason: 'zego_connection_listener_attach_failed');
    }
  }

  void _onConnectionStateChanged(
    ZegoSignalingPluginConnectionStateChangedEvent event,
  ) {
    final now = DateTime.now();
    final previous = _lastConnectionState;
    _lastConnectionState = event.state;
    _lastConnectionStateAt = now;

    log('[ZegoCallService] ${now.toIso8601String()} '
        'signaling state: ${previous?.name ?? 'unknown'} → ${event.state.name} '
        '(action: ${event.action.name}, extendedData: ${event.extendedData})');

    if (event.state == ZegoSignalingPluginConnectionState.connected) {
      // Healthy again — drop any pending retry and reset the backoff so a
      // future drop starts from a clean slate.
      _reconnectAttempts = 0;
      _cancelScheduledReconnect();
    }

    if (event.state == ZegoSignalingPluginConnectionState.disconnected) {
      // Allow the next login/resume to actually re-init...
      _isInitialized = false;
      log('[ZegoCallService] Signaling disconnected — cleared init flag');
      // ...and don't wait for a natural trigger: recover on our own.
      _scheduleReconnect();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PROACTIVE RECONNECT — self-heal without waiting for login/resume/call
  // ═══════════════════════════════════════════════════════════════════════════

  /// Queue a [_attemptReconnect] after a backoff delay.
  ///
  /// Everything that could turn recovery into a loop is filtered here:
  /// logout teardown, our own uninit/init, an active call, a missing session,
  /// an already-pending timer, and the attempt cap.
  void _scheduleReconnect({Duration? overrideDelay}) {
    if (_isLoggingOut) {
      log('[ZegoCallService] Reconnect skipped — logging out');
      return;
    }
    if (_loginInFlight) {
      // This disconnect is almost certainly our own uninit() inside
      // onUserLogin; that flow re-inits by itself.
      log('[ZegoCallService] Reconnect skipped — login already in flight');
      return;
    }
    if (_reconnectTimer?.isActive ?? false) {
      log('[ZegoCallService] Reconnect already scheduled');
      return;
    }
    if (_isInCall) {
      // Re-initializing tears down the invitation service under a live call.
      // The call's own media channel is separate from signaling, so let it
      // finish; the next send() repairs signaling anyway.
      log('[ZegoCallService] Reconnect deferred — call in progress');
      return;
    }
    if (_resolveCredentials() == null) {
      log('[ZegoCallService] Reconnect skipped — no user session');
      return;
    }
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      log('[ZegoCallService] Reconnect give-up after $_reconnectAttempts '
          'attempts — cause is not recoverable at runtime '
          '(Zego balance, appSign, or kicked out by another device?)');
      _recordNonFatal(
        'Zego signaling unrecoverable after $_reconnectAttempts reconnects',
        StackTrace.current,
        reason: 'zego_reconnect_exhausted',
        extra: {
          'signaling_state': _connectionState?.name ?? 'unavailable',
          'last_successful_init':
              _lastSuccessfulInitAt?.toIso8601String() ?? 'never',
        },
      );
      return;
    }

    final delay = overrideDelay ?? _reconnectDelay;
    log('[ZegoCallService] Scheduling reconnect #${_reconnectAttempts + 1} '
        'in ${delay.inMilliseconds}ms');
    _reconnectTimer = Timer(delay, () => unawaited(_attemptReconnect()));
  }

  /// Exponential backoff: grace, then 2×, 4×… capped at [_maxReconnectDelay].
  Duration get _reconnectDelay {
    if (_reconnectAttempts == 0) return _reconnectGrace;
    final scaled = _reconnectGrace * (1 << _reconnectAttempts);
    return scaled > _maxReconnectDelay ? _maxReconnectDelay : scaled;
  }

  void _cancelScheduledReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// Re-establish the Zego session using the cached user, then verify it
  /// actually came up — scheduling another attempt if it did not.
  Future<void> _attemptReconnect() async {
    _reconnectTimer = null;

    if (_isLoggingOut || _loginInFlight) return;

    // ZIM's own reconnect may have won during the grace period.
    if (_isSignalingConnected) {
      log('[ZegoCallService] Reconnect unnecessary — ZIM recovered on its own');
      _reconnectAttempts = 0;
      return;
    }
    if (_isSignalingSettling) {
      // ZIM is handling it. Re-check on a fixed, slower interval rather than
      // the backoff: this path deliberately does not consume an attempt, so
      // using the short grace here would poll forever on a device that stays
      // stuck in `reconnecting` (e.g. no network at all).
      log('[ZegoCallService] ZIM is ${_connectionState?.name} — '
          'deferring our reconnect');
      _scheduleReconnect(overrideDelay: _connectionWaitTimeout);
      return;
    }
    if (_isInCall) {
      log('[ZegoCallService] Reconnect deferred — call in progress');
      return;
    }

    final credentials = _resolveCredentials();
    if (credentials == null) return;

    _reconnectAttempts++;
    log('[ZegoCallService] Reconnect attempt $_reconnectAttempts for '
        '${credentials.userID}');

    await onUserLogin(
      userID: credentials.userID,
      userName: credentials.userName,
      forceReinit: true,
    );

    final recovered = await _waitForConnection(_connectionWaitTimeout);
    if (recovered) {
      log('[ZegoCallService] Reconnect attempt $_reconnectAttempts succeeded');
      _reconnectAttempts = 0;
    } else {
      log('[ZegoCallService] Reconnect attempt $_reconnectAttempts failed');
      _scheduleReconnect();
    }
  }

  /// True when a call is pending or live, so recovery does not tear down a
  /// session the user is actively using.
  bool get _isInCall {
    final pendingSince = _pendingCallStartedAt;
    if (_pendingStaffId != null &&
        pendingSince != null &&
        DateTime.now().difference(pendingSince) < _pendingCallMaxAge) {
      return true;
    }
    try {
      return Get.find<HomeController>().isInCall.value;
    } catch (_) {
      return false;
    }
  }

  /// Live ZIM state. Null when the plugin is not reachable yet.
  ZegoSignalingPluginConnectionState? get _connectionState {
    try {
      return ZegoUIKit().getSignalingPlugin().getConnectionState();
    } catch (_) {
      return null;
    }
  }

  /// True only when signaling is fully usable for sending an invitation.
  bool get _isSignalingConnected =>
      _connectionState == ZegoSignalingPluginConnectionState.connected;

  /// True while ZIM is mid-handshake. Not sendable, but must not be torn down.
  bool get _isSignalingSettling {
    final state = _connectionState;
    return state == ZegoSignalingPluginConnectionState.connecting ||
        state == ZegoSignalingPluginConnectionState.reconnecting;
  }

  /// Whether the SDK itself still considers the invitation service initialized.
  bool get _sdkReportsInit {
    try {
      return ZegoUIKitPrebuiltCallInvitationService().isInit;
    } catch (_) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOGIN — call AFTER successful user login (safe to call repeatedly)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Registers the current user with Zego signaling (ZIM) so they can
  /// send/receive call invitations.
  ///
  /// Safe to call on every `checkIsLogin()` — it no-ops when the session is
  /// genuinely healthy and repairs it when it is not. It never gates on
  /// [_isInitialized] alone; the live connection state gets the final say.
  ///
  /// [userID] MUST be the unique backend user ID (same `_id` stored in DB).
  /// [userName] is the display name shown in call notifications.
  Future<void> onUserLogin({
    required String userID,
    required String userName,
    bool forceReinit = false,
  }) async {
    if (userID.isEmpty) {
      log('[ZegoCallService] onUserLogin called with empty userID — ignoring');
      return;
    }

    final isDifferentUser = _cachedUserID != null && _cachedUserID != userID;
    _cachedUserID = userID;
    _cachedUserName = userName;

    if (_loginInFlight) {
      log('[ZegoCallService] Login already in flight — skipping duplicate');
      return;
    }

    // Healthy session for the same user → nothing to do. This is the common
    // path, since checkIsLogin runs on every tab switch.
    if (!forceReinit &&
        !isDifferentUser &&
        _isInitialized &&
        _sdkReportsInit &&
        _isSignalingConnected) {
      log('[ZegoCallService] Already connected for $userID — skipping re-init');
      return;
    }

    // ZIM is mid-(re)connect for the same user: let it finish rather than
    // tearing the session down underneath it.
    if (!forceReinit &&
        !isDifferentUser &&
        _isInitialized &&
        _sdkReportsInit &&
        _isSignalingSettling) {
      log('[ZegoCallService] Signaling is ${_connectionState?.name} — '
          'waiting for it to settle instead of re-initializing');
      return;
    }

    _loginInFlight = true;
    try {
      log('[ZegoCallService] Initializing Zego for $userID '
          '(forceReinit: $forceReinit, differentUser: $isDifferentUser, '
          'sdkInit: $_sdkReportsInit, state: ${_connectionState?.name})');

      // init() early-returns when the SDK already thinks it is initialized,
      // so a stale session must be torn down first or the "recovery" would
      // silently do nothing.
      if (_sdkReportsInit) {
        log('[ZegoCallService] Tearing down stale session before re-init');
        await ZegoUIKitPrebuiltCallInvitationService().uninit();
      }

      await _initInvitationService(userID: userID, userName: userName);

      _isInitialized = true;
      _lastSuccessfulInitAt = DateTime.now();
      log('[ZegoCallService] User logged in to Zego — userID: $userID '
          'at ${_lastSuccessfulInitAt!.toIso8601String()}');
    } catch (e, s) {
      // Leave _isInitialized false so the next attempt retries rather than
      // being locked out for the rest of the process lifetime.
      _isInitialized = false;
      log('[ZegoCallService] Zego init failed for $userID: $e');
      _recordNonFatal(e, s, reason: 'zego_init_failed');
    } finally {
      _loginInFlight = false;
    }
  }

  Future<void> _initInvitationService({
    required String userID,
    required String userName,
  }) {
    return ZegoUIKitPrebuiltCallInvitationService().init(
      appID: appID,
      appSign: appSign,
      userID: userID,
      userName: userName,
      plugins: [ZegoUIKitSignalingPlugin()],
      ringtoneConfig: ZegoCallRingtoneConfig(
        incomingCallPath: 'assets/sounds/teams_ringtone.mp3',
        outgoingCallPath: 'assets/sounds/teams_ringtone.mp3',
      ),
      invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
        onError: (error) {
          // Reported to Crashlytics too — this callback carries the real ZIM
          // error code behind an otherwise generic call failure.
          log('[ZegoCallService] Error: ${error.code} — ${error.message}');
          _recordNonFatal(
            'Zego invitation error ${error.code}: ${error.message}',
            StackTrace.current,
            reason: 'zego_invitation_error',
            extra: {'zego_error_code': error.code.toString()},
          );
        },
        onOutgoingCallSent: (callID, callee, type, invitees, customData) {
          log('[ZegoCallService] Call sent → invitees: ${invitees.map((e) => e.id).toList()}');
          // Store staff ID for when call is accepted
          if (invitees.isNotEmpty) {
            _pendingStaffId = invitees.first.id;
            _pendingCallStartedAt = DateTime.now();
          }
        },
        onOutgoingCallAccepted: (callID, callee) {
          log('[ZegoCallService] Call accepted by: ${callee.id}');
          // NOW initiate call API — coins start deducting only after staff picks up
          _onCallAccepted(callee.id);
        },
        onOutgoingCallDeclined: (callID, callee, data) {
          log('[ZegoCallService] Call declined by callee');
          _clearPendingCall();
        },
        onOutgoingCallRejectedCauseBusy: (callID, callee, data) {
          log('[ZegoCallService] Callee is busy');
          _clearPendingCall();
        },
        onOutgoingCallTimeout: (callID, callees, isVideo) {
          log('[ZegoCallService] Call timeout — staff did not answer');
          _clearPendingCall();
        },
        onOutgoingCallCancelButtonPressed: () {
          log('[ZegoCallService] User cancelled outgoing call');
          _clearPendingCall();
        },
      ),
      notificationConfig: ZegoCallInvitationNotificationConfig(
        androidNotificationConfig: ZegoCallAndroidNotificationConfig(
          showFullScreen: true,
          callChannel: ZegoCallAndroidNotificationChannelConfig(
            channelID: "ZegoCallChannelV3",
            channelName: "Call Notifications",
            sound: "teams_ringtone",
            icon: "call",
          ),
          missedCallChannel: ZegoCallAndroidNotificationChannelConfig(
            channelID: "MissedCall",
            channelName: "Missed Call",
            sound: "missed_call",
            icon: "missed_call",
            vibrate: false,
          ),
        ),
        iOSNotificationConfig: ZegoCallIOSNotificationConfig(
          systemCallingIconName: 'CallKitIcon',
        ),
      ),
      events: ZegoUIKitPrebuiltCallEvents(
        onCallEnd: (ZegoCallEndEvent event, VoidCallback defaultAction) {
          log('[ZegoCallService] Call ended — reason: ${event.reason}');
          _onCallEnded();
          defaultAction.call();
        },
      ),
      requireConfig: (ZegoCallInvitationData data) {
        final config = ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
          ..turnOnCameraWhenJoining = false
          ..turnOnMicrophoneWhenJoining = true
          ..useSpeakerWhenJoining = false;
        config.layout = ZegoLayout.pictureInPicture(
          isSmallViewDraggable: false,
          smallViewSize: Size.zero, // 🔥 THIS removes the small preview
        );
        config.topMenuBar.isVisible = true;
        config.topMenuBar.buttons.insert(
          0,
          ZegoCallMenuBarButtonName.minimizingButton,
        );

        return config;
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // APP LIFECYCLE — repair the session when the user comes back
  // ═══════════════════════════════════════════════════════════════════════════

  /// The OS routinely kills the ZIM socket while the app sits in the
  /// background (doze, OEM battery managers, network handover). On resume we
  /// re-verify and re-init if needed, so the first call attempt after coming
  /// back is not the one that has to discover the session is dead.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    log('[ZegoCallService] Lifecycle: $state '
        '(signaling: ${_connectionState?.name ?? 'unknown'})');

    if (state == AppLifecycleState.resumed) {
      unawaited(_verifyConnectionOnResume());
    }
  }

  Future<void> _verifyConnectionOnResume() async {
    final credentials = _resolveCredentials();
    if (credentials == null) {
      log('[ZegoCallService] Resume: no cached user — nothing to restore');
      return;
    }

    if (_isSignalingConnected && _sdkReportsInit) {
      log('[ZegoCallService] Resume: signaling healthy — no action needed');
      return;
    }

    if (_isSignalingSettling) {
      log('[ZegoCallService] Resume: signaling ${_connectionState?.name} — '
          'letting ZIM finish its own reconnect');
      return;
    }

    log('[ZegoCallService] Resume: signaling '
        '${_connectionState?.name ?? 'unknown'} → re-initializing Zego');
    await onUserLogin(
      userID: credentials.userID,
      userName: credentials.userName,
      forceReinit: true,
    );
  }

  /// Cached credentials, falling back to the live `AuthController` session
  /// (registered `permanent: true`, so it outlives individual routes).
  ({String userID, String userName})? _resolveCredentials() {
    final cachedID = _cachedUserID;
    if (cachedID != null && cachedID.isNotEmpty) {
      return (userID: cachedID, userName: _cachedUserName ?? 'User');
    }

    try {
      final profile = Get.find<AuthController>().userProfile.value;
      if (profile != null && profile.id.isNotEmpty) {
        return (userID: profile.id, userName: profile.name);
      }
    } catch (_) {
      // AuthController not registered yet (pre-login) — nothing to restore.
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SEND CALL — trigger outgoing audio call invitation
  // ═══════════════════════════════════════════════════════════════════════════

  /// Send an audio call invitation to a staff member.
  ///
  /// [staffUserID] MUST be the exact same ID the staff used in their Zego init().
  /// [staffUserName] is the staff display name.
  /// [callerName] is used as notification title on the receiver side.
  ///
  /// Before sending, the live signaling state is verified and repaired if
  /// needed, so a dead-but-flagged-alive session no longer produces an
  /// unrecoverable failure toast.
  ///
  /// Returns `true` if the invitation was actually dispatched, `false`
  /// otherwise. On failure a toast is shown so the user is never left tapping
  /// into a void, and a non-fatal is reported to Crashlytics with the real
  /// connection state so "no network", "not logged in" and "session expired"
  /// can be told apart from the logs.
  Future<bool> sendAudioCallToStaff({
    required String staffUserID,
    required String staffUserName,
    required String callerName,
  }) async {
    log('[ZegoCallService] Sending audio call → staff: $staffUserID ($staffUserName)');

    // Network-absence check first, so "the phone has no data" is never
    // reported (to the user or to Crashlytics) as a signaling desync. Note
    // this detects a missing *interface* — a connected-but-dead network
    // (captive portal, no data balance) still falls through to the signaling
    // path below, which is the correct place to catch it.
    final connectivity = await _currentConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      await _handleCallFailure(
        staffUserID: staffUserID,
        stage: 'offline',
        detail: 'Device reports no network interface',
        connectivity: connectivity,
        showToast: _showNoInternetToast,
      );
      return false;
    }

    final ready = await _ensureSignalingReady();
    if (!ready) {
      await _handleCallFailure(
        staffUserID: staffUserID,
        stage: 'precheck',
        detail: 'Signaling not ready before send',
      );
      return false;
    }

    try {
      final sent = await ZegoUIKitPrebuiltCallInvitationService().send(
        invitees: [ZegoCallUser(staffUserID, staffUserName)],
        isVideoCall: false,
        resourceID: _resourceID,
        notificationTitle: callerName,
        notificationMessage: 'Incoming audio call',
        timeoutSeconds: 30,
      );

      if (!sent) {
        // send() only returns false for a handful of reasons: signaling not
        // connected, the SDK not initialized, the callee already in our
        // "inviting" set from a previous call that never cleaned up, or ZIM
        // rejecting the invite (unknown callee / quota / auth). The
        // diagnostics attached below are what distinguish them.
        await _handleCallFailure(
          staffUserID: staffUserID,
          stage: 'send_returned_false',
          detail: 'ZegoUIKitPrebuiltCallInvitationService.send() returned false',
        );
      }
      return sent;
    } catch (e, s) {
      await _handleCallFailure(
        staffUserID: staffUserID,
        stage: 'send_threw',
        detail: e.toString(),
        stackTrace: s,
      );
      return false;
    }
  }

  /// Verify — and if necessary repair — the signaling session before sending.
  ///
  /// Returns true only when ZIM is `connected`. Re-inits a dead session using
  /// the cached credentials, then polls until the socket comes up or
  /// [_connectionWaitTimeout] elapses.
  Future<bool> _ensureSignalingReady() async {
    if (_isSignalingConnected && _sdkReportsInit) return true;

    final credentials = _resolveCredentials();
    if (credentials == null) {
      log('[ZegoCallService] Cannot send — no user session available '
          '(user never completed Zego login)');
      return false;
    }

    // Dead session → rebuild it. Mid-handshake → skip straight to waiting.
    if (!_isSignalingSettling) {
      log('[ZegoCallService] Pre-send repair: signaling '
          '${_connectionState?.name ?? 'unknown'}, sdkInit: $_sdkReportsInit '
          '→ re-initializing');
      await onUserLogin(
        userID: credentials.userID,
        userName: credentials.userName,
        forceReinit: true,
      );
    }

    return _waitForConnection(_connectionWaitTimeout);
  }

  Future<bool> _waitForConnection(Duration timeout) async {
    const pollInterval = Duration(milliseconds: 250);
    var waited = Duration.zero;

    while (waited < timeout) {
      if (_isSignalingConnected) {
        if (waited > Duration.zero) {
          log('[ZegoCallService] Signaling connected after ${waited.inMilliseconds}ms');
        }
        return true;
      }
      await Future.delayed(pollInterval);
      waited += pollInterval;
    }

    log('[ZegoCallService] Timed out after ${timeout.inSeconds}s waiting for '
        'signaling (last state: ${_connectionState?.name ?? 'unknown'})');
    return false;
  }

  /// Single exit point for a failed call attempt: specific log line, generic
  /// user-facing toast, and a Crashlytics non-fatal carrying the diagnosis.
  Future<void> _handleCallFailure({
    required String staffUserID,
    required String stage,
    required String detail,
    StackTrace? stackTrace,
    List<ConnectivityResult>? connectivity,
    VoidCallback? showToast,
  }) async {
    final diagnostics = await _collectDiagnostics(
      staffUserID: staffUserID,
      connectivity: connectivity,
    );
    final summary =
        stage == 'offline' ? 'device is offline' : _describeFailure();

    log('[ZegoCallService] CALL FAILED ($stage): $detail\n'
        '  diagnosis: $summary\n'
        '  ${diagnostics.entries.map((e) => '${e.key}: ${e.value}').join('\n  ')}');

    (showToast ?? _showCallFailedToast)();

    _recordNonFatal(
      'Zego call failed [$stage] — $summary: $detail',
      stackTrace ?? StackTrace.current,
      reason: 'zego_call_send_failed',
      extra: {'failure_stage': stage, ...diagnostics},
    );
  }

  /// Best-effort human-readable cause, so log/Crashlytics triage does not
  /// require re-deriving it from the raw state every time.
  String _describeFailure() {
    if (_resolveCredentials() == null) {
      return 'no user session — Zego login never ran (check is-login API)';
    }
    switch (_connectionState) {
      case null:
        return 'signaling plugin unavailable — init never completed';
      case ZegoSignalingPluginConnectionState.disconnected:
        return _lastSuccessfulInitAt == null
            ? 'never connected — likely network, appSign, or Zego account issue'
            : 'signaling dropped after a good init — network switch, long '
                'background, or kicked out by same userID elsewhere';
      case ZegoSignalingPluginConnectionState.connecting:
        return 'still connecting — user tapped before ZIM login finished';
      case ZegoSignalingPluginConnectionState.reconnecting:
        return 'reconnecting — transient network loss';
      case ZegoSignalingPluginConnectionState.connected:
        return 'signaling connected but send rejected — check the callee ID '
            'matches the staff app Zego userID, or a stale invitation is '
            'still pending for this callee';
    }
  }

  /// Current network interfaces. `[ConnectivityResult.none]` means offline;
  /// an empty list means the query itself failed, which must NOT be treated
  /// as offline or we would block calls on a plugin error.
  Future<List<ConnectivityResult>> _currentConnectivity() async {
    try {
      // connectivity_plus is already a dependency (used by SocketService).
      return await Connectivity().checkConnectivity();
    } catch (e) {
      log('[ZegoCallService] Connectivity check failed: $e');
      return const [];
    }
  }

  Future<Map<String, String>> _collectDiagnostics({
    required String staffUserID,
    List<ConnectivityResult>? connectivity,
  }) async {
    final now = DateTime.now();
    // Reuse the caller's reading when it already has one (the offline path),
    // otherwise query fresh.
    final results = connectivity ?? await _currentConnectivity();
    final networkType =
        results.isEmpty ? 'unknown' : results.map((r) => r.name).join(',');

    return {
      'timestamp': now.toIso8601String(),
      'signaling_state': _connectionState?.name ?? 'unavailable',
      'last_state_change': _lastConnectionStateAt?.toIso8601String() ?? 'never',
      'last_stream_state': _lastConnectionState?.name ?? 'none',
      'sdk_is_init': _sdkReportsInit.toString(),
      'service_flag_init': _isInitialized.toString(),
      'last_successful_init':
          _lastSuccessfulInitAt?.toIso8601String() ?? 'never',
      'seconds_since_init': _lastSuccessfulInitAt == null
          ? 'n/a'
          : now.difference(_lastSuccessfulInitAt!).inSeconds.toString(),
      'network_type': networkType,
      'caller_user_id': _cachedUserID ?? 'none',
      'callee_staff_id': staffUserID,
      'platform':
          '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
    };
  }

  /// Non-fatal reporting. Crashlytics is the crash reporter wired into this
  /// project (initialized in main.dart); it already attaches app version,
  /// device model and OS, so we only add call-specific keys here.
  void _recordNonFatal(
    Object error,
    StackTrace stackTrace, {
    required String reason,
    Map<String, String> extra = const {},
  }) {
    try {
      final crashlytics = FirebaseCrashlytics.instance;
      for (final entry in extra.entries) {
        crashlytics.setCustomKey(entry.key, entry.value);
      }
      crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        information: extra.entries.map((e) => '${e.key}: ${e.value}').toList(),
        fatal: false,
      );
    } catch (e) {
      // Never let telemetry break the call flow.
      log('[ZegoCallService] Failed to record non-fatal: $e');
    }
  }

  void _showCallFailedToast() {
    Fluttertoast.showToast(
      msg: 'Unable to place the call right now. Please check your '
          'connection and try again.',
      toastLength: Toast.LENGTH_LONG,
    );
  }

  /// Shown only when the device has no network interface at all. Kept
  /// distinct from [_showCallFailedToast] so the user gets an actionable
  /// message, and so support can tell the two apart from a screenshot alone.
  void _showNoInternetToast() {
    Fluttertoast.showToast(
      msg: 'No internet connection. Turn on Wi-Fi or mobile data and '
          'try again.',
      toastLength: Toast.LENGTH_LONG,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOGOUT — cleanup Zego session
  // ═══════════════════════════════════════════════════════════════════════════

  /// Call on user logout to disconnect from Zego signaling.
  Future<void> onUserLogout() async {
    // Order matters. uninit() below makes ZIM emit `disconnected`, which feeds
    // the proactive-reconnect path — and AuthController only nulls its
    // userProfile *after* awaiting this method. Without the flag (and clearing
    // the cache first) the reconnect would resolve the still-live profile and
    // log the user straight back into Zego.
    _isLoggingOut = true;
    _cancelScheduledReconnect();
    _reconnectAttempts = 0;
    _cachedUserID = null;
    _cachedUserName = null;
    _isInitialized = false;
    _lastSuccessfulInitAt = null;

    try {
      if (!_sdkReportsInit) return;
      await ZegoUIKitPrebuiltCallInvitationService().uninit();
      log('[ZegoCallService] User logged out from Zego');
    } finally {
      // Held briefly past uninit() so the trailing `disconnected` event, which
      // arrives asynchronously on the stream, still sees the logout in
      // progress and does not schedule a reconnect.
      Timer(const Duration(seconds: 1), () => _isLoggingOut = false);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIVATE — Backend API integration (socket & coin deduction)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Called when staff accepts the call — NOW start coin deduction.
  void _onCallAccepted(String staffId) {
    try {
      final homeController = Get.find<HomeController>();
      final actualStaffId = staffId.isNotEmpty ? staffId : _pendingStaffId;
      if (actualStaffId == null || actualStaffId.isEmpty) {
        log('[ZegoCallService] No staff ID available for initiateCall');
        return;
      }
      final roomId =
          '${homeController.userProfile?.id ?? "user"}_${actualStaffId}_${DateTime.now().millisecondsSinceEpoch}';
      homeController.initiateCall(receiverId: actualStaffId, roomId: roomId);
    } catch (e) {
      log('[ZegoCallService] Error calling initiate API: $e');
    }
  }

  /// Clear pending state when call was not connected.
  void _clearPendingCall() {
    _pendingStaffId = null;
    _pendingCallStartedAt = null;
  }

  /// Called when the actual call ends (hang up or remote end).
  void _onCallEnded() {
    _pendingStaffId = null;
    _pendingCallStartedAt = null;
    try {
      final homeController = Get.find<HomeController>();
      homeController.endCall();
    } catch (e) {
      log('[ZegoCallService] Error calling end-call API: $e');
    }
  }
}
