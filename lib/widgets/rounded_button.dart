import 'package:flutter/material.dart';
import '../utils/colors.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? bgColor; // ✅ opsional

  const RoundedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.bgColor, required Color color, required Color textColor, // ✅ default optional
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor ?? AppColors.buttonColor, // ✅ gunakan warna yg dipilih, atau default
        foregroundColor: AppColors.buttonTextColor,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
