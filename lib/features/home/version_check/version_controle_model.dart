// ignore_for_file: file_names

/// Parses the `data` object of GET api/v1/user/current/version.
///
/// Expected shape:
/// {
///   "version": [
///     { "name": "user-android", "forceUpdate": false, "active": true,
///       "version": "1.0.2", "redirectUrl": "https://..." },
///     ...,
///     { "name": "maintenanceBreak", "active": false,
///       "message": "App is under maintenance..." }
///   ]
/// }
class VersionControlData {
  List<VersionItem>? version;

  VersionControlData({this.version});

  VersionControlData.fromJson(Map<String, dynamic> json) {
    if (json['version'] != null) {
      version = <VersionItem>[];
      for (final v in (json['version'] as List)) {
        version!.add(VersionItem.fromJson(v as Map<String, dynamic>));
      }
    }
  }

  Map<String, dynamic> toJson() => {
        if (version != null)
          'version': version!.map((v) => v.toJson()).toList(),
      };
}

class VersionItem {
  String? sId;
  bool? active;
  bool? forceUpdate;
  String? name;
  String? version;
  int? createdAt;
  String? message;
  String? redirectUrl;

  VersionItem({
    this.sId,
    this.active,
    this.forceUpdate,
    this.name,
    this.version,
    this.createdAt,
    this.message,
    this.redirectUrl,
  });

  VersionItem.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    active = json['active'];
    forceUpdate = json['forceUpdate'];
    name = json['name'];
    version = json['version'];
    createdAt = json['createdAt'];
    message = json['message'];
    redirectUrl = json['redirectUrl'];
  }

  Map<String, dynamic> toJson() => {
        '_id': sId,
        'active': active,
        'forceUpdate': forceUpdate,
        'name': name,
        'version': version,
        'createdAt': createdAt,
        'message': message,
        'redirectUrl': redirectUrl,
      };
}
