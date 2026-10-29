import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'add_expense_page.dart';
import 'history_page.dart';
import 'budget_page.dart';
import 'dashboard_page.dart';
import 'category_management_page.dart';
import 'household_create_page.dart';

import '../providers/current_household_provider.dart';
import '../services/household_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> households = [];

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
      final household = result.first['households'];

      context.read<CurrentHouseholdProvider>().setHousehold(
        id: household['id'],
        name: household['name'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    onChanged: (value) {
                      if (value == null) return;

                      final selected = households.firstWhere(
                        (h) => h['households']['id'] == value,
                      )['households'];

                      provider.setHousehold(
                        id: selected['id'],
                        name: selected['name'],
                      );
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddExpensePage()),
                );
              },
              child: const Text('支出登録'),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryPage()),
                );
              },
              child: const Text('支出履歴'),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BudgetPage()),
                );
              },
              child: const Text('予算'),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardPage()),
                );
              },
              child: const Text('ダッシュボード'),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
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

            const SizedBox(height: 20),

            ElevatedButton(
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
          ],
        ),
      ),
    );
  }
}
