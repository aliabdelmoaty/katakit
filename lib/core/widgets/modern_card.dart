import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_theme.dart';

class ModernCard extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? content;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final bool withAnimation;

  const ModernCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.content,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    this.padding,
    this.margin,
    this.borderRadius,
    this.withAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final card = Container(
      margin: margin ?? EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            (isDarkMode ? AppTheme.cardDark : AppTheme.cardLight),
        borderRadius: borderRadius ?? BorderRadius.circular(16.r),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
            blurRadius: (elevation ?? 2) * 2,
            offset: const Offset(0, 2),
            spreadRadius: (elevation ?? 1) * 0.5,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius ?? BorderRadius.circular(16.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(16.r),
          child: Padding(
            padding: padding ?? EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    if (leading != null) ...[leading!, SizedBox(width: 12.w)],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          title,
                          if (subtitle != null) ...[
                            SizedBox(height: 4.h),
                            subtitle!,
                          ],
                        ],
                      ),
                    ),
                    if (actions != null && actions!.isNotEmpty) ...[
                      Row(mainAxisSize: MainAxisSize.min, children: actions!),
                    ],
                  ],
                ),
                if (content != null) ...[SizedBox(height: 12.h), content!],
              ],
            ),
          ),
        ),
      ),
    );

    // Apply animation if enabled
    if (withAnimation) {
      return _AnimatedCard(child: card);
    }

    return card;
  }
}

class _AnimatedCard extends StatefulWidget {
  final Widget child;

  const _AnimatedCard({required this.child});

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
