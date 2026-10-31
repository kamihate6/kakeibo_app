import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

class HouseholdService {
  static Future<List<dynamic>> getHouseholds() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return [];
    }

    final result = await Supabase.instance.client
        .from('household_members')
        .select('''
  household_id,
  households(
    id,
    name,
    invite_code
          )
        ''')
        .eq('user_id', user.id);

    return result;
  }

  static Future<void> createHousehold(String name) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      throw Exception('ログインしてください');
    }

    // household作成
    final household = await Supabase.instance.client
        .from('households')
        .insert({
          'name': name,
          'owner_user_id': user.id,
          'invite_code': generateInviteCode(),
        })
        .select()
        .single();
    final householdId = household['id'];

    // household_member作成
    await Supabase.instance.client.from('household_members').insert({
      'household_id': householdId,
      'user_id': user.id,
      'role': 'ADMIN',
    });

    // 親カテゴリ作成
    final categories = await Supabase.instance.client.from('categories').insert(
      [
        {
          'household_id': householdId,
          'name': '食費',
          'type': 'BOTH',
          'sort_order': 1,
        },
        {
          'household_id': householdId,
          'name': '日用品',
          'type': 'BOTH',
          'sort_order': 2,
        },
        {
          'household_id': householdId,
          'name': '交通費',
          'type': 'BOTH',
          'sort_order': 3,
        },
        {
          'household_id': householdId,
          'name': '通信費',
          'type': 'BOTH',
          'sort_order': 4,
        },
        {
          'household_id': householdId,
          'name': '住宅',
          'type': 'BOTH',
          'sort_order': 5,
        },
        {
          'household_id': householdId,
          'name': '医療費',
          'type': 'BOTH',
          'sort_order': 6,
        },
        {
          'household_id': householdId,
          'name': '娯楽',
          'type': 'BOTH',
          'sort_order': 7,
        },
        {
          'household_id': householdId,
          'name': 'その他',
          'type': 'BOTH',
          'sort_order': 8,
        },
      ],
    ).select();

    // 予算プラン作成
    final budgetPlan = await Supabase.instance.client
        .from('budget_plans')
        .insert({
          'household_id': householdId,
          'name': '初期予算',
          'version': 1,
          'effective_from': DateTime.now().toIso8601String().substring(0, 10),
          'status': 'ACTIVE',
          'created_by': user.id,
        })
        .select()
        .single();

    final budgetPlanId = budgetPlan['id'];

    // 予算明細作成（親カテゴリのみ）
    final budgetItems = categories.map((category) {
      return {
        'budget_plan_id': budgetPlanId,
        'category_id': category['id'],
        'scope': 'HOUSEHOLD',
        'yearly_amount': 0,
      };
    }).toList();

    await Supabase.instance.client.from('budget_items').insert(budgetItems);
  }

  static String generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

    final random = Random();

    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  static Future<List<dynamic>> getHouseholdMembers(String householdId) async {
    return await Supabase.instance.client
        .from('household_members')
        .select('''
        role,
        user_id
      ''')
        .eq('household_id', householdId);
  }

  static Future<List<dynamic>> getMembers(String householdId) async {
    return await Supabase.instance.client
        .from('household_members')
        .select()
        .eq('household_id', householdId);
  }

  static Future<void> renameHousehold({
    required String householdId,
    required String name,
  }) async {
    await Supabase.instance.client
        .from('households')
        .update({'name': name})
        .eq('id', householdId);
  }
}
