
class ApiBaseModel {
  bool success;
  int responseCode;
  String message;
  dynamic data;

  ApiBaseModel({
    required this.success,
    required this.responseCode,
    required this.message,
    this.data,
  });

  factory ApiBaseModel.fromJson(Map<String, dynamic> json) => ApiBaseModel(
        success: json["success"] ?? false,
        responseCode: json["responseCode"] ?? 0,
        message: json["message"] ?? "",
        data: json["data"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "responseCode": responseCode,
        "message": message,
        "data": data,
      };
}