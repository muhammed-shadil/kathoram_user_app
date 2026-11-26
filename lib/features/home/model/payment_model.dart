/// `data` of a successful POST /payment/initiate (apiVersion 2).
///
/// The backend picks the gateway. [checkoutData] holds that gateway's own
/// fields, so it is parsed per gateway by [CashfreeCheckoutData] /
/// [RazorpayCheckoutData] at the point the checkout is opened.
class PaymentInitiateResponse {
  final String gateway;
  final String orderId;
  final Map<String, dynamic> checkoutData;

  PaymentInitiateResponse({
    required this.gateway,
    required this.orderId,
    required this.checkoutData,
  });

  factory PaymentInitiateResponse.fromJson(Map<String, dynamic> json) =>
      PaymentInitiateResponse(
        gateway: (json["gateway"] ?? "").toString().toLowerCase(),
        orderId: (json["orderId"] ?? "").toString(),
        checkoutData: json["checkoutData"] is Map<String, dynamic>
            ? json["checkoutData"] as Map<String, dynamic>
            : <String, dynamic>{},
      );
}

/// `checkoutData` when `gateway == "cashfree"`.
class CashfreeCheckoutData {
  final String orderId;
  final String paymentSessionId;

  /// "SANDBOX" or "PRODUCTION", as sent by the backend.
  final String environment;

  CashfreeCheckoutData({
    required this.orderId,
    required this.paymentSessionId,
    required this.environment,
  });

  factory CashfreeCheckoutData.fromJson(Map<String, dynamic> json) =>
      CashfreeCheckoutData(
        orderId: (json["orderId"] ?? "").toString(),
        paymentSessionId: (json["paymentSessionId"] ?? "").toString(),
        environment: (json["environment"] ?? "").toString().toUpperCase(),
      );
}

/// `checkoutData` when `gateway == "razorpay"` (only if the backend switches
/// back to Razorpay).
class RazorpayCheckoutData {
  final String key;
  final String razorpayOrderId;

  /// Amount in paise.
  final int amount;
  final String currency;

  RazorpayCheckoutData({
    required this.key,
    required this.razorpayOrderId,
    required this.amount,
    required this.currency,
  });

  factory RazorpayCheckoutData.fromJson(Map<String, dynamic> json) =>
      RazorpayCheckoutData(
        key: (json["key"] ?? "").toString(),
        razorpayOrderId: (json["razorpayOrderId"] ?? "").toString(),
        amount: json["amount"] is num
            ? (json["amount"] as num).toInt()
            : int.tryParse("${json["amount"]}") ?? 0,
        currency: (json["currency"] ?? "INR").toString(),
      );
}

/// `data.status` of POST /payment/verify.
enum PaymentVerifyStatus { credited, pending, failed, unknown }

PaymentVerifyStatus parsePaymentVerifyStatus(dynamic data) {
  if (data is! Map) return PaymentVerifyStatus.unknown;
  switch ((data["status"] ?? "").toString().toLowerCase()) {
    case "credited":
      return PaymentVerifyStatus.credited;
    case "pending":
      return PaymentVerifyStatus.pending;
    case "failed":
      return PaymentVerifyStatus.failed;
    default:
      return PaymentVerifyStatus.unknown;
  }
}
