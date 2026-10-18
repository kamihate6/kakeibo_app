import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_application_1/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Logout Flow', (tester) async {
    app.main();

    await tester.pumpAndSettle();

    // 自動ログイン後 Home表示

    expect(find.text('支出登録'), findsOneWidget);

    // ログアウト

    await tester.tap(find.byTooltip('ログアウト'));

    await tester.pumpAndSettle(const Duration(seconds: 3));

    // ログイン画面確認

    expect(find.text('ログイン'), findsOneWidget);
  });
}
