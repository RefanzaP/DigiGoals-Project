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
          backgroundColor: Colors.blue.shade700,
          elevation: 0,
          leading: Consumer<BerandaState>(
            builder: (_, state, __) => Icon(
              Icons.radio_button_checked,
              color: state.isOnline ? Colors.green : Colors.red,
              size: 16,
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
              colors: [Colors.blue.shade700, Colors.blue.shade400],
            ),
          ),
          child: Column(
            children: [
              Center(
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 100,
                  color: Colors.white,
                ),
                // To replace the icon with a logo image, use the following code:
                // child: Image.asset(
                //   'assets/images/logo.png', // Update the path to your logo image
                //   height: 100,
                //   width: 100,
                // ),
              ),
              SizedBox(height: 8),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ABI',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Loyalty Point',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Refresh',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(
                                Icons.refresh,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 8.0),
                  child: Consumer<BerandaState>(
                    builder: (_, state, __) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.account_balance,
                                color: Colors.blue,
                                size: 25,
                              ),
                            ),
                            SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '0123456789012',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  state.isSaldoVisible
                                      ? 'IDR 1,000,000'
                                      : 'IDR ******',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade700,
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
                            SizedBox(width: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.yellow,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.arrow_forward_ios,
                                    color: Colors.white),
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
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount =
                          (constraints.maxWidth ~/ 100).clamp(3, 6);
                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        padding: EdgeInsets.all(8),
                        children: [
                          MenuItem(
                            icon: Icons.manage_accounts,
                            label: 'Manajemen Keuangan',
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => ManajemenKeuanganPage()));
                            },
                          ),
                          MenuItem(
                            icon: Icons.swap_horiz,
                            label: 'Transfer',
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => TransferPage()));
                            },
                          ),
                          MenuItem(
                            icon: Icons.payment,
                            label: 'Bayar',
                            onTap: () {
                              // Navigator.push(context,
                              //     MaterialPageRoute(builder: (context) => BayarPage()));
                            },
                          ),
                          MenuItem(
                            icon: Icons.shopping_cart,
                            label: 'Beli',
                            onTap: () {
                              // Navigator.push(context,
                              //     MaterialPageRoute(builder: (context) => BeliPage()));
                            },
                          ),
                          MenuItem(
                            icon: Icons.credit_card,
                            label: 'Cardless',
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => CardlessPage()));
                            },
                          ),
                          MenuItem(
                            icon: Icons.account_balance,
                            label: 'Buka Rekening',
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => BukaRekeningPage()));
                            },
                          ),
                          MenuItem(
                            icon: Icons.savings,
                            label: 'bjb Deposito',
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => DepositoPage()));
                            },
                          ),
                          MenuItem(
                            icon: Icons.compare_arrows,
                            label: 'Flip',
                            onTap: () {
                              // Navigator.push(context,
                              //     MaterialPageRoute(builder: (context) => FlipPage()));
                            },
                          ),
                          MenuItem(
                            icon: Icons.volunteer_activism,
                            label: 'Donasi',
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => DonasiPage()));
                            },
                          ),
                          MenuItem(
                            icon: Icons.money,
                            label: 'Collect Dana',
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => CollectDanaPage()));
                            },
                          ),
                          MenuItem(
                            icon: Icons.account_balance_wallet,
                            label: 'Pinjaman ASN',
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => PinjamanAsnPage()));
                            },
                          ),
                          MenuItem(
                            icon: Icons.flag,
                            label: 'Our Goals',
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OurGoals()));
                            },
                          ),
                        ],
                      );
                    },
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
                    MaterialPageRoute(
                        builder: (context) =>
                            Inbox()), // Assuming Inbox is a defined page
                  );
                }),
                _buildBottomNavItem(Icons.favorite, 'Favorite'),
                SizedBox(width: 40), // Space for floating action button
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
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 2,
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

  Widget _buildBottomNavItem(IconData icon, String label,
      [VoidCallback? onTap]) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blue),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.blue),
          ),
        ],
      ),
    );
  }
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
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.blue.shade700,
              size: 40,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
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
