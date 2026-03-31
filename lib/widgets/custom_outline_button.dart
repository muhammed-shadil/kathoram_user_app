import 'package:flutter/material.dart';

class CustomOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final String? iconPath;

  const CustomOutlineButton({
    super.key,
    required this.text,
    required this.onTap,
    this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.blue),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconPath != null) ...[
              Image.asset(iconPath!, height: 20),
              const SizedBox(width: 10),
            ],
            Text(text),
          ],
        ),
      ),
    );
  }
}
