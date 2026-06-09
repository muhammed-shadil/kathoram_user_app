import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../services/api_constants.dart';
import '../../../services/socket_service.dart';
import '../../../utils/enum.dart';
import '../../authentication/controller/auth_controller.dart';
import '../../authentication/model/user_profile_model.dart';
import '../model/plan_model.dart';
import '../model/payment_model.dart';
import '../model/staff_model.dart';
import '../model/call_history_model.dart';
import '../repository/home_repository.dart';

class HomeController extends GetxController {
  // ─── Plans ───
  var plans = <PlanModel>[].obs;
  var isPlansLoading = false.obs;
  var plansApiStatus = ApiCallStatus.holding.obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var hasMorePages = true.obs;

  // ─── Staff List ───
  var staffList = <StaffModel>[].obs;
  var isStaffLoading = false.obs;
  var staffApiStatus = ApiCallStatus.holding.obs;
  var staffCurrentPage = 1.obs;
  var staffTotalPages = 1.obs;
  var staffHasMorePages = true.obs;

  // ─── Call History ───
  var callHistoryList = <CallHistoryModel>[].obs;
  var isCallHistoryLoading = false.obs;
  var callHistoryApiStatus = ApiCallStatus.holding.obs;
  var callHistoryCurrentPage = 1.obs;
  var callHistoryTotalPages = 1.obs;
  var callHistoryHasMorePages = true.obs;

  // ─── Payment ───
  var isPaymentLoading = false.obs;
  late Razorpay _razorpay;
  String? _currentPlanId;
  VoidCallback? _onPaymentSuccess;

  // ─── Active Call State ───
  var isCallLoading = false.obs;
  var activeCallId = RxnString(); // backend call _id from initiate-call
  var isInCall = false.obs; // whether user is currently in a Zego call

  // ─── Animated Move-to-Top ───
  /// Tracks the staff ID that was just moved to the top of the list (for animation).
  var recentlyMovedToTopId = RxnString();

  // ─── Socket Service ───
  late SocketService _socketService;

  // ─── User Profile (shared from AuthController) ───
  UserProfileData? get userProfile {
    try {
      final authController = Get.find<AuthController>();
      return authController.userProfile.value;
    } catch (_) {
      return null;
    }
  }

  int get userCoins => userProfile?.userCoins ?? 0;
  String get userName => userProfile?.name ?? "User";
  String get userMobile => userProfile?.mobileNumber ?? "";
  String get userProfileImage => userProfile?.profileImage ?? "";

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Get or create socket service (permanent so it survives controller re-creation)
    _socketService = Get.put(SocketService(), permanent: true);

    // Ensure user profile data is loaded
    _refreshUserProfile();
    fetchPlans();
    fetchStaffList();
    fetchCallHistory();

