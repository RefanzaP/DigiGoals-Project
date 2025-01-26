import 'package:digigoals_app/Beranda.dart';
import 'package:digigoals_app/SplashScreen.dart';
import 'package:digigoals_app/OurGoals.dart';
import 'package:digigoals_app/auth/token_manager.dart'; // Import TokenManager
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider

void main() => runApp(
      // Gunakan MultiProvider untuk menyediakan TokenManager
      MultiProvider(
        providers: [
          Provider<TokenManager>(create: (_) => TokenManager()),
        ],
        child: const MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digi Bank BJB (OurGoals)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/beranda': (context) => const Beranda(),
        '/ourGoals': (context) => OurGoals(),
      },
    );
  }
}
