import 'package:flutter/material.dart';
import 'package:kathoram_user_app/theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isReversed;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed, 
    required this.isReversed,
    
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isReversed ? Colors.white : AppColors.primary;

    final textColor =
        isReversed ? AppColors.primary : Colors.white;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        minimumSize: const Size(double.infinity, 50),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, 
              color: textColor)),
    );
  }
}
