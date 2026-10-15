import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:flutter_application_1/pages/home_page.dart';

void main() {
  testWidgets('ホーム画面表示', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    expect(find.text('支出登録'), findsOneWidget);

    expect(find.text('支出履歴'), findsOneWidget);

    expect(find.text('予算'), findsOneWidget);

    expect(find.text('ダッシュボード'), findsOneWidget);
  });
}
