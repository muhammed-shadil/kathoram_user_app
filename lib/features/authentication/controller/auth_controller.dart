import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../local_storage/shared_pref.dart';
import '../../../routes/route_path.dart';
import '../../../routes/custom_navigator.dart';
import '../../../services/socket_service.dart';
import '../../../services/zego_call_service.dart';
import '../../../theme/app_colors.dart';
import '../../home/controller/home_controller.dart';
import '../../../utils/enum.dart';
import '../model/guest_login_response_model.dart';
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
  final signupEmailController = TextEditingController();
  final signupMobileController = TextEditingController();
  final signupPasswordController = TextEditingController();
  final signupConfirmPasswordController = TextEditingController();

  // ─── Guest Login Fields ───
  final guestNameController = TextEditingController();
  final guestMobileController = TextEditingController();

  // ─── Forgot Password Fields ───
  final forgotEmailController = TextEditingController();
  final otpControllers = List.generate(4, (_) => TextEditingController());
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  // ─── Edit Profile Fields ───
  final editNameController = TextEditingController();
  final editEmailController = TextEditingController();
  final editMobileController = TextEditingController();
  final editPasswordController = TextEditingController();
  final editConfirmPasswordController = TextEditingController();

  /// Temporary token received after OTP verification (used for password update)
  var _forgotPasswordToken = '';

  var isTermsAgreed = false.obs;
  var isLoading = false.obs;
  var isGoogleLoading = false.obs;
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

  // ─── Guest Login ───
  /// Creates a lightweight guest account using only name + mobile number.
  /// Backend response includes an accessToken; from then on the app behaves
  /// the same as a fully signed-up user (HomeController.onInit calls
  /// checkIsLogin which loads the full profile).
  Future<void> guestLogin() async {
    final name = guestNameController.text.trim();
    final mobile = guestMobileController.text.trim();

    if (name.isEmpty || mobile.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter your name and mobile number");
      return;
    }

    if (mobile.length < 10) {
      Fluttertoast.showToast(msg: "Please enter a valid mobile number");
      return;
    }

    try {
      isLoading.value = true;
      apiCallStatus.value = ApiCallStatus.loading;

      final payload = {
        "name": name,
        "mobileNumber": mobile,
      };

      final response = await AuthRepository.guestLogin(payload);

      if (response.success && response.data != null) {
        final guestData = GuestLoginResponseData.fromJson(
            response.data as Map<String, dynamic>);

        // Persist session in the same way as login/signup so subsequent
        // authenticated calls (is-login, staff/list, etc.) work normally.
        await MySharedPref.setAuthToken(guestData.accessToken);
        await MySharedPref.setLoggedInStatus(true);
        await MySharedPref.setMobileNumber(guestData.mobileNumber);

        apiCallStatus.value = ApiCallStatus.success;
        Fluttertoast.showToast(msg: response.message);

        clearGuestFields();
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
    final email = signupEmailController.text.trim();
    final mobile = signupMobileController.text.trim();

    if (signupNameController.text.trim().isEmpty ||
        email.isEmpty ||
        mobile.isEmpty ||
        signupPasswordController.text.trim().isEmpty ||
        signupConfirmPasswordController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please fill all fields");
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Fluttertoast.showToast(msg: "Please enter a valid email");
      return;
    }

    if (mobile.length < 10) {
      Fluttertoast.showToast(msg: "Please enter a valid mobile number");
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
        "email": email,
        "mobileNumber": mobile,
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

      // Admin blocked this account (HTTP/responseCode 423). Show a blocking
      // dialog and log the user out — checkIsLogin runs on every tab switch,
      // so the block takes effect within the session without an app restart.
      if (response.responseCode == 423) {
        _handleBlockedUser(response.message);
        return false;
      }

      if (response.success && response.data != null) {
        userProfile.value =
            UserProfileData.fromJson(response.data as Map<String, dynamic>);

        // Validation succeeded → user is not blocked; reset the guard so a
        // future block (even later in the same app run) can show the dialog.
        _blockedDialogShown = false;

        // Initialize Zego call invitation service after profile is available
        _initZegoAfterLogin();

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Guard so the block dialog is only shown once even though checkIsLogin is
  /// called repeatedly (every tab switch, pull-to-refresh, etc.).
  bool _blockedDialogShown = false;

  /// Shows a non-dismissible "account blocked" dialog. The single OK button
  /// clears the session and routes to the sign-in screen, exactly like logout.
  void _handleBlockedUser(String message) {
    if (_blockedDialogShown) return;
    _blockedDialogShown = true;

    Get.dialog(
      AlertDialog(
        title: const Text('Account Blocked'),
        content: Text(
          message.trim().isNotEmpty
              ? message
              : 'Your account has been blocked. Please contact support.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (Get.isDialogOpen ?? false) Get.back();
              await _clearSessionAndNavigate();
              _blockedDialogShown = false;
            },
            child: const Text('OK'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Initialize Zego signaling with the user's backend ID.
  /// Called after userProfile is successfully loaded.
  void _initZegoAfterLogin() {
    final profile = userProfile.value;
    if (profile == null) return;
    log('[AuthController] Initializing Zego for user: ${profile.id} (${profile.name})');
    ZegoCallService.instance.onUserLogin(
      userID: profile.id,
      userName: profile.name,
    );
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

  // ─── Google Sign-In ───
  Future<void> googleSignIn() async {
    try {
      isGoogleLoading.value = true;

      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();

      // Sign out first to always show the account picker
      await googleSignIn.signOut();
      final GoogleSignInAccount account = await googleSignIn.authenticate();

      final String? googleIdToken = account.authentication.idToken;

      if (googleIdToken == null) {
        Fluttertoast.showToast(msg: "Failed to get Google token");
        isGoogleLoading.value = false;
        return;
      }

      // Sign in to Firebase with the Google credential
      final credential = GoogleAuthProvider.credential(idToken: googleIdToken);
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Get the Firebase ID token (this is what the backend expects)
      final firebaseIdToken = await userCredential.user?.getIdToken();

      if (firebaseIdToken == null) {
        Fluttertoast.showToast(msg: "Failed to get Firebase token");
        isGoogleLoading.value = false;
        return;
      }

      // Send Firebase ID token to backend
      final payload = {"token": firebaseIdToken};
      final response = await AuthRepository.googleAuth(payload);

      if (response.success && response.data != null) {
        final loginData =
            LoginResponseData.fromJson(response.data as Map<String, dynamic>);

        await MySharedPref.setAuthToken(loginData.accessToken);
        await MySharedPref.setLoggedInStatus(true);

        Fluttertoast.showToast(msg: response.message);
        CustomNavigator.pushCompleteReplacement(RoutePath.bottomNav);
      } else {
        Fluttertoast.showToast(msg: response.message);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Google sign-in failed: ${e.toString()}");
    } finally {
      isGoogleLoading.value = false;
    }
  }

  // ─── Send OTP (Forgot Password) ───
  Future<void> sendOtp() async {
    final email = forgotEmailController.text.trim();
    if (email.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter your email");
      return;
    }
    if (!GetUtils.isEmail(email)) {
      Fluttertoast.showToast(msg: "Please enter a valid email");
      return;
    }

    try {
      isLoading.value = true;

      final payload = {
        "email": email,
      };

      final response = await AuthRepository.sendOtp(payload);

      if (response.success) {
        Fluttertoast.showToast(msg: response.message);
        Get.toNamed(RoutePath.otp);
      } else {
        Fluttertoast.showToast(msg: response.message);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Verify OTP ───
  Future<void> verifyOtp() async {
    final otp = otpControllers.map((c) => c.text.trim()).join();
    if (otp.length != 4) {
      Fluttertoast.showToast(msg: "Please enter the complete OTP");
      return;
    }

    try {
      isLoading.value = true;

      final payload = {
        "email": forgotEmailController.text.trim(),
        "otp": otp,
      };

      final response = await AuthRepository.verifyOtp(payload);

      if (response.success && response.responseCode == 200 && response.data != null) {
        // Store the temporary access token for password update
        _forgotPasswordToken = response.data['accessToken'] ?? '';
        Fluttertoast.showToast(msg: response.message);
        Get.toNamed(RoutePath.changePassword);
      } else {
        Fluttertoast.showToast(msg: response.message);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Update Password ───
  Future<void> updatePassword() async {
    if (newPasswordController.text.trim().isEmpty ||
        confirmNewPasswordController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please fill all fields");
      return;
    }

    if (newPasswordController.text.trim() !=
        confirmNewPasswordController.text.trim()) {
      Fluttertoast.showToast(msg: "Passwords do not match");
      return;
    }

    try {
      isLoading.value = true;

      final payload = {
        "newPassword": newPasswordController.text.trim(),
      };

      final response =
          await AuthRepository.passwordUpdate(payload, _forgotPasswordToken);

      if (response.success) {
        Fluttertoast.showToast(msg: response.message);
        // Clear forgot password fields
        clearForgotPasswordFields();
        // Navigate back to sign in
        Get.offAllNamed(RoutePath.signIn);
      } else {
        Fluttertoast.showToast(msg: response.message);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Prefill Edit-Profile fields from current profile ───
  void prefillEditProfileFields() {
    final profile = userProfile.value;
    if (profile == null) return;
    editNameController.text = profile.name;
    editEmailController.text = profile.email;
    editMobileController.text = profile.mobileNumber;
    editPasswordController.clear();
    editConfirmPasswordController.clear();
  }

  // ─── Edit Profile (PATCH api/v1/user/edit) ───
  Future<void> editProfile() async {
    final name = editNameController.text.trim();
    final email = editEmailController.text.trim();
    final mobile = editMobileController.text.trim();
    final pass = editPasswordController.text.trim();
    final confirmPass = editConfirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || mobile.isEmpty) {
      Fluttertoast.showToast(msg: "Name, email and mobile are required");
      return;
    }
    if (!GetUtils.isEmail(email)) {
      Fluttertoast.showToast(msg: "Please enter a valid email");
      return;
    }
    if (pass.isNotEmpty && pass != confirmPass) {
      Fluttertoast.showToast(msg: "Passwords do not match");
      return;
    }

    // Build payload with only the editable fields. Password is included
    // only when the user actually typed one (leave blank to skip change).
    final payload = <String, dynamic>{
      "name": name,
      "email": email,
      "mobileNumber": mobile,
    };
    if (pass.isNotEmpty) {
      payload["password"] = pass;
    }

    try {
      isLoading.value = true;
      final response = await AuthRepository.editProfile(payload);

      if (response.success) {
        Fluttertoast.showToast(msg: response.message);
        // Refresh profile so UI shows updated values
        await checkIsLogin();
        Get.back();
      } else {
        Fluttertoast.showToast(msg: response.message);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Resend OTP ───
  Future<void> resendOtp() async {
    // Clear OTP fields
    for (var c in otpControllers) {
      c.clear();
    }
    try {
      isLoading.value = true;

      final payload = {
        "email": forgotEmailController.text.trim(),
      };

      final response = await AuthRepository.sendOtp(payload);
      Fluttertoast.showToast(msg: response.message);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Clear session and navigate to login ───
  Future<void> _clearSessionAndNavigate() async {
    // Disconnect from Zego signaling before clearing session
    await ZegoCallService.instance.onUserLogout();
    await MySharedPref.clear();
    Get.offAllNamed(RoutePath.signIn);

    // Tear down the session-scoped singletons AFTER navigating away (so no
    // mounted Obx reads a deleted controller). HomeController is permanent now,
    // so it won't auto-dispose — without this, a re-login would reuse the old
    // user's controller and never re-run its onInit fetches. force:true is
    // required to delete permanent instances. HomeController.onClose also
    // disconnects the socket; we delete SocketService too so it's fully reset.
    Get.delete<HomeController>(force: true);
    Get.delete<SocketService>(force: true);
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
    signupEmailController.clear();
    signupMobileController.clear();
    signupPasswordController.clear();
    signupConfirmPasswordController.clear();
    isTermsAgreed.value = false;
  }

  // ─── Clear guest login fields ───
  void clearGuestFields() {
    guestNameController.clear();
    guestMobileController.clear();
  }

  // ─── Clear forgot password fields ───
  void clearForgotPasswordFields() {
    forgotEmailController.clear();
    for (var c in otpControllers) {
      c.clear();
    }
    newPasswordController.clear();
    confirmNewPasswordController.clear();
    _forgotPasswordToken = '';
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
