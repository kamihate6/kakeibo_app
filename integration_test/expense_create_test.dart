import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_application_1/main.dart' as app;

const testEmail = 'kakeibo003@example.com';

const testPassword = '1234567890';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Expense Create Flow', (tester) async {
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

    // 支出登録画面へ

    await tester.tap(find.text('支出登録'));

    await tester.pumpAndSettle();

    // 金額入力

    await tester.enterText(find.byType(TextField).at(0), '1234');

    // メモ入力

    await tester.enterText(find.byType(TextField).at(1), 'integration_test');

    expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(2));

    // 親カテゴリ確認

    expect(find.text('親カテゴリ'), findsOneWidget);

    // 子カテゴリ確認

    expect(find.text('子カテゴリ'), findsOneWidget);

    // 保存
    await tester.tap(find.text('保存'));

    await tester.pumpAndSettle(const Duration(seconds: 5));

    await tester.pumpAndSettle(const Duration(seconds: 5));

    // 完了確認

    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.text('支出登録'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.text('integration_test'), findsWidgets);
  });
}
