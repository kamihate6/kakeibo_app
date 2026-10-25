import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_application_1/main.dart' as app;

const testEmail = 'kakeibo003@example.com';

const testPassword = '1234567890';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Expense Update Flow', (tester) async {
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

    // 支出登録

    await tester.tap(find.text('支出登録'));

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '1111');

    await tester.enterText(find.byType(TextField).at(1), 'edit_test');

    // カテゴリ選択
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('保存'));

    await tester.pumpAndSettle();

    await tester.tap(find.text('保存'));

    await tester.pumpAndSettle(const Duration(seconds: 5));

    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.text('支出登録'), findsOneWidget);

    // 履歴画面へ

    await tester.tap(find.text('支出履歴'));

    await tester.pumpAndSettle(const Duration(seconds: 5));

    // 支出一覧確認

    expect(find.byType(ListTile), findsWidgets);

    await tester.tap(find.byType(ListTile).first);

    await tester.pumpAndSettle();

    // 編集

    await tester.enterText(find.byType(TextField).at(0), '2222');

    await tester.enterText(find.byType(TextField).at(1), 'edited');

    await tester.ensureVisible(find.text('保存'));

    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, '保存'));

    await tester.pumpAndSettle(const Duration(seconds: 5));

    // 履歴画面へ戻ったことを確認

    expect(find.byType(ListTile), findsWidgets);
  });
}
