import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kathoram_user_app/features/widgets/cutom_textfield.dart';

import '../../routes/route_path.dart';
import '../authentication/controller/auth_controller.dart';

class GuestSignUpScreen extends StatelessWidget {
  GuestSignUpScreen({super.key});

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
        body: Column(
          children: [
            Stack(children: [
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
                    angle: -1.4,
                    child: Image.asset(
                      'assets/images/ripples.png',
                      width: 100,
                    ),
                  )),
              Positioned(
                  bottom: -10,
                  right: -10,
                  child: Transform.rotate(
                    angle: 2,
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
            ]),

            //form
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                        child: Column(children: [
                      const SizedBox(height: 10),
                      const Text(
                        "Continue as Guest",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        labelText: "Name",
                        hint: "Enter your name",
                        controller: authController.guestNameController,
                      ),
                      CustomTextField(
                        labelText: "Phone",
                        hint: "+91 0000000000",
                        controller: authController.guestMobileController,
                        keyboardType: TextInputType.phone,
                      ),
                    ])))),
            const SizedBox(height: 10),

            /// Continue button (with loading state)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Obx(
                () => GestureDetector(
                  onTap: authController.isLoading.value
                      ? null
                      : () => authController.guestLogin(),
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: authController.isLoading.value
                          ? Colors.blue.withOpacity(0.5)
                          : Colors.blue,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: authController.isLoading.value
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Continue",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? "),
                InkWell(
                  onTap: () {
                    Get.offNamed(RoutePath.signIn);
                  },
                  child: const Text(
                    "Sign In",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
