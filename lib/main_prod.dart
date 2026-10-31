import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pages/splash_page.dart';

import 'package:provider/provider.dart';

import 'providers/current_household_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://tkhajeoffjvvrampqbnw.supabase.co',
    anonKey: 'sb_publishable_6jq8r4WpL_g6bGpdGMgmbg_EpRV3rLC',
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => CurrentHouseholdProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashPage(),
    );
  }
}
