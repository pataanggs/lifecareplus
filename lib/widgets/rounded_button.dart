import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final double? elevation;
  final IconData? icon;

  const RoundedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius,
    this.elevation,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.white,
        foregroundColor: textColor ?? Colors.black,
        minimumSize: Size(width ?? 200, height ?? 50),
        elevation: elevation ?? 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon, size: 24), const SizedBox(width: 8)],
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
