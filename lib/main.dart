import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'features/batches/presentation/screens/batches_screen.dart';
import 'features/batches/cubit/batches_cubit.dart';
import 'features/additions/cubit/additions_cubit.dart';
import 'features/deaths/cubit/deaths_cubit.dart';
import 'features/sales/cubit/sales_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BatchesCubit>(create: (context) => sl<BatchesCubit>()),
        BlocProvider<AdditionsCubit>(create: (context) => sl<AdditionsCubit>()),
        BlocProvider<DeathsCubit>(create: (context) => sl<DeathsCubit>()),
        BlocProvider<SalesCubit>(create: (context) => sl<SalesCubit>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'كتاكيت عبد المعطي',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            themeMode: ThemeMode.light,
            locale: const Locale('ar', 'EG'),
            supportedLocales: const [Locale('ar', 'EG')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },
            home: const BatchesScreen(),
          );
        },
      ),
    );
  }
}
