import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../widgets/cutom_textfield.dart';
import '../controller/auth_controller.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
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
                    angle: -1.4,
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
              ],
            ),

            /// Form Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// Google Button
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xFF048EF2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/google.png",
                              height: 20,
                              width: 20,
                            ),
                            const SizedBox(width: 5),
                            const Text("Continue With Google"),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),
                      const Text("Or"),

                      CustomTextField(
                        labelText: "Name",
                        hint: "Enter your name",
                        controller: authController.signupNameController,
                      ),
                      CustomTextField(
                        labelText: "Phone",
                        hint: "+91 0000000000",
                        controller: authController.signupMobileController,
                        keyboardType: TextInputType.phone,
                      ),
                      CustomTextField(
                        hint: "Password",
                        labelText: "Password",
                        controller: authController.signupPasswordController,
                        isPassword: true,
                      ),
                      CustomTextField(
                        hint: "Confirm Password",
                        labelText: "Confirm Password",
                        controller:
                            authController.signupConfirmPasswordController,
                        isPassword: true,
                      ),

                      /// Checkbox - Terms & Conditions
                      Obx(
                        () => Row(
                          children: [
                            Checkbox(
                              value: authController.isTermsAgreed.value,
                              onChanged: (val) {
                                authController.isTermsAgreed.value = val!;
                              },
                            ),
                            Expanded(
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black),
                                  children: [
                                    TextSpan(text: "Accept "),
                                    TextSpan(
                                      text: "Terms and Conditions ",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                    TextSpan(text: "and\n "),
                                    TextSpan(
                                      text: "Privacy Policy",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// Sign Up Button with loading
                      Obx(
                        () => authController.isLoading.value
                            ? const Center(child: CircularProgressIndicator())
                            : SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  onPressed: () {
                                    authController.signup();
                                  },
                                  child: const Text(
                                    "Sign Up",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                      ),

                      const SizedBox(height: 10),

                      /// Sign In Text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 14),
                              children: [
                                const TextSpan(text: "Already registered? "),
                                TextSpan(
                                  text: "Sign in",
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.offAllNamed('/sign-in');
                                    },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
