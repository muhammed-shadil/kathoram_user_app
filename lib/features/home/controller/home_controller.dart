import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../local_storage/shared_pref.dart';
import '../../../services/socket_service.dart';
import '../../../utils/enum.dart';
import '../../authentication/controller/auth_controller.dart';
import '../../authentication/model/user_profile_model.dart';
import '../../widgets/phone_number_dialog.dart';
import '../model/plan_model.dart';
import '../model/payment_model.dart';
import '../model/staff_model.dart';
import '../model/call_history_model.dart';
import '../repository/home_repository.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
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

  /// Shown under the spinner on the payment screen (e.g. "Payment processing").
  var paymentProgressText = RxnString();
  late Razorpay _razorpay;
  final CFPaymentGatewayService _cashfree = CFPaymentGatewayService();
  VoidCallback? _onPaymentSuccess;

  /// Order whose checkout (Cashfree or Razorpay) is currently open. Set just
  /// before the SDK opens and cleared once its callback has been handled.
  String? _checkoutOrderId;

  /// Order currently being confirmed with /payment/verify. Stops a second
  /// SDK callback or a lifecycle reconcile from running a parallel verify.
  String? _confirmingOrderId;

  bool _isReconciling = false;

  static const Duration _verifyPollInterval = Duration(seconds: 3);
  static const Duration _verifyPollTimeout = Duration(seconds: 30);
  static const String _gatewayUnavailableMessage =
      "Payments are unavailable. Please update the app.";
  static const String _generalPaymentErrorMessage =
      "Something went wrong with your payment. Please try again.";

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

    // Cashfree callbacks must be registered before doPayment(). The service is
    // a singleton with static callbacks, so registering here covers every
    // checkout this controller opens.
    _cashfree.setCallback(_onCashfreeVerify, _onCashfreeError);

    // Observe app lifecycle so we can reconcile a payment whose verify callback
    // never ran because the app was killed while on a UPI app (GPay/PhonePe).
    WidgetsBinding.instance.addObserver(this);
    // Also reconcile on a fresh launch (app process was killed and relaunched).
    reconcilePendingPayment();

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
    WidgetsBinding.instance.removeObserver(this);
    _razorpay.clear();
    disconnectSocket();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When the user returns from a UPI app (or any backgrounded state), make
    // sure a completed-but-unverified payment gets credited.
    if (state == AppLifecycleState.resumed) {
      reconcilePendingPayment();
    }
  }

  /// Reconcile a pending payment against the backend's authoritative status.
  ///
  /// The SDK callback only runs if the app survives the trip to the UPI app.
  /// On low-RAM devices Android often kills the app, so the order id is saved
  /// before checkout opens and re-verified here — on launch, on resume and
  /// when the user opens the Add Coins (wallet) tab. /payment/verify asks the
  /// gateway for the real status and credits the coins server-side, so this
  /// only has to refresh the local balance.
  Future<void> reconcilePendingPayment() async {
    // A live checkout reports through its own SDK callback. Verifying here as
    // well would race it (e.g. resume fires when the checkout screen closes).
    if (_checkoutOrderId != null || _confirmingOrderId != null) return;
    // Launch, resume and the wallet tab can fire close together.
    if (_isReconciling) return;

    final pendingOrderId = MySharedPref.getPendingPaymentOrderId();
    if (pendingOrderId == null || pendingOrderId.isEmpty) return;

    _isReconciling = true;
    try {
      final status = await _verifyOnce(pendingOrderId);
      switch (status) {
        case PaymentVerifyStatus.credited:
          await _clearPendingOrderIfStill(pendingOrderId);
          await _refreshUserProfile();
          Fluttertoast.showToast(msg: "Coins added to your wallet");
          break;
        case PaymentVerifyStatus.failed:
          // Terminal — stop re-checking it.
          await _clearPendingOrderIfStill(pendingOrderId);
          break;
        case PaymentVerifyStatus.pending:
        case PaymentVerifyStatus.unknown:
        case null: // network error
          // Keep it and check again next time.
          break;
      }
    } finally {
      _isReconciling = false;
    }
  }

  /// Clears the saved order id only if it is still [orderId] — a new purchase
  /// may have replaced it while a verify was in flight.
  Future<void> _clearPendingOrderIfStill(String orderId) async {
    if (MySharedPref.getPendingPaymentOrderId() == orderId) {
      await MySharedPref.clearPendingPaymentOrderId();
    }
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
        // Note: intentionally NOT clearing here — see fetchCallHistory. Emptying
        // the list mid-refresh flips the screen to its shimmer branch, which
        // unmounts the RefreshIndicator and makes pull-to-refresh look broken.
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
          staffList.assignAll(staffResponse.result);
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

  /// Monotonic token for call-history refreshes. fetchCallHistory() is fired
  /// from several places that can overlap (call-end, tab switch, socket
  /// reconnect, pull-to-refresh). Without sequencing, a slower/staler refresh
  /// — e.g. the one fired the instant a call ends, before the backend has
  /// persisted the new record — could land LAST and overwrite a fresher
  /// response, so the just-finished call never shows up. Only the response
  /// whose token still matches the latest refresh is allowed to win.
  int _callHistoryRefreshSeq = 0;

  // ─── Fetch Call History (with pagination) ───
  Future<void> fetchCallHistory({bool loadMore = false}) async {
    if (loadMore && !callHistoryHasMorePages.value) return;

    // Refreshes (not load-more) get a fresh token; load-more rides the current.
    final int seq =
        loadMore ? _callHistoryRefreshSeq : ++_callHistoryRefreshSeq;

    try {
      if (loadMore) {
        callHistoryCurrentPage.value++;
      } else {
        callHistoryCurrentPage.value = 1;
        // Note: intentionally NOT clearing here — keep showing the existing
        // list until the new data arrives, then swap it in. Clearing first
        // blanked the list to a shimmer on every refresh and made the race
        // above visible as a flash of stale/empty content.
      }

      isCallHistoryLoading.value = true;
      callHistoryApiStatus.value = ApiCallStatus.loading;

      final response = await HomeRepository.callHistory(
        page: callHistoryCurrentPage.value,
        pageSize: 10,
      );

      // A newer refresh started while we were awaiting — discard this stale one.
      if (!loadMore && seq != _callHistoryRefreshSeq) return;

      if (response.success && response.data != null) {
        final historyResponse = CallHistoryListResponse.fromJson(
            response.data as Map<String, dynamic>);

        if (loadMore) {
          callHistoryList.addAll(historyResponse.result);
        } else {
          // assignAll is the canonical GetX way to replace list contents and
          // guarantees a single reactive notification to the Obx.
          callHistoryList.assignAll(historyResponse.result);
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
      // Don't let a superseded refresh switch the spinner off — let the
      // newest one own the loading flag until it completes.
      if (loadMore || seq == _callHistoryRefreshSeq) {
        isCallHistoryLoading.value = false;
      }
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
        // Note: intentionally NOT clearing here — see fetchCallHistory. Emptying
        // the list mid-refresh flips the screen to its shimmer branch, which
        // unmounts the RefreshIndicator and makes pull-to-refresh look broken.
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
          plans.assignAll(planListResponse.result);
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

  // ═══════════════════════════════════════════════════════════════════════════
  // PAYMENT FLOW — initiate → gateway checkout → verify
  //
  // The backend chooses the gateway and is the only source of truth: an SDK
  // "success" callback is never treated as proof of payment. Coins are added
  // by the backend inside /payment/verify; the app only refreshes the balance.
  // ═══════════════════════════════════════════════════════════════════════════

  /// Step 1: create an order (asking for a phone number first if the backend
  /// needs one), then open the checkout of whichever gateway it returned.
  Future<void> initiatePayment(
    String planId, {
    VoidCallback? onSuccess,
  }) async {
    if (isPaymentLoading.value) return;
    isPaymentLoading.value = true;
    paymentProgressText.value = null;
    _onPaymentSuccess = onSuccess;

    try {
      String? phone;
      var response = await HomeRepository.initiatePayment(planId);

      // 130 = phone number needed (Cashfree requires one; Google sign-in
      // users have none) or the number just sent was rejected. The backend
      // saves a valid number, so the user is only asked once.
      while (response.responseCode == 130) {
        final entered = await Get.dialog<String>(
          PhoneNumberDialog(
            errorText: phone == null ? null : response.message,
            initialValue: phone ?? '',
          ),
          barrierDismissible: false,
        );
        if (entered == null) {
          _endPayment();
          return;
        }
        phone = entered;
        response = await HomeRepository.initiatePayment(planId, phone: phone);
      }

      final data = response.data;
      if (response.responseCode != 200 || data is! Map<String, dynamic>) {
        // e.g. "Invalid Plan" (data is null).
        _endPayment();
        Fluttertoast.showToast(
          msg: response.message.isNotEmpty
              ? response.message
              : _generalPaymentErrorMessage,
        );
        return;
      }

      final order = PaymentInitiateResponse.fromJson(data);
      if (order.orderId.isEmpty) {
        _endPayment();
        Fluttertoast.showToast(msg: _generalPaymentErrorMessage);
        return;
      }

      // Step 2: one case per gateway the app supports.
      switch (order.gateway) {
        case 'cashfree':
          await _openCashfreeCheckout(order);
          break;
        case 'razorpay':
          await _openRazorpayCheckout(order);
          break;
        default:
          // Also what an old backend looks like: it ignores apiVersion and
          // returns a raw Razorpay order with no "gateway" field.
          log('[Payment] Unsupported gateway "${order.gateway}": $data');
          _endPayment();
          Fluttertoast.showToast(msg: _gatewayUnavailableMessage);
      }
    } catch (e) {
      _endPayment();
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  // ─── Cashfree ───
  Future<void> _openCashfreeCheckout(PaymentInitiateResponse order) async {
    final checkout = CashfreeCheckoutData.fromJson(order.checkoutData);

    // The environment always comes from the backend, never from app code.
    final CFEnvironment? environment = switch (checkout.environment) {
      'PRODUCTION' => CFEnvironment.PRODUCTION,
      'SANDBOX' => CFEnvironment.SANDBOX,
      _ => null,
    };
    if (environment == null || checkout.paymentSessionId.isEmpty) {
      log('[Payment] Bad Cashfree checkoutData: ${order.checkoutData}');
      _endPayment();
      Fluttertoast.showToast(msg: _generalPaymentErrorMessage);
      return;
    }

    try {
      final session = CFSessionBuilder()
          .setEnvironment(environment)
          .setOrderId(
              checkout.orderId.isNotEmpty ? checkout.orderId : order.orderId)
          .setPaymentSessionId(checkout.paymentSessionId)
          .build();
      final webCheckout = CFWebCheckoutPaymentBuilder()
          .setSession(session)
          .setTheme(CFThemeBuilder()
              .setNavigationBarBackgroundColorColor('#0D6EFD')
              .setNavigationBarTextColor('#FFFFFF')
              .setButtonBackgroundColor('#0D6EFD')
              .setButtonTextColor('#FFFFFF')
              .build())
          .build();

      await _beginCheckout(order.orderId);
      _cashfree.doPayment(webCheckout);
    } on CFException catch (e) {
      await _abortCheckout(order.orderId);
      Fluttertoast.showToast(msg: e.message);
    }
  }

  void _onCashfreeVerify(String orderId) {
    _onCheckoutClosed(callbackOrderId: orderId);
  }

  void _onCashfreeError(CFErrorResponse error, String orderId) {
    log('[Payment] Cashfree error: ${error.getCode()} ${error.getMessage()}');
    final code = error.getCode();
    final message = error.getMessage() ?? 'Payment failed';
    _onCheckoutClosed(
      callbackOrderId: orderId,
      // Include the code: production-only blocks (Play Store install check,
      // app whitelisting) are identified by it.
      sdkError: (code == null || code.isEmpty) ? message : '$message ($code)',
    );
  }

  // ─── Razorpay (only if the backend switches back to it) ───
  Future<void> _openRazorpayCheckout(PaymentInitiateResponse order) async {
    final checkout = RazorpayCheckoutData.fromJson(order.checkoutData);
    if (checkout.key.isEmpty || checkout.razorpayOrderId.isEmpty) {
      log('[Payment] Bad Razorpay checkoutData: ${order.checkoutData}');
      _endPayment();
      Fluttertoast.showToast(msg: _generalPaymentErrorMessage);
      return;
    }

    final options = {
      'key': checkout.key,
      'amount': checkout.amount, // paise
      'currency': checkout.currency,
      'name': 'Kathoram',
      'description': 'Coin Purchase',
      'order_id': checkout.razorpayOrderId,
      'prefill': {
        'contact': userMobile,
        'email': '',
      },
      'theme': {
        'color': '#0D6EFD',
      },
    };

    await _beginCheckout(order.orderId);
    try {
      _razorpay.open(options);
    } catch (e) {
      await _abortCheckout(order.orderId);
      Fluttertoast.showToast(msg: "Error opening payment gateway");
    }
  }

  // The Razorpay ids and signature in these responses are deliberately not
  // used: the backend checks the order with Razorpay itself in /payment/verify.
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _onCheckoutClosed();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _onCheckoutClosed(sdkError: response.message ?? 'Payment failed');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // The payment continues outside Razorpay. The saved order id stays, so it
    // is re-verified on the next resume / wallet visit.
    _endPayment();
    Fluttertoast.showToast(
        msg: "External wallet selected: ${response.walletName}");
  }

  // ─── Shared checkout plumbing ───

  /// Saves the order id BEFORE the checkout opens, so a payment completed
  /// while the app was killed (e.g. on a UPI app) can be verified on relaunch.
  Future<void> _beginCheckout(String orderId) async {
    await MySharedPref.setPendingPaymentOrderId(orderId);
    _checkoutOrderId = orderId;
  }

  /// The checkout never opened, so nothing can have been paid on this order.
  Future<void> _abortCheckout(String orderId) async {
    await _clearPendingOrderIfStill(orderId);
    _endPayment();
  }

  void _endPayment() {
    _checkoutOrderId = null;
    paymentProgressText.value = null;
    isPaymentLoading.value = false;
  }

  /// Called from every SDK callback (success AND error): a payment can succeed
  /// even when the SDK reports an error or the user backs out, so the backend
  /// is always asked.
  void _onCheckoutClosed({String? callbackOrderId, String? sdkError}) {
    // Prefer the order we opened: the SDK's error path can report the
    // placeholder "order_id_not_found" instead of a real id.
    final fromCallback = (callbackOrderId == null ||
            callbackOrderId.isEmpty ||
            callbackOrderId == 'order_id_not_found')
        ? null
        : callbackOrderId;
    final orderId = _checkoutOrderId ??
        fromCallback ??
        MySharedPref.getPendingPaymentOrderId();
    _checkoutOrderId = null;

    if (orderId == null || orderId.isEmpty) {
      log('[Payment] Checkout closed with no known order id');
      _endPayment();
      return;
    }
    _confirmPayment(orderId, sdkError: sdkError);
  }

  /// Step 3: POST /payment/verify, polling while the backend says "pending".
  ///
  /// [sdkError] is the gateway SDK's own message when checkout closed through
  /// its error callback. It is shown to the user whenever the backend can't
  /// confirm a payment, so the real cause (e.g. Cashfree production's
  /// "installer_package_not_approved") isn't hidden behind a generic message.
  Future<void> _confirmPayment(
    String orderId, {
    String? sdkError,
  }) async {
    if (_confirmingOrderId == orderId) return;
    _confirmingOrderId = orderId;
    isPaymentLoading.value = true;

    try {
      var status = await _verifyOnce(orderId);

      if (status == PaymentVerifyStatus.pending) {
        paymentProgressText.value = "Payment processing";
        Fluttertoast.showToast(msg: "Payment processing");
        final deadline = DateTime.now().add(_verifyPollTimeout);
        while (status == PaymentVerifyStatus.pending &&
            DateTime.now().isBefore(deadline)) {
          await Future.delayed(_verifyPollInterval);
          // A transient network error mid-poll just means "ask again".
          status = await _verifyOnce(orderId) ?? PaymentVerifyStatus.pending;
        }
      }

      switch (status) {
        case PaymentVerifyStatus.credited:
          await _clearPendingOrderIfStill(orderId);
          Fluttertoast.showToast(msg: "Payment successful!");
          // Refresh the coin balance BEFORE the success callback, as before.
          await _refreshUserProfile();
          _onPaymentSuccess?.call();
          break;
        case PaymentVerifyStatus.pending:
          // Keep the saved order id: it is re-verified on the next launch,
          // resume or wallet visit.
          Fluttertoast.showToast(
            msg: sdkError != null
                ? "Payment not completed: $sdkError\nIf you did pay, your coins will be added automatically in a few minutes."
                : "Your payment is still processing. Your coins will be added automatically in a few minutes.",
            toastLength: Toast.LENGTH_LONG,
          );
          break;
        case PaymentVerifyStatus.failed:
          await _clearPendingOrderIfStill(orderId);
          Fluttertoast.showToast(
            msg: "Payment failed. No coins were added. Please try again.",
            toastLength: Toast.LENGTH_LONG,
          );
          break;
        case PaymentVerifyStatus.unknown:
          Fluttertoast.showToast(
            msg: sdkError != null
                ? "Payment not completed: $sdkError"
                : _generalPaymentErrorMessage,
            toastLength: Toast.LENGTH_LONG,
          );
          break;
        case null:
          Fluttertoast.showToast(
            msg: "Couldn't confirm your payment right now. We'll check again automatically.",
            toastLength: Toast.LENGTH_LONG,
          );
          break;
      }
    } finally {
      _confirmingOrderId = null;
      _onPaymentSuccess = null;
      _endPayment();
    }
  }

  /// One POST /payment/verify. Returns null on a network/transport error.
  Future<PaymentVerifyStatus?> _verifyOnce(String orderId) async {
    try {
      final response = await HomeRepository.verifyPayment(orderId: orderId);
      final status = parsePaymentVerifyStatus(response.data);
      log('[Payment] verify $orderId → $status (${response.message})');
      return status;
    } catch (e) {
      log('[Payment] verify $orderId failed: $e');
      return null;
    }
  }
}
