import 'package:flutter/material.dart';

import 'home_page.dart';
import '../services/household_service.dart';

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
      await HouseholdService.createHousehold(householdController.text.trim());

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
