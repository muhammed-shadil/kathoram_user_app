import 'dart:developer';
import 'dart:io';

import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../components/custom_widgets/dialog_and_toast/custom_dialogs.dart';
import '../../../services/api_constants.dart';
import '../../../services/network_adapter.dart';
import 'app_alert_dialog.dart';
import 'version_controle_model.dart';

/// Checks GET api/v1/user/current/version on app open and, for THIS user app:
///   • shows a maintenance dialog if `maintenanceBreak` is active, or
///   • shows an update dialog if the store version for this platform
///     (`user-android` / `user-ios`) is newer than the installed version.
///
/// Failures are swallowed silently so a version-check problem never blocks
/// the user from using the app.
class VersionControlApi {
  VersionControlApi.init();

  static final VersionControlApi instance = VersionControlApi.init();

  /// Only run once per app launch.
  static bool _alreadyChecked = false;

  Future<void> checkVersionStatus() async {
    if (_alreadyChecked) return;
    _alreadyChecked = true;

    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;

      await BaseClient.shared.safeApiCall(
        ApiConstants.currentVersion,
        RequestType.get,
        includeAuth: true,
        onSuccess: (response) {
          if (response.responseCode != 200 || response.data == null) return;

          final VersionControlData parsed =
              VersionControlData.fromJson(response.data as Map<String, dynamic>);
          final items = parsed.version ?? [];
          if (items.isEmpty) return;

          // ───── 1) Maintenance break takes priority ─────
          final maintenance = items.firstWhereOrNull(
            (e) => e.name == "maintenanceBreak",
          );
          if (maintenance?.active == true) {
            Future.delayed(const Duration(milliseconds: 300), () {
              CustomDialogs.showDialogs(
                borderRadius: 24,
                child: AppMaintenanceDialog(
                  message: maintenance?.message ?? "",
                ),
              );
            });
            return;
          }

          // ───── 2) Platform-specific update check ─────
          final String platformName =
              Platform.isAndroid ? "user-android" : "user-ios";

          final platformVersion = items.firstWhereOrNull(
            (e) => e.name == platformName && e.active == true,
          );
          if (platformVersion == null) return;

          if (!_isUpdateAvailable(currentVersion, platformVersion.version)) {
            return;
          }

          Future.delayed(const Duration(milliseconds: 300), () {
            CustomDialogs.showDialogs(
              borderRadius: 24,
              child: AppUpdateAlertDialog(
                onConfirm: () async {
                  final url = platformVersion.redirectUrl;
                  if (url == null || url.isEmpty) return;
                  await launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  );
                },
                // forceUpdate => no "Later", non-dismissible
                onCancel: platformVersion.forceUpdate == true
                    ? null
                    : () => Get.back(),
              ),
            );
          });
        },
        onError: (_) {
          // ignore — version check should never block app usage
        },
      );
    } catch (e, s) {
      log('[VersionControlApi] check failed', error: e, stackTrace: s);
    }
  }

  /// Returns true when [storeVersion] is strictly greater than
  /// [currentVersion] using a numeric, segment-by-segment compare
  /// (e.g. "1.0.10" > "1.0.2"). Falls back to false on unparsable input
  /// so we never nag the user incorrectly.
  bool _isUpdateAvailable(String currentVersion, String? storeVersion) {
    if (storeVersion == null || storeVersion.trim().isEmpty) return false;

    final current = _parseSegments(currentVersion);
    final store = _parseSegments(storeVersion);

    final length = current.length > store.length ? current.length : store.length;
    for (var i = 0; i < length; i++) {
      final c = i < current.length ? current[i] : 0;
      final s = i < store.length ? store[i] : 0;
      if (s > c) return true;
      if (s < c) return false;
    }
    return false; // equal
  }

  List<int> _parseSegments(String version) {
    return version
        .split('.')
        .map((p) => int.tryParse(p.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .toList();
  }
}
