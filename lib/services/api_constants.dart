class ApiConstants {
  static const baseUrl = 'http://localhost:4000/';

  // Auth endpoints
  static const String login = 'api/v1/user/login';
  static const String signup = 'api/v1/user/signup';
  static const String isLogin = 'api/v1/user/is-login';
  static const String logout = 'api/v1/user/logout';
  static const String deleteAccount = 'api/v1/user/delete';
  static const String googleAuth = 'api/v1/user/google/auth';
  static const String sendOtp = 'api/v1/user/send-otp';
  static const String verifyOtp = 'api/v1/user/verify-otp';
  static const String passwordUpdate = 'api/v1/user/password-update';

  // Plan endpoints
  static const String planList = 'api/v1/user/plan/list';

  // Staff endpoints
  static const String staffList = 'api/v1/user/staff/list';

  // Call endpoints
  static const String callHistory = 'api/v1/user/call-history';
  static const String initiateCall = 'api/v1/user/initiate-call';
  static const String endCall = 'api/v1/user/end-call';

  // Socket
  static const String socketUrl = 'http://localhost:4000';

  // Payment endpoints
  static const String paymentInitiate = 'api/v1/user/payment/initiate';
  static const String paymentVerify = 'api/v1/user/payment/verify';

  // Razorpay
  static const String razorpayKey = 'rzp_test_6hIAG1K15Br3uN'; // TODO: Replace with your actual Razorpay key

  static String refreshToken = "";
}
