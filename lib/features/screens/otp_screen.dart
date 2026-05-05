import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../authentication/controller/auth_controller.dart';

class OTPScreen extends StatelessWidget {
  OTPScreen({super.key});

  final AuthController authController = Get.find<AuthController>();

  /// Mask the local part of an email so only the first character is visible:
  /// e.g. "dathasai@gmail.com" → "d*******@gmail.com"
  String _maskEmail(String email) {
    final at = email.indexOf('@');
    if (at <= 1) return email;
    final local = email.substring(0, at);
    final domain = email.substring(at);
    return '${local[0]}${'*' * (local.length - 1)}$domain';
  }

  @override
  Widget build(BuildContext context) {
    final email = authController.forgotEmailController.text.trim();
    final maskedEmail = _maskEmail(email);

    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      body: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                "assets/images/Rectangle2.png",
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: -20,
                left: -20,
                child: Transform.rotate(
                  angle: -1.8,
                  child: Image.asset(
                    'assets/images/ripples.png',
                    width: 100,
                  ),
                ),
              ),
              Positioned(
                bottom: -10,
                right: -10,
                child: Transform.rotate(
                  angle: 1.8,
                  child: Image.asset(
                    'assets/images/ripples.png',
                    width: 100,
                  ),
                ),
              ),
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
              ),
              Positioned(
                top: 40,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Text(
            "Enter OTP",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Enter the OTP sent to $maskedEmail",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return Container(
                width: 55,
                height: 55,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                child: TextField(
                  controller: authController.otpControllers[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: const TextStyle(fontSize: 18),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && index < 3) {
                      FocusScope.of(context).nextFocus();
                    } else if (value.isEmpty && index > 0) {
                      FocusScope.of(context).previousFocus();
                    }
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              authController.resendOtp();
            },
            child: const Text(
              "Resend OTP",
              style: TextStyle(color: Colors.blue, fontSize: 13),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: SizedBox(
              width: double.infinity,
              height: 45,
              child: Obx(
                () => authController.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff1976D2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        onPressed: () {
                          authController.verifyOtp();
                        },
                        child: const Text(
                          "Confirm OTP",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
