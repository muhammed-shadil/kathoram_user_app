import 'package:get/get.dart';
import 'package:kathoram_user_app/features/authentication/controller/auth_controller.dart';
import 'package:kathoram_user_app/features/authentication/screens/sign_in.dart';
import 'package:kathoram_user_app/features/authentication/screens/sign_up.dart';
import 'package:kathoram_user_app/features/home/controller/home_controller.dart';
import 'package:kathoram_user_app/features/screens/add_coin_done_screen.dart';
import 'package:kathoram_user_app/features/screens/bottom_nav_bar.dart';
import 'package:kathoram_user_app/features/screens/bottom_nav_screens/add_coin_screen.dart';
import 'package:kathoram_user_app/features/screens/call_screen.dart';
import 'package:kathoram_user_app/features/screens/change_password.dart';
import 'package:kathoram_user_app/features/screens/edit_profile_screen.dart';
import 'package:kathoram_user_app/features/screens/forgot_screen.dart';
import 'package:kathoram_user_app/features/screens/guest_signup_screen.dart';
import 'package:kathoram_user_app/features/screens/onboarding_screen.dart';
import 'package:kathoram_user_app/features/screens/otp_screen.dart';
import 'package:kathoram_user_app/features/screens/splash_screen.dart';
import 'package:kathoram_user_app/routes/route_path.dart';

class RoutePages {
  static const transition = Transition.fadeIn;

  /// AuthController must be ONE permanent instance for the whole session —
  /// the same rule (and the same past bug) as HomeController below.
  ///
  /// It used to be a fenix lazyPut on every route binding. Popping any of those
  /// routes (edit-profile, OTP, …) let GetX dispose the instance, and the next
  /// Get.find silently built a fresh one. Screens that captured the controller
  /// once in initState — AddCoinsScreen does, in a `late final` — kept pointing
  /// at the dead instance: is-login updated `userProfile` on the NEW controller
  /// while the app bar's Obx was still watching the OLD one, so the API fired on
  /// every tab switch but the coin balance never moved.
  static void _bindAuth() {
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController(), permanent: true);
    }
  }

  /// AuthController + HomeController, both permanent. Used by the session
  /// routes (bottom nav and add-coins) that need the full set.
  static void _bindSession() {
    _bindAuth();
    // HomeController must be ONE permanent instance for the whole session.
    // It was fenix-lazyPut before, which let GetX dispose & recreate it: the
    // screens captured one instance in initState while the call-end/socket
    // flow's Get.find resolved to a freshly recreated one — so list updates
    // (e.g. a new call-history entry) never reached the watching Obx.
    if (!Get.isRegistered<HomeController>()) {
      Get.put<HomeController>(HomeController(), permanent: true);
    }
  }

  static final routes = [
    GetPage(
      name: RoutePath.splash,
      page: () => const SplashScreen(),
      transition: transition,
    ),
    GetPage(
      name: RoutePath.onboard,
      page: () => OnboardingScreen(),
      transition: transition,
    ),
    GetPage(
      name: RoutePath.signIn,
      page: () => SignInScreen(),
      binding: BindingsBuilder(_bindAuth),
      transition: transition,
    ),
    GetPage(
      name: RoutePath.signUp,
      page: () => SignUpScreen(),
      binding: BindingsBuilder(_bindAuth),
      transition: transition,
    ),
    GetPage(
      name: RoutePath.guestSignup,
      page: () => GuestSignUpScreen(),
      binding: BindingsBuilder(_bindAuth),
      transition: transition,
    ),
    GetPage(
      name: RoutePath.bottomNav,
      page: () => BottomNavBar(),
      binding: BindingsBuilder(_bindSession),
      transition: transition,
    ),
    GetPage(
      name: RoutePath.addCoins,
      page: () => AddCoinsScreen(),
      binding: BindingsBuilder(_bindSession),
      transition: transition,
    ),
    GetPage(
      name: RoutePath.addCoinsDone,
      page: () => AddCoinsDoneScreen(),
      transition: transition,
    ),
    GetPage(
      name: RoutePath.forgotPassword,
      page: () => ForgotPasswordScreen(),
      binding: BindingsBuilder(_bindAuth),
      transition: transition,
    ),
    GetPage(
      name: RoutePath.call,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return CallScreen(
          name: args['name'],
          image: args['image'],
          coins: args['coins'],
        );
      },
      transition: transition,
    ),
    GetPage(
      name: RoutePath.otp,
      page: () => OTPScreen(),
      binding: BindingsBuilder(_bindAuth),
      transition: transition,
    ),
    GetPage(
      name: RoutePath.changePassword,
      page: () => ChangePasswordScreen(),
      binding: BindingsBuilder(_bindAuth),
      transition: transition,
    ),
    GetPage(
      name: RoutePath.editProfile,
      page: () => EditProfileScreen(),
      binding: BindingsBuilder(_bindAuth),
      transition: transition,
    ),
  ];
}