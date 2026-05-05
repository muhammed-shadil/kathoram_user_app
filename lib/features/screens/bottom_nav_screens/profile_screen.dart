import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../routes/route_path.dart';
import '../../authentication/controller/auth_controller.dart';
import '../../widgets/shimmer_loaders.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // ─── URLs ───
  static const String _privacyPolicyUrl = 'https://kathoram.com/privacy-policy';
  static const String _termsUrl = 'https://kathoram.com/terms-and-conditions';
  static const String _supportNumber = '919876543210'; // WhatsApp number with country code

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse('https://wa.me/$_supportNumber?text=Hi, I need help with Kathoram app');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

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

            if (profile == null) {
              return const ProfileShimmer();
            }

            final name = profile.name.isNotEmpty ? profile.name : "User";
            final mobile = profile.mobileNumber;
            final profileImage = profile.profileImage;
            final initial = name[0].toUpperCase();

            return RefreshIndicator(
              onRefresh: () => authController.checkIsLogin().then((_) {}),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
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

                  /// PROFILE IMAGE (with edit overlay)
                  Center(
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Stack(
                        children: [
                          Center(
                            child: profileImage.isNotEmpty
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
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () =>
                                  Get.toNamed(RoutePath.editProfile),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.blue, width: 1.5),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Center(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Center(
                    child: Text(
                      mobile.isNotEmpty ? "+91 $mobile" : "",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// MENU BUTTONS
                  menuButton(Icons.privacy_tip, "Privacy Policy", onTap: () {
                    _launchUrl(_privacyPolicyUrl);
                  }),
                  menuButton(Icons.description, "Terms and Conditions", onTap: () {
                    _launchUrl(_termsUrl);
                  }),
                  menuButton(Icons.support_agent, "Support", onTap: () {
                    _openWhatsApp();
                  }),

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

                  const SizedBox(height: 20),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// MENU BUTTON
  Widget menuButton(IconData icon, String text, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
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
