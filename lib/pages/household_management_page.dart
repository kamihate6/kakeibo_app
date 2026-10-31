import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/loading_overlay.dart';
import '../services/household_service.dart';

class HouseholdManagementPage extends StatefulWidget {
  final Map<String, dynamic> household;

  const HouseholdManagementPage({super.key, required this.household});

  @override
  State<HouseholdManagementPage> createState() =>
      _HouseholdManagementPageState();
}

class _HouseholdManagementPageState extends State<HouseholdManagementPage> {
  List<dynamic> members = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadMembers();
  }

  Future<void> loadMembers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await HouseholdService.getMembers(widget.household['id']);

      if (!mounted) {
        return;
      }

      setState(() {
        members = result;
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> renameHousehold() async {
    final controller = TextEditingController(text: widget.household['name']);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('家計簿名変更'),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );

    if (result == null || result.isEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await HouseholdService.renameHousehold(
        householdId: widget.household['id'],
        name: result,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('家計簿名を更新しました')));
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
      appBar: AppBar(title: const Text('家計簿管理')),
      body: LoadingOverlay(
        isLoading: isLoading,
        message: '家計簿情報を更新中...',
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.household['name'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              const Text('招待コード'),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.household['invite_code']?.toString() ?? '未発行',
                    ),
                  ),

                  IconButton(
                    onPressed: () async {
                      final code = widget.household['invite_code'];

                      if (code == null) {
                        return;
                      }

                      await Clipboard.setData(ClipboardData(text: code));

                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('コピーしました')));
                    },
                    icon: const Icon(Icons.copy),
                  ),
                ],
              ),

              const Divider(),

              const Text(
                'メンバー',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              ...members.map((member) {
                return ListTile(
                  dense: true,
                  leading: Icon(
                    member['role'] == 'ADMIN'
                        ? Icons.admin_panel_settings
                        : Icons.person,
                  ),
                  title: Text(member['user_id'].toString().substring(0, 8)),
                  subtitle: Text(member['role'] == 'ADMIN' ? '管理者' : 'メンバー'),
                );
              }),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: isLoading ? null : renameHousehold,
                child: const Text('家計簿名変更'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
