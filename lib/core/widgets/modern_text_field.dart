import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_theme.dart';

class ModernTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final String? hintText;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final bool readOnly;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Color? fillColor;
  final String? helperText;
  final bool withAnimation;

  const ModernTextField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.obscureText = false,
    this.textInputAction,
    this.onTap,
    this.focusNode,
    this.hintText,
    this.inputFormatters,
    this.autofocus = false,
    this.readOnly = false,
    this.onEditingComplete,
    this.onChanged,
    this.onSubmitted,
    this.fillColor,
    this.helperText,
    this.withAnimation = true,
  });

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _focusNode.removeListener(_handleFocusChange);
    _animationController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _animationController.forward();
      setState(() {
        _isFocused = true;
      });
    } else {
      _animationController.reverse();
      setState(() {
        _isFocused = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    // Generate border styles
    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(
        color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
        width: 1.5,
      ),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(
        color: isDarkMode ? AppTheme.accent : AppTheme.primary,
        width: 2,
      ),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: AppTheme.error, width: 1.5),
    );

    // Base TextField
    final textField = TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: widget.obscureText,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      validator: widget.validator,
      inputFormatters: widget.inputFormatters,
      onTap: widget.onTap,
      onEditingComplete: widget.onEditingComplete,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      style: TextStyle(
        fontSize: 16.sp,
        fontFamily: 'Cairo',
        color: isDarkMode ? AppTheme.textLight : AppTheme.textMain,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        helperText: widget.helperText,
        prefixIcon:
            widget.prefixIcon != null
                ? Icon(
                  widget.prefixIcon,
                  color:
                      _isFocused
                          ? (isDarkMode ? AppTheme.accent : AppTheme.primary)
                          : theme.hintColor,
                )
                : null,
        suffixIcon: widget.suffixIcon,
        filled: true,
        fillColor:
            widget.fillColor ??
            (isDarkMode ? AppTheme.cardDark : AppTheme.cardLight),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: widget.maxLines > 1 ? 16.h : 0,
        ),
        border: defaultBorder,
        enabledBorder: defaultBorder,
        focusedBorder: focusedBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
        labelStyle: TextStyle(
          color:
              _isFocused
                  ? (isDarkMode ? AppTheme.accent : AppTheme.primary)
                  : theme.hintColor,
          fontFamily: 'Cairo',
          fontSize: 14.sp,
        ),
        hintStyle: TextStyle(
          color: theme.hintColor,
          fontFamily: 'Cairo',
          fontSize: 14.sp,
        ),
        errorStyle: TextStyle(
          color: AppTheme.error,
          fontFamily: 'Cairo',
          fontSize: 12.sp,
        ),
        helperStyle: TextStyle(
          color: theme.hintColor,
          fontFamily: 'Cairo',
          fontSize: 12.sp,
        ),
      ),
    );

    // Apply animation if enabled
    if (widget.withAnimation) {
      return ScaleTransition(scale: _scaleAnimation, child: textField);
    }

    return textField;
  }
}
