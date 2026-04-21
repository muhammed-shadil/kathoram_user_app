import 'package:flutter/material.dart';
import 'package:kathoram_app/models/coins_model.dart';
import 'package:kathoram_app/screens/add_coin_done_screen.dart';
import 'package:kathoram_app/screens/bottom_nav_bar.dart';
import 'package:kathoram_app/screens/bottom_nav_screens/add_coin_screen.dart';
import 'package:kathoram_app/screens/call_screen.dart';
import 'package:kathoram_app/screens/forgot_screen.dart';
import 'package:kathoram_app/screens/guest_signup_screen.dart';
import 'package:kathoram_app/screens/bottom_nav_screens/chat_home_screen.dart';
import 'package:kathoram_app/screens/onboarding_screen.dart';
import 'package:kathoram_app/screens/payment_screen.dart';
import 'package:kathoram_app/screens/sign_in.dart';
import 'package:kathoram_app/screens/sign_up.dart';
import 'package:kathoram_app/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PaymentScreen(
        pack: CoinPack(coins: 100, price: 50),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/onboard': (context) => OnboardingScreen(),
        '/sign up': (context) => SignUpScreen(),
        '/sign in': (context) => SignInScreen(),
        '/guestSignup': (context) => GuestSignUpScreen(),
        '/bottomnav': (context) => BottomNavBar(),
        '/addcoins': (context) => AddCoinsScreen(),
        '/addcoinsdone': (context) => AddCoinsDoneScreen(),
        '/payment': (context) =>
            PaymentScreen(pack: CoinPack(coins: 100, price: 50)),
        '/call': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;

          return CallScreen(
            name: args['name'],
            image: args['image'],
            coins: args['coins'],
          );
          
        },
        '/forgotpassword': (context) => ForgotPasswordScreen(),
      },
    );
  }
}
