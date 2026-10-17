import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_application_1/main.dart' as app;

const testEmail = 'kakeibo003@example.com';

const testPassword = '1234567890';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Budget Create Flow', (tester) async {
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

    expect(find.text('予算'), findsOneWidget);

    // 予算画面へ

    await tester.tap(find.text('予算'));

    await tester.pumpAndSettle();

    // 年間予算入力

    expect(find.byType(TextField), findsWidgets);

    await tester.enterText(find.byType(TextField).first, '123456');

    // 登録

    await tester.tap(find.text('登録'));

    await tester.pumpAndSettle(const Duration(seconds: 3));

    // 完了確認

    expect(find.text('予算登録完了'), findsOneWidget);
  });
}
