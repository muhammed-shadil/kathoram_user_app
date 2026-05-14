import '../../../services/api_base_model.dart';
import '../../../services/api_constants.dart';
import '../../../services/network_adapter.dart';

class AuthRepository {
  /// Login API call
  static Future<ApiBaseModel> login(Map<String, dynamic> payload) async {
    late ApiBaseModel response;
    await BaseClient.shared.safeApiCall(
      ApiConstants.login,
      RequestType.post,
      data: payload,
      includeAuth: false,
      onSuccess: (s) {
        response = s;
      },
      onError: (s) {
        s.fold(
          (l) {
            throw l.message;
          },
          (l) {
            throw l;
          },
        );
      },
    );
    return response;
  }

  /// Guest Login API call - POST api/v1/user/guest-login
  /// Payload: { "name": "...", "mobileNumber": "..." }
  static Future<ApiBaseModel> guestLogin(Map<String, dynamic> payload) async {
    late ApiBaseModel response;
    await BaseClient.shared.safeApiCall(
      ApiConstants.guestLogin,
      RequestType.post,
      data: payload,
      includeAuth: false,
      onSuccess: (s) {
        response = s;
      },
      onError: (s) {
        s.fold(
          (l) {
            throw l.message;
          },
          (l) {
            throw l;
          },
        );
      },
    );
    return response;
  }

  /// Signup API call
  static Future<ApiBaseModel> signup(Map<String, dynamic> payload) async {
    late ApiBaseModel response;
    await BaseClient.shared.safeApiCall(
      ApiConstants.signup,
      RequestType.post,
      data: payload,
      includeAuth: false,
      onSuccess: (s) {
        response = s;
      },
      onError: (s) {
        s.fold(
          (l) {
            throw l.message;
          },
          (l) {
            throw l;
          },
        );
      },
    );
    return response;
  }

  /// Is-Login (validate session) API call - GET
  static Future<ApiBaseModel> isLogin() async {
    late ApiBaseModel response;
    await BaseClient.shared.safeApiCall(
      ApiConstants.isLogin,
      RequestType.get,
      onSuccess: (s) {
        response = s;
      },
      onError: (s) {
        s.fold(
          (l) {
            throw l.message;
          },
          (l) {
            throw l;
          },
        );
      },
    );
    return response;
  }

  /// Logout API call - GET
  static Future<ApiBaseModel> logout() async {
    late ApiBaseModel response;
    await BaseClient.shared.safeApiCall(
      ApiConstants.logout,
      RequestType.get,
      onSuccess: (s) {
        response = s;
      },
      onError: (s) {
        s.fold(
          (l) {
            throw l.message;
          },
          (l) {
            throw l;
          },
        );
      },
    );
    return response;
  }

  /// Delete Account API call - GET
  static Future<ApiBaseModel> deleteAccount() async {
    late ApiBaseModel response;
    await BaseClient.shared.safeApiCall(
      ApiConstants.deleteAccount,
      RequestType.get,
      onSuccess: (s) {
        response = s;
      },
      onError: (s) {
        s.fold(
          (l) {
            throw l.message;
          },
          (l) {
            throw l;
          },
        );
      },
    );
    return response;
  }

  /// Google Auth API call
  static Future<ApiBaseModel> googleAuth(Map<String, dynamic> payload) async {
    late ApiBaseModel response;
    await BaseClient.shared.safeApiCall(
      ApiConstants.googleAuth,
      RequestType.post,
      data: payload,
      includeAuth: false,
      onSuccess: (s) {
        response = s;
      },
      onError: (s) {
        s.fold(
          (l) {
            throw l.message;
          },
          (l) {
            throw l;
          },
        );
      },
    );
    return response;
  }

  /// Send OTP API call
  static Future<ApiBaseModel> sendOtp(Map<String, dynamic> payload) async {
    late ApiBaseModel response;
    await BaseClient.shared.safeApiCall(
      ApiConstants.sendOtp,
      RequestType.post,
      data: payload,
      includeAuth: false,
      onSuccess: (s) {
        response = s;
      },
      onError: (s) {
        s.fold(
          (l) {
            throw l.message;
          },
          (l) {
            throw l;
          },
        );
      },
    );
    return response;
  }

  /// Verify OTP API call
  static Future<ApiBaseModel> verifyOtp(Map<String, dynamic> payload) async {
    late ApiBaseModel response;
    await BaseClient.shared.safeApiCall(
      ApiConstants.verifyOtp,
      RequestType.post,
      data: payload,
      includeAuth: false,
      onSuccess: (s) {
        response = s;
      },
      onError: (s) {
        s.fold(
          (l) {
            throw l.message;
          },
          (l) {
            throw l;
          },
        );
      },
    );
    return response;
  }

  /// Edit Profile API call - PATCH api/v1/user/edit
  static Future<ApiBaseModel> editProfile(Map<String, dynamic> payload) async {
    late ApiBaseModel response;
    await BaseClient.shared.safeApiCall(
      ApiConstants.editProfile,
      RequestType.patch,
      data: payload,
      onSuccess: (s) {
        response = s;
      },
      onError: (s) {
        s.fold(
          (l) {
            throw l.message;
          },
          (l) {
            throw l;
          },
        );
      },
    );
    return response;
  }

  /// Password Update API call
  static Future<ApiBaseModel> passwordUpdate(
      Map<String, dynamic> payload, String accessToken) async {
    late ApiBaseModel response;
    await BaseClient.shared.safeApiCall(
      ApiConstants.passwordUpdate,
      RequestType.post,
      data: payload,
      accessToken: accessToken,
      onSuccess: (s) {
        response = s;
      },
      onError: (s) {
        s.fold(
          (l) {
            throw l.message;
          },
          (l) {
            throw l;
          },
        );
      },
    );
    return response;
  }
}
