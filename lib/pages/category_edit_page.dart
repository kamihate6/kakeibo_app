import 'package:flutter/material.dart';

import '../widgets/loading_overlay.dart';
import '../services/category_service.dart';

class CategoryEditPage extends StatefulWidget {
  final Map<String, dynamic> category;

  const CategoryEditPage({super.key, required this.category});

  @override
  State<CategoryEditPage> createState() => _CategoryEditPageState();
}

class _CategoryEditPageState extends State<CategoryEditPage> {
  late TextEditingController nameController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.category['name']);
  }

  Future<void> updateCategory() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('カテゴリ名を入力してください')));

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await CategoryService.updateCategory(
        categoryId: widget.category['id'],
        name: nameController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('カテゴリを更新しました')));

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

  Future<void> deactivateCategory() async {
    setState(() {
      isLoading = true;
    });

    try {
      await CategoryService.deactivateCategory(
        categoryId: widget.category['id'],
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('カテゴリを無効化しました')));

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('カテゴリ編集')),
      body: LoadingOverlay(
        isLoading: isLoading,
        message: 'カテゴリを更新中...',
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'カテゴリ名'),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: isLoading ? null : updateCategory,
                child: const Text('保存'),
              ),

              const SizedBox(height: 16),

              if (widget.category['parent_category_id'] != null)
                OutlinedButton(
                  onPressed: isLoading ? null : showDeactivateDialog,
                  child: const Text('無効化'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
