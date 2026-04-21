import 'package:flutter/material.dart';
import 'package:kathoram_app/screens/otp_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      body: Column(
        children: [
          // Top Blue Header
          Stack(
            children: [
              Image.asset(
                "assets/images/Rectangle2.png",
                width: double.infinity,
                fit: BoxFit.cover,
              ),

              //TOP left WAVES
              Positioned(
                  top: -20,
                  left: -20,
                  child: Transform.rotate(
                    angle: -1.8,
                    child: Image.asset(
                      'assets/images/ripples.png',
                      width: 100,
                    ),
                  )),
              Positioned(
                  bottom: -10,
                  right: -10,
                  child: Transform.rotate(
                    angle: 1.8,
                    child: Image.asset(
                      'assets/images/ripples.png',
                      width: 100,
                    ),
                  )),

              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset("assets/images/kathoram.png", width: 150),
                    ],
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 30),
          const Text("Forgot Password",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue)),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Enter E-Mail Here",
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.blue.shade200),
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1976D2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OTPScreen()),
                  );
                },
                child: const Text(
                  "Get OTP",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
