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
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await FirebaseAndNotification.initNotification();

  MySharedPref.init();

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
