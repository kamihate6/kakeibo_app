import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_application_1/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('認証画面表示', (tester) async {
    app.main();

    await tester.pumpAndSettle();

    expect(find.text('ログイン'), findsOneWidget);
    expect(find.text('新規登録'), findsOneWidget);

    expect(find.byType(TextField), findsNWidgets(2));

    expect(find.byType(ElevatedButton), findsNWidgets(2));
  });
}
