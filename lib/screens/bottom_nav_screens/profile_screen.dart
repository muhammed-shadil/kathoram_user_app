import 'package:flutter/material.dart';

// lib/profile_screen.dart


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Blue Header + Avatar overlap ──
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // Blue background
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E88E5),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: const Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          'Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // White curved area at bottom of blue
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(30)),
                    ),
                  ),
                ),

                // Avatar overlapping blue/white boundary
                Positioned(
                  bottom: -44,
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Center(
                      child: Text(
                        'J',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 56), // space for avatar overlap

            // ── Name & Phone ──
            const Text(
              'Jhon',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '+91 5678 765 884',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 24),

            // ── Menu Items ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _MenuItem(
                    icon: Icons.shield_outlined,
                    iconColor: const Color(0xFF1E88E5),
                    title: 'Privacy Policy',
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  _MenuItem(
                    icon: Icons.description_outlined,
                    iconColor: const Color(0xFF1E88E5),
                    title: 'Terms and Conditions',
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  _MenuItem(
                    icon: Icons.headset_mic_outlined,
                    iconColor: const Color(0xFF1E88E5),
                    title: 'Support',
                    onTap: () {},
                  ),

                  const SizedBox(height: 20),

                  // ── Delete Account ──
                  _OutlineButton(
                    label: 'Delete Account',
                    textColor: Colors.red.shade400,
                    borderColor: Colors.red.shade300,
                    onTap: () {},
                  ),

                  const SizedBox(height: 12),

                  // ── Logout ──
                  _OutlineButton(
                    label: 'Logout',
                    textColor: const Color(0xFF1E88E5),
                    borderColor: const Color(0xFF1E88E5),
                    onTap: () {},
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Menu Item ─────────────────────────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// ── Outline Button ────────────────────────────────────────────────────────────

class _OutlineButton extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _OutlineButton({
    required this.label,
    required this.textColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}