import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallScreen extends StatefulWidget {
  final String name;
  final String image;
  final int coins;

  const CallScreen({
    super.key,
    required this.name,
    required this.image,
    required this.coins,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool isMuted = false;
  bool isSpeakerOn = false;

  int seconds = 0;
  Timer? timer;

  int coinBalance = 0;

  @override
  void initState() {
    super.initState();
    coinBalance = widget.coins;
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        seconds++;

        // Example: 1 coin per second
        if (coinBalance > 0) {
          coinBalance--;
        } else {
          endCall();
        }
      });
    });
  }

  void endCall() {
    timer?.cancel();
    Get.back();
  }

  String formatTime(int totalSeconds) {
    int hrs = totalSeconds ~/ 3600;
    int mins = (totalSeconds % 3600) ~/ 60;
    int secs = totalSeconds % 60;

    return "${hrs.toString().padLeft(2, '0')}:"
        "${mins.toString().padLeft(2, '0')}:"
        "${secs.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E88E5), Color(0xFF1976D2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// TOP
              Column(
                children: [
                  const SizedBox(height: 20),

                  Text(
                    widget.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// PROFILE IMAGE
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
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage(widget.image),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// TIMER
                  Text(
                    formatTime(seconds),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              /// BOTTOM CARD
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
                      /// COIN BALANCE
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Coin Balance: ",
                            style: TextStyle(color: Colors.white70),
                          ),
                          Image.asset('assets/images/coin.png', height: 20),
                          const SizedBox(width: 5),
                          Text(
                            "$coinBalance",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// BUTTONS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          /// SPEAKER
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isSpeakerOn = !isSpeakerOn;
                              });
                            },
                            child: circleButton(
                              'assets/images/volumeup_icon.png',
                              isSpeakerOn,
                            ),
                          ),

                          /// END CALL
                          GestureDetector(
                            onTap: endCall,
                            child: Image.asset(
                              'assets/images/call_red.png',
                              height: 55,
                            ),
                          ),

                          /// MUTE
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isMuted = !isMuted;
                              });
                            },
                            child: circleButton(
                              'assets/images/mute_icon.png',
                              isMuted,
                            ),
                          ),
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

  /// BUTTON UI
  Widget circleButton(String imagePath, bool active) {
    return Container(
      height: 55,
      width: 55,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? Colors.white : Colors.transparent,
        border: Border.all(color: Colors.white54),
      ),
      child: Center(
        child: Image.asset(
          imagePath,
          height: 24,
          color: active ? Colors.blue : Colors.white,
        ),
      ),
    );
  }
}
