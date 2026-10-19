import 'package:flutter/material.dart';

import '../services/category_service.dart';

class CategoryEditPage extends StatefulWidget {
  final Map<String, dynamic> category;

  const CategoryEditPage({super.key, required this.category});

  @override
  State<CategoryEditPage> createState() => _CategoryEditPageState();
}

class _CategoryEditPageState extends State<CategoryEditPage> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.category['name']);
  }

  Future<void> updateCategory() async {
    await CategoryService.updateCategory(
      categoryId: widget.category['id'],
      name: nameController.text,
    );

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('カテゴリ編集')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'カテゴリ名'),
            ),

            const SizedBox(height: 24),

            ElevatedButton(onPressed: updateCategory, child: const Text('保存')),

            const SizedBox(height: 16),

            if (widget.category['parent_category_id'] != null)
              OutlinedButton(
                onPressed: showDeactivateDialog,
                child: const Text('無効化'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> deactivateCategory() async {
    await CategoryService.deactivateCategory(categoryId: widget.category['id']);

    if (!mounted) return;

    Navigator.pop(context);
  }

  Future<void> showDeactivateDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('確認'),
          content: Text('カテゴリ「${widget.category['name']}」を無効化しますか？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('無効化'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await deactivateCategory();
    }
  }
}
