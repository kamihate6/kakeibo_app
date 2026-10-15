import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_application_1/main.dart' as app;

const testEmail = 'kakeibo003@example.com';

const testPassword = '1234567890';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('支出編集フロー', (tester) async {
    app.main();

    await tester.pumpAndSettle();

    // ログイン

    await tester.enterText(find.byType(TextField).at(0), testEmail);

    await tester.enterText(find.byType(TextField).at(1), testPassword);

    await tester.tap(find.text('ログイン'));

    await tester.pumpAndSettle(const Duration(seconds: 5));

    // 支出登録

    await tester.tap(find.text('支出登録'));

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '1111');

    await tester.enterText(find.byType(TextField).at(1), 'edit_test');

    await tester.tap(find.text('保存'));

    await tester.pumpAndSettle(const Duration(seconds: 3));

    // 履歴へ

    await tester.tap(find.text('支出履歴'));

    await tester.pumpAndSettle(const Duration(seconds: 3));

    // 先頭レコード選択

    await tester.tap(find.byType(ListTile).first);

    await tester.pumpAndSettle();

    // 編集

    await tester.enterText(find.byType(TextField).at(0), '2222');

    await tester.enterText(find.byType(TextField).at(1), 'edited');

    await tester.tap(find.text('保存'));

    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('更新しました'), findsOneWidget);
  });
}
