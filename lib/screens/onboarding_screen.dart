import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// BACKGROUND (WHITE)
          Container(color: Colors.white),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset("assets/images/Ellipse1.png"),
                  Image.asset("assets/images/Ellipse2.png",
                      height: 400, width: 400),
                  Image.asset("assets/images/Ellipse3.png",
                      width: 450, height: 450),
                ],
              ),
            ),
          ),

          /// CIRCLES (TOP BACKGROUND)
          // Positioned(
          //   top: 0,
          //   left: 0,
          //   right: 0,
          //   child: Image.asset(
          //     "assets/images/Ellipse1.png",
          //     fit: BoxFit.cover,
          //   ),
          // ),

          // Positioned(
          //   top: 20,
          //   left: 0,
          //   right: 0,
          //   child: Image.asset(
          //     "assets/images/Ellipse2.png",
          //     fit: BoxFit.cover,
          //   ),
          // ),

          // Positioned(
          //   top: 40,
          //   left: 0,
          //   right: 0,
          //   child: Image.asset(
          //     "assets/images/Ellipse3.png",
          //     fit: BoxFit.cover,
          //   ),
          // ),

          /// GIRL IMAGE
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "assets/images/girl.png",
                //height: 320,
              ),
            ),
          ),

          /// HELLO
          Positioned(
            top: 120,
            left: 30,
            child: Image.asset(
              "assets/images/hello.png",
              height: 70,
              width: 80,
            ),
          ),

          /// HEY
          Positioned(
            top: 140,
            right: 30,
            child: Image.asset(
              "assets/images/hey.png",
              height: 70,
              width: 80,
            ),
          ),

          /// BLUE SECTION IMAGE (YOUR ASSET)
          Positioned(
            bottom: -90,
            left: 0,
            right: 0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                /// BLUE BACKGROUND IMAGE
                Image.asset(
                  "assets/images/Rectangle1.png", // your blue section image
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

                /// CONTENT OVER BLUE IMAGE
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                        "Engage in real conversations without\n distractions. "
                        "Share thoughts, stories,\n and moments through genuine voice interactions.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// BUTTON
                      CustomButton(
                        text: "Get Started",
                        isReversed: true
                        ,
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/sign up');
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
