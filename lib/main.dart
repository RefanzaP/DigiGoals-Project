import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'First App',
      home: NavigationExample(), // Gunakan widget NavigationExample
    );
  }
}

class NavigationExample extends StatefulWidget {
  @override
  _NavigationExampleState createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0; // Indeks halaman/tab aktif

  // Daftar destinasi
  final List<NavigationDestination> destinations = [
    NavigationDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
    NavigationDestination(icon: Icon(Icons.favorite), label: 'Favorit'),
    NavigationDestination(icon: Icon(Icons.settings), label: 'Setting'),
    NavigationDestination(icon: Icon(Icons.logout), label: 'Keluar'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF19A7D7), // Perbaiki warna
        elevation: 0,
        title: Text('e'),
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
