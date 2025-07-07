import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_theme.dart';

class BaseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final bool withShadow;
  final bool withBorder;

  const BaseCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
    this.withShadow = true,
    this.withBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final defaultBorderRadius = BorderRadius.circular(15.r);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            (isDarkMode ? AppTheme.cardDark : AppTheme.cardLight),
        borderRadius: borderRadius ?? defaultBorderRadius,
        border:
            withBorder
                ? Border.all(
                  color:
                      isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                  width: 1,
                )
                : null,
        boxShadow:
            withShadow
                ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                    blurRadius: (elevation ?? 2) * 4,
                    offset: const Offset(0, 2),
                    spreadRadius: (elevation ?? 1) * 0.5,
                  ),
                ]
                : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? defaultBorderRadius,
          splashColor:
              onTap != null
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : Colors.transparent,
          highlightColor:
              onTap != null
                  ? Theme.of(context).primaryColor.withOpacity(0.05)
                  : Colors.transparent,
          child: Padding(
            padding: padding ?? EdgeInsets.all(16.r),
            child: child,
          ),
        ),
      ),
    );
  }
}
