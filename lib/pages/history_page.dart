import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'expense_edit_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> expenses = [];

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    final member = await Supabase.instance.client
        .from('household_members')
        .select()
        .eq('user_id', user.id)
        .single();

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
        .eq('household_id', member['household_id'])
        .eq('status', 'ACTIVE')
        .order('expense_date', ascending: false);

    for (final expense in result) {
      debugPrint(expense['categories'].toString());
    }

    setState(() {
      expenses = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('支出履歴')),
      body: expenses.isEmpty
          ? const Center(child: Text('支出データがありません'))
          : ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];

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
                          builder: (_) => ExpenseEditPage(expense: expense),
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
                          expense['categories']['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if ((expense['memo'] ?? '').isNotEmpty)
                          Text(expense['memo']),
                      ],
                    ),

                    trailing: Text(expense['expense_date'].toString()),
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
    );
  }
}
