import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:kathoram_app/widgets/cutom_textfield.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    angle: -1.4,
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
      
              Positioned(
                top:3,
                left:1,
                child: Image.asset(
                  "assets/images/back.png", 
                  width: 120,
                ),
              ),
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "Create Account",
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
                      labelText: "Name",
                      hint: "Enter your name",
                      controller: nameController,
                    ),
                    CustomTextField(
                      labelText: "Phone",
                      hint: "+91 0000000000",
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    CustomTextField(
                      hint: "Password",
                      labelText: "********************",
                      controller: passwordController,
                      isPassword: true,
                    ),
                    CustomTextField(
                      hint: "Confirm Password",
                      labelText: "Confirm Password",
                      controller: confirmPasswordController,
                      isPassword: true,
                    ),
      
                    /// Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: isChecked,
                          onChanged: (val) {
                            setState(() {
                              isChecked = val!;
                            });
                          },
                        ),
                        Expanded(
                            child: RichText(
                          text: TextSpan(
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black),
                              children: [
                                TextSpan(text: "Accept "),
                                TextSpan(
                                    text: "Terms and Conditions ",
                                    style: TextStyle(color: Colors.blue)),
                                TextSpan(text: "and\n "),
                                TextSpan(
                                    text: "Privacy Policy",
                                    style: TextStyle(color: Colors.blue)),
                              ]),
                        )),
                      ],
                    ),
      
                    const SizedBox(height: 10),
      
                    /// Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/bottomnav');
                        },
                        child: const Text("Sign Up"),
                      ),
                    ),
      
                    const SizedBox(height: 10),
      
                    /// Sign In Text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            style:
                                TextStyle(color: Colors.black, fontSize: 14),
                            children: [
                              TextSpan(text: "Already registered? "),
                              TextSpan(
                                text: "Sign in",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(context, '/sign in');
                                  },
                              ),
                            ],
                          ),
                        ),
      
                        
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
