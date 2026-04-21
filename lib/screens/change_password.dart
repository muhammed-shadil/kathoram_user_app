import 'package:flutter/material.dart';
import 'package:kathoram_app/screens/bottom_nav_bar.dart';


class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  Widget textField(String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: Colors.blue.shade200),
          ),
        ),
      ),
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
          const Text("Change Password",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          textField("New Password"),
          textField("Confirm New Password"),
          const SizedBox(height: 20),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BottomNavBar(),
                    ),
                  );
                },
                child:
                    const Text("Save", style: TextStyle(color: Colors.white)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
