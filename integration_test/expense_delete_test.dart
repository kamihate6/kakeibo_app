import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_application_1/main.dart' as app;

const testEmail = 'kakeibo003@example.com';

const testPassword = '1234567890';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Expense Delete Flow', (tester) async {
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

    await tester.enterText(find.byType(TextField).at(0), '9999');

    await tester.enterText(find.byType(TextField).at(1), 'delete_test');

    // カテゴリ選択

    await tester.tap(find.byType(DropdownButtonFormField<String>).last);

    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('食費'), findsWidgets);

    //await tester.tap(find.text('食費').first);

    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('保存'));

    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('保存'));

    await tester.pumpAndSettle();

    await tester.tap(find.text('保存'), warnIfMissed: false);

    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.text('支出登録完了'), findsOneWidget);

    debugDumpApp();
    // 履歴へ

    await tester.tap(find.text('支出履歴'));

    await tester.pumpAndSettle(const Duration(seconds: 3));

    // レコード存在確認

    expect(find.byType(ListTile), findsWidgets);

    // 先頭レコード長押し

    await tester.longPress(find.byType(ListTile).first);

    await tester.pumpAndSettle();

    // ダイアログ確認

    expect(find.text('削除確認'), findsOneWidget);

    // 削除実行

    await tester.tap(find.text('はい'));

    await tester.pumpAndSettle(const Duration(seconds: 3));

    // ダイアログが閉じる

    expect(find.text('削除確認'), findsNothing);
  });
}
