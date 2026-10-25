import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/category_service.dart';

class ExpenseEditPage extends StatefulWidget {
  final Map<String, dynamic> expense;

  const ExpenseEditPage({super.key, required this.expense});

  @override
  State<ExpenseEditPage> createState() => _ExpenseEditPageState();
}

class _ExpenseEditPageState extends State<ExpenseEditPage> {
  late TextEditingController amountController;
  late TextEditingController memoController;

  List<dynamic> categories = [];

  List<dynamic> parentCategories = [];

  List<dynamic> childCategories = [];

  String? selectedParentId;

  String? selectedChildId;

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    amountController = TextEditingController(
      text: widget.expense['amount'].toString(),
    );

    memoController = TextEditingController(text: widget.expense['memo'] ?? '');

    selectedDate = DateTime.parse(widget.expense['expense_date']);

    loadCategories();
  }

  Future<void> loadCategories() async {
    final result = await CategoryService.getCategories();

    final parents = result
        .where((c) => c['parent_category_id'] == null)
        .toList();

    final currentCategoryId = widget.expense['category_id'];

    final currentCategory = result.firstWhere(
      (c) => c['id'] == currentCategoryId,
      orElse: () => <String, dynamic>{},
    );

    if (currentCategory.isEmpty) return;

    final parentId = currentCategory['parent_category_id'];

    final children = result
        .where((c) => c['parent_category_id'] == parentId)
        .toList();

    if (!mounted) return;

    setState(() {
      categories = result;

      parentCategories = parents;

      selectedParentId = parentId;

      childCategories = children;

      selectedChildId = currentCategoryId;
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

  Future<void> updateExpense() async {
    try {
      await Supabase.instance.client
          .from('expenses')
          .update({
            'amount': int.parse(amountController.text),
            'memo': memoController.text,
            'category_id': selectedChildId,
            'expense_date': selectedDate.toIso8601String().substring(0, 10),
          })
          .eq('id', widget.expense['id']);

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('更新しました')));

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('支出編集')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '金額'),
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
              onChanged: (value) {
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

            ElevatedButton(onPressed: updateExpense, child: const Text('保存')),
          ],
        ),
      ),
    );
  }
}
