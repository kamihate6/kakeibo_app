import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'category_create_page.dart';
import 'category_edit_page.dart';

import '../providers/current_household_provider.dart';
import '../services/category_service.dart';

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  List<dynamic> categories = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadCategories();
    });
  }

  Future<void> loadCategories() async {
    final householdId = context.read<CurrentHouseholdProvider>().householdId;

    debugPrint('Current householdId=$householdId');

    if (householdId == null) {
      return;
    }

    final result = await CategoryService.getCategories(householdId);

    setState(() {
      categories = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('カテゴリ管理')),
      body: ListView(
        children: categories.where((c) => c['parent_category_id'] == null).map((
          parent,
        ) {
          final childCategories = categories
              .where((c) => c['parent_category_id'] == parent['id'])
              .toList();

          return ExpansionTile(
            title: Row(
              children: [
                Expanded(child: Text(parent['name'])),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryEditPage(category: parent),
                      ),
                    ).then((_) {
                      loadCategories();
                    });
                  },
                ),
              ],
            ),

            children: childCategories.map((child) {
              return ListTile(
                leading: const Icon(Icons.subdirectory_arrow_right),
                title: Text(child['name']),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryEditPage(category: child),
                      ),
                    ).then((_) {
                      loadCategories();
                    });
                  },
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CategoryCreatePage()),
          ).then((_) {
            loadCategories();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
