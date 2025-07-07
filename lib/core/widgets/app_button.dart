import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_theme.dart';

enum ButtonSize { small, medium, large }

enum ButtonType { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final ButtonSize size;
  final ButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.size = ButtonSize.medium,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Determine size
    final buttonSize = _getButtonSize();

    // Colors based on button type
    final (backgroundColor, textColor, borderColor) = _getButtonColors(
      context,
      isDarkMode,
    );

    // Create the button
    Widget button = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: buttonSize.height,
      width: isFullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(buttonSize.radius),
        border:
            type == ButtonType.outline || type == ButtonType.text
                ? Border.all(color: borderColor)
                : null,
        boxShadow:
            type != ButtonType.outline && type != ButtonType.text && !isLoading
                ? [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                    spreadRadius: -2,
                  ),
                ]
                : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(buttonSize.radius),
          splashColor: textColor.withOpacity(0.1),
          highlightColor: textColor.withOpacity(0.05),
          child: Padding(
            padding: padding ?? buttonSize.padding,
            child: Center(
              child:
                  isLoading
                      ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(textColor),
                          strokeWidth: 2.5,
                        ),
                      )
                      : Row(
                        mainAxisSize:
                            isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (icon != null) ...[
                            Icon(
                              icon,
                              color: textColor,
                              size: buttonSize.iconSize,
                            ),
                            SizedBox(width: 8.w),
                          ],
                          Text(
                            text,
                            style: TextStyle(
                              color: textColor,
                              fontSize: buttonSize.fontSize,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ),
      ),
    );

    return button;
  }

  ({
    double height,
    double radius,
    EdgeInsetsGeometry padding,
    double fontSize,
    double iconSize,
  })
  _getButtonSize() {
    switch (size) {
      case ButtonSize.small:
        return (
          height: 36.h,
          radius: 8.r,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          fontSize: 12.sp,
          iconSize: 16.sp,
        );
      case ButtonSize.large:
        return (
          height: 56.h,
          radius: 12.r,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          fontSize: 16.sp,
          iconSize: 20.sp,
        );
      case ButtonSize.medium:
      default:
        return (
          height: 48.h,
          radius: 10.r,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          fontSize: 14.sp,
          iconSize: 18.sp,
        );
    }
  }

  (Color backgroundColor, Color textColor, Color borderColor) _getButtonColors(
    BuildContext context,
    bool isDarkMode,
  ) {
    switch (type) {
      case ButtonType.secondary:
        return (
          isDarkMode
              ? AppTheme.secondary.withOpacity(0.2)
              : AppTheme.secondary.withOpacity(0.15),
          isDarkMode ? AppTheme.secondary : AppTheme.secondary,
          Colors.transparent,
        );
      case ButtonType.outline:
        return (
          Colors.transparent,
          isDarkMode ? AppTheme.accent : AppTheme.primary,
          isDarkMode ? AppTheme.accent : AppTheme.primary,
        );
      case ButtonType.text:
        return (
          Colors.transparent,
          isDarkMode ? AppTheme.accent : AppTheme.primary,
          Colors.transparent,
        );
      case ButtonType.primary:
        return (
          isDarkMode ? AppTheme.accent : AppTheme.primary,
          AppTheme.textLight,
          Colors.transparent,
        );
    }
  }
}
