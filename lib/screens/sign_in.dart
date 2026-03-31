import 'package:flutter/material.dart';
import 'package:kathoram_app/widgets/custom_button.dart';
import 'package:kathoram_app/widgets/custom_outline_button.dart';
import 'package:kathoram_app/widgets/cutom_textfield.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            /// Top Image Section (your rectangle + ripple)
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

            /// Form Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// Google Button
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/google.png",
                              height: 20,
                              width: 20,
                            ),
                            SizedBox(width: 5),
                            Text("Continue With Google"),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),
                      const Text("Or"),

                      CustomTextField(
                        labelText: "Phone Number",
                        hint: "+91 0000000000",
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 12),
                      CustomTextField(
                        hint: "Password",
                        labelText: "Password",
                        controller: passwordController,
                        isPassword: true,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {},
                          child: const Text(
                            "Forgot password?",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      const Text("Or"),

                      const SizedBox(height: 15),

                      // Container(
                      //   height: 50,
                      //   width: double.infinity,
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(30),
                      //     border: Border.all(color: Colors.blue),
                      //   ),
                      //   child: const Center(
                      //     child: Text("Continue As Guest"),
                      //   ),
                      // ),
                      CustomOutlineButton(
                        text: "Continue As Guest",
                        onTap: () {
                          Navigator.pushReplacementNamed(
                              context, '/guestSignup');
                        },
                      ),

                      const SizedBox(height: 20),

                      /// 🔗 CREATE ACCOUNT
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          InkWell(
                            onTap: () {},
                            child: const Text(
                              "Create Account",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                     
                     CustomButton(text: 'Sign In', onPressed: () {Navigator.pushNamed(context, '/bottomnav');},
                      isReversed: false),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