    // Connect socket for real-time events (stays alive for entire session)
    connectSocket();
  }

  /// Call isLogin API to ensure user profile data is available
  Future<void> _refreshUserProfile() async {
    try {
      final authController = Get.find<AuthController>();
      await authController.checkIsLogin();
    } catch (_) {}
  }

  @override
  void onClose() {
    _razorpay.clear();
    disconnectSocket();
    super.onClose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SOCKET.IO — connect, listen, disconnect
  // ═══════════════════════════════════════════════════════════════════════════

  /// Connect socket and register event listeners
  void connectSocket() {
    // Resync REST state after every reconnect — socket events emitted while
    // we were offline are lost, so without this the UI shows stale staff
    // status / call history / coin balance after a network drop.
    _socketService.onReconnected = _resyncStateAfterReconnect;

    _socketService.connect();
    // Remove old listeners before adding new ones to prevent duplicates
    _socketService.off(SocketEvents.updateCallStatus);
    _socketService.off(SocketEvents.endCall);
    _listenSocketEvents();
  }

  /// Called by SocketService after a successful reconnect (not the initial
  /// connect). Re-pulls every list that the socket would otherwise have kept
  /// up to date in real time.
  void _resyncStateAfterReconnect() {
    log('[HomeController] Socket reconnected — resyncing state from REST');
    _refreshUserProfile();
    fetchStaffList();
    fetchCallHistory();
    // Re-register event listeners on the live socket so future deltas are
    // delivered correctly after this reconnect.
    _socketService.off(SocketEvents.updateCallStatus);
    _socketService.off(SocketEvents.endCall);
    _listenSocketEvents();
  }

  /// Disconnect socket and remove event listeners
  void disconnectSocket() {
    _socketService.off(SocketEvents.updateCallStatus);
    _socketService.off(SocketEvents.endCall);
    _socketService.disconnect();
  }

  /// Register socket event listeners
  void _listenSocketEvents() {
    // ── UPDATE_CALL_STATUS: { staffId, status }
    _socketService.on(SocketEvents.updateCallStatus, (data) {
      log('[Socket] UPDATE_CALL_STATUS: $data');
      if (data is Map<String, dynamic>) {
        final staffId = data['staffId']?.toString() ?? '';
        final newStatus = data['status']?.toString() ?? '';

        if (staffId.isEmpty) return;

        // Find the staff in our list and update their status in-place
        final index = staffList.indexWhere((s) => s.id == staffId);
        log('[Socket] Looking for staffId: "$staffId" in list of ${staffList.length} staff. Found at index: $index');
        if (index != -1) {
          final old = staffList[index];
          log('[Socket] Updating "${old.name}" status: "${old.status}" → "$newStatus"');

          // If going online and not already at the top, move to position 0
          // so the UI can play an entrance animation.
          if (newStatus == 'online' && old.status != 'online' && index > 0) {
            final updatedStaff = old.copyWith(status: newStatus);
            // Operate on the underlying list to avoid multiple reactive notifications
            staffList.value.removeAt(index);
            staffList.value.insert(0, updatedStaff);
            recentlyMovedToTopId.value = staffId;
            staffList.refresh(); // single notification
          } else {
            staffList[index] = old.copyWith(status: newStatus);
            staffList.refresh(); 
          }
        }
      }
    });

    // ── END_CALL: backend says stop (coins exhausted / timeout)
    _socketService.on(SocketEvents.endCall, (data) {
      log('[Socket] END_CALL: $data');
      _handleForceEndCall();
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CALL FLOW — initiate → zego → end
  // ═══════════════════════════════════════════════════════════════════════════

  /// Step 1: Call the initiate-call API. On success, returns the call _id and
  /// sets [isInCall] so ZegoCallService can begin.
  /// [roomId] is the Zego room ID that the staff app must join to connect.
  Future<bool> initiateCall({
    required String receiverId,
    required String roomId,
  }) async {
    try {
      isCallLoading.value = true;

      final response = await HomeRepository.initiateCall(
        receiverId: receiverId,
        roomId: roomId,
      );

      if (response.success && response.responseCode == 200 && response.data != null) {
        final callData = response.data as Map<String, dynamic>;
        activeCallId.value = callData['_id']?.toString();
        isInCall.value = true;
        log('[Call] Initiated — callId: ${activeCallId.value}');
        return true;
      } else {
        Fluttertoast.showToast(msg: response.message);
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      return false;
    } finally {
      isCallLoading.value = false;
    }
  }

  /// Step 2: Called when user manually hangs up or Zego call ends normally.
  Future<void> endCall() async {
    final callId = activeCallId.value;
    if (callId == null || callId.isEmpty) return;

    try {
      log('[Call] Ending — callId: $callId');
      await HomeRepository.endCall(callId: callId, endedBy: "caller");
    } catch (e) {
      log('[Call] End-call API error: $e');
    } finally {
      _resetCallState();
      // Refresh user profile to update coins
      _refreshUserProfile();
      // Refresh call history
      fetchCallHistory();
    }
  }

  /// Called by the END_CALL socket event — force-end the active Zego call.
  void _handleForceEndCall() {
    if (!isInCall.value) return;

    log('[Call] Force-ending call from backend');
    Fluttertoast.showToast(msg: "Call ended — coins exhausted");

    // Reset call state
    final callId = activeCallId.value;
    _resetCallState();

    // Fire end-call API just in case backend needs acknowledgement
    if (callId != null && callId.isNotEmpty) {
      HomeRepository.endCall(callId: callId, endedBy: "caller").ignore();
    }

    // Refresh user profile & call history
    _refreshUserProfile();
    fetchCallHistory();
  }

  void _resetCallState() {
    activeCallId.value = null;
    isInCall.value = false;
  }

  // ─── Fetch Staff List (with pagination) ───
  Future<void> fetchStaffList({bool loadMore = false}) async {
    if (loadMore && !staffHasMorePages.value) return;

    try {
      if (loadMore) {
        staffCurrentPage.value++;
      } else {
        staffCurrentPage.value = 1;
        staffList.clear();
      }

      isStaffLoading.value = true;
      staffApiStatus.value = ApiCallStatus.loading;

      final response = await HomeRepository.listStaff(
        page: staffCurrentPage.value,
        pageSize: 10,
      );

      if (response.success && response.data != null) {
        final staffResponse =
            StaffListResponse.fromJson(response.data as Map<String, dynamic>);

        if (loadMore) {
          staffList.addAll(staffResponse.result);
        } else {
          staffList.value = staffResponse.result;
        }

        staffTotalPages.value = staffResponse.pagination.totalPages;
        staffHasMorePages.value =
            staffCurrentPage.value < staffResponse.pagination.totalPages;

        staffApiStatus.value = ApiCallStatus.success;
      } else {
        staffApiStatus.value = ApiCallStatus.error;
        Fluttertoast.showToast(msg: response.message);
      }
    } catch (e) {
      staffApiStatus.value = ApiCallStatus.error;
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isStaffLoading.value = false;
    }
  }

  // ─── Fetch Call History (with pagination) ───
  Future<void> fetchCallHistory({bool loadMore = false}) async {
    if (loadMore && !callHistoryHasMorePages.value) return;

    try {
      if (loadMore) {
        callHistoryCurrentPage.value++;
      } else {
        callHistoryCurrentPage.value = 1;
        callHistoryList.clear();
      }

      isCallHistoryLoading.value = true;
      callHistoryApiStatus.value = ApiCallStatus.loading;

      final response = await HomeRepository.callHistory(
        page: callHistoryCurrentPage.value,
        pageSize: 10,
      );

      if (response.success && response.data != null) {
        final historyResponse = CallHistoryListResponse.fromJson(
            response.data as Map<String, dynamic>);

        if (loadMore) {
          callHistoryList.addAll(historyResponse.result);
        } else {
          callHistoryList.value = historyResponse.result;
        }

        callHistoryTotalPages.value = historyResponse.pagination.totalPages;
        callHistoryHasMorePages.value =
            callHistoryCurrentPage.value < historyResponse.pagination.totalPages;

        callHistoryApiStatus.value = ApiCallStatus.success;
      } else {
        callHistoryApiStatus.value = ApiCallStatus.error;
        Fluttertoast.showToast(msg: response.message);
      }
    } catch (e) {
      callHistoryApiStatus.value = ApiCallStatus.error;
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isCallHistoryLoading.value = false;
    }
  }

  // ─── Fetch Plans (with pagination) ───
  Future<void> fetchPlans({bool loadMore = false}) async {
    if (loadMore && !hasMorePages.value) return;

    try {
      if (loadMore) {
        currentPage.value++;
      } else {
        currentPage.value = 1;
        plans.clear();
      }

      isPlansLoading.value = true;
      plansApiStatus.value = ApiCallStatus.loading;

      final response = await HomeRepository.listPlans(
        page: currentPage.value,
        pageSize: 10,
      );

      if (response.success && response.data != null) {
        final planListResponse =
            PlanListResponse.fromJson(response.data as Map<String, dynamic>);

        if (loadMore) {
          plans.addAll(planListResponse.result);
        } else {
          plans.value = planListResponse.result;
        }

        totalPages.value = planListResponse.pagination.totalPages;
        hasMorePages.value =
            currentPage.value < planListResponse.pagination.totalPages;

        plansApiStatus.value = ApiCallStatus.success;
      } else {
        plansApiStatus.value = ApiCallStatus.error;
        Fluttertoast.showToast(msg: response.message);
      }
    } catch (e) {
      plansApiStatus.value = ApiCallStatus.error;
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isPlansLoading.value = false;
    }
  }

  // ─── Initiate Payment ───
  Future<void> initiatePayment(
    String planId, {
    VoidCallback? onSuccess,
  }) async {
    try {
      isPaymentLoading.value = true;
      _currentPlanId = planId;
      _onPaymentSuccess = onSuccess;

      final response = await HomeRepository.initiatePayment(planId);

      if (response.success && response.data != null) {
        final paymentData = PaymentInitiateResponse.fromJson(
            response.data as Map<String, dynamic>);

        _openRazorpayCheckout(paymentData);
      } else {
        isPaymentLoading.value = false;
        Fluttertoast.showToast(msg: response.message);
      }
    } catch (e) {
      isPaymentLoading.value = false;
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  // ─── Open Razorpay Checkout ───
  void _openRazorpayCheckout(PaymentInitiateResponse paymentData) {
    var options = {
      'key': ApiConstants.razorpayKey,
      'amount': paymentData.amount,
      'currency': paymentData.currency,
      'name': 'Kathoram',
      'description': 'Coin Purchase',
      'order_id': paymentData.orderId,
      'prefill': {
        'contact': userMobile,
        'email': '',
      },
      'theme': {
        'color': '#0D6EFD',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      isPaymentLoading.value = false;
      Fluttertoast.showToast(msg: "Error opening payment gateway");
    }
  }

  // ─── Razorpay Callbacks ───
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final verifyResponse = await HomeRepository.verifyPayment(
        razorpayOrderId: response.orderId ?? "",
        razorpayPaymentId: response.paymentId ?? "",
        razorpaySignature: response.signature ?? "",
      );

      if (verifyResponse.success) {
        Fluttertoast.showToast(msg: "Payment successful!");

        // Refresh user profile to update coins BEFORE calling success callback
        try {
          final authController = Get.find<AuthController>();
          await authController.checkIsLogin();
        } catch (_) {}

        // Now call success callback after profile is refreshed
        _onPaymentSuccess?.call();
      } else {
        Fluttertoast.showToast(
            msg: verifyResponse.message);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Payment verification failed");
    } finally {
      isPaymentLoading.value = false;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    isPaymentLoading.value = false;
    Fluttertoast.showToast(
        msg: "Payment failed: ${response.message ?? 'Unknown error'}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    isPaymentLoading.value = false;
    Fluttertoast.showToast(
        msg: "External wallet selected: ${response.walletName}");
  }
}
