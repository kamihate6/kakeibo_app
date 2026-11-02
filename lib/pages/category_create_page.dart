import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/loading_overlay.dart';

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

  bool isParentCategory = false;

  bool isLoading = false;

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

    setState(() {
      isLoading = true;
    });

    try {
      final categories = await CategoryService.getCategories(householdId);

      categories.sort((a, b) {
        final aOrder = a['sort_order'] ?? 0;
        final bOrder = b['sort_order'] ?? 0;

        return aOrder.compareTo(bOrder);
      });

      final parents = categories
          .where((c) => c['parent_category_id'] == null)
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        parentCategories = parents;

        if (parents.isNotEmpty) {
          selectedParentId = parents.first['id'];
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> createCategory() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('カテゴリ名を入力してください')));

      return;
    }

    if (!isParentCategory && selectedParentId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('親カテゴリを選択してください')));

      return;
    }

    final householdId = context.read<CurrentHouseholdProvider>().householdId;

    if (householdId == null) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await CategoryService.createCategory(
        householdId: householdId,
        parentCategoryId: isParentCategory ? null : selectedParentId,
        name: nameController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('カテゴリを作成しました')));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
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
      appBar: AppBar(title: const Text('カテゴリ追加')),
      body: LoadingOverlay(
        isLoading: isLoading,
        message: 'カテゴリを作成中...',
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('親カテゴリとして作成'),
                value: isParentCategory,
                onChanged: (value) {
                  setState(() {
                    isParentCategory = value;
                  });
                },
              ),
              if (!isParentCategory)
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

              ElevatedButton(
                onPressed: isLoading ? null : createCategory,
                child: const Text('登録'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
