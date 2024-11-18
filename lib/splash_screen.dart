import 'package:flutter/material.dart';
import 'dart:async'; // Untuk Timer
import 'main.dart'; // Mengimpor MainApp dari main.dart
import 'theme/theme.dart';

void main() => runApp(MySplash());

class MySplash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigasi otomatis ke halaman utama setelah 3 detik
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NavigationExample()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/digi_image.png'), 
            fit: BoxFit.cover, 
          ),
        ),
      
        ),
      );
  }
}
