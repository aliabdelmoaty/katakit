import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:katakit/features/auth/cubit/auth_cubit.dart';
import 'package:katakit/features/auth/repository/auth_repository.dart';
import 'package:katakit/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      syncStatusStream: Stream.empty(),
      authCubit: AuthCubit(authRepository: AuthRepository()),
    ));

    // Verify that the app title is displayed
    expect(find.text('🐣 كتاكيت عبد المعطي'), findsOneWidget);

    // Verify that the FAB is present
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
