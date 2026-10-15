import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseEditPage extends StatefulWidget {
  final Map<String, dynamic> expense;

  const ExpenseEditPage({super.key, required this.expense});

  @override
  State<ExpenseEditPage> createState() => _ExpenseEditPageState();
}

class _ExpenseEditPageState extends State<ExpenseEditPage> {
  late TextEditingController amountController;
  late TextEditingController memoController;

  @override
  void initState() {
    super.initState();

    amountController = TextEditingController(
      text: widget.expense['amount'].toString(),
    );

    memoController = TextEditingController(text: widget.expense['memo'] ?? '');
  }

  Future<void> updateExpense() async {
    try {
      await Supabase.instance.client
          .from('expenses')
          .update({
            'amount': int.parse(amountController.text),
            'memo': memoController.text,
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
