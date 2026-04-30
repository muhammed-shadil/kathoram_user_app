class StaffModel {
  final String id;
  final bool active;
  final String tagId;
  final String userType;
  final String name;
  final int age;
  final int coinsPerSec;
  final String language;
  final String profileImage;
  final String status; // "online", "offline", or ""
  final int updatedAt;
  final int createdAt;

  StaffModel({
    required this.id,
    required this.active,
    required this.tagId,
    required this.userType,
    required this.name,
    required this.age,
    required this.coinsPerSec,
    required this.language,
    required this.profileImage,
    required this.status,
    required this.updatedAt,
    required this.createdAt,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) => StaffModel(
        id: json["_id"] ?? "",
        active: json["active"] ?? false,
        tagId: json["tagId"] ?? "",
        userType: json["userType"] ?? "",
        name: json["name"] ?? "",
        age: json["age"] ?? 0,
        coinsPerSec: json["coinsPerSec"] ?? 0,
        language: json["language"] ?? "",
        profileImage: json["profileImage"] ?? "",
        status: json["status"] ?? "",
        updatedAt: json["updatedAt"] ?? 0,
        createdAt: json["createdAt"] ?? 0,
      );

  bool get isOnline => status == "online";
  bool get isOnCall => status == "oncall" || status == "on_call";
  bool get isOffline => status == "offline" || status.isEmpty;
}

class StaffListResponse {
  final List<StaffModel> result;
  final StaffPagination pagination;

  StaffListResponse({
    required this.result,
    required this.pagination,
  });

  factory StaffListResponse.fromJson(Map<String, dynamic> json) =>
      StaffListResponse(
        result: (json["result"] as List? ?? [])
            .map((e) => StaffModel.fromJson(e))
            .toList(),
        pagination: StaffPagination.fromJson(json["pagination"] ?? {}),
      );
}

class StaffPagination {
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  StaffPagination({
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory StaffPagination.fromJson(Map<String, dynamic> json) =>
      StaffPagination(
        total: json["total"] ?? 0,
        page: json["page"] ?? 1,
        pageSize: json["pageSize"] ?? 10,
        totalPages: json["totalPages"] ?? 1,
      );
}
