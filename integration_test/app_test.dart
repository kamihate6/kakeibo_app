import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_application_1/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App Startup', (tester) async {
    app.main();

    await tester.pumpAndSettle();

    // Home画面またはAuth画面のどちらかが表示される

    final isHome = find.text('支出登録').evaluate().isNotEmpty;

    final isAuth = find.text('ログイン').evaluate().isNotEmpty;

    expect(isHome || isAuth, isTrue);
  });
}
