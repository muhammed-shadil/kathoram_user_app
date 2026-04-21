import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kathoram_app/models/user.dart';
import 'package:kathoram_app/screens/bottom_nav_bar.dart';
import 'package:kathoram_app/widgets/user_tile.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<User> users = [
    User(
        name: "Isha Fathima",
        age: 25,
        language: "Malayali",
        image: "assets/images/girl1.png",
        isOnline: true,
        ratePerSec: 5),
    User(
        name: "Priya Kumar",
        age: 23,
        language: "Malayali",
        image: "assets/images/girl2.png",
        isOnline: true,
        ratePerSec: 5),
    User(
        name: "Julie James",
        age: 24,
        language: "Malayali",
        image: "assets/images/girl3.png",
        isOnCall: true,
        ratePerSec: 5),
    User(
        name: "Riya",
        age: 24,
        language: "Malayali",
        image: "assets/images/girl4.png",
        isOnline: true,
        ratePerSec: 5),
    User(
        name: "Geetha",
        age: 26,
        language: "Malayali",
        image: "assets/images/girl5.png",
        isOnline: true,
        ratePerSec: 5),
    User(
        name: "Diya Krishna",
        age: 22,
        language: "Malayali",
        image: "assets/images/girl6.png",
        isOnline: false,
        ratePerSec: 5),
  ];

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  Widget buildTabContent() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: users.length,
      itemBuilder: (context, index) {
        return UserTile(user: users[index]);
      },
    );
  }

  int selectedIndex = 0;

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
        backgroundColor: const Color(0xFFF2F2F2),
        body: Column(
          children: [
            /// BLUE HEADER
            /// BLUE HEADER
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.23,
              width: double.infinity,
              child: Stack(
                children: [
                  /// BLUE BACKGROUND WITH CURVE
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xff1976D2),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                  ),

                  /// APP NAME
                  Positioned(
                    top: 80,
                    left: 20,
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/kathoram.png",
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Kathoram",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// COINS
                  Positioned(
                    top: 60,
                    right: 20,
                    child: Row(
                      children: [
                        Image.asset("assets/images/coin.png", width: 26),
                        const SizedBox(width: 2),
                        const Text(
                          "100",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),
                  ),

                  /// ADD COINS BUTTON
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BottomNavBar(initialIndex: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, color: Colors.blue),
                      label: const Text(
                        "Add Coins",
                        style: TextStyle(color: Colors.blue),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    /// PROFESSIONAL SEGMENTED TAB
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6E6E6),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TabBar(
                          padding: EdgeInsets.zero,
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          indicatorPadding: const EdgeInsets.all(4),
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          tabs: const [
                            Tab(child: Center(child: Text("All"))),
                            Tab(child: Center(child: Text("New"))),
                            Tab(child: Center(child: Text("Popular"))),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),

                    /// USER LIST
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          buildTabContent(),
                          buildTabContent(),
                          buildTabContent(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),

        /// BOTTOM NAVIGATION
      ),
    );
  }
}
