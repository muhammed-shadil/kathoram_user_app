import 'package:flutter/material.dart';
import 'package:kathoram_app/widgets/cutom_textfield.dart';

class GuestSignUpScreen extends StatefulWidget {
  const GuestSignUpScreen({super.key});

  @override
  State<GuestSignUpScreen> createState() => _GuestSignUpScreenState();
}

class _GuestSignUpScreenState extends State<GuestSignUpScreen> {
    final nameController = TextEditingController();
  final phoneController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(
      children: [
        Stack(children: [
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
                angle: 2,
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
        ]),

        
        //form
        Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8,),
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


                  ])))),
                    const SizedBox(height: 10),

                     Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            "Continue",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),


                        ),
                      ),

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


      ],
    )));
  }
}
