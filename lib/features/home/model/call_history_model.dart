class CallHistoryModel {
  final String id;
  final String caller;
  final String receiver;
  final int startTime;
  final int? endedAt;
  final int duration;
  final int coinsUsed;
  final String status; // "ONGOING", "ENDED", "MISSED", "CANCELLED"
  final String disconnectReason;
  final CallReceiverDetails receiverDetails;

  CallHistoryModel({
    required this.id,
    required this.caller,
    required this.receiver,
    required this.startTime,
    this.endedAt,
    required this.duration,
    required this.coinsUsed,
    required this.status,
    required this.disconnectReason,
    required this.receiverDetails,
  });

  factory CallHistoryModel.fromJson(Map<String, dynamic> json) =>
      CallHistoryModel(
        id: json["_id"] ?? "",
        caller: json["caller"] ?? "",
        receiver: json["receiver"] ?? "",
        startTime: json["startTime"] ?? 0,
        endedAt: json["endedAt"],
        duration: json["duration"] ?? 0,
        coinsUsed: json["coinsUsed"] ?? 0,
        status: json["status"] ?? "",
        disconnectReason: json["disconnectReason"] ?? "",
        receiverDetails:
            CallReceiverDetails.fromJson(json["receiverDetails"] ?? {}),
      );

  /// Formatted duration string (HH:MM:SS)
  String get formattedDuration {
    int hrs = duration ~/ 3600;
    int mins = (duration % 3600) ~/ 60;
    int secs = duration % 60;
    return "${hrs.toString().padLeft(2, '0')}:"
        "${mins.toString().padLeft(2, '0')}:"
        "${secs.toString().padLeft(2, '0')}";
  }

  /// Formatted start time
  String get formattedStartTime {
    final date = DateTime.fromMillisecondsSinceEpoch(startTime);
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    return "${date.day} ${months[date.month - 1]} | "
        "${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $amPm";
  }

  bool get isEnded => status == "ENDED";
  bool get isMissed => status == "MISSED";
  bool get isCancelled => status == "CANCELLED";
  bool get isOngoing => status == "ONGOING";
}

class CallReceiverDetails {
  final String name;
  final String email;

  CallReceiverDetails({
    required this.name,
    required this.email,
  });

  factory CallReceiverDetails.fromJson(Map<String, dynamic> json) =>
      CallReceiverDetails(
        name: json["name"] ?? "",
        email: json["email"] ?? "",
      );
}

class CallHistoryListResponse {
  final List<CallHistoryModel> result;
  final CallHistoryPagination pagination;

  CallHistoryListResponse({
    required this.result,
    required this.pagination,
  });

  factory CallHistoryListResponse.fromJson(Map<String, dynamic> json) =>
      CallHistoryListResponse(
        result: (json["result"] as List? ?? [])
            .map((e) => CallHistoryModel.fromJson(e))
            .toList(),
        pagination: CallHistoryPagination.fromJson(json["pagination"] ?? {}),
      );
}

class CallHistoryPagination {
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  CallHistoryPagination({
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory CallHistoryPagination.fromJson(Map<String, dynamic> json) =>
      CallHistoryPagination(
        total: json["total"] ?? 0,
        page: json["page"] ?? 1,
        pageSize: json["pageSize"] ?? 10,
        totalPages: json["totalPages"] ?? 1,
      );
}
