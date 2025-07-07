import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/navigation_service.dart';

class AppUtils {
  static void setupSystemUIOverlayStyle({bool isDarkMode = false}) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDarkMode ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );
  }

  static void enableFullScreenMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    );
  }

  static void setPreferredOrientations(
    List<DeviceOrientation> orientations,
  ) async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  static NavigationService get navigation => NavigationService();
}

// Extension for showing SnackBar with improved UI
extension SnackBarExtension on BuildContext {
  void showSuccessSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(message, SnackBarType.success, duration: duration);
  }

  void showErrorSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(message, SnackBarType.error, duration: duration);
  }

  void showWarningSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(message, SnackBarType.warning, duration: duration);
  }

  void showInfoSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(message, SnackBarType.info, duration: duration);
  }

  void _showSnackBar(String message, SnackBarType type, {Duration? duration}) {
    final Color backgroundColor;
    final Color textColor;
    final IconData icon;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = Colors.green.shade800;
        textColor = Colors.white;
        icon = Icons.check_circle_outline;
        break;
      case SnackBarType.error:
        backgroundColor = Colors.red.shade800;
        textColor = Colors.white;
        icon = Icons.error_outline;
        break;
      case SnackBarType.warning:
        backgroundColor = Colors.amber.shade800;
        textColor = Colors.black87;
        icon = Icons.warning_amber_outlined;
        break;
      case SnackBarType.info:
        backgroundColor = Colors.blue.shade800;
        textColor = Colors.white;
        icon = Icons.info_outline;
        break;
    }

    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: duration ?? const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'إغلاق',
          textColor: textColor.withOpacity(0.8),
          onPressed: () {
            ScaffoldMessenger.of(this).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

enum SnackBarType { success, error, warning, info }
