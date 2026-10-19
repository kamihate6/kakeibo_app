import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_application_1/main.dart' as app;

const testEmail = 'kakeibo003@example.com';

const testPassword = '1234567890';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Category Create Flow', (tester) async {
    app.main();

    await tester.pumpAndSettle();

    // 未ログイン時のみログイン

    if (find.text('ログイン').evaluate().isNotEmpty) {
      await tester.enterText(find.byType(TextField).at(0), testEmail);

      await tester.enterText(find.byType(TextField).at(1), testPassword);

      await tester.tap(find.text('ログイン'));

      await tester.pumpAndSettle(const Duration(seconds: 5));
    }

    expect(find.text('カテゴリ管理'), findsOneWidget);

    await tester.tap(find.text('カテゴリ管理'));

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));

    await tester.pumpAndSettle();

    expect(find.text('カテゴリ追加'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'test_category');

    await tester.tap(find.text('登録'));

    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('test_category'), findsWidgets);
  });
}
