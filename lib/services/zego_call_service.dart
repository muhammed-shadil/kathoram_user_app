import 'dart:developer';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import '../features/home/controller/home_controller.dart';

/// Singleton service managing ZegoCloud call invitations.
///
/// Usage:
///  1. Call [initialSetUp] BEFORE runApp().
///  2. Call [onUserLogin] AFTER successful backend login (user profile available).
///  3. Call [sendAudioCallToStaff] to initiate an outgoing call invitation.
///  4. Call [onUserLogout] on logout.
class ZegoCallService {
  ZegoCallService._();
  static final ZegoCallService instance = ZegoCallService._();

  /// TODO: Replace with your actual ZegoCloud credentials from https://console.zegocloud.com/
  static const int appID = 1989024957;
  static const String appSign =
      'e6d8e11e47a3d184fefe93bf57948f147bd6a4d36c3e41e1ecf60b59682a0d4d';

  /// Resource ID configured in Zego Console push certificate.
  /// MUST match exactly in both User & Staff apps AND Zego Console.
  static const String _resourceID = 'zego_audio_call';

  bool _isInitialized = false;

  /// Temporarily stores the staff ID between call-sent and call-accepted
  String? _pendingStaffId;

  // ═══════════════════════════════════════════════════════════════════════════
  // SETUP — call BEFORE runApp()
  // ═══════════════════════════════════════════════════════════════════════════

  /// Must be called BEFORE runApp() to enable system calling UI (CallKit/ConnectionService).
  Future<void> initialSetUp(GlobalKey<NavigatorState> navigatorKey) async {
    ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
    await ZegoUIKit().initLog();
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
      [ZegoUIKitSignalingPlugin()],
    );
    log('[ZegoCallService] Initial setup complete (before runApp)');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOGIN — call AFTER successful user login
  // ═══════════════════════════════════════════════════════════════════════════

  /// Registers the current user with Zego signaling (ZIM) so they can
  /// send/receive call invitations.
  ///
  /// [userID] MUST be the unique backend user ID (same `_id` stored in DB).
  /// [userName] is the display name shown in call notifications.
  void onUserLogin({
    required String userID,
    required String userName,
  }) {
    if (_isInitialized) {
      log('[ZegoCallService] Already initialized — skipping duplicate login');
      return;
    }

    ZegoUIKitPrebuiltCallInvitationService().init(
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
          log('[ZegoCallService] Error: ${error.code} — ${error.message}');
        },
        onOutgoingCallSent: (callID, callee, type, invitees, customData) {
          log('[ZegoCallService] Call sent → invitees: ${invitees.map((e) => e.id).toList()}');
          // Store staff ID for when call is accepted
          if (invitees.isNotEmpty) {
            _pendingStaffId = invitees.first.id;
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

    _isInitialized = true;
    log('[ZegoCallService] User logged in to Zego — userID: $userID');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SEND CALL — trigger outgoing audio call invitation
  // ═══════════════════════════════════════════════════════════════════════════

  /// Send an audio call invitation to a staff member.
  ///
  /// [staffUserID] MUST be the exact same ID the staff used in their Zego init().
  /// [staffUserName] is the staff display name.
  /// [callerName] is used as notification title on the receiver side.
  /// Returns `true` if the invitation was actually dispatched, `false` if it
  /// failed (e.g. Zego signaling not connected — which happens when the Zego
  /// account balance/trial is exhausted, or there is no network). On failure a
  /// toast is shown so the user is never left tapping into a void.
  Future<bool> sendAudioCallToStaff({
    required String staffUserID,
    required String staffUserName,
    required String callerName,
  }) async {
    log('[ZegoCallService] Sending audio call → staff: $staffUserID ($staffUserName)');

    // Guard: signaling session must be up before we can send anything.
    if (!_isInitialized) {
      log('[ZegoCallService] Cannot send — service not initialized (user not logged into Zego)');
      _showCallFailedToast();
      return false;
    }

    try {
      final sent = await ZegoUIKitPrebuiltCallInvitationService().send(
        invitees: [ZegoCallUser(staffUserID, staffUserName)],
        isVideoCall: false,
        resourceID: _resourceID,
        notificationTitle: callerName,
        notificationMessage: 'Incoming audio call',
        timeoutSeconds: 60,
      );

      if (!sent) {
        // Most common cause: Zego signaling is disconnected because the Zego
        // project's balance/trial has run out. Nothing the app can fix at
        // runtime — but the user must be told instead of seeing a dead button.
        log('[ZegoCallService] send() returned false — signaling likely disconnected (check Zego balance/network)');
        _showCallFailedToast();
      }
      return sent;
    } catch (e) {
      log('[ZegoCallService] send() threw: $e');
      _showCallFailedToast();
      return false;
    }
  }

  void _showCallFailedToast() {
    Fluttertoast.showToast(
      msg: 'Unable to place the call right now. Please check your '
          'connection and try again.',
      toastLength: Toast.LENGTH_LONG,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOGOUT — cleanup Zego session
  // ═══════════════════════════════════════════════════════════════════════════

  /// Call on user logout to disconnect from Zego signaling.
  Future<void> onUserLogout() async {
    if (!_isInitialized) return;
    await ZegoUIKitPrebuiltCallInvitationService().uninit();
    _isInitialized = false;
    log('[ZegoCallService] User logged out from Zego');
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
  }

  /// Called when the actual call ends (hang up or remote end).
  void _onCallEnded() {
    _pendingStaffId = null;
    try {
      final homeController = Get.find<HomeController>();
      homeController.endCall();
    } catch (e) {
      log('[ZegoCallService] Error calling end-call API: $e');
    }
  }
}
