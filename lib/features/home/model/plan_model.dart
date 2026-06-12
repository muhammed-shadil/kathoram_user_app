class PlanModel {
  final String id;
  final int noOfCoins;
  final int amount;
  final bool active;
  /// Optional marketing label sent by the backend (e.g. "value pack").
  /// Present only on some plans — null/empty means the plan has no badge.
  final String? packName;
  final int updatedAt;
  final int createdAt;

  PlanModel({
    required this.id,
    required this.noOfCoins,
    required this.amount,
    required this.active,
    this.packName,
    required this.updatedAt,
    required this.createdAt,
  });

  /// True when the backend tagged this plan with a pack name to highlight.
  bool get hasPackName => packName != null && packName!.trim().isNotEmpty;

  factory PlanModel.fromJson(Map<String, dynamic> json) => PlanModel(
        id: json["_id"] ?? "",
        noOfCoins: json["noOfCoins"] ?? 0,
        amount: json["amount"] ?? 0,
        active: json["active"] ?? false,
        packName: (json["packName"] as String?),
        updatedAt: json["updatedAt"] ?? 0,
        createdAt: json["createdAt"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "noOfCoins": noOfCoins,
        "amount": amount,
        "active": active,
        "packName": packName,
        "updatedAt": updatedAt,
        "createdAt": createdAt,
      };
}

class PlanPagination {
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  PlanPagination({
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory PlanPagination.fromJson(Map<String, dynamic> json) => PlanPagination(
        total: json["total"] ?? 0,
        page: json["page"] ?? 1,
        pageSize: json["pageSize"] ?? 10,
        totalPages: json["totalPages"] ?? 1,
      );
}

class PlanListResponse {
  final List<PlanModel> result;
  final PlanPagination pagination;

  PlanListResponse({
    required this.result,
    required this.pagination,
  });

  factory PlanListResponse.fromJson(Map<String, dynamic> json) =>
      PlanListResponse(
        result: (json["result"] as List? ?? [])
            .map((e) => PlanModel.fromJson(e))
            .toList(),
        pagination: PlanPagination.fromJson(json["pagination"] ?? {}),
      );
}
