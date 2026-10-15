import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/pages/add_expense_page.dart';

void main() {
  testWidgets('支出登録画面表示', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddExpensePage()));

    expect(find.text('支出登録'), findsOneWidget);

    expect(find.text('金額'), findsOneWidget);

    expect(find.text('カテゴリ'), findsOneWidget);

    expect(find.text('保存'), findsOneWidget);
  });
}
