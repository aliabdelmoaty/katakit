import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_theme.dart';

class LoadingOverlay extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final Color? backgroundColor;
  final Color? progressColor;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.backgroundColor,
    this.progressColor,
  });

  static _LoadingOverlayState of(BuildContext context) {
    return context.findAncestorStateOfType<_LoadingOverlayState>()!;
  }

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isLoading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _isLoading = widget.isLoading;
    _message = widget.message;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    if (_isLoading) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(LoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      setState(() {
        _isLoading = widget.isLoading;
      });

      if (_isLoading) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }

    if (widget.message != oldWidget.message) {
      setState(() {
        _message = widget.message;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void show({String? message}) {
    setState(() {
      _isLoading = true;
      _message = message ?? _message;
    });
    _controller.forward();
  }

  void hide() {
    setState(() {
      _isLoading = false;
    });
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Visibility(
              visible: _animation.value > 0,
              child: Opacity(
                opacity: _animation.value,
                child: Stack(
                  children: [
                    // Backdrop
                    Positioned.fill(
                      child: Container(
                        color:
                            widget.backgroundColor ??
                            (isDarkMode
                                ? Colors.black.withOpacity(0.7)
                                : Colors.black.withOpacity(0.5)),
                      ),
                    ),

                    // Loading indicator
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 24.h,
                            horizontal: 32.w,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isDarkMode
                                    ? AppTheme.cardDark
                                    : AppTheme.cardLight,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 48.w,
                                height: 48.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    widget.progressColor ??
                                        (isDarkMode
                                            ? AppTheme.accent
                                            : AppTheme.primary),
                                  ),
                                ),
                              ),
                              if (_message != null) ...[
                                SizedBox(height: 16.h),
                                Text(
                                  _message!,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        isDarkMode
                                            ? AppTheme.textLight
                                            : AppTheme.textMain,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// Extension method for showing loading overlay
extension LoadingOverlayExtension on BuildContext {
  void showLoading({String? message}) {
    LoadingOverlay.of(this).show(message: message);
  }

  void hideLoading() {
    LoadingOverlay.of(this).hide();
  }
}
