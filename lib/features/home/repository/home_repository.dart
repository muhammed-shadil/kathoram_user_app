import '../../../services/api_base_model.dart';
import '../../../services/api_constants.dart';
import '../../../services/network_adapter.dart';

class HomeRepository {
  /// List Plans API call - POST
  static Future<ApiBaseModel> listPlans({
    String keyword = "",
    int page = 1,
    int pageSize = 10,
  }) async {
    late ApiBaseModel response;
    await BaseClient.shared.safeApiCall(
      ApiConstants.planList,
      RequestType.post,
      data: {
        "keyword": keyword,
        "page": page,
        "pageSize": pageSize,
      },
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

  /// List Staff API call - POST
  static Future<ApiBaseModel> listStaff({
    String keyword = "",
    int page = 1,
    int pageSize = 10,
  }) async {
    late ApiBaseModel response;
    await BaseClient.shared.safeApiCall(
      ApiConstants.staffList,
      RequestType.post,
      data: {
        "keyword": keyword,
        "page": page,
        "pageSize": pageSize,
      },
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

  /// Call History API call - POST
  static Future<ApiBaseModel> callHistory({
    String staffId = "",
    int page = 1,
    int pageSize = 10,
    String keyword = "",
    String startDate = "",
    String endDate = "",
    String status = "",
  }) async {
    late ApiBaseModel response;
    await BaseClient.shared.safeApiCall(
      ApiConstants.callHistory,
      RequestType.post,
      data: {
        "staffId": staffId,
        "page": page,
        "pageSize": pageSize,
        "keyword": keyword,
        "startDate": startDate,
        "endDate": endDate,
        "status": status,
      },
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

  /// Initiate Payment API call - POST
  static Future<ApiBaseModel> initiatePayment(String planId) async {
    late ApiBaseModel response;
    await BaseClient.shared.safeApiCall(
      ApiConstants.paymentInitiate,
      RequestType.post,
      data: {
        "planId": planId,
      },
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

  /// Verify Payment API call - POST
  static Future<ApiBaseModel> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    late ApiBaseModel response;
    await BaseClient.shared.safeApiCall(
      ApiConstants.paymentVerify,
      RequestType.post,
      data: {
        "razorpay_order_id": razorpayOrderId,
        "razorpay_payment_id": razorpayPaymentId,
        "razorpay_signature": razorpaySignature,
      },
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

  /// Initiate Call API - POST
  static Future<ApiBaseModel> initiateCall({
    required String receiverId,
    required String roomId,
  }) async {
    late ApiBaseModel response;
    await BaseClient.shared.safeApiCall(
      ApiConstants.initiateCall,
      RequestType.post,
      data: {
        "receiverId": receiverId,
        "roomId": roomId,
      },
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

  /// End Call API - POST
  static Future<ApiBaseModel> endCall({
    required String callId,
    String endedBy = "caller",
  }) async {
    late ApiBaseModel response;
    await BaseClient.shared.safeApiCall(
      ApiConstants.endCall,
      RequestType.post,
      data: {
        "callId": callId,
        "endedBy": endedBy,
      },
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
