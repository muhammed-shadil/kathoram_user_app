import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kathoram_user_app/features/authentication/controller/auth_controller.dart';
import 'package:kathoram_user_app/features/home/controller/home_controller.dart';
import 'package:kathoram_user_app/features/screens/bottom_nav_screens/add_coin_screen.dart';
import 'package:kathoram_user_app/features/screens/bottom_nav_screens/call_historyscreen.dart';
import 'package:kathoram_user_app/features/screens/bottom_nav_screens/chat_home_screen.dart';
import 'package:kathoram_user_app/features/screens/bottom_nav_screens/profile_screen.dart';

class BottomNavBar extends StatefulWidget {
  final int initialIndex;
  const BottomNavBar({super.key, this.initialIndex = 0});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _selectedIndex;

  final List<Widget> _screens = [
    const ChatHomeScreen(),
    const CallHistoryScreen(),
    const AddCoinsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    _selectedIndex = widget.initialIndex;
    super.initState();
  }

  /// Refresh the data for the tab the user just switched to.
  /// IndexedStack keeps each screen alive, so their initState only fires once
  /// at startup — without this, switching tabs shows stale data.
  void _refreshTabData(int index) {
    HomeController? home;
    AuthController? auth;
    try {
      home = Get.find<HomeController>();
    } catch (e) {
      log('[BottomNav] HomeController not found: $e');
    }
    try {
      auth = Get.find<AuthController>();
    } catch (e) {
      log('[BottomNav] AuthController not found: $e');
    }

    log('[BottomNav] Tab switched to $index — refreshing data');

    // Always re-validate the session on every tab switch so an admin block
    // (is-login → 423) takes effect promptly without needing an app restart.
    auth?.checkIsLogin();

    switch (index) {
      case 0: // Home — staff list
        home?.fetchStaffList();
        break;
      case 1: // Calls — call history
        home?.fetchCallHistory();
        break;
      case 2: // Add Coins — plans + user balance
        home?.fetchPlans();
        break;
      case 3: // Profile — user data
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      /// PROFESSIONAL BOTTOM NAV BAR
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            final changed = index != _selectedIndex;
            setState(() {
              _selectedIndex = index;
            });
            if (changed) {
              _refreshTabData(index);
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 26),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.call, size: 26),
              label: "Calls",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet, size: 26),
              label: "Add Coins",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 26),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
