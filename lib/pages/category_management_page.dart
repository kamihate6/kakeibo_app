import 'package:flutter/material.dart';

import 'category_create_page.dart';
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
    loadCategories();
  }

  Future<void> loadCategories() async {
    final result = await CategoryService.getCategories();

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
            title: Text(parent['name']),
            children: childCategories.map((child) {
              return ListTile(
                leading: const Icon(Icons.subdirectory_arrow_right),
                title: Text(child['name']),
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
