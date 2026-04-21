import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:kathoram_app/models/user.dart';
import 'package:kathoram_app/features/widgets/user_tile.dart';

class CallHistoryScreen extends StatelessWidget {
  CallHistoryScreen({super.key});

  final List<User> callHistory = [
    User(
      name: "Isha Fathima",
      age: 25,
      language: "Malayali",
      image: "assets/images/girl1.png",
      isOnline: true,
      ratePerSec: 5,
      callDate: "10 Feb | 12:55 PM",
      callDuration: "01:00:98",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Color(0xFFF2F2F2),
        body: SafeArea(
          child: Column(
            children: [
              // ── HEADER ──
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Call History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              // ── LIST ──
              Expanded(
                child: callHistory.isEmpty
                    ? const Center(child: Text('No call history'))
                    : ListView.builder(
                        itemCount: callHistory.length,
                        itemBuilder: (context, index) =>
                            UserTile(user: callHistory[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
