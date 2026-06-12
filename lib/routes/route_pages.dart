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
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
      }),
      transition: transition,
    ),
    GetPage(
      name: RoutePath.signUp,
      page: () => SignUpScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
      }),
      transition: transition,
    ),
    GetPage(
      name: RoutePath.guestSignup,
      page: () => GuestSignUpScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
      }),
      transition: transition,
    ),
    GetPage(
      name: RoutePath.bottomNav,
      page: () => BottomNavBar(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
        // HomeController must be ONE permanent instance for the whole session.
        // It was fenix-lazyPut before, which let GetX dispose & recreate it: the
        // screens captured one instance in initState while the call-end/socket
        // flow's Get.find resolved to a freshly recreated one — so list updates
        // (e.g. a new call-history entry) never reached the watching Obx.
        if (!Get.isRegistered<HomeController>()) {
          Get.put<HomeController>(HomeController(), permanent: true);
        }
      }),
      transition: transition,
    ),
    GetPage(
      name: RoutePath.addCoins,
      page: () => AddCoinsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
        // HomeController must be ONE permanent instance for the whole session.
        // It was fenix-lazyPut before, which let GetX dispose & recreate it: the
        // screens captured one instance in initState while the call-end/socket
        // flow's Get.find resolved to a freshly recreated one — so list updates
        // (e.g. a new call-history entry) never reached the watching Obx.
        if (!Get.isRegistered<HomeController>()) {
          Get.put<HomeController>(HomeController(), permanent: true);
        }
      }),
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
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
      }),
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
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
      }),
      transition: transition,
    ),
    GetPage(
      name: RoutePath.changePassword,
      page: () => ChangePasswordScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
      }),
      transition: transition,
    ),
    GetPage(
      name: RoutePath.editProfile,
      page: () => EditProfileScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
      }),
      transition: transition,
    ),
  ];
}