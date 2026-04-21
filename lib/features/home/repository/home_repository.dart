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
}
