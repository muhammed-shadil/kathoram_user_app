class ApiConstants {
  static const baseUrl = 'http://192.168.1.12:4000/';

  // Auth endpoints
  static const String login = 'api/v1/user/login';
  static const String signup = 'api/v1/user/signup';
  static const String isLogin = 'api/v1/user/is-login';
  static const String logout = 'api/v1/user/logout';
  static const String deleteAccount = 'api/v1/user/delete';

  // Plan endpoints
  static const String planList = 'api/v1/user/plan/list';

  // Payment endpoints
  static const String paymentInitiate = 'api/v1/user/payment/initiate';
  static const String paymentVerify = 'api/v1/user/payment/verify';

  // Razorpay
  static const String razorpayKey = 'rzp_test_6hIAG1K15Br3uN'; // TODO: Replace with your actual Razorpay key

  static String refreshToken = "";
}
