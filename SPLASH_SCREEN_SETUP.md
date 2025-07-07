# Native Splash Screen Setup

تم إعداد native splash screen للتطبيق بنجاح.

## الملفات المضافة/المعدلة:

### 1. pubspec.yaml
- إضافة dependency: `flutter_native_splash: ^2.4.0`

### 2. flutter_native_splash.yaml
- ملف تكوين الـ splash screen
- إعداد اللوجو والخلفية

### 3. lib/main.dart
- إضافة import: `flutter_native_splash`
- إضافة `FlutterNativeSplash.preserve()` في بداية main
- إضافة `FlutterNativeSplash.remove()` بعد انتهاء التهيئة

### 4. android/app/src/main/res/drawable/splash_background.xml
- ملف drawable للـ splash screen
- يحتوي على اللوجو والخلفية البيضاء

### 5. android/app/src/main/res/values/styles.xml
- تعديل LaunchTheme لاستخدام splash_background

### 6. android/app/src/main/res/values/strings.xml
- إضافة نصوص التطبيق:
  - `app_name`: "كتاكيت عبد المعطي"
  - `developer_info`: "Developed by Ali Mohammed"

### 7. android/app/src/main/AndroidManifest.xml
- تعديل android:label لاستخدام @string/app_name

## كيفية التشغيل:

1. `flutter pub get`
2. `flutter pub run flutter_native_splash:create`
3. `flutter clean`
4. `flutter pub get`
5. `flutter run`

## النتيجة:
- splash screen يظهر عند بدء التطبيق
- يحتوي على اللوجو وخلفية بيضاء
- اسم التطبيق: "كتاكيت عبد المعطي"
- معلومات المطور: "Developed by Ali Mohammed" 