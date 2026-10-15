import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_application_1/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('支出登録フロー', (tester) async {
    app.main();

    await tester.pumpAndSettle();

    // ログイン

    await tester.enterText(
      find.byType(TextField).at(0),
      'kakeibo003@example.com',
    );

    await tester.enterText(find.byType(TextField).at(1), '1234567890');

    await tester.tap(find.text('ログイン'));

    await tester.pumpAndSettle(const Duration(seconds: 5));

    // 支出登録画面へ

    await tester.tap(find.text('支出登録'));

    await tester.pumpAndSettle();

    // 金額入力

    await tester.enterText(find.byType(TextField).at(0), '1234');

    // メモ入力

    await tester.enterText(find.byType(TextField).at(1), 'integration_test');

    // 保存

    await tester.tap(find.text('保存'));

    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Snackbar確認

    expect(find.text('支出登録完了'), findsOneWidget);
  });
}
