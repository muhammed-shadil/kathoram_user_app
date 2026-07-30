import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kathoram_user_app/firebase_options.dart';
import 'package:kathoram_user_app/local_storage/shared_pref.dart';
import 'package:kathoram_user_app/routes/route_pages.dart';
import 'package:kathoram_user_app/routes/route_path.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:kathoram_user_app/services/firebase_fcm.dart';
import 'package:kathoram_user_app/services/meta_analytics_service.dart';
import 'package:kathoram_user_app/services/zego_call_service.dart';
import 'package:kathoram_user_app/utils/navigator_key_utils.dart';
import 'package:kathoram_user_app/utils/screen_security.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      fatal: !_isZegoIsolateCloseNoise(error, stack),
    );
    return true;
  };

  await FirebaseAndNotification.initNotification();

  MySharedPref.init();

  // Meta ads measurement. App Install and App Open are logged by the Facebook
  // SDK itself once this runs; Registration and Login are logged explicitly
  // from AuthController. See MetaAnalytics for the full event table.
  await MetaAnalytics.instance.init();

  // Block screenshots & screen recording across the entire app (reinforces the
  // native Android FLAG_SECURE and enables the iOS secure layer + app-switcher
  // blur). See android MainActivity.kt for the native Android counterpart.
  await ScreenSecurity.enable();

  // CRITICAL: Zego system calling UI setup MUST be before runApp()
  await ZegoCallService.instance.initialSetUp(NavigatorKeyHelper.navigatorKey);

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
      // DevicePreview(enabled: true, builder: (context) =>
      MyApp()
      //  )
      );
}

/// `zego_uikit_prebuilt_call` (4.16.28, still broken in 4.22.2) sends the plain
/// string `'close'` on its offline-call isolate port
/// (`private.dart` -> `lookupIsolate.send(backgroundMessageIsolateCloseCommand)`)
/// but the main-isolate listener `jsonDecode`s every message without the
/// `message == 'close'` guard that its own background-isolate handler has.
///
/// The result is an uncaught `FormatException` whenever the app is opened from
/// an offline call notification. It carries no call payload, so nothing is lost
/// — but it must not be reported as a fatal crash.
bool _isZegoIsolateCloseNoise(Object error, StackTrace stack) {
  if (error is! FormatException) return false;
  final frames = stack.toString();
  return frames.contains('_registerOfflineCallIsolateNameServer') ||
      frames.contains('ZegoCallInvitationServicePrivateImpl');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Kathoram',
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigatorKeyHelper.navigatorKey,
      initialRoute: RoutePath.splash,
      getPages: RoutePages.routes,
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            // Zego mini overlay for minimized call state
            ZegoUIKitPrebuiltCallMiniOverlayPage(
              contextQuery: () {
                return NavigatorKeyHelper.navigatorKey.currentState!.context;
              },
            ),
          ],
        );
      },
    );
  }
}
