import 'package:flutter/material.dart';
import 'package:kathoram_app/screens/bottom_nav_screens/add_coin_screen.dart';
import 'package:kathoram_app/screens/bottom_nav_screens/call_historyscreen.dart';
import 'package:kathoram_app/screens/bottom_nav_screens/chat_home_screen.dart';
import 'package:kathoram_app/screens/bottom_nav_screens/profile_screen.dart';
   // create this file with dummy widget

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    ChatHomeScreen(),
     CallHistoryScreen(),
  AddCoinsScreen(),
   ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(      // keeps state of each screen
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: const Color.fromARGB(255, 54, 49, 49),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: "Calls"),
          BottomNavigationBarItem(icon: Icon(Icons.save), label: "Add Coins"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}