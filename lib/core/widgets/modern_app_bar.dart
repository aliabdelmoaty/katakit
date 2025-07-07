import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_theme.dart';

class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final Color? textColor;
  final bool automaticallyImplyLeading;
  final double? elevation;
  final VoidCallback? onBackPressed;

  const ModernAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.leading,
    this.bottom,
    this.backgroundColor,
    this.textColor,
    this.automaticallyImplyLeading = true,
    this.elevation,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
          color:
              textColor ??
              (isDarkMode ? AppTheme.textLight : AppTheme.textLight),
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor:
          backgroundColor ??
          (isDarkMode ? AppTheme.cardDark : AppTheme.primary),
      elevation: elevation ?? 0,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading:
          leading ??
          (automaticallyImplyLeading && Navigator.of(context).canPop()
              ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                color:
                    textColor ??
                    (isDarkMode ? AppTheme.textLight : AppTheme.textLight),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              )
              : null),
      actions: actions,
      bottom: bottom,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.r)),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              backgroundColor ??
                  (isDarkMode ? AppTheme.cardDark : AppTheme.primary),
              backgroundColor != null
                  ? backgroundColor!.withOpacity(0.8)
                  : (isDarkMode
                      ? AppTheme.cardDark.withOpacity(0.85)
                      : AppTheme.primary.withOpacity(0.85)),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.r)),
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}
