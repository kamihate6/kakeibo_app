import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JoinHouseholdPage extends StatefulWidget {
  const JoinHouseholdPage({super.key});

  @override
  State<JoinHouseholdPage> createState() => _JoinHouseholdPageState();
}

class _JoinHouseholdPageState extends State<JoinHouseholdPage> {
  final codeController = TextEditingController();

  Future<void> joinHousehold() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return;
    }

    final household = await Supabase.instance.client
        .from('households')
        .select()
        .eq('invite_code', codeController.text.trim())
        .maybeSingle();

    if (household == null) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('招待コードが存在しません')));
      }

      return;
    }

    final householdId = household['id'];

    final existing = await Supabase.instance.client
        .from('household_members')
        .select()
        .eq('household_id', householdId)
        .eq('user_id', user.id);

    if (existing.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('既に参加済みです')));
      }

      return;
    }

    await Supabase.instance.client.from('household_members').insert({
      'household_id': householdId,
      'user_id': user.id,
      'role': 'MEMBER',
    });

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('参加しました')));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('家計簿参加')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: '招待コード'),
            ),

            const SizedBox(height: 24),

            ElevatedButton(onPressed: joinHousehold, child: const Text('参加')),
          ],
        ),
      ),
    );
  }
}
