import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/route_path.dart';
import '../widgets/custom_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// WHITE BACKGROUND
          Container(color: Colors.white),

          /// TOP CIRCLES
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset("assets/images/Ellipse1.png", width: 320),
                  Image.asset("assets/images/Ellipse2.png", width: 360),
                  Image.asset("assets/images/Ellipse3.png", width: 420),
                ],
              ),
            ),
          ),

          /// GIRL IMAGE (PERFECT POSITION)
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                "assets/images/girl.png",
                height: 500,
                width: 300,
                fit: BoxFit.contain,
              ),
            ),
          ),

          /// HELLO STICKER
          Positioned(
            top: 140,
            left: 50,
            child: Image.asset(
              "assets/images/hello.png",
              height: 60,
            ),
          ),

          /// HEY STICKER
          Positioned(
            top: 140,
            right: 40,
            child: Image.asset(
              "assets/images/hey.png",
              height: 60,
            ),
          ),

          /// BLUE BOTTOM SECTION
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  "assets/images/Rectangle1.png",
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 10, 25, 35),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Welcome to Kathoram!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Engage in real conversations without distractions. "
                        "Share thoughts, stories, and moments through genuine voice interactions.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        text: "Get Started",
                        isReversed: true,
                        onPressed: () {
                          Get.offNamed(RoutePath.signIn);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
