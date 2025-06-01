import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final double? elevation;
  final IconData? icon;
  final Color? iconColor;
  final bool loading;
  final bool fullWidth;
  final bool outlined;
  final Widget? customChild;
  final String? semanticsLabel;

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
    this.iconColor,
    this.loading = false,
    this.fullWidth = false,
    this.outlined = false,
    this.customChild,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || loading;
    final Color effectiveColor =
        outlined ? Colors.transparent : (color ?? Colors.white);
    final Color effectiveTextColor =
        textColor ?? (outlined ? (color ?? Colors.teal) : Colors.black);
    final Color effectiveIconColor = iconColor ?? effectiveTextColor;
    final double effectiveWidth = fullWidth ? double.infinity : (width ?? 200);
    final double effectiveHeight = height ?? 50;
    final double effectiveRadius = borderRadius ?? 25;

    final ButtonStyle style = ElevatedButton.styleFrom(
      backgroundColor: effectiveColor,
      foregroundColor: effectiveTextColor,
      minimumSize: Size(effectiveWidth, effectiveHeight),
      elevation: elevation ?? 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(effectiveRadius),
        side:
            outlined
                ? BorderSide(color: color ?? Colors.teal, width: 2)
                : BorderSide.none,
      ),
      disabledBackgroundColor: (color ?? Colors.white).withOpacity(0.7),
      disabledForegroundColor: (textColor ?? Colors.black).withOpacity(0.5),
    ).copyWith(
      overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
        if (states.contains(MaterialState.pressed)) {
          return (color ?? Colors.teal).withOpacity(0.15);
        }
        if (states.contains(MaterialState.hovered)) {
          return (color ?? Colors.teal).withOpacity(0.08);
        }
        if (states.contains(MaterialState.focused)) {
          return (color ?? Colors.teal).withOpacity(0.12);
        }
        return null;
      }),
    );

    Widget child =
        customChild ??
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 24, color: effectiveIconColor),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      isDisabled
                          ? (effectiveTextColor).withOpacity(0.5)
                          : effectiveTextColor,
                ),
              ),
            ),
          ],
        );

    if (loading) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: (effectiveTextColor).withOpacity(0.7),
              ),
            ),
          ),
        ],
      );
    }

    return Semantics(
      button: true,
      label: semanticsLabel ?? text,
      enabled: !isDisabled,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: style,
        child: child,
      ),
    );
  }
}
