import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'features/batches/presentation/screens/batches_screen.dart';
import 'features/batches/cubit/batches_cubit.dart';
import 'features/additions/cubit/additions_cubit.dart';
import 'features/deaths/cubit/deaths_cubit.dart';
import 'features/sales/cubit/sales_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/cubit/auth_cubit.dart' as auth;
import 'features/auth/repository/auth_repository.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'dart:developer' as dev;
import 'core/services/connection_service.dart';
import 'core/services/sync_service.dart';

const supabaseUrl = 'https://qqrgsjguqhbshrypjsti.supabase.co';
const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFxcmdzamd1cWhic2hyeXBqc3RpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4ODMyNDEsImV4cCI6MjA2NzQ1OTI0MX0.ZINXdpvWcThzAKlf9nzE0r8IK-MYRDwQQt2uxGNIhxs';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  await init();
  final connected = await ConnectionService().isConnected;
  dev.log(
    'Internet connection: ${connected ? 'Online' : 'Offline'}',
    name: 'connection',
  );
  SyncService().startSync();
  runApp(MyApp(syncStatusStream: SyncService().syncStatusStream));
}

class MyApp extends StatelessWidget {
  final Stream<SyncStatus> syncStatusStream;
  const MyApp({super.key, required this.syncStatusStream});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BatchesCubit>(create: (context) => sl<BatchesCubit>()),
        BlocProvider<AdditionsCubit>(create: (context) => sl<AdditionsCubit>()),
        BlocProvider<DeathsCubit>(create: (context) => sl<DeathsCubit>()),
        BlocProvider<SalesCubit>(create: (context) => sl<SalesCubit>()),
        BlocProvider<auth.AuthCubit>(
          create: (_) => auth.AuthCubit(authRepository: AuthRepository()),
        ),
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
            home: BlocBuilder<auth.AuthCubit, auth.AuthState>(
              builder: (context, state) {
                if (state is auth.Authenticated) {
                  return BatchesScreen(syncStatusStream: syncStatusStream);
                } else {
                  return const LoginScreen();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
