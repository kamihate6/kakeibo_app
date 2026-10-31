import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import '../widgets/loading_overlay.dart';
import '../providers/current_household_provider.dart';
import '../services/category_service.dart';
import '../services/household_service.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  bool isSaving = false;
  List<dynamic> categories = [];

  final Map<String, TextEditingController> controllers = {};

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

    final result = await CategoryService.getCategories(householdId);

    debugPrint(result.toString());

    for (final category in result) {
      controllers[category['id']] = TextEditingController();
    }

    final ordered = <dynamic>[];

    final parents = result.where((c) => c['parent_category_id'] == null);

    for (final parent in parents) {
      ordered.add(parent);

      ordered.addAll(
        result.where((c) => c['parent_category_id'] == parent['id']),
      );
    }

    setState(() {
      categories = ordered;
    });

    await loadBudget();
  }

  Future<void> loadBudget() async {
    final householdId = context.read<CurrentHouseholdProvider>().householdId;

    if (householdId == null) {
      return;
    }

    final plans = await Supabase.instance.client
        .from('budget_plans')
        .select()
        .eq('household_id', householdId)
        .eq('version', 1);

    if (plans.isEmpty) {
      return;
    }

    final plan = plans.first;

    final items = await Supabase.instance.client
        .from('budget_items')
        .select()
        .eq('budget_plan_id', plan['id']);

    for (final item in items) {
      final categoryId = item['category_id'];

      final controller = controllers[categoryId];

      if (controller != null) {
        controller.text = item['yearly_amount'].toString();
      }
    }

    setState(() {});
  }

  Future<void> saveBudget() async {
    setState(() {
      isSaving = true;
    });
    try {
      // 親カテゴリ予算チェック
      for (final parent in categories.where(
        (c) => c['parent_category_id'] == null,
      )) {
        final parentAmount =
            int.tryParse(controllers[parent['id']]?.text ?? '') ?? 0;

        final children = categories.where(
          (c) => c['parent_category_id'] == parent['id'],
        );

        int childTotal = 0;

        for (final child in children) {
          childTotal += int.tryParse(controllers[child['id']]?.text ?? '') ?? 0;
        }

        if (childTotal > parentAmount) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${parent['name']} の子カテゴリ予算が親カテゴリ予算を超えています'),
              ),
            );
          }

          setState(() {
            isSaving = false;
          });

          return;
        }
      }
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        return;
      }

      final householdId = context.read<CurrentHouseholdProvider>().householdId;

      if (householdId == null) {
        return;
      }

      final existingPlans = await Supabase.instance.client
          .from('budget_plans')
          .select()
          .eq('household_id', householdId)
          .eq('version', 1);

      dynamic plan;

      if (existingPlans.isEmpty) {
        plan = await Supabase.instance.client
            .from('budget_plans')
            .insert({
              'household_id': householdId,
              'name': '2026予算',
              'version': 1,
              'effective_from': DateTime.now().toIso8601String().substring(
                0,
                10,
              ),
              'status': 'ACTIVE',
              'created_by': user.id,
            })
            .select()
            .single();
      } else {
        plan = existingPlans.first;
      }

      for (final category in categories) {
        final categoryId = category['id'];

        final controller = controllers[categoryId];

        final amount = int.tryParse(controller?.text ?? '') ?? 0;

        final existingItems = await Supabase.instance.client
            .from('budget_items')
            .select()
            .eq('budget_plan_id', plan['id'])
            .eq('category_id', categoryId);

        if (existingItems.isEmpty) {
          await Supabase.instance.client.from('budget_items').insert({
            'budget_plan_id': plan['id'],
            'category_id': categoryId,
            'scope': 'HOUSEHOLD',
            'yearly_amount': amount,
          });
        } else {
          await Supabase.instance.client
              .from('budget_items')
              .update({'yearly_amount': amount})
              .eq('id', existingItems.first['id']);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('予算を保存しました')));
      }
    } catch (e) {
      debugPrint('saveBudget error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  int getChildTotal(String parentId) {
    int total = 0;

    for (final category in categories) {
      if (category['parent_category_id'] == parentId) {
        total += int.tryParse(controllers[category['id']]?.text ?? '') ?? 0;
      }
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('予算')),
      body: LoadingOverlay(
        isLoading: isSaving,
        message: '予算を保存中...',
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isChild = category['parent_category_id'] != null;

                    return Padding(
                      padding: EdgeInsets.only(
                        left: isChild ? 24 : 0,
                        bottom: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: controllers[category['id']],
                            keyboardType: TextInputType.number,
                            onChanged: (_) {
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              labelText: isChild
                                  ? '└ ${category['name']}'
                                  : category['name'],
                              border: const OutlineInputBorder(),
                            ),
                          ),

                          if (!isChild)
                            Builder(
                              builder: (_) {
                                final parentBudget =
                                    int.tryParse(
                                      controllers[category['id']]?.text ?? '',
                                    ) ??
                                    0;

                                final childTotal = getChildTotal(
                                  category['id'],
                                );

                                final remain = parentBudget - childTotal;

                                return Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    left: 8,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '子合計: $childTotal   残り: $remain',
                                        style: TextStyle(
                                          color: remain < 0
                                              ? Colors.red
                                              : Colors.grey,
                                        ),
                                      ),

                                      if (remain < 0)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            '⚠ 子カテゴリ予算が ${remain.abs()} 円超過しています',
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const Divider(),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '合計予算',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$totalBudget 円',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: isSaving ? null : saveBudget,
                child: const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int get totalBudget {
    int total = 0;

    for (final controller in controllers.values) {
      total += int.tryParse(controller.text) ?? 0;
    }

    return total;
  }
}
