import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/current_household_provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateTime selectedMonth = DateTime.now();

  List<Map<String, dynamic>> categorySummaries = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  Future<void> loadData() async {
    final householdId = context.read<CurrentHouseholdProvider>().householdId;

    if (householdId == null) {
      return;
    }

    final firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);

    final nextMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);

    final budgetDetails = await Supabase.instance.client
        .from('budget_items')
        .select('''
        yearly_amount,
        categories(
          id,
          name,
          sort_order
        ),
        budget_plans!inner(
          household_id
        )
      ''')
        .eq('budget_plans.household_id', householdId);

    final allCategories = await Supabase.instance.client
        .from('categories')
        .select('''
        id,
        name,
        parent_category_id,
        sort_order
      ''')
        .eq('household_id', householdId)
        .eq('is_active', true);

    final allExpenses = await Supabase.instance.client
        .from('expenses')
        .select('''
        amount,
        category_id
      ''')
        .eq('household_id', householdId)
        .eq('status', 'ACTIVE')
        .gte('expense_date', firstDay.toIso8601String().substring(0, 10))
        .lt('expense_date', nextMonth.toIso8601String().substring(0, 10));

    final Map<String, int> expenseMap = {};

    for (final expense in allExpenses) {
      final categoryId = expense['category_id'];

      expenseMap[categoryId] =
          (expenseMap[categoryId] ?? 0) + ((expense['amount'] ?? 0) as int);
    }

    final List<Map<String, dynamic>> summaries = [];

    for (final budget in budgetDetails) {
      final category = budget['categories'];

      if (category == null) {
        continue;
      }

      final parentAmount = expenseMap[category['id']] ?? 0;

      final childCategories = allCategories
          .where((c) => c['parent_category_id'] == category['id'])
          .toList();

      int actual = parentAmount;

      for (final child in childCategories) {
        actual += expenseMap[child['id']] ?? 0;
      }

      final yearlyBudget = (budget['yearly_amount'] ?? 0) as int;

      final monthlyBudget = (yearlyBudget / 12).round();

      final rate = yearlyBudget == 0 ? 0.0 : actual / yearlyBudget;

      final List<Map<String, dynamic>> childSummaries = [];

      if (parentAmount > 0) {
        childSummaries.add({'name': '直接登録', 'amount': parentAmount});
      }

      for (final child in childCategories) {
        final childAmount = expenseMap[child['id']] ?? 0;

        childSummaries.add({'name': child['name'], 'amount': childAmount});
      }

      for (final child in childSummaries) {
        child['rate'] = actual == 0 ? 0.0 : (child['amount'] as int) / actual;
      }

      childSummaries.sort(
        (a, b) => (b['amount'] as int).compareTo(a['amount'] as int),
      );

      summaries.add({
        'name': category['name'],
        'actual': actual,
        'monthlyBudget': monthlyBudget,
        'yearlyBudget': yearlyBudget,
        'rate': rate,
        'sortOrder': category['sort_order'] ?? 9999,
        'children': childSummaries,
      });
    }

    summaries.sort(
      (a, b) => (a['sortOrder'] as int).compareTo(b['sortOrder'] as int),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      categorySummaries = summaries;
    });
  }

  Future<void> previousMonth() async {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1, 1);
    });

    await loadData();
  }

  Future<void> nextMonth() async {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);
    });

    await loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ダッシュボード')),
      body: Column(
        children: [
          // 月切替
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
                  '${selectedMonth.year}年'
                  '${selectedMonth.month}月',
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

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: categorySummaries.length,
                itemBuilder: (context, index) {
                  final item = categorySummaries[index];

                  final children =
                      item['children'] as List<Map<String, dynamic>>;

                  return Card(
                    child: ExpansionTile(
                      title: Text(
                        item['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      childrenPadding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('支出: ${item['actual']}円'),

                              Text('月予算: ${item['monthlyBudget']}円'),

                              Text('年予算: ${item['yearlyBudget']}円'),

                              Text(
                                '年消化率: '
                                '${((item['rate'] as double) * 100).toStringAsFixed(1)}%',
                              ),

                              const SizedBox(height: 10),

                              LinearProgressIndicator(
                                value:
                                    (item['actual'] as int) /
                                    ((item['monthlyBudget'] as int) == 0
                                        ? 1
                                        : item['monthlyBudget'] as int),
                                minHeight: 10,
                                color:
                                    (item['actual'] as int) >
                                        (item['monthlyBudget'] as int)
                                    ? Colors.red
                                    : Colors.green,
                              ),

                              if (children.isNotEmpty) ...[
                                const SizedBox(height: 16),

                                const Divider(),

                                const Text(
                                  '内訳',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),

                                const SizedBox(height: 8),

                                ...children.map((child) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text(child['name'])),

                                        Text('${child['amount']}円'),

                                        const SizedBox(width: 12),

                                        Text(
                                          '${((child['rate'] as double) * 100).toStringAsFixed(1)}%',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
