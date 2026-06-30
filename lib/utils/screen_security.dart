import 'package:screen_protector/screen_protector.dart';

/// App-wide protection against screenshots and screen recording.
///
/// Android is primarily protected natively via `FLAG_SECURE` set in
/// `MainActivity` (covers screenshots, screen recording, and the recent-apps
/// thumbnail before the first frame renders). This class reinforces that and
/// adds the iOS protection, since iOS has no OS-level screenshot block:
///   * [ScreenProtector.preventScreenshotOn] applies a secure layer so
///     screenshots and screen recordings capture a blank/black frame.
///   * [ScreenProtector.protectDataLeakageWithBlur] blurs the UI in the app
///     switcher / when backgrounded so content isn't exposed in the preview.
class ScreenSecurity {
  ScreenSecurity._();

  /// Enables protection for the entire app. Call once during startup.
  static Future<void> enable() async {
    try {
      await ScreenProtector.preventScreenshotOn();
      await ScreenProtector.protectDataLeakageWithBlur();
    } catch (_) {
      // Never let a protection failure crash app startup.
    }
  }
}
