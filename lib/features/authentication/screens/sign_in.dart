import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../utils/support_helper.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_outline_button.dart';
import '../../widgets/cutom_textfield.dart';
import '../../widgets/meta_ads_debug_panel.dart';
import '../controller/auth_controller.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});

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
        floatingActionButton: const SupportFab(
          message: 'Hi, I need help logging in to the Kathoram app',
          iconColor: Colors.blue,
          backgroundColor: Colors.white,
          size: 25,
          mini: true,
        ),
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
              ],
            ),

            /// Form Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// Google Button
                      Obx(
                        () => authController.isGoogleLoading.value
                            ? const SizedBox(
                                height: 50,
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )
                            : GestureDetector(
                                onTap: () {
                                  authController.googleSignIn();
                                },
                                child: Container(
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
                              ),
                      ),

                      const SizedBox(height: 10),
                      const Text("Or"),

                      CustomTextField(
                        labelText: "Phone Number",
                        hint: "+91 ",
                        controller: authController.loginMobileController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        hint: "Password",
                        labelText: "Password",
                        controller: authController.loginPasswordController,
                        isPassword: true,
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {
                            Get.toNamed('/forgotpassword');
                          },
                          child: const Text(
                            "Forgot password?",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text("Or"),
                      const SizedBox(height: 15),

                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF048EF2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                          // border: Border.all(color: Colors.blue),
                        ),
                        child: CustomOutlineButton(
                          text: "Continue As Guest",
                          onTap: () {
                            Get.offNamed('/guestSignup');
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// Create Account link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          InkWell(
                            onTap: () {
                              Get.toNamed('/sign-up');
                            },
                            child: const Text(
                              "Create Account",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// Sign In Button with loading
                      Obx(
                        () => authController.isLoading.value
                            ? const Center(child: CircularProgressIndicator())
                            : CustomButton(
                                text: 'Sign In',
                                onPressed: () {
                                  authController.login();
                                },
                                isReversed: false,
                              ),
                      ),

                      /// Meta Ads event tester. Renders nothing in release
                      /// builds — see MetaAdsDebugPanel.
                      const MetaAdsDebugPanel(),

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
