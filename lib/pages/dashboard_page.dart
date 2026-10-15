import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

List<Map<String, dynamic>> categorySummaries = [];

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int totalBudget = 0;
  int totalExpense = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    final member = await Supabase.instance.client
        .from('household_members')
        .select()
        .eq('user_id', user.id)
        .single();

    final householdId = member['household_id'];

    final budgetItems = await Supabase.instance.client
        .from('budget_items')
        .select('yearly_amount');

    final now = DateTime.now();

    final firstDay = DateTime(now.year, now.month, 1);

    final nextMonth = DateTime(now.year, now.month + 1, 1);

    final expenses = await Supabase.instance.client
        .from('expenses')
        .select('amount')
        .eq('household_id', householdId)
        .eq('status', 'ACTIVE')
        .gte('expense_date', firstDay.toIso8601String().substring(0, 10))
        .lt('expense_date', nextMonth.toIso8601String().substring(0, 10));

    int budgetSum = 0;
    int expenseSum = 0;

    for (final item in budgetItems) {
      budgetSum += (item['yearly_amount'] ?? 0) as int;
    }

    for (final item in expenses) {
      expenseSum += (item['amount'] ?? 0) as int;
    }

    final budgetDetails = await Supabase.instance.client
        .from('budget_items')
        .select('''
          yearly_amount,
          categories(
            id,
            name
          )
        ''');
    final List<Map<String, dynamic>> summaries = [];

    for (final budget in budgetDetails) {
      final category = budget['categories'];

      if (category == null) continue;

      final categoryExpenses = await Supabase.instance.client
          .from('expenses')
          .select('amount')
          .eq('category_id', category['id'])
          .eq('status', 'ACTIVE');

      int actual = 0;

      for (final item in categoryExpenses) {
        actual += (item['amount'] ?? 0) as int;
      }

      summaries.add({
        'name': category['name'],
        'budget': budget['yearly_amount'] ?? 0,
        'actual': actual,
      });
    }
    setState(() {
      totalBudget = budgetSum;
      totalExpense = expenseSum;
      categorySummaries = summaries;
    });
  }

  @override
  Widget build(BuildContext context) {
    final remain = totalBudget - totalExpense;
    final usageRate = totalBudget == 0 ? 0.0 : totalExpense / totalBudget;

    return Scaffold(
      appBar: AppBar(title: const Text('ダッシュボード')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text('予算'),
                trailing: Text('${totalBudget.toString()}円'),
              ),
            ),

            Card(
              child: ListTile(
                title: const Text('今月支出'),
                trailing: Text('${totalExpense.toString()}円'),
              ),
            ),

            Card(
              child: ListTile(
                title: const Text('残額'),
                trailing: Text('${remain.toString()}円'),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '予算消化率 ${(usageRate * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    LinearProgressIndicator(
                      value: usageRate.clamp(0, 1),
                      minHeight: 12,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'カテゴリ別集計',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: categorySummaries.length,
                itemBuilder: (context, index) {
                  final item = categorySummaries[index];

                  final remain =
                      (item['budget'] as int) - (item['actual'] as int);

                  return Card(
                    child: ListTile(
                      title: Text(item['name']),
                      subtitle: Text(
                        '${item['actual']}円 / '
                        '${item['budget']}円',
                      ),
                      trailing: Text('残${remain}円'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
