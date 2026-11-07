import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/current_household_provider.dart';
import '../services/category_service.dart';

import 'expense_edit_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> expenses = [];
  List<dynamic> filteredExpenses = [];

  Map<String, dynamic> categoryMap = {};

  DateTime selectedMonth = DateTime.now();

  String searchKeyword = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadExpenses();
    });
  }

  Future<void> loadExpenses() async {
    final householdId = context.read<CurrentHouseholdProvider>().householdId;

    if (householdId == null) {
      return;
    }

    final allCategories = await CategoryService.getCategories(householdId);

    final map = <String, dynamic>{};

    for (final category in allCategories) {
      map[category['id']] = category;
    }

    final firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);

    final nextMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);

    final result = await Supabase.instance.client
        .from('expenses')
        .select('''
      *,
      categories(
        id,
        name,
        parent_category_id
      )
    ''')
        .eq('household_id', householdId)
        .eq('status', 'ACTIVE')
        .gte('expense_date', firstDay.toIso8601String().substring(0, 10))
        .lt('expense_date', nextMonth.toIso8601String().substring(0, 10))
        .order('expense_date', ascending: false);

    setState(() {
      expenses = result;
      filteredExpenses = result;
      categoryMap = map;
    });
  }

  Future<void> previousMonth() async {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1, 1);
    });

    await loadExpenses();
  }

  Future<void> nextMonth() async {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);
    });

    await loadExpenses();
  }

  int get filteredTotal {
    int total = 0;

    for (final expense in filteredExpenses) {
      total += (expense['amount'] ?? 0) as int;
    }

    return total;
  }

  String getCategoryDisplayName(Map<String, dynamic> expense) {
    final category = expense['categories'];

    final parentId = category['parent_category_id'];

    if (parentId == null) {
      return category['name'];
    }

    final parent = categoryMap[parentId];

    if (parent == null) {
      return category['name'];
    }

    return '${parent['name']} > ${category['name']}';
  }

  void filterExpenses(String keyword) {
    setState(() {
      searchKeyword = keyword;

      if (keyword.isEmpty) {
        filteredExpenses = expenses;
        return;
      }

      filteredExpenses = expenses.where((expense) {
        final categoryName = getCategoryDisplayName(expense);

        final memo = (expense['memo'] ?? '').toString().toLowerCase();

        final search = keyword.toLowerCase();

        return categoryName.toLowerCase().contains(search) ||
            memo.contains(search);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('支出履歴')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: previousMonth,
                ),
                Text(
                  '${selectedMonth.year}年${selectedMonth.month}月',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: nextMonth,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'カテゴリ・メモ検索',
                border: OutlineInputBorder(),
              ),
              onChanged: filterExpenses,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '件数 ${filteredExpenses.length}件  合計 ¥$filteredTotal',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: expenses.isEmpty
                ? const Center(child: Text('支出データがありません'))
                : ListView.builder(
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = filteredExpenses[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ExpenseEditPage(expense: expense),
                              ),
                            ).then((_) {
                              loadExpenses();
                            });
                          },
                          leading: const Icon(Icons.attach_money),
                          title: Text('${expense['amount']}円'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                getCategoryDisplayName(expense),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if ((expense['memo'] ?? '').isNotEmpty)
                                Text(expense['memo']),
                            ],
                          ),
                          trailing: Text(
                            expense['expense_date'].toString().replaceAll(
                              '-',
                              '/',
                            ),
                          ),
                          onLongPress: () async {
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('削除確認'),
                                  content: const Text('削除しますか？'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, false);
                                      },
                                      child: const Text('いいえ'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                      child: const Text('はい'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (result == true) {
                              await Supabase.instance.client
                                  .from('expenses')
                                  .update({'status': 'CANCELLED'})
                                  .eq('id', expense['id']);

                              loadExpenses();
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
