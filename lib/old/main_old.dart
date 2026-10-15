import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xbgpdfzlwfvpbqfyyzgk.supabase.co',
    anonKey: 'sb_publishable_-Fgs_vTozv5ywtpzD5KYKg_mWy4sAgo',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class HouseholdSetupPage extends StatefulWidget {
  const HouseholdSetupPage({super.key});

  @override
  State<HouseholdSetupPage> createState() => _HouseholdSetupPageState();
}

class _HouseholdSetupPageState extends State<HouseholdSetupPage> {
  final householdController = TextEditingController();

  Future<void> createHousehold() async {
    if (householdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('世帯名を入力してください')));
      return;
    }

    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) return;

      final household = await Supabase.instance.client
          .from('households')
          .insert({
            'name': householdController.text.trim(),
            'owner_user_id': user.id,
          })
          .select()
          .single();

      await Supabase.instance.client.from('household_members').insert({
        'household_id': household['id'],
        'user_id': user.id,
        'role': 'ADMIN',
      });

      await Supabase.instance.client.from('categories').insert([
        {'household_id': household['id'], 'name': '食費', 'type': 'BOTH'},
        {'household_id': household['id'], 'name': '日用品', 'type': 'BOTH'},
        {'household_id': household['id'], 'name': '住宅', 'type': 'HOUSEHOLD'},
        {'household_id': household['id'], 'name': '通信費', 'type': 'BOTH'},
        {'household_id': household['id'], 'name': '交通費', 'type': 'BOTH'},
        {'household_id': household['id'], 'name': '医療費', 'type': 'BOTH'},
        {'household_id': household['id'], 'name': '娯楽', 'type': 'BOTH'},
        {'household_id': household['id'], 'name': 'その他', 'type': 'BOTH'},
      ]);

      print('HOUSEHOLD CREATED');

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('世帯作成')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: householdController,
              decoration: const InputDecoration(labelText: '世帯名'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: createHousehold,
              child: const Text('世帯作成'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthPageState extends State<AuthPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> signUp() async {
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = response.user;

      print("AUTH SUCCESS");

      if (user != null) {
        await Supabase.instance.client.from('profiles').insert({
          'id': user.id,
          'display_name': emailController.text.split('@').first,
        });

        print("PROFILE CREATED");
      }

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('登録成功')));
      }
    } catch (e) {
      print("ERROR");
      print(e);
    }
  }

  Future<void> signIn() async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = response.user;

      if (user == null) return;

      final members = await Supabase.instance.client
          .from('household_members')
          .select()
          .eq('user_id', user.id);

      if (!mounted) return;

      if (members.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HouseholdSetupPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('家計簿アプリ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'メールアドレス'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'パスワード'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: signUp, child: const Text('新規登録')),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: signIn, child: const Text('ログイン')),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('家計簿アプリ')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddExpensePage()),
                );
              },
              child: const Text('支出登録'),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryPage()),
                );
              },
              child: const Text('支出履歴'),
            ),
          ],
        ),
      ),
    );
  }
}

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  List<dynamic> categories = [];

  String? selectedCategoryId;

  final amountController = TextEditingController();

  final memoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    final member = await Supabase.instance.client
        .from('household_members')
        .select()
        .eq('user_id', user.id)
        .single();

    final result = await Supabase.instance.client
        .from('categories')
        .select()
        .eq('household_id', member['household_id']);

    setState(() {
      categories = result;

      if (result.isNotEmpty) {
        selectedCategoryId = result.first['id'];
      }
    });
  }

  Future<void> saveExpense() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) return;

      final member = await Supabase.instance.client
          .from('household_members')
          .select()
          .eq('user_id', user.id)
          .single();

      final householdId = member['household_id'];

      await Supabase.instance.client.from('expenses').insert({
        'household_id': householdId,
        'user_id': user.id,
        'category_id': selectedCategoryId,
        'payer_user_id': user.id,
        'amount': int.parse(amountController.text),
        'expense_date': DateTime.now().toIso8601String().substring(0, 10),
        'expense_type': 'HOUSEHOLD',
        'memo': memoController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('支出登録完了')));

        Navigator.pop(context);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('支出登録')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: '金額'),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: selectedCategoryId,
              decoration: const InputDecoration(labelText: 'カテゴリ'),
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category['id'],
                  child: Text(category['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategoryId = value;
                });
              },
            ),

            const SizedBox(height: 16),

            TextField(
              controller: memoController,
              decoration: const InputDecoration(labelText: 'メモ'),
            ),

            const SizedBox(height: 24),

            ElevatedButton(onPressed: saveExpense, child: const Text('保存')),
          ],
        ),
      ),
    );
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> expenses = [];

  Future<void> loadExpenses() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    final member = await Supabase.instance.client
        .from('household_members')
        .select()
        .eq('user_id', user.id)
        .single();

    final result = await Supabase.instance.client
        .from('expenses')
        .select('''
            *,
            categories(name)
          ''')
        .eq('household_id', member['household_id'])
        .order('expense_date');

    setState(() {
      expenses = result;
    });
  }

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('支出履歴')),
      body: ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expense = expenses[index];

          return ListTile(
            title: Text("${expense['amount']}円"),
            subtitle: Text(
              "${expense['categories']['name']} ${expense['memo'] ?? ''}",
            ),
          );
        },
      ),
    );
  }
}
