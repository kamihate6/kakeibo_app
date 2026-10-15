import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_application_1/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ログインフロー', (tester) async {
    app.main();

    await tester.pumpAndSettle();

    // メールアドレス
    await tester.enterText(
      find.byType(TextField).at(0),
      'kakeibo003@example.com',
    );

    // パスワード
    await tester.enterText(find.byType(TextField).at(1), '1234567890');

    // ログインボタン
    await tester.tap(find.text('ログイン'));

    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Home画面確認
    expect(find.text('支出登録'), findsOneWidget);
  });
}
