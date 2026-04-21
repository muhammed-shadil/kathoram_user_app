import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../authentication/controller/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          /// TOP BLUE CURVE
          ClipPath(
            clipper: TopCurveClipper(),
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          /// PROFILE CONTENT
          Obx(() {
            final profile = authController.userProfile.value;
            final name = profile?.name ?? "User";
            final mobile = profile?.mobileNumber ?? "";
            final profileImage = profile?.profileImage ?? "";
            final initial = name.isNotEmpty ? name[0].toUpperCase() : "U";

            return Column(
              children: [
                const SizedBox(height: 60),

                /// TITLE
                const Center(
                  child: Text(
                    "Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 55),

                /// PROFILE IMAGE
                profileImage.isNotEmpty
                    ? CircleAvatar(
                        radius: 45,
                        backgroundImage: NetworkImage(profileImage),
                        backgroundColor: Colors.grey.shade300,
                      )
                    : CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.red,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                const SizedBox(height: 10),

                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  mobile.isNotEmpty ? "+91 $mobile" : "",
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                /// MENU BUTTONS
                menuButton(Icons.privacy_tip, "Privacy Policy"),
                menuButton(Icons.description, "Terms and Conditions"),
                menuButton(Icons.support_agent, "Support"),

                const SizedBox(height: 10),

                /// DELETE ACCOUNT
                redButton("Delete Account", onTap: () {
                  AuthController.showConfirmationDialog(
                    title: "Delete Account",
                    message:
                        "Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.",
                    confirmText: "Delete",
                    onConfirm: () {
                      authController.deleteAccount();
                    },
                  );
                }),

                const SizedBox(height: 10),

                /// LOGOUT
                redButton("Logout", onTap: () {
                  AuthController.showConfirmationDialog(
                    title: "Logout",
                    message:
                        "Are you sure you want to logout from your account?",
                    confirmText: "Logout",
                    onConfirm: () {
                      authController.logout();
                    },
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// MENU BUTTON
  Widget menuButton(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  /// RED BUTTON
  Widget redButton(String text, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(0, size.height - 80);

    path.cubicTo(
      size.width * 0.20, size.height, // left curve
      size.width * 0.80, size.height, // right curve
      size.width, size.height - 80, // end point
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
