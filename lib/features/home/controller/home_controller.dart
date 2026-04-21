import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../services/api_constants.dart';
import '../../../utils/enum.dart';
import '../../authentication/controller/auth_controller.dart';
import '../../authentication/model/user_profile_model.dart';
import '../model/plan_model.dart';
import '../model/payment_model.dart';
import '../repository/home_repository.dart';

class HomeController extends GetxController {
  // ─── Plans ───
  var plans = <PlanModel>[].obs;
  var isPlansLoading = false.obs;
  var plansApiStatus = ApiCallStatus.holding.obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var hasMorePages = true.obs;

  // ─── Payment ───
  var isPaymentLoading = false.obs;
  late Razorpay _razorpay;
  String? _currentPlanId;
  VoidCallback? _onPaymentSuccess;

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

    // Ensure user profile data is loaded
    _refreshUserProfile();
    fetchPlans();
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
    super.onClose();
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
