class UserProfileData {
  final String id;
  final bool active;
  final String tagId;
  final String userType;
  final String name;
  final String email;
  final String mobileNumber;
  final String rawPass;
  final int dob;
  final String fcmToken;
  final String profileImage;
  final bool isTermsAgreed;
  final List<dynamic> providers;
  final int updatedAt;
  final int createdAt;
  final int userCoins;

  UserProfileData({
    required this.id,
    required this.active,
    required this.tagId,
    required this.userType,
    required this.name,
    required this.email,
    required this.mobileNumber,
    required this.rawPass,
    required this.dob,
    required this.fcmToken,
    required this.profileImage,
    required this.isTermsAgreed,
    required this.providers,
    required this.updatedAt,
    required this.createdAt,
    required this.userCoins,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) =>
      UserProfileData(
        id: json["_id"] ?? "",
        active: json["active"] ?? false,
        tagId: json["tagId"] ?? "",
        userType: json["userType"] ?? "",
        name: json["name"] ?? "",
        email: json["email"] ?? "",
        mobileNumber: json["mobileNumber"] ?? "",
        rawPass: json["rawPass"] ?? "",
        dob: json["dob"] ?? 0,
        fcmToken: json["fcmToken"] ?? "",
        profileImage: json["profileImage"] ?? "",
        isTermsAgreed: json["isTermsAgreed"] ?? false,
        providers: json["providers"] ?? [],
        updatedAt: json["updatedAt"] ?? 0,
        createdAt: json["createdAt"] ?? 0,
        userCoins: json["userCoins"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "active": active,
        "tagId": tagId,
        "userType": userType,
        "name": name,
        "email": email,
        "mobileNumber": mobileNumber,
        "rawPass": rawPass,
        "dob": dob,
        "fcmToken": fcmToken,
        "profileImage": profileImage,
        "isTermsAgreed": isTermsAgreed,
        "providers": providers,
        "updatedAt": updatedAt,
        "createdAt": createdAt,
        "userCoins": userCoins,
      };
}
