import 'package:flutter/material.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1E88E5),
              Color(0xFF1976D2),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Section
              Column(
                children: [
                  const SizedBox(height: 20),

                  // Name
                  const Text(
                    "Isha",
                    style: TextStyle(
                      letterSpacing: 1.2,
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Profile Image with circle border
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white54, width: 2),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white30, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage("assets/images/girl1.png"),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Timer
                  const Text(
                    "10:00:00",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              // Bottom Card
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Coin Balance
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Coin Balance: ",
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                         Image.asset('assets/images/coin.png', height: 20),
                          const SizedBox(width: 5),
                          const Text(
                            "100",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _circleButton('assets/images/volumeup_icon.png'),
                          _callButton(),
                          _circleButton('assets/images/mute_icon.png'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Small circle buttons
  static Widget _circleButton(String imagePath) {
    return Container(
      height: 55,
      width: 55,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white54),
      ),
      child: Center(child: Image.asset(imagePath, height: 24,
      fit: BoxFit.contain,)),
    );
  }

  // Red call button
  static Widget _callButton() {
    return Image.asset('assets/images/call_red.png', height: 50);
  }
}
