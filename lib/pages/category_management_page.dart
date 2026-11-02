import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/loading_overlay.dart';

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

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadCategories();
    });
  }

  Future<void> loadCategories() async {
    final householdId = context.read<CurrentHouseholdProvider>().householdId;

    if (householdId == null) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await CategoryService.getCategories(householdId);

      for (final c in result) {
        debugPrint('${c['name']} sort=${c['sort_order']}');
      }

      result.sort((a, b) {
        final aOrder = a['sort_order'] ?? 0;
        final bOrder = b['sort_order'] ?? 0;

        return aOrder.compareTo(bOrder);
      });

      debugPrint('---- after sort ----');

      for (final c in result) {
        debugPrint('${c['name']} sort=${c['sort_order']}');
      }

      result.sort((a, b) {
        final aOrder = a['sort_order'] ?? 9999;
        final bOrder = b['sort_order'] ?? 9999;

        return aOrder.compareTo(bOrder);
      });

      if (!mounted) {
        return;
      }

      setState(() {
        categories = result;
      });
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
      appBar: AppBar(title: const Text('カテゴリ管理')),
      body: LoadingOverlay(
        isLoading: isLoading,
        message: 'カテゴリを読み込み中...',
        child: ListView(
          children: categories
              .where((c) => c['parent_category_id'] == null)
              .map((parent) {
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
                              builder: (_) =>
                                  CategoryEditPage(category: parent),
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
              })
              .toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isLoading
            ? null
            : () {
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
