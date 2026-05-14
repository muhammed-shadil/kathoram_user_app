class CoinsConfigModel {
  final double daytimeCoinsPerSec;
  final double nightTimeCoinsPerSec;

  CoinsConfigModel({
    required this.daytimeCoinsPerSec,
    required this.nightTimeCoinsPerSec,
  });

  factory CoinsConfigModel.fromJson(Map<String, dynamic> json) =>
      CoinsConfigModel(
        daytimeCoinsPerSec: (json["daytimeCoinsPerSec"] ?? 0).toDouble(),
        nightTimeCoinsPerSec: (json["nightTimeCoinsPerSec"] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "daytimeCoinsPerSec": daytimeCoinsPerSec,
        "nightTimeCoinsPerSec": nightTimeCoinsPerSec,
      };
}

class GuestLoginResponseData {
  final String accessToken;
  final String id;
  final String name;
  final String mobileNumber;
  final String tagId;
  final String userType;
  final int userCoins;
  final String timezone;
  final CoinsConfigModel? coinsConfig;

  GuestLoginResponseData({
    required this.accessToken,
    required this.id,
    required this.name,
    required this.mobileNumber,
    required this.tagId,
    required this.userType,
    required this.userCoins,
    required this.timezone,
    required this.coinsConfig,
  });

  factory GuestLoginResponseData.fromJson(Map<String, dynamic> json) =>
      GuestLoginResponseData(
        accessToken: json["accessToken"] ?? "",
        id: json["_id"] ?? "",
        name: json["name"] ?? "",
        mobileNumber: json["mobileNumber"] ?? "",
        tagId: json["tagId"] ?? "",
        userType: json["userType"] ?? "",
        userCoins: json["userCoins"] ?? 0,
        timezone: json["timezone"] ?? "",
        coinsConfig: json["coinsConfig"] != null
            ? CoinsConfigModel.fromJson(
                json["coinsConfig"] as Map<String, dynamic>)
            : null,
      );
}
