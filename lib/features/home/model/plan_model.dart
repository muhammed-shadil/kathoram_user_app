class PlanModel {
  final String id;
  final int noOfCoins;
  final int amount;
  final bool active;
  final int updatedAt;
  final int createdAt;

  PlanModel({
    required this.id,
    required this.noOfCoins,
    required this.amount,
    required this.active,
    required this.updatedAt,
    required this.createdAt,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) => PlanModel(
        id: json["_id"] ?? "",
        noOfCoins: json["noOfCoins"] ?? 0,
        amount: json["amount"] ?? 0,
        active: json["active"] ?? false,
        updatedAt: json["updatedAt"] ?? 0,
        createdAt: json["createdAt"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "noOfCoins": noOfCoins,
        "amount": amount,
        "active": active,
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
