import 'package:digigoals_app/ourGoals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Pastikan package ini ada
import 'theme/theme.dart';
import 'splash_screen.dart';
import 'ourGoals.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digi',
      home: SplashScreen(),
    );
  }
}

class dashboardMenu extends StatefulWidget {
  @override
  _dashboardMenuState createState() => _dashboardMenuState();
}

class _dashboardMenuState extends State<dashboardMenu> {
  int currentPageIndex = 0;

  final List<NavigationDestination> destinations = [
    NavigationDestination(
      icon: Icon(Icons.inbox_outlined),
      label: 'Inbox',
    ),
    NavigationDestination(
      icon: Icon(Icons.favorite_border),
      label: 'Favorit',
    ),
    NavigationDestination(
      icon: Icon(Icons.qr_code_scanner),
      label: '',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      label: 'Setting',
    ),
    NavigationDestination(
      icon: Icon(Icons.logout),
      label: 'Keluar',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: const Text(''),
      ),
      body: Column(
        children: [
          // top navbar
          Container(
            height: 368,
            color: AppColors.primaryColor,
            child: Center(
              child: Text(
                '',
                style: AppTextStyle.headline1.copyWith(color: AppColors.white),
              ),
            ),
          ),
          // main content
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildContent(Icons.money_rounded, "Manajemen\nKeuangan"),
                          _buildContent(Icons.send, "Transfer"),
                          _buildContent(Icons.receipt, "Bayar"),
                          _buildContent(Icons.shopping_cart, "Beli"),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildContent(Icons.credit_card, "Cardless"),
                          _buildContent(Icons.people, "Buka\nRekening bjb"),
                          _buildContent(Icons.compare_arrows, "BJB\nDeposito "),
                          _buildContent('assets/icons/emergency-svgrepo-com 1.svg', "Flip"),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildContent(Icons.favorite_border, "Donasi"),
                          _buildContent(Icons.toll, "Collect\nDana"),
                          _buildContent(Icons.flag, "Pinjaman\nASN"),
                          _buildContent('assets/icons/pig_money.svg', "Our Goals"),
                        ],
                      ),
                    ),
                  ],
                ),
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

  /// Widget untuk menampilkan konten dengan ikon
  Widget _buildContent(dynamic icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: icon is IconData
              ? Icon(icon, size: 36, color: AppColors.primaryColor)
              : SvgPicture.asset(
                  icon,
                  height: 36,
                  width: 36,
                ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyle.bodyText2,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
