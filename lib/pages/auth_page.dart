import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'home_page.dart';
import 'household_setup_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> signUp() async {
    try {
      setState(() {
        isLoading = true;
      });

      await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('登録しました。確認メールが届いている場合は認証後にログインしてください。')),
      );
    } catch (e) {
      debugPrint('SIGNUP ERROR: $e');

      if (!mounted) return;

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

  Future<void> signIn() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = response.user;

      if (user == null) {
        throw Exception('ログインに失敗しました');
      }

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
      debugPrint('LOGIN ERROR: $e');

      if (!mounted) return;

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
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
            if (isLoading)
              const CircularProgressIndicator()
            else ...[
              ElevatedButton(onPressed: signUp, child: const Text('新規登録')),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: signIn, child: const Text('ログイン')),
            ],
          ],
        ),
      ),
    );
  }
}
