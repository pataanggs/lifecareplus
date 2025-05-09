import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RoundedInput extends StatefulWidget {
  final String label;
  final String hint;
  final bool isPassword;
  final TextEditingController controller;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final int? maxLength;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final Function()? onEditingComplete;
  final Function(String)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  
  const RoundedInput({
    super.key,
    required this.label,
    required this.hint,
    this.isPassword = false,
    required this.controller,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.maxLength,
    this.autofocus = false,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.onEditingComplete,
    this.onSubmitted,
    this.inputFormatters,
  });

  @override
  State<RoundedInput> createState() => _RoundedInputState();
}

class _RoundedInputState extends State<RoundedInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = true;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _hasText = widget.controller.text.isNotEmpty;
    
    // Listen for text changes to update the _hasText state
    widget.controller.addListener(_handleTextChange);
  }
  
  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.removeListener(_handleFocusChange);
      _focusNode.dispose();
    }
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }
  
  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }
  
  void _handleTextChange() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with animation
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: hasError 
                ? Colors.red.shade300 
                : (_isFocused ? Colors.white : Colors.white.withOpacity(0.9)),
            fontWeight: _isFocused ? FontWeight.w700 : FontWeight.w600,
            fontSize: _isFocused ? 15 : 14,
          ),
          child: Text(widget.label),
        ),
        
        const SizedBox(height: 8),
        
        // Text field with animation
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (_isFocused)
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
            border: Border.all(
              color: hasError 
                  ? Colors.red.shade400 
                  : (_isFocused ? Colors.blue.shade300 : Colors.transparent),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Prefix icon if provided
              if (widget.prefixIcon != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: IconTheme(
                    data: IconThemeData(
                      color: _isFocused ? Colors.blue.shade400 : Colors.grey.shade600,
                      size: 20,
                    ),
                    child: widget.prefixIcon!,
                  ),
                ),
              
              // Text field
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.isPassword && _obscureText,
                  keyboardType: widget.keyboardType,
                  maxLength: widget.maxLength,
                  autofocus: widget.autofocus,
                  textInputAction: widget.textInputAction,
                  onChanged: widget.onChanged,
                  onEditingComplete: widget.onEditingComplete,
                  onSubmitted: widget.onSubmitted,
                  inputFormatters: widget.inputFormatters,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 15,
                    ),
                    filled: false,
                    counterText: "",
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: widget.prefixIcon != null ? 8 : 16, 
                      vertical: 14
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              
              // Password visibility toggle
              if (widget.isPassword)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _obscureText = !_obscureText);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                  ),
                )
              // Custom suffix icon if provided
              else if (widget.suffixIcon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconTheme(
                    data: IconThemeData(
                      color: _isFocused ? Colors.blue.shade400 : Colors.grey.shade600,
                      size: 20,
                    ),
                    child: widget.suffixIcon!,
                  ),
                )
                
              // Clear button when text is present  
              else if (_hasText)
                GestureDetector(
                  onTap: () {
                    widget.controller.clear();
                    HapticFeedback.selectionClick();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.clear,
                      color: Colors.grey.shade600,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ).animate(
          target: _isFocused ? 1 : 0,
        ).scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.01, 1.0),
          duration: 200.ms,
          curve: Curves.easeOutQuad,
        ),
        
        // Error message with animation
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                color: Colors.red.shade400,
                fontSize: 12,
              ),
            ),
          ).animate().fadeIn(duration: 200.ms).slideY(
            begin: 0.3, 
            end: 0,
            duration: 200.ms,
            curve: Curves.easeOut,
          ),
          
        if (!hasError)
          const SizedBox(height: 18),
      ],
    );
  }
}