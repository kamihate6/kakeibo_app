import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'home_page.dart';

class HouseholdSetupPage extends StatefulWidget {
  const HouseholdSetupPage({super.key});

  @override
  State<HouseholdSetupPage> createState() => _HouseholdSetupPageState();
}

class _HouseholdSetupPageState extends State<HouseholdSetupPage> {
  final householdController = TextEditingController();

  Future<void> createHousehold() async {
    if (householdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('世帯名を入力してください')));

      return;
    }

    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) return;

      final household = await Supabase.instance.client
          .from('households')
          .insert({
            'name': householdController.text.trim(),
            'owner_user_id': user.id,
          })
          .select()
          .single();

      await Supabase.instance.client.from('household_members').insert({
        'household_id': household['id'],
        'user_id': user.id,
        'role': 'ADMIN',
      });

      await Supabase.instance.client.from('categories').insert([
        {'household_id': household['id'], 'name': '食費', 'type': 'BOTH'},
        {'household_id': household['id'], 'name': '日用品', 'type': 'BOTH'},
        {'household_id': household['id'], 'name': '住宅', 'type': 'HOUSEHOLD'},
        {'household_id': household['id'], 'name': '通信費', 'type': 'BOTH'},
        {'household_id': household['id'], 'name': '交通費', 'type': 'BOTH'},
        {'household_id': household['id'], 'name': '医療費', 'type': 'BOTH'},
        {'household_id': household['id'], 'name': '娯楽', 'type': 'BOTH'},
        {'household_id': household['id'], 'name': 'その他', 'type': 'BOTH'},
      ]);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('世帯作成')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: householdController,
              decoration: const InputDecoration(labelText: '世帯名'),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: createHousehold,
              child: const Text('世帯作成'),
            ),
          ],
        ),
      ),
    );
  }
}
