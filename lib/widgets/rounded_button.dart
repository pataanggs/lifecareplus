import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/colors.dart';

class RoundedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool isLoading;
  final Widget? icon;
  final bool iconAfterText;
  final double? elevation;
  final TextStyle? textStyle;
  final Duration feedbackDuration;
  final bool enableFeedback;

  const RoundedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = AppColors.buttonColor,
    this.textColor = AppColors.buttonTextColor,
    this.width,
    this.height = 52,
    this.borderRadius = 26,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
    this.isLoading = false,
    this.icon,
    this.iconAfterText = false,
    this.elevation = 2,
    this.textStyle,
    this.feedbackDuration = const Duration(milliseconds: 50),
    this.enableFeedback = true,
  });

  @override
  State<RoundedButton> createState() => _RoundedButtonState();
}

class _RoundedButtonState extends State<RoundedButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.feedbackDuration,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isLoading) {
      setState(() => _isPressed = true);
      _animationController.forward();
      if (widget.enableFeedback) {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _resetButton();
  }

  void _handleTapCancel() {
    _resetButton();
  }

  void _resetButton() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final finalTextStyle = widget.textStyle ?? 
        TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.bold,
          color: widget.textColor,
        );

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: widget.elevation != null ? [
                // Distant soft shadow for depth
                BoxShadow(
                  color: widget.color.withOpacity(0.2),
                  blurRadius: _isPressed ? 10 : 15,
                  offset: _isPressed ? const Offset(0, 2) : const Offset(0, 8),
                  spreadRadius: _isPressed ? 0 : 1,
                ),
                // Mid-level shadow
                BoxShadow(
                  color: widget.color.withOpacity(0.3),
                  blurRadius: _isPressed ? 5 : 8,
                  offset: _isPressed ? const Offset(0, 1) : const Offset(0, 4),
                  spreadRadius: 0,
                ),
                // Close sharp shadow for definition
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: _isPressed ? 2 : 3,
                  offset: _isPressed ? const Offset(0, 1) : const Offset(0, 2),
                  spreadRadius: 0,
                ),
                // Subtle inner highlight at top for 3D effect
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                  spreadRadius: 0,
                ),
              ] : null,
            ),
            child: Material(
              color: widget.color,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              // Add subtle gradient for better depth perception
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      widget.color.withOpacity(1.0),
                      widget.color.withOpacity(0.9),
                    ],
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  onTapDown: _handleTapDown,
                  onTapUp: _handleTapUp,
                  onTapCancel: _handleTapCancel,
                  splashColor: widget.textColor.withOpacity(0.1),
                  highlightColor: widget.textColor.withOpacity(0.05),
                  onTap: widget.isLoading ? null : widget.onPressed,
                  child: Padding(
                    padding: widget.padding,
                    child: Center(
                      child: widget.isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(widget.textColor),
                              ),
                            )
                          : _buildButtonContent(finalTextStyle),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent(TextStyle textStyle) {
    if (widget.icon == null) {
      return Text(widget.text, style: textStyle);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.iconAfterText
          ? [
              Text(widget.text, style: textStyle),
              const SizedBox(width: 8),
              widget.icon!,
            ]
          : [
              widget.icon!,
              const SizedBox(width: 8),
              Text(widget.text, style: textStyle),
            ],
    );
  }
}