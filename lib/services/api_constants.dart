class ApiConstants {
  // static const baseUrl = 'http://13.206.185.19/';
  // static const baseUrl = 'http://3.7.254.77/';

  // static const baseUrl = 'http://localhost:4000/';
  static const String baseUrl = 'https://admin.kathoram.coresports.co.in/';
  // TEMP: Cashfree sandbox testing backend. Switch back to the line above
  // before a production build.
  // static const String baseUrl = 'https://carmaker-mulled-hardly.ngrok-free.dev/';


  // App version / maintenance
  static const String currentVersion = 'api/v1/user/current/version';

  // Auth endpoints
  static const String login = 'api/v1/user/login';
  static const String signup = 'api/v1/user/signup';
  static const String guestLogin = 'api/v1/user/guest-login';
  static const String isLogin = 'api/v1/user/is-login';
  static const String logout = 'api/v1/user/logout';
  static const String deleteAccount = 'api/v1/user/delete';
  static const String googleAuth = 'api/v1/user/google/auth';
  static const String sendOtp = 'api/v1/user/send-otp';
  static const String verifyOtp = 'api/v1/user/verify-otp';
  static const String passwordUpdate = 'api/v1/user/password-update';
  static const String editProfile = 'api/v1/user/edit';

  // Plan endpoints
  static const String planList = 'api/v1/user/plan/list';

  // Staff endpoints
  static const String staffList = 'api/v1/user/staff/list';

  // Call endpoints
  static const String callHistory = 'api/v1/user/call-history';
  static const String initiateCall = 'api/v1/user/initiate-call';
  static const String endCall = 'api/v1/user/end-call';

  // Socket
  static const String socketUrl = 'https://admin.kathoram.coresports.co.in';
  // static const String socketUrl = 'http://3.7.254.77';


  // Payment endpoints (gateway-agnostic, apiVersion 2). No gateway keys live
  // in the app: everything checkout needs comes back from /payment/initiate.
  static const String paymentInitiate = 'api/v1/user/payment/initiate';
  static const String paymentVerify = 'api/v1/user/payment/verify';

  static String refreshToken = "";
}
