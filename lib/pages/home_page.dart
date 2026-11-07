import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_expense_page.dart';
import 'history_page.dart';
import 'budget_page.dart';
import 'dashboard_page.dart';
import 'category_management_page.dart';
import 'household_create_page.dart';
import 'join_household_page.dart';
import 'household_members_page.dart';
import 'household_management_page.dart';

import '../providers/current_household_provider.dart';
import '../services/household_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> households = [];
  int monthlyExpense = 0;
  int monthlyBudget = 0;

  @override
  void initState() {
    super.initState();

    loadHouseholds();
  }

  Future<void> loadHouseholds() async {
    final result = await HouseholdService.getHouseholds();

    if (!mounted) return;

    setState(() {
      households = result;
    });

    debugPrint('households count=${households.length}');
    if (result.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();

      final savedHouseholdId = prefs.getString('selectedHouseholdId');

      dynamic household;

      if (savedHouseholdId != null) {
        final matched = result.where(
          (h) => h['households']['id'] == savedHouseholdId,
        );

        if (matched.isNotEmpty) {
          household = matched.first['households'];
        }
      }

      household ??= result.first['households'];

      context.read<CurrentHouseholdProvider>().setHousehold(
        id: household['id'],
        name: household['name'],
      );

      await loadSummary(household['id']);
    }
  }

  Future<void> loadSummary(String householdId) async {
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

    int expenseTotal = 0;

    for (final item in expenses) {
      expenseTotal += (item['amount'] ?? 0) as int;
    }

    final budgetItems = await Supabase.instance.client
        .from('budget_items')
        .select('''
        yearly_amount,
        budget_plans!inner(
          household_id
        )
      ''')
        .eq('budget_plans.household_id', householdId);

    int budgetTotal = 0;

    for (final item in budgetItems) {
      budgetTotal += ((item['yearly_amount'] ?? 0) as int) ~/ 12;
    }

    if (!mounted) return;

    setState(() {
      monthlyExpense = expenseTotal;
      monthlyBudget = budgetTotal;
    });
  }

  Future<void> saveSelectedHousehold(String householdId) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('selectedHouseholdId', householdId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CurrentHouseholdProvider>();

    dynamic selectedHousehold;

    if (households.isNotEmpty) {
      final matched = households.where(
        (h) => h['households']['id'] == provider.householdId,
      );

      if (matched.isNotEmpty) {
        selectedHousehold = matched.first['households'];
      } else {
        selectedHousehold = households.first['households'];
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: households.isEmpty
            ? const Text('家計簿アプリ')
            : Consumer<CurrentHouseholdProvider>(
                builder: (context, provider, child) {
                  return DropdownButton<String>(
                    value: provider.householdId,
                    items: households.map((h) {
                      final household = h['households'];

                      return DropdownMenuItem<String>(
                        value: household['id'],
                        child: Text(household['name']),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      if (value == null) return;

                      final selected = households.firstWhere(
                        (h) => h['households']['id'] == value,
                      )['households'];

                      provider.setHousehold(
                        id: selected['id'],
                        name: selected['name'],
                      );

                      await saveSelectedHousehold(selected['id']);

                      await loadSummary(selected['id']);
                    },
                  );
                },
              ),

        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'ログアウト',
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();

              if (!context.mounted) return;

              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        '${DateTime.now().month}月の状況',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text('今月支出: ¥$monthlyExpense'),

                      Text('今月予算: ¥$monthlyBudget'),

                      Text(
                        '消化率: '
                        '${monthlyBudget == 0 ? 0 : ((monthlyExpense / monthlyBudget) * 100).toStringAsFixed(1)}%',
                      ),

                      const SizedBox(height: 12),

                      LinearProgressIndicator(
                        value: monthlyBudget == 0
                            ? 0
                            : (monthlyExpense / monthlyBudget).clamp(0.0, 1.0),
                        minHeight: 10,
                        color: monthlyExpense > monthlyBudget
                            ? Colors.red
                            : Colors.green,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddExpensePage(),
                          ),
                        );
                      },
                      child: const Text('支出登録'),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DashboardPage(),
                          ),
                        );
                      },
                      child: const Text('ダッシュボード'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HistoryPage(),
                          ),
                        );
                      },
                      child: const Text('支出履歴'),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BudgetPage()),
                        );
                      },
                      child: const Text('予算'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '管理',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CategoryManagementPage(),
                      ),
                    );
                  },
                  child: const Text('カテゴリ管理'),
                ),
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedHousehold == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HouseholdManagementPage(
                                household: selectedHousehold,
                              ),
                            ),
                          );
                        },
                  child: const Text('家計簿管理'),
                ),
              ),

              const SizedBox(height: 24),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '家計簿',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HouseholdCreatePage(),
                      ),
                    );

                    loadHouseholds();
                  },
                  child: const Text('家計簿作成'),
                ),
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const JoinHouseholdPage(),
                      ),
                    ).then((_) {
                      loadHouseholds();
                    });
                  },
                  child: const Text('家計簿参加'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
