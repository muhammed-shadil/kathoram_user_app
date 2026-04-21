import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/route_path.dart';

class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key});

  Widget otpBox(String text) {
    return Container(
      width: 55,
      height: 55,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(text, style: const TextStyle(fontSize: 18)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      body: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                "assets/images/Rectangle2.png",
                width: double.infinity,
                fit: BoxFit.cover,
              ),

              //TOP left WAVES
              Positioned(
                  top: -20,
                  left: -20,
                  child: Transform.rotate(
                    angle: -1.8,
                    child: Image.asset(
                      'assets/images/ripples.png',
                      width: 100,
                    ),
                  )),
              Positioned(
                  bottom: -10,
                  right: -10,
                  child: Transform.rotate(
                    angle: 1.8,
                    child: Image.asset(
                      'assets/images/ripples.png',
                      width: 100,
                    ),
                  )),

              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset("assets/images/kathoram.png", width: 150),
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 30),
          const Text("Enter OTP",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue)),
          const SizedBox(height: 10),
          const Text("Enter the OTP sent to abcdefghi@gmail.com",
              style: TextStyle(fontSize: 12)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              otpBox("8"),
              const SizedBox(width: 10),
              otpBox("9"),
              const SizedBox(width: 10),
              otpBox("0"),
              const SizedBox(width: 10),
              otpBox("0"),
            ],
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1976D2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: () {
                  Get.toNamed(RoutePath.changePassword);
                },
                child: const Text(
                  "Confirm OTP",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget topHeader() {
    return Stack(
      children: [
        Container(
          height: 180,
          decoration: const BoxDecoration(
            color: Color(0xff1976D2),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
        ),
        const Positioned(
          top: 90,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Icon(Icons.mic, color: Colors.white, size: 30),
              SizedBox(height: 5),
              Text("Kathoram",
                  style: TextStyle(color: Colors.white, fontSize: 18))
            ],
          ),
        )
      ],
    );
  }
}
