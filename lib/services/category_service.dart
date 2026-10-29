import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryService {
  static Future<List<dynamic>> getCategories([String? householdId]) async {
    if (householdId != null) {
      return await Supabase.instance.client
          .from('categories')
          .select()
          .eq('household_id', householdId)
          .eq('is_active', true)
          .order('parent_category_id')
          .order('sort_order')
          .order('name');
    }

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return [];
    }

    final member = await Supabase.instance.client
        .from('household_members')
        .select()
        .eq('user_id', user.id)
        .single();

    return await Supabase.instance.client
        .from('categories')
        .select()
        .eq('household_id', member['household_id'])
        .eq('is_active', true)
        .order('parent_category_id')
        .order('sort_order')
        .order('name');
  }

  static Future<void> createCategory({
    required String householdId,
    required String parentCategoryId,
    required String name,
  }) async {
    await Supabase.instance.client.from('categories').insert({
      'household_id': householdId,
      'parent_category_id': parentCategoryId,
      'name': name,
      'type': 'BOTH',
      'sort_order': 0,
      'is_active': true,
    });
  }

  static Future<void> updateCategory({
    required String categoryId,
    required String name,
  }) async {
    await Supabase.instance.client
        .from('categories')
        .update({'name': name, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', categoryId);
  }

  static Future<void> deactivateCategory({required String categoryId}) async {
    await Supabase.instance.client
        .from('categories')
        .update({
          'is_active': false,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', categoryId);
  }

  static Future<List<dynamic>> getParentCategories(String householdId) async {
    return await Supabase.instance.client
        .from('categories')
        .select()
        .eq('household_id', householdId)
        .isFilter('parent_category_id', null)
        .eq('is_active', true)
        .order('sort_order')
        .order('name');
  }
}
