import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../features/authentication/controller/auth_controller.dart';
import '../../features/home/controller/home_controller.dart';
import '../../local_storage/shared_pref.dart';
import '../../routes/route_path.dart';
import '../../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      _navigateBasedOnAuth();
    });
  }

  Future<void> _navigateBasedOnAuth() async {
    // First time user → show onboarding
    if (!MySharedPref.getOnboardingShown()) {
      await MySharedPref.setOnboardingShown(true);
      Get.offAllNamed(RoutePath.onboard);
      return;
    }

    // Returning user with saved token → validate session with is-login API
    if (MySharedPref.getLoggedInStatus()) {
      // permanent: true — a plain Get.put here is scoped to the splash route, so
      // GetX disposed it on the offAllNamed below and every later Get.find built
      // a fresh controller. Screens holding the original instance then watched a
      // dead `userProfile` and never saw coin updates.
      if (!Get.isRegistered<AuthController>()) {
        Get.put<AuthController>(AuthController(), permanent: true);
      }
      final authController = Get.find<AuthController>();
      final isValid = await authController.checkIsLogin();
      if (isValid) {
        if (!Get.isRegistered<HomeController>()) {
          Get.put(HomeController(), permanent: true);
        }
        Get.offAllNamed(RoutePath.bottomNav);
      } else {
        // Token expired or invalid → clear and go to login
        await MySharedPref.clear();
        Get.offAllNamed(RoutePath.signIn);
      }
      return;
    }

    // Onboarding already shown, not logged in → go to login
    Get.offAllNamed(RoutePath.signIn);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
          backgroundColor: AppColors.primary,
          body: Stack(
            children: [
              /// 🔵 TOP RIGHT WAVES
              Positioned(
                  top: -60,
                  right: -60,
                  child: Image.asset(
                    'assets/images/ripples.png',
                    width: 350,
                  )),

              /// 🔵 BOTTOM LEFT WAVES
              Positioned(
                bottom: -60,
                left: -60,
                child: Transform.rotate(
                  angle: 3.14, // 👈 rotate same image for opposite side
                  child: Image.asset(
                    "assets/images/ripples.png",
                    width: 350,
                  ),
                ),
              ),

              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Image(
                      image: AssetImage('assets/images/record_image.png'),
                      width: 150,
                      height: 150,
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
