import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  // ألوان هادئة ومريحة للعين - تعبر عن البيئة الريفية وتربية الكتاكيت

  // Backgrounds - خلفيات هادئة
  static const Color scaffoldLight = Color(0xFFF8F6F0); // كريمي فاتح
  static const Color cardLight = Color(0xFFFFFFFF); // أبيض نقي
  static const Color scaffoldDark = Color(0xFF1A1A1A); // رمادي داكن هادئ
  static const Color cardDark = Color(0xFF2D2D2D); // رمادي متوسط

  // Primary + Accent - ألوان رئيسية تعبر عن الطبيعة
  static const Color primary = Color(0xFF8D6E63); // بني طبيعي (لون التربة)
  static const Color accent = Color(0xFFFBC02D); // ذهبي (لون القمح/الذرة)
  static const Color secondary = Color(0xFF795548); // بني فاتح

  // Text - نصوص مريحة للعين
  static const Color textMain = Color(0xFF2E2E2E); // رمادي داكن للقراءة
  static const Color textSecondary = Color(0xFF6B6B6B); // رمادي متوسط
  static const Color textFaint = Color(0xFF9E9E9E); // رمادي فاتح
  static const Color textLight = Color(0xFFF5F5F5); // أبيض للوضع المظلم

  // Status - ألوان الحالة
  static const Color success = Color(0xFF66BB6A); // أخضر هادئ
  static const Color error = Color(0xFFEF5350); // أحمر هادئ
  static const Color warning = Color(0xFFFFB74D); // برتقالي هادئ
  static const Color info = Color(0xFF29B6F6); // أزرق هادئ

  // Natural Colors - ألوان طبيعية
  static const Color earthBrown = Color(0xFF8D6E63); // بني التربة
  static const Color wheatGold = Color(0xFFFBC02D); // ذهبي القمح
  static const Color grassGreen = Color(0xFF66BB6A); // أخضر العشب
  static const Color skyBlue = Color(0xFF29B6F6); // أزرق السماء

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
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: textLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
          color: textLight,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textLight,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: textFaint),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: textFaint),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: primary),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        labelStyle: TextStyle(
          fontSize: 14.sp,
          color: textSecondary,
          fontFamily: 'Cairo',
        ),
        hintStyle: TextStyle(
          fontSize: 14.sp,
          color: textFaint,
          fontFamily: 'Cairo',
        ),
      ),
      cardTheme: CardTheme(
        color: cardLight,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
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
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cardDark,
        foregroundColor: textLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
          color: textLight,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: textMain,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: textFaint),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: textFaint),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: accent),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        labelStyle: TextStyle(
          fontSize: 14.sp,
          color: textSecondary,
          fontFamily: 'Cairo',
        ),
        hintStyle: TextStyle(
          fontSize: 14.sp,
          color: textFaint,
          fontFamily: 'Cairo',
        ),
      ),
      cardTheme: CardTheme(
        color: cardDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
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
