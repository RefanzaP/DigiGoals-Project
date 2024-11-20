import 'package:flutter/material.dart';
import 'theme/theme.dart';

void main() {
  runApp(MyGoals());
}

class MyGoals extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digi',
      home: OurGoals(),
    );
  }
}

class OurGoals extends StatefulWidget {
  @override
  _OurGoalsState createState() => _OurGoalsState();
}

class _OurGoalsState extends State<OurGoals> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        elevation: 0,
        toolbarHeight: 84,
        titleSpacing: 16,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Text(
              'Buat Goals',
              style: AppTextStyle.bodyText1.copyWith(color: Colors.white),
            ),
            Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 16), // Jarak 16px dari AppBar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20), // Margin kanan-kiri 20px
            width: MediaQuery.of(context).size.width - 40, // Responsif
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20), // Padding atas-bawah 20px
              child: Stack(
                clipBehavior: Clip.none, // Membiarkan logo tetap di luar jika diperlukan
                children: [
                  // Logo bank bjb di pojok kanan atas
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Image.asset(
                      'assets/images/bankbjb-logo.png',
                      width: 51,
                      height: 26,
                    ),
                  ),
                  // Konten utama
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.yellow1,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(Icons.add, size: 32, color: Colors.grey[700]),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Buat Tabungan Bersamamu!',
                          style: AppTextStyle.bodyMText1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sesuaikan Goals kamu untuk hal yang kamu inginkan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
                  icon: Icon(Icons.qr_code_scanner),
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
                  currentPageIndex = index;
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
