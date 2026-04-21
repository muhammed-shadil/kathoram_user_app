import 'package:flutter/material.dart';
import 'package:kathoram_app/features/screens/bottom_nav_screens/add_coin_screen.dart';
import 'package:kathoram_app/features/screens/bottom_nav_screens/call_historyscreen.dart';
import 'package:kathoram_app/features/screens/bottom_nav_screens/chat_home_screen.dart';
import 'package:kathoram_app/features/screens/bottom_nav_screens/profile_screen.dart';

class BottomNavBar extends StatefulWidget {
  final int initialIndex;
  const BottomNavBar({super.key, this.initialIndex = 0});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
 late  int _selectedIndex;

  final List<Widget> _screens = [
    const ChatHomeScreen(),
    CallHistoryScreen(),
    const AddCoinsScreen(),
    const ProfileScreen(),
  ];
    @override
  void initState() {
    _selectedIndex = widget.initialIndex;
    super.initState();
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
            setState(() {
              _selectedIndex = index;
            });
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
