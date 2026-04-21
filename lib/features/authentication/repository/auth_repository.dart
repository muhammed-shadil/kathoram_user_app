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
}
