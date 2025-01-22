import 'package:digigoals_app/Inbox.dart';
import 'package:digigoals_app/SplashScreen.dart';
import 'package:digigoals_app/OurGoals.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

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
        '/ourGoals': (context) => OurGoals(),
        '/inbox': (context) => Inbox(),
      },
    );
  }
}
