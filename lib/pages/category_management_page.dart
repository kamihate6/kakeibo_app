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

  Future<void> moveCategoryUp(Map<String, dynamic> category) async {
    final currentOrder = category['sort_order'];

    final target = categories
        .where(
          (c) =>
              c['parent_category_id'] == null && c['sort_order'] < currentOrder,
        )
        .toList();

    if (target.isEmpty) return;

    target.sort((a, b) => b['sort_order'].compareTo(a['sort_order']));

    final swap = target.first;

    await CategoryService.updateSortOrder(
      categoryId: category['id'],
      sortOrder: swap['sort_order'],
    );

    await CategoryService.updateSortOrder(
      categoryId: swap['id'],
      sortOrder: currentOrder,
    );

    await loadCategories();
  }

  Future<void> moveCategoryDown(Map<String, dynamic> category) async {
    final currentOrder = category['sort_order'];

    final target = categories
        .where(
          (c) =>
              c['parent_category_id'] == null && c['sort_order'] > currentOrder,
        )
        .toList();

    if (target.isEmpty) return;

    target.sort((a, b) => a['sort_order'].compareTo(b['sort_order']));

    final swap = target.first;

    await CategoryService.updateSortOrder(
      categoryId: category['id'],
      sortOrder: swap['sort_order'],
    );

    await CategoryService.updateSortOrder(
      categoryId: swap['id'],
      sortOrder: currentOrder,
    );

    await loadCategories();
  }

  Future<void> moveChildCategoryUp(Map<String, dynamic> category) async {
    final currentOrder = category['sort_order'];

    final target = categories
        .where(
          (c) =>
              c['parent_category_id'] == category['parent_category_id'] &&
              c['sort_order'] < currentOrder,
        )
        .toList();

    if (target.isEmpty) return;

    target.sort((a, b) => b['sort_order'].compareTo(a['sort_order']));

    final swap = target.first;

    await CategoryService.updateSortOrder(
      categoryId: category['id'],
      sortOrder: swap['sort_order'],
    );

    await CategoryService.updateSortOrder(
      categoryId: swap['id'],
      sortOrder: currentOrder,
    );

    await loadCategories();
  }

  Future<void> moveChildCategoryDown(Map<String, dynamic> category) async {
    final currentOrder = category['sort_order'];

    final target = categories
        .where(
          (c) =>
              c['parent_category_id'] == category['parent_category_id'] &&
              c['sort_order'] > currentOrder,
        )
        .toList();

    if (target.isEmpty) return;

    target.sort((a, b) => a['sort_order'].compareTo(b['sort_order']));

    final swap = target.first;

    await CategoryService.updateSortOrder(
      categoryId: category['id'],
      sortOrder: swap['sort_order'],
    );

    await CategoryService.updateSortOrder(
      categoryId: swap['id'],
      sortOrder: currentOrder,
    );

    await loadCategories();
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
                childCategories.sort(
                  (a, b) => (a['sort_order'] ?? 9999).compareTo(
                    b['sort_order'] ?? 9999,
                  ),
                );

                return ExpansionTile(
                  title: Row(
                    children: [
                      Expanded(child: Text(parent['name'])),

                      IconButton(
                        icon: const Icon(Icons.arrow_upward),
                        onPressed: () {
                          moveCategoryUp(parent);
                        },
                      ),

                      IconButton(
                        icon: const Icon(Icons.arrow_downward),
                        onPressed: () {
                          moveCategoryDown(parent);
                        },
                      ),

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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_upward),
                            onPressed: () {
                              moveChildCategoryUp(child);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_downward),
                            onPressed: () {
                              moveChildCategoryDown(child);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CategoryEditPage(category: child),
                                ),
                              ).then((_) {
                                loadCategories();
                              });
                            },
                          ),
                        ],
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
