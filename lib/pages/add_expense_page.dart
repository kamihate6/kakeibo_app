import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  List<dynamic> categories = [];

  String? selectedCategoryId;

  final amountController = TextEditingController();

  final memoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    final member = await Supabase.instance.client
        .from('household_members')
        .select()
        .eq('user_id', user.id)
        .single();

    final result = await Supabase.instance.client
        .from('categories')
        .select()
        .eq('household_id', member['household_id']);

    setState(() {
      categories = result;

      if (result.isNotEmpty) {
        selectedCategoryId = result.first['id'];
      }
    });
  }

  Future<void> saveExpense() async {
    try {
      if (amountController.text.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('金額を入力してください')));
        return;
      }

      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) return;

      final member = await Supabase.instance.client
          .from('household_members')
          .select()
          .eq('user_id', user.id)
          .single();

      final householdId = member['household_id'];

      await Supabase.instance.client.from('expenses').insert({
        'household_id': householdId,
        'user_id': user.id,
        'category_id': selectedCategoryId,
        'payer_user_id': user.id,
        'amount': int.parse(amountController.text),
        'expense_date': DateTime.now().toIso8601String().substring(0, 10),
        'expense_type': 'HOUSEHOLD',
        'memo': memoController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('支出登録完了')));

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));

      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('支出登録')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: '金額'),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

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
              controller: memoController,
              decoration: const InputDecoration(labelText: 'メモ'),
            ),

            const SizedBox(height: 24),

            ElevatedButton(onPressed: saveExpense, child: const Text('保存')),
          ],
        ),
      ),
    );
  }
}
