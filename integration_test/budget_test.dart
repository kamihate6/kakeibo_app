import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/pages/budget_page.dart';

void main() {
  testWidgets('予算画面表示', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BudgetPage()));

    expect(find.text('予算'), findsOneWidget);

    expect(find.text('年間予算'), findsOneWidget);

    expect(find.text('登録'), findsOneWidget);
  });
}
