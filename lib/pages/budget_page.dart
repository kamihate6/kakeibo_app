import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/current_household_provider.dart';
import '../services/category_service.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  List<dynamic> categories = [];

  String? selectedCategoryId;

  final amountController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadCategories();
    });
  }

  Future<void> loadCategories() async {
    final householdId = context.read<CurrentHouseholdProvider>().householdId;

    if (householdId == null) {
      return;
    }

    final result = await CategoryService.getParentCategories(householdId);

    setState(() {
      categories = result;

      if (result.isNotEmpty) {
        selectedCategoryId = result.first['id'];
      }
    });
  }

  Future<void> saveBudget() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) return;

      final householdId = context.read<CurrentHouseholdProvider>().householdId;

      if (householdId == null) {
        return;
      }

      final existingPlans = await Supabase.instance.client
          .from('budget_plans')
          .select()
          .eq('household_id', householdId)
          .eq('version', 1);

      dynamic plan;

      if (existingPlans.isEmpty) {
        plan = await Supabase.instance.client
            .from('budget_plans')
            .insert({
              'household_id': householdId,
              'name': '2026予算',
              'version': 1,
              'effective_from': DateTime.now().toIso8601String().substring(
                0,
                10,
              ),
              'status': 'ACTIVE',
              'created_by': user.id,
            })
            .select()
            .single();
      } else {
        plan = existingPlans.first;
      }

      final existingItems = await Supabase.instance.client
          .from('budget_items')
          .select()
          .eq('budget_plan_id', plan['id'])
          .eq('category_id', selectedCategoryId!);

      if (existingItems.isEmpty) {
        await Supabase.instance.client.from('budget_items').insert({
          'budget_plan_id': plan['id'],
          'category_id': selectedCategoryId,
          'scope': 'HOUSEHOLD',
          'yearly_amount': int.parse(amountController.text),
        });
      } else {
        await Supabase.instance.client
            .from('budget_items')
            .update({'yearly_amount': int.parse(amountController.text)})
            .eq('id', existingItems.first['id']);
      }

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('予算登録完了')));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('予算')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedCategoryId,
              decoration: const InputDecoration(labelText: 'カテゴリ'),
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category['id'],
                  child: Text(category['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategoryId = value;
                });
              },
            ),

            const SizedBox(height: 16),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '年間予算'),
            ),

            const SizedBox(height: 24),

            ElevatedButton(onPressed: saveBudget, child: const Text('登録')),
          ],
        ),
      ),
    );
  }
}
