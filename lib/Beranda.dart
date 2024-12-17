import 'package:digigoals_app/Inbox.dart';
import 'package:digigoals_app/OurGoals.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  _BerandaState createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BerandaState(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF007CC3), // Warna biru sesuai referensi
          elevation: 0,
          leading: Container(
            margin: EdgeInsets.all(22),
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          actions: [
            _buildIconButton(context, Icons.search, () {
              showSearch(context: context, delegate: CustomSearchDelegate());
            }, 'Search'),
            _buildIconButton(context, Icons.mic_none, () {
              // Voice search action
            }, 'Voice Search'),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade700, // Warna biru atas
                Colors.blue.shade400, // Warna biru bawah
              ],
            ),
          ),
          child: Column(
            children: [
              Center(
                child: Image.asset(
                  'assets/icons/logo-digi-bank-bjb-home.png',
                  width: 120,
                  height: 120,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ABI',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Loyalty Point',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.refresh,
                              color: Colors.white, size: 18),
                          label: Text(
                            'Reload',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white70.withOpacity(0.25),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
                  child: Consumer<BerandaState>(
                    builder: (_, state, __) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 5,
                            ),
                            Image.asset(
                              'assets/icons/logo-digi-biru.png',
                              width: 35,
                              height: 35,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '0123456789012',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  state.isSaldoVisible
                                      ? 'IDR 1,000,000'
                                      : 'IDR ******',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                state.isSaldoVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.blue,
                              ),
                              tooltip: 'Toggle Balance Visibility',
                              onPressed: state.toggleSaldoVisibility,
                            ),
                            SizedBox(width: 5),
                            Container(
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 238, 202, 25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.arrow_forward_ios,
                                    size: 20, color: Colors.blue),
                                onPressed: () {
                                  // Navigate to account list
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: GridView.count(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 6 : 4,
                    mainAxisSpacing: 12.0,
                    crossAxisSpacing: 8.0,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    childAspectRatio: 0.838,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    clipBehavior: Clip.none,
                    children: [
                      MenuItem(
                          icon: Icons.manage_accounts,
                          label: 'Manajemen Keuangan',
                          onTap: () {}),
                      MenuItem(
                          icon: Icons.swap_horiz,
                          label: 'Transfer',
                          onTap: () {}),
                      MenuItem(
                          icon: Icons.payment, label: 'Bayar', onTap: () {}),
                      MenuItem(
                          icon: Icons.shopping_cart,
                          label: 'Beli',
                          onTap: () {}),
                      MenuItem(
                          icon: Icons.credit_card,
                          label: 'Cardless',
                          onTap: () {}),
                      MenuItem(
                          icon: Icons.account_balance,
                          label: 'Buka Rekening',
                          onTap: () {}),
                      MenuItem(
                          icon: Icons.savings,
                          label: 'bjb Deposito',
                          onTap: () {}),
                      MenuItem(
                          icon: Icons.compare_arrows,
                          label: 'Flip',
                          onTap: () {}),
                      MenuItem(
                          icon: Icons.volunteer_activism,
                          label: 'Donasi',
                          onTap: () {}),
                      MenuItem(
                          icon: Icons.money,
                          label: 'Collect Dana',
                          onTap: () {}),
                      MenuItem(
                          icon: Icons.account_balance_wallet,
                          label: 'Pinjaman ASN',
                          onTap: () {}),
                      MenuItem(
                          icon: Icons.flag,
                          label: 'Our Goals',
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OurGoals()));
                          }),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 10,
          color: Colors.white,
          child: SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(Icons.inbox, 'Inbox', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Inbox()),
                  );
                }),
                _buildBottomNavItem(Icons.favorite, 'Favorite'),
                SizedBox(width: 40),
                _buildBottomNavItem(Icons.settings, 'Settings'),
                _buildBottomNavItem(Icons.logout, 'Logout'),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          shape: CircleBorder(),
          backgroundColor: Colors.white,
          elevation: 4,
          onPressed: () {},
          tooltip: 'Scan QR Code',
          child: Icon(
            Icons.qr_code_scanner,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon,
      VoidCallback onPressed, String tooltip) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black, size: 20),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }
}

Widget _buildBottomNavItem(IconData icon, String label, [VoidCallback? onTap]) {
  return InkWell(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.blue.shade700,
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.blue.shade700,
          ),
        ),
      ],
    ),
  );
}

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const MenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.blue.shade700,
              size: 40,
            ),
          ),
          SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class BerandaState with ChangeNotifier {
  bool isOnline = true;
  bool isSaldoVisible = false;

  void toggleSaldoVisibility() {
    isSaldoVisible = !isSaldoVisible;
    notifyListeners();
  }
}

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text('Hasil pencarian untuk "$query"'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Saran $index untuk "$query"'),
          onTap: () {
            query = 'Saran $index';
            showResults(context);
          },
        );
      },
    );
  }
}
