import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../authentication/controller/auth_controller.dart';
import '../widgets/cutom_textfield.dart';

class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({super.key}) {
    // Prefill the form with the current profile values whenever the screen
    // is constructed so the user can see/edit existing data.
    Get.find<AuthController>().prefillEditProfileFields();
  }

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

            /// Form Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        "Edit Profile",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),

                      CustomTextField(
                        labelText: "Name",
                        hint: "Enter your name",
                        controller: authController.editNameController,
                      ),
                      CustomTextField(
                        labelText: "Email",
                        hint: "Enter your email",
                        controller: authController.editEmailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      CustomTextField(
                        labelText: "Phone",
                        hint: "+91 0000000000",
                        controller: authController.editMobileController,
                        keyboardType: TextInputType.phone,
                      ),
                      CustomTextField(
                        hint: "Leave blank to keep current",
                        labelText: "New Password (optional)",
                        controller: authController.editPasswordController,
                        isPassword: true,
                      ),
                      CustomTextField(
                        hint: "Confirm new password",
                        labelText: "Confirm Password",
                        controller:
                            authController.editConfirmPasswordController,
                        isPassword: true,
                      ),

                      const SizedBox(height: 20),

                      /// Save Button with loading
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
                                    authController.editProfile();
                                  },
                                  child: const Text(
                                    "Save Changes",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
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
