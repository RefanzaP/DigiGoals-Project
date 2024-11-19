import 'package:flutter/material.dart';
import 'theme/theme.dart'; 

void main() {
  runApp(ourGoals());
}

class MyGoals extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digi',
      home: ourGoals(),
    );
  }
}

class ourGoals extends StatefulWidget {
  @override
  _OurGoalsState createState() => _OurGoalsState();
}

class _OurGoalsState extends State<ourGoals> {
  @override
  int currentPageIndex = 0;
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        elevation: 0,
        toolbarHeight: 84, 
        titleSpacing: 16, // Menghilangkan padding default
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Ikon panah kiri
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context); 
              },
            ),
            // Teks di tengah
            Text(
              'Buat Goals',
              style: AppTextStyle.bodyText1.copyWith(color: Colors.white),
            ),
            // Lingkaran hijau di kanan
            Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                color: Colors.green, // Warna lingkaran
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '', // Isi lingkaran (opsional)
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Isi Halaman'),
      ),
     bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: NavigationBar(
              destinations: [
                NavigationDestination(
                  icon: currentPageIndex == 0
                      ? Icon(Icons.inbox) 
                      : Icon(Icons.inbox_outlined), 
                  label: 'Inbox',
                ),
                NavigationDestination(
                  icon: currentPageIndex == 1
                      ? Icon(Icons.favorite)
                      : Icon(Icons.favorite_border), 
                  label: 'Favorit',
                ),
                NavigationDestination(
                  icon: currentPageIndex == 2
                      ? Icon(Icons.qr_code_scanner) 
                      : Icon(Icons.qr_code_scanner), 
                  label: '',
                ),
                NavigationDestination(
                  icon: currentPageIndex == 3
                      ? Icon(Icons.settings) 
                      : Icon(Icons.settings_outlined), 
                  label: 'Setting',
                ),
                NavigationDestination(
                  icon: currentPageIndex == 4
                      ? Icon(Icons.logout) 
                      : Icon(Icons.logout), 
                  label: 'Keluar',
                ),
              ],
              selectedIndex: currentPageIndex,
              backgroundColor: AppColors.white,
              onDestinationSelected: (int index) {
                setState(() {
                });
              },
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            ),
          ),
        ],
      ),
    
    );
  }


}
