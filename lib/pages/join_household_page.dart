import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/loading_overlay.dart';

class JoinHouseholdPage extends StatefulWidget {
  const JoinHouseholdPage({super.key});

  @override
  State<JoinHouseholdPage> createState() => _JoinHouseholdPageState();
}

class _JoinHouseholdPageState extends State<JoinHouseholdPage> {
  final codeController = TextEditingController();

  bool isLoading = false;

  Future<void> joinHousehold() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('家計簿参加')),
      body: LoadingOverlay(
        isLoading: isLoading,
        message: '家計簿に参加中...',
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: '招待コード'),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: isLoading ? null : joinHousehold,
                child: const Text('参加'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
