import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  // ألوان هادئة ومريحة للعين - تعبر عن البيئة الريفية وتربية الكتاكيت

  // Backgrounds - خلفيات هادئة محسنة
  static const Color scaffoldLight = Color(0xFFFAF8F2); // كريمي فاتح محسن
  static const Color cardLight = Color(0xFFFFFFFF); // أبيض نقي
  static const Color scaffoldDark = Color(0xFF121212); // رمادي داكن هادئ محسن
  static const Color cardDark = Color(0xFF1E1E1E); // رمادي متوسط محسن

  // Primary + Accent - ألوان رئيسية محسنة تعبر عن الطبيعة
  static const Color primary = Color(0xFF795548); // بني طبيعي (لون التربة)
  static const Color accent = Color(0xFFFFB300); // ذهبي (لون القمح/الذرة)
  static const Color secondary = Color(0xFF6D4C41); // بني فاتح
  static const Color primaryLight = Color(
    0xFFD7CCC8,
  ); // بني فاتح جداً (خلفية عناصر)

  // Text - نصوص مريحة للعين
  static const Color textMain = Color(0xFF212121); // رمادي داكن للقراءة
  static const Color textSecondary = Color(0xFF616161); // رمادي متوسط
  static const Color textFaint = Color(0xFF9E9E9E); // رمادي فاتح
  static const Color textLight = Color(0xFFF9F9F9); // أبيض للوضع المظلم

  // Status - ألوان الحالة محسنة
  static const Color success = Color(0xFF4CAF50); // أخضر هادئ
  static const Color error = Color(0xFFE53935); // أحمر هادئ
  static const Color warning = Color(0xFFFFA726); // برتقالي هادئ
  static const Color info = Color(0xFF2196F3); // أزرق هادئ

  // Natural Colors - ألوان طبيعية محسنة
  static const Color earthBrown = Color(0xFF8D6E63); // بني التربة
  static const Color wheatGold = Color(0xFFFFC107); // ذهبي القمح
  static const Color grassGreen = Color(0xFF66BB6A); // أخضر العشب
  static const Color skyBlue = Color(0xFF42A5F5); // أزرق السماء

  // Gradients - تدرجات لونية جميلة
  static const List<Color> primaryGradient = [
    Color(0xFF8D6E63),
    Color(0xFF6D4C41),
  ];
  static const List<Color> accentGradient = [
    Color(0xFFFFC107),
    Color(0xFFFF8F00),
  ];
  static const List<Color> successGradient = [
    Color(0xFF66BB6A),
    Color(0xFF388E3C),
  ];
  static const List<Color> errorGradient = [
    Color(0xFFEF5350),
    Color(0xFFC62828),
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo',
      scaffoldBackgroundColor: scaffoldLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        background: scaffoldLight,
        surface: cardLight,
        primary: primary,
        secondary: secondary,
        tertiary: accent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: textLight,
        elevation: 0,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.r)),
        ),
        titleTextStyle: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
          color: textLight,
        ),
        toolbarHeight: 60.h,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return primary.withOpacity(0.5);
            }
            return primary;
          }),
          foregroundColor: WidgetStateProperty.all(textLight),
          padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return 0;
            return 2;
          }),
          shadowColor: WidgetStateProperty.all(primary.withOpacity(0.4)),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withOpacity(0.1);
            }
            if (states.contains(WidgetState.hovered)) {
              return Colors.white.withOpacity(0.05);
            }
            return null;
          }),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: textFaint.withOpacity(0.5), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: textFaint.withOpacity(0.5), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: error, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        labelStyle: TextStyle(
          fontSize: 14.sp,
          color: textSecondary,
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          fontSize: 14.sp,
          color: textFaint,
          fontFamily: 'Cairo',
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      cardTheme: CardTheme(
        color: cardLight,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 0),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: textMain,
          fontFamily: 'Cairo',
        ),
        headlineMedium: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: textMain,
          fontFamily: 'Cairo',
        ),
        headlineSmall: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: textMain,
          fontFamily: 'Cairo',
        ),
        titleLarge: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: textMain,
          fontFamily: 'Cairo',
        ),
        titleMedium: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: textMain,
          fontFamily: 'Cairo',
        ),
        titleSmall: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          fontFamily: 'Cairo',
        ),
        bodyLarge: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.normal,
          color: textMain,
          fontFamily: 'Cairo',
        ),
        bodyMedium: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.normal,
          color: textMain,
          fontFamily: 'Cairo',
        ),
        bodySmall: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.normal,
          color: textSecondary,
          fontFamily: 'Cairo',
        ),
        labelLarge: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: accent,
          fontFamily: 'Cairo',
        ),
        labelMedium: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: accent,
          fontFamily: 'Cairo',
        ),
        labelSmall: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: textFaint,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffoldDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.dark,
        background: scaffoldDark,
        surface: cardDark,
        primary: accent,
        secondary: secondary,
        tertiary: primary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cardDark,
        foregroundColor: textLight,
        elevation: 0,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.r)),
        ),
        titleTextStyle: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
          color: textLight,
        ),
        toolbarHeight: 60.h,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return accent.withOpacity(0.5);
            }
            return accent;
          }),
          foregroundColor: WidgetStateProperty.all(textMain),
          padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return 0;
            return 2;
          }),
          shadowColor: WidgetStateProperty.all(accent.withOpacity(0.3)),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.black.withOpacity(0.1);
            }
            if (states.contains(WidgetState.hovered)) {
              return Colors.black.withOpacity(0.05);
            }
            return null;
          }),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade700, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade700, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: error, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        labelStyle: TextStyle(
          fontSize: 14.sp,
          color: textSecondary,
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          fontSize: 14.sp,
          color: textFaint,
          fontFamily: 'Cairo',
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      cardTheme: CardTheme(
        color: cardDark,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 0),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: textLight,
          fontFamily: 'Cairo',
        ),
        headlineMedium: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: textLight,
          fontFamily: 'Cairo',
        ),
        headlineSmall: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: textLight,
          fontFamily: 'Cairo',
        ),
        titleLarge: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: textLight,
          fontFamily: 'Cairo',
        ),
        titleMedium: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: textLight,
          fontFamily: 'Cairo',
        ),
        titleSmall: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          fontFamily: 'Cairo',
        ),
        bodyLarge: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.normal,
          color: textLight,
          fontFamily: 'Cairo',
        ),
        bodyMedium: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.normal,
          color: textLight,
          fontFamily: 'Cairo',
        ),
        bodySmall: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.normal,
          color: textSecondary,
          fontFamily: 'Cairo',
        ),
        labelLarge: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: accent,
          fontFamily: 'Cairo',
        ),
        labelMedium: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: accent,
          fontFamily: 'Cairo',
        ),
        labelSmall: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: textFaint,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}
