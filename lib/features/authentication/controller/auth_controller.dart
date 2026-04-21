import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../../local_storage/shared_pref.dart';
import '../../../routes/route_path.dart';
import '../../../routes/custom_navigator.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/enum.dart';
import '../model/login_response_model.dart';
import '../model/signup_response_model.dart';
import '../model/user_profile_model.dart';
import '../repository/auth_repository.dart';

class AuthController extends GetxController {
  // ─── Login Fields ───
  final loginMobileController = TextEditingController();
  final loginPasswordController = TextEditingController();

  // ─── Signup Fields ───
  final signupNameController = TextEditingController();
  final signupMobileController = TextEditingController();
  final signupPasswordController = TextEditingController();
  final signupConfirmPasswordController = TextEditingController();

  var isTermsAgreed = false.obs;
  var isLoading = false.obs;
  var apiCallStatus = ApiCallStatus.holding.obs;

  // ─── User Profile Data ───
  var userProfile = Rxn<UserProfileData>();

  @override
  void onInit() {
    super.onInit();
    // Auto-fetch profile if user is already logged in
    if (MySharedPref.getLoggedInStatus()) {
      checkIsLogin();
    }
  }

  // ─── Login ───
  Future<void> login() async {
    if (loginMobileController.text.trim().isEmpty ||
        loginPasswordController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please fill all fields");
      return;
    }

    try {
      isLoading.value = true;
      apiCallStatus.value = ApiCallStatus.loading;

      final payload = {
        "mobileNumber": loginMobileController.text.trim(),
        "password": loginPasswordController.text.trim(),
      };

      final response = await AuthRepository.login(payload);

      if (response.success && response.data != null) {
        final loginData =
            LoginResponseData.fromJson(response.data as Map<String, dynamic>);

        // Save token and login status to local storage
        await MySharedPref.setAuthToken(loginData.accessToken);
        await MySharedPref.setLoggedInStatus(true);
        await MySharedPref.setMobileNumber(loginMobileController.text.trim());

        apiCallStatus.value = ApiCallStatus.success;
        Fluttertoast.showToast(msg: response.message);

        // Navigate to home
        CustomNavigator.pushCompleteReplacement(RoutePath.bottomNav);
      } else {
        apiCallStatus.value = ApiCallStatus.error;
        Fluttertoast.showToast(msg: response.message);
      }
    } catch (e) {
      apiCallStatus.value = ApiCallStatus.error;
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Signup ───
  Future<void> signup() async {
    if (signupNameController.text.trim().isEmpty ||
        signupMobileController.text.trim().isEmpty ||
        signupPasswordController.text.trim().isEmpty ||
        signupConfirmPasswordController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please fill all fields");
      return;
    }

    if (signupPasswordController.text.trim() !=
        signupConfirmPasswordController.text.trim()) {
      Fluttertoast.showToast(msg: "Passwords do not match");
      return;
    }

    if (!isTermsAgreed.value) {
      Fluttertoast.showToast(msg: "Please accept terms and conditions");
      return;
    }

    try {
      isLoading.value = true;
      apiCallStatus.value = ApiCallStatus.loading;

      final payload = {
        "name": signupNameController.text.trim(),
        "mobileNumber": signupMobileController.text.trim(),
        "password": signupPasswordController.text.trim(),
        "isTermsAgreed": isTermsAgreed.value,
      };

      final response = await AuthRepository.signup(payload);

      if (response.success && response.data != null) {
        final signupData =
            SignupResponseData.fromJson(response.data as Map<String, dynamic>);

        // Save token and login status to local storage
        await MySharedPref.setAuthToken(signupData.accessToken);
        await MySharedPref.setLoggedInStatus(true);
        await MySharedPref.setMobileNumber(signupData.mobileNumber);

        apiCallStatus.value = ApiCallStatus.success;
        Fluttertoast.showToast(msg: response.message);

        // Navigate to home
        CustomNavigator.pushCompleteReplacement(RoutePath.bottomNav);
      } else {
        apiCallStatus.value = ApiCallStatus.error;
        Fluttertoast.showToast(msg: response.message);
      }
    } catch (e) {
      apiCallStatus.value = ApiCallStatus.error;
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Is-Login (Validate Session) ───
  Future<bool> checkIsLogin() async {
    try {
      final response = await AuthRepository.isLogin();

      if (response.success && response.data != null) {
        userProfile.value =
            UserProfileData.fromJson(response.data as Map<String, dynamic>);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // ─── Logout ───
  Future<void> logout() async {
    try {
      isLoading.value = true;
      final response = await AuthRepository.logout();

      if (response.success) {
        Fluttertoast.showToast(msg: response.message);
      }
    } catch (e) {
      // Even if API fails, we clear local data
    } finally {
      isLoading.value = false;
      await _clearSessionAndNavigate();
    }
  }

  // ─── Delete Account ───
  Future<void> deleteAccount() async {
    try {
      isLoading.value = true;
      final response = await AuthRepository.deleteAccount();

      if (response.success) {
        Fluttertoast.showToast(msg: response.message);
      } else {
        Fluttertoast.showToast(msg: response.message);
        isLoading.value = false;
        return;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      isLoading.value = false;
      return;
    }
    isLoading.value = false;
    await _clearSessionAndNavigate();
  }

  // ─── Clear session and navigate to login ───
  Future<void> _clearSessionAndNavigate() async {
    await MySharedPref.clear();
    Get.offAllNamed(RoutePath.signIn);
  }

  // ─── Show Confirmation Dialog ───
  static void showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  title.toLowerCase().contains("delete")
                      ? Icons.delete_outline_rounded
                      : Icons.logout_rounded,
                  color: Colors.red,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),

              /// Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              /// Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),

              /// Buttons
              Row(
                children: [
                  /// Cancel
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),

                  /// Confirm
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(confirmText),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // ─── Clear login fields ───
  void clearLoginFields() {
    loginMobileController.clear();
    loginPasswordController.clear();
  }

  // ─── Clear signup fields ───
  void clearSignupFields() {
    signupNameController.clear();
    signupMobileController.clear();
    signupPasswordController.clear();
    signupConfirmPasswordController.clear();
    isTermsAgreed.value = false;
  }

  @override
  void onClose() {
    // Do NOT dispose TextEditingControllers here.
    // GetX recreates the controller via lazyPut(fenix: true),
    // but disposed controllers can still be accessed briefly during
    // route transitions (e.g. logout → sign-in), causing errors.
    // The controllers are lightweight and GC'd with the GetxController.
    super.onClose();
  }
}
