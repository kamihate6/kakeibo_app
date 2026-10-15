import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_application_1/main.dart' as app;

const testEmail = 'kakeibo003@example.com';

const testPassword = '1234567890';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ダッシュボード表示', (tester) async {
    app.main();

    await tester.pumpAndSettle();

    // ログイン

    await tester.enterText(find.byType(TextField).at(0), testEmail);

    await tester.enterText(find.byType(TextField).at(1), testPassword);

    await tester.tap(find.text('ログイン'));

    await tester.pumpAndSettle(const Duration(seconds: 5));

    // ダッシュボードへ

    await tester.tap(find.text('ダッシュボード'));

    await tester.pumpAndSettle(const Duration(seconds: 5));

    // タイトル確認

    expect(find.text('ダッシュボード'), findsOneWidget);

    // 予算関連表示

    expect(find.text('予算'), findsOneWidget);

    expect(find.text('今月支出'), findsOneWidget);

    expect(find.text('残額'), findsOneWidget);

    expect(find.textContaining('予算消化率'), findsOneWidget);
  });
}
