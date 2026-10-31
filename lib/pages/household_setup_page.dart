import 'package:flutter/material.dart';

import '../widgets/loading_overlay.dart';

import 'home_page.dart';
import '../services/household_service.dart';

class HouseholdSetupPage extends StatefulWidget {
  const HouseholdSetupPage({super.key});

  @override
  State<HouseholdSetupPage> createState() => _HouseholdSetupPageState();
}

class _HouseholdSetupPageState extends State<HouseholdSetupPage> {
  final householdController = TextEditingController();

  bool isLoading = false;

  Future<void> createHousehold() async {
    if (householdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('世帯名を入力してください')));

      return;
    }

    setState(() {
      isLoading = true;
    });

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
      appBar: AppBar(title: const Text('世帯作成')),
      body: LoadingOverlay(
        isLoading: isLoading,
        message: '世帯を作成中...',
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: householdController,
                decoration: const InputDecoration(labelText: '世帯名'),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: isLoading ? null : createHousehold,
                child: const Text('世帯作成'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
