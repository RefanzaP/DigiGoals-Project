import 'package:flutter/material.dart';
// mengimpor theme.dart dari folder theme
import 'theme/theme.dart';
import 'splash_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digi',
      home: SplashScreen()
    );
  }
}

class NavigationExample extends StatefulWidget {
  @override
  _NavigationExampleState createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0; // Indeks halaman/tab aktif


  final List<NavigationDestination> destinations = [
    NavigationDestination(icon: Icon(Icons.inbox), label: 'Inbox',  selectedIcon: Icon(Icons.inbox, color: AppColors.secondaryColor)),
    NavigationDestination(icon: Icon(Icons.favorite), label: 'Favorit',  selectedIcon: Icon(Icons.favorite, color: AppColors.secondaryColor)),
    NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: '',  selectedIcon: Icon(Icons.qr_code_scanner, color: AppColors.secondaryColor)),
    NavigationDestination(icon: Icon(Icons.settings), label: 'Setting',  selectedIcon: Icon(Icons.settings, color: AppColors.secondaryColor)),
    NavigationDestination(icon: Icon(Icons.logout), label: 'Keluar',  selectedIcon: Icon(Icons.logout, color: AppColors.secondaryColor)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF19A7D7), 
        elevation: 0,
        title: Text(''),
      ),
      body: Center(
        child: Text('Page $currentPageIndex', style: TextStyle(fontSize: 18)),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: destinations, // Tambahkan daftar destinasi
        selectedIndex: currentPageIndex, // Indeks aktif
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index; // Ubah tab aktif
          });
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
