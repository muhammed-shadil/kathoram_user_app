class LoginResponseData {
  final String accessToken;

  LoginResponseData({
    required this.accessToken,
  });

  factory LoginResponseData.fromJson(Map<String, dynamic> json) =>
      LoginResponseData(
        accessToken: json["accessToken"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "accessToken": accessToken,
      };
}
