import 'package:flutter/material.dart';

import '../services/household_service.dart';

class HouseholdCreatePage extends StatefulWidget {
  const HouseholdCreatePage({super.key});

  @override
  State<HouseholdCreatePage> createState() => _HouseholdCreatePageState();
}

class _HouseholdCreatePageState extends State<HouseholdCreatePage> {
  final nameController = TextEditingController();

  Future<void> save() async {
    await HouseholdService.createHousehold(nameController.text);

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('家計簿作成')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '家計簿名'),
            ),

            const SizedBox(height: 24),

            ElevatedButton(onPressed: save, child: const Text('作成')),
          ],
        ),
      ),
    );
  }
}
