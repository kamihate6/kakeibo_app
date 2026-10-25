import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/category_service.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  List<dynamic> categories = [];

  List<dynamic> parentCategories = [];

  List<dynamic> childCategories = [];

  String? selectedParentId;

  String? selectedChildId;

  DateTime selectedDate = DateTime.now();

  final amountController = TextEditingController();

  final memoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final result = await CategoryService.getCategories();

    final parents = result
        .where((c) => c['parent_category_id'] == null)
        .toList();

    if (!mounted) return;

    setState(() {
      categories = result;

      parentCategories = parents;

      if (parents.isNotEmpty) {
        selectedParentId = parents.first['id'];

        childCategories = result
            .where((c) => c['parent_category_id'] == selectedParentId)
            .toList();

        if (childCategories.isNotEmpty) {
          selectedChildId = childCategories.first['id'];
        } else {
          selectedChildId = null;
        }
      }
    });
  }

  Future<void> selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    setState(() {
      selectedDate = pickedDate;
    });
  }

  Future<void> saveExpense() async {
    try {
      if (amountController.text.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('金額を入力してください')));
        return;
      }

      if (selectedChildId == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('子カテゴリを選択してください')));
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

      debugPrint('selectedChildId=$selectedChildId');

      debugPrint('before insert');

      await Supabase.instance.client.from('expenses').insert({
        'household_id': householdId,
        'user_id': user.id,
        'category_id': selectedChildId,
        'payer_user_id': user.id,
        'amount': int.parse(amountController.text),

        'expense_date': selectedDate.toIso8601String().substring(0, 10),

        'expense_type': 'HOUSEHOLD',
        'memo': memoController.text,
      });

      debugPrint('after insert');

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('支出登録完了')));

      Navigator.pop(context);

      debugPrint('after pop');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));

      debugPrint(e.toString());
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
              value: selectedParentId,
              decoration: const InputDecoration(labelText: '親カテゴリ'),
              items: parentCategories.map((category) {
                return DropdownMenuItem<String>(
                  value: category['id'],
                  child: Text(category['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedParentId = value;

                  childCategories = categories
                      .where((c) => c['parent_category_id'] == value)
                      .toList();

                  if (childCategories.isNotEmpty) {
                    selectedChildId = childCategories.first['id'];
                  } else {
                    selectedChildId = null;
                  }
                });
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: selectedChildId,
              decoration: const InputDecoration(labelText: '子カテゴリ'),
              items: childCategories.map((category) {
                return DropdownMenuItem<String>(
                  value: category['id'],
                  child: Text(category['name']),
                );
              }).toList(),
              onChanged: childCategories.isEmpty
                  ? null
                  : (value) {
                      setState(() {
                        selectedChildId = value;
                      });
                    },
            ),

            const SizedBox(height: 16),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('支払日'),
              subtitle: Text(selectedDate.toIso8601String().substring(0, 10)),
              trailing: const Icon(Icons.calendar_month),
              onTap: selectDate,
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
