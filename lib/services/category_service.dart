import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryService {
  static Future<List<dynamic>> getCategories() async {
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
        .order('sort_order');
  }

  static Future<void> createCategory({
    required String parentCategoryId,
    required String name,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    final member = await Supabase.instance.client
        .from('household_members')
        .select()
        .eq('user_id', user.id)
        .single();

    await Supabase.instance.client.from('categories').insert({
      'household_id': member['household_id'],
      'parent_category_id': parentCategoryId,
      'name': name,
      'type': 'BOTH',
      'sort_order': 0,
      'is_active': true,
    });
  }
}
