import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_application_1/main.dart' as app;

const testEmail = 'kakeibo003@example.com';

const testPassword = '1234567890';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Regression Suite', (tester) async {
    app.main();

    await tester.pumpAndSettle();

    // 未ログイン時のみログイン

    if (find.text('ログイン').evaluate().isNotEmpty) {
      await tester.enterText(find.byType(TextField).at(0), testEmail);

      await tester.enterText(find.byType(TextField).at(1), testPassword);

      await tester.tap(find.text('ログイン'));

      await tester.pumpAndSettle(const Duration(seconds: 5));
    }

    // Home画面確認

    expect(find.text('支出登録'), findsOneWidget);

    expect(find.text('支出履歴'), findsOneWidget);

    expect(find.text('予算'), findsOneWidget);

    expect(find.text('ダッシュボード'), findsOneWidget);
  });
}
