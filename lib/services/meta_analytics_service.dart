import 'dart:developer';

import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around Meta (Facebook) App Events, used to attribute installs
/// and conversions back to Meta ad campaigns.
///
/// ## Which events go to Meta
///
/// | Event        | How it is sent                                             |
/// |--------------|------------------------------------------------------------|
/// | App Install  | `fb_mobile_first_app_launch` — logged automatically by the  |
/// |              | native SDK on first launch. No app code required.           |
/// | App Open     | `fb_mobile_activate_app` — logged automatically by the      |
/// |              | native SDK once per session (foreground after >60s away).   |
/// | Registration | `fb_mobile_complete_registration` — [logRegistration].      |
/// | Login        | `Login` (custom event) — [logLogin].                        |
///
/// Install and App Open are *not* logged from Dart on purpose: the Facebook
/// SDK already logs both while `AutoLogAppEvents` is enabled (see [init]), and
/// logging them again from here would double-count every session. Only call
/// [logAppOpen] if you disable auto-logging to gate it behind a consent flow.
///
/// Every method swallows its errors — ad measurement must never be able to
/// break a user flow.
class MetaAnalytics {
  MetaAnalytics._();

  static final MetaAnalytics instance = MetaAnalytics._();

  /// Meta has no standard "login" app event, so this is a custom event. It
  /// shows up under Events Manager → Custom Events and can be used for custom
  /// conversions, audiences and campaign optimisation like any standard event.
  static const String eventNameLogin = 'Login';

  final FacebookAppEvents _fb = FacebookAppEvents();

  /// False until [init] confirms a real App ID is configured. Guards every
  /// log call so we don't spam the SDK with events that cannot be delivered.
  bool _ready = false;

  /// The App ID shipped in the Android/iOS config before a real one is filled
  /// in. Kept numeric so the native SDKs still parse it without throwing.
  static const String _placeholderAppId = '000000000000000';

  /// Initialise the Facebook SDK. Call once from `main()`, after
  /// `WidgetsFlutterBinding.ensureInitialized()`.
  Future<void> init() async {
    try {
      // Auto-logging is what produces App Install and App Open. Setting it
      // explicitly means the behaviour does not depend on the plist/manifest
      // defaults, and gives one place to flip if a consent flow is added.
      await _fb.setAutoLogAppEventsEnabled(true);

      // Advertiser ID (GAID / IDFA) is what lets Meta match an event back to
      // the person who saw the ad. On iOS it only resolves once the user has
      // granted App Tracking Transparency.
      await _fb.setAdvertiserIdCollectionEnabled(true);

      await _fb.setDebugLoggingEnabled(kDebugMode);

      final appId = await _fb.getApplicationId();
      _ready = appId != null &&
          appId.isNotEmpty &&
          appId != _placeholderAppId;

      if (!_ready) {
        log('[MetaAnalytics] Disabled — Facebook App ID is not configured. '
            'Set it in android/app/src/main/res/values/strings.xml and '
            'ios/Runner/Info.plist.');
      }
    } catch (e) {
      _ready = false;
      log('[MetaAnalytics] init failed: $e');
    }
  }

  /// Logs `fb_mobile_activate_app` manually.
  ///
  /// Not needed in the default setup — the native SDK already logs it while
  /// auto-logging is on (see [init]). Only use this if auto-logging is turned
  /// off (e.g. delayed until the user accepts a consent prompt); calling it on
  /// top of auto-logging double-counts App Open.
  Future<void> logAppOpen() async {
    if (!_ready) return;
    try {
      await _fb.activateApp();
    } catch (e) {
      log('[MetaAnalytics] logAppOpen failed: $e');
    }
  }

  /// Standard **Completed Registration** event — fire once, right after a new
  /// account is created (signup, guest signup, first Google sign-in).
  ///
  /// [method] lands in `fb_registration_method` so campaigns can be broken
  /// down by signup path, e.g. `email`, `guest`, `Google`.
  Future<void> logRegistration({required String method}) async {
    if (!_ready) return;
    try {
      await _fb.logCompletedRegistration(registrationMethod: method);
    } catch (e) {
      log('[MetaAnalytics] logRegistration failed: $e');
    }
  }

  /// Custom **Login** event — fire when an existing user signs back in.
  Future<void> logLogin({required String method}) async {
    if (!_ready) return;
    try {
      await _fb.logEvent(
        name: eventNameLogin,
        parameters: {'method': method},
      );
    } catch (e) {
      log('[MetaAnalytics] logLogin failed: $e');
    }
  }

  /// Attaches the signed-in user to subsequent events.
  ///
  /// [email] and [phone] are hashed on-device by the SDK before they leave the
  /// app; they power Meta's Advanced Matching, which materially improves how
  /// many conversions get attributed back to a campaign.
  Future<void> identifyUser({
    required String userId,
    String? name,
    String? email,
    String? phone,
  }) async {
    if (!_ready || userId.isEmpty) return;
    try {
      await _fb.setUserID(userId);
      await _fb.setUserData(
        externalId: userId,
        firstName: _firstName(name),
        lastName: _lastName(name),
        email: _orNull(email),
        phone: _orNull(phone),
      );
    } catch (e) {
      log('[MetaAnalytics] identifyUser failed: $e');
    }
  }

  /// Drops the user identity on logout so the next person on this device is
  /// not matched against the previous account.
  Future<void> clearUser() async {
    if (!_ready) return;
    try {
      await _fb.clearUserID();
      await _fb.clearUserData();
    } catch (e) {
      log('[MetaAnalytics] clearUser failed: $e');
    }
  }

  // ─── Helpers ───

  static String? _orNull(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  static String? _firstName(String? fullName) {
    final name = _orNull(fullName);
    if (name == null) return null;
    return name.split(RegExp(r'\s+')).first;
  }

  static String? _lastName(String? fullName) {
    final name = _orNull(fullName);
    if (name == null) return null;
    final parts = name.split(RegExp(r'\s+'));
    return parts.length > 1 ? parts.last : null;
  }
}
