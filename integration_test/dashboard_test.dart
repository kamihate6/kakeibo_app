import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/pages/dashboard_page.dart';

void main() {
  testWidgets('ダッシュボード画面表示', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardPage()));

    expect(find.text('ダッシュボード'), findsOneWidget);
  });
}
