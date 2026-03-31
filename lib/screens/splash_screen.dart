import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/onboard');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.primary,
        body: Stack(
          children: [
            /// 🔵 TOP RIGHT WAVES
            Positioned(
              top: -60,
              right: -60,
              child:Image.asset('assets/images/ripples.png', width: 350, )
            ),
           

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
        ));
  }
}
