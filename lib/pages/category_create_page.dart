import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/current_household_provider.dart';
import '../services/category_service.dart';

class CategoryCreatePage extends StatefulWidget {
  const CategoryCreatePage({super.key});

  @override
  State<CategoryCreatePage> createState() => _CategoryCreatePageState();
}

class _CategoryCreatePageState extends State<CategoryCreatePage> {
  final nameController = TextEditingController();

  List<dynamic> parentCategories = [];

  String? selectedParentId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadParentCategories();
    });
  }

  Future<void> loadParentCategories() async {
    final householdId = context.read<CurrentHouseholdProvider>().householdId;

    if (householdId == null) {
      return;
    }

    final categories = await CategoryService.getCategories(householdId);

    final parents = categories
        .where((c) => c['parent_category_id'] == null)
        .toList();

    if (!mounted) return;

    setState(() {
      parentCategories = parents;

      if (parents.isNotEmpty) {
        selectedParentId = parents.first['id'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('カテゴリ追加')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
                });
              },
            ),

            const SizedBox(height: 16),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'カテゴリ名'),
            ),

            const SizedBox(height: 24),

            ElevatedButton(onPressed: createCategory, child: const Text('登録')),
          ],
        ),
      ),
    );
  }

  Future<void> createCategory() async {
    if (nameController.text.isEmpty) {
      return;
    }

    if (selectedParentId == null) {
      return;
    }

    final householdId = context.read<CurrentHouseholdProvider>().householdId;

    if (householdId == null) {
      return;
    }

    await CategoryService.createCategory(
      householdId: householdId,
      parentCategoryId: selectedParentId!,
      name: nameController.text,
    );

    if (!mounted) return;

    Navigator.pop(context);
  }
}
