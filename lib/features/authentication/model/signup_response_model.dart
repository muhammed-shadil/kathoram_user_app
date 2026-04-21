class SignupResponseData {
  final bool active;
  final String tagId;
  final String userType;
  final String name;
  final String mobileNumber;
  final String fcmToken;
  final String profileImage;
  final bool isTermsAgreed;
  final double coinsPerSec;
  final String id;
  final List<dynamic> providers;
  final int updatedAt;
  final int createdAt;
  final String accessToken;

  SignupResponseData({
    required this.active,
    required this.tagId,
    required this.userType,
    required this.name,
    required this.mobileNumber,
    required this.fcmToken,
    required this.profileImage,
    required this.isTermsAgreed,
    required this.coinsPerSec,
    required this.id,
    required this.providers,
    required this.updatedAt,
    required this.createdAt,
    required this.accessToken,
  });

  factory SignupResponseData.fromJson(Map<String, dynamic> json) =>
      SignupResponseData(
        active: json["active"] ?? false,
        tagId: json["tagId"] ?? "",
        userType: json["userType"] ?? "",
        name: json["name"] ?? "",
        mobileNumber: json["mobileNumber"] ?? "",
        fcmToken: json["fcmToken"] ?? "",
        profileImage: json["profileImage"] ?? "",
        isTermsAgreed: json["isTermsAgreed"] ?? false,
        coinsPerSec: (json["coinsPerSec"] ?? 0).toDouble(),
        id: json["_id"] ?? "",
        providers: json["providers"] ?? [],
        updatedAt: json["updatedAt"] ?? 0,
        createdAt: json["createdAt"] ?? 0,
        accessToken: json["accessToken"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "active": active,
        "tagId": tagId,
        "userType": userType,
        "name": name,
        "mobileNumber": mobileNumber,
        "fcmToken": fcmToken,
        "profileImage": profileImage,
        "isTermsAgreed": isTermsAgreed,
        "coinsPerSec": coinsPerSec,
        "_id": id,
        "providers": providers,
        "updatedAt": updatedAt,
        "createdAt": createdAt,
        "accessToken": accessToken,
      };
}
