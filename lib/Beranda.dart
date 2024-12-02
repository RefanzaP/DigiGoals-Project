import 'package:digigoals_app/OurGoals.dart';
import 'package:flutter/material.dart';

class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  _BerandaState createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  bool isOnline = true;
  bool isSaldoVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(22),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isOnline ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        actions: [
          Container(
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
              icon: Icon(
                Icons.search,
                color: Colors.black,
                size: 20,
              ),
              onPressed: () {
                showSearch(context: context, delegate: CustomSearchDelegate());
              },
            ),
          ),
          Container(
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
              icon: Icon(
                Icons.mic_none,
                color: Colors.black,
                size: 20,
              ),
              onPressed: () {
                // Voice search action
              },
            ),
          ),
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
            // SizedBox(height: 50),
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
            SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                  SizedBox(height: 2),
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
            SizedBox(height: 20),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(5),
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
                            SizedBox(height: 2),
                            Text(
                              isSaldoVisible ? 'IDR 1,000,000' : 'IDR ******',
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
                            isSaldoVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            setState(() {
                              isSaldoVisible = !isSaldoVisible;
                            });
                          },
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
            SizedBox(height: 20),
            Flexible(
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
                      MediaQuery.of(context).size.width > 380 ? 4 : 3,
                  padding:
                      EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                  children: [
                    _buildMenuItem(Icons.manage_accounts, 'Manajemen\nKeuangan',
                        () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => ManajemenKeuanganPage()));
                    }),
                    _buildMenuItem(Icons.swap_horiz, 'Transfer', () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => TransferPage()));
                    }),
                    _buildMenuItem(Icons.payment, 'Bayar', () {
                      // Navigator.push(context,
                      //     MaterialPageRoute(builder: (context) => BayarPage()));
                    }),
                    _buildMenuItem(Icons.shopping_cart, 'Beli', () {
                      // Navigator.push(context,
                      //     MaterialPageRoute(builder: (context) => BeliPage()));
                    }),
                    _buildMenuItem(Icons.credit_card, 'Cardless', () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => CardlessPage()));
                    }),
                    _buildMenuItem(Icons.account_balance, 'Buka Rekening', () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => BukaRekeningPage()));
                    }),
                    _buildMenuItem(Icons.savings, 'bjb Deposito', () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => DepositoPage()));
                    }),
                    _buildMenuItem(Icons.compare_arrows, 'Flip', () {
                      // Navigator.push(context,
                      //     MaterialPageRoute(builder: (context) => FlipPage()));
                    }),
                    _buildMenuItem(Icons.volunteer_activism, 'Donasi', () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => DonasiPage()));
                    }),
                    _buildMenuItem(Icons.money, 'Collect Dana', () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => CollectDanaPage()));
                    }),
                    _buildMenuItem(Icons.account_balance_wallet, 'Pinjaman ASN',
                        () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => PinjamanAsnPage()));
                    }),
                    _buildMenuItem(Icons.flag, 'Our Goals', () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => OurGoals()));
                    }),
                  ],
                ),
              ),
            ),
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
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, color: Colors.blue),
                  SizedBox(height: 4),
                  Text('Inbox',
                      style: TextStyle(fontSize: 12, color: Colors.blue)),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite, color: Colors.blue),
                  SizedBox(height: 4),
                  Text('Favorite',
                      style: TextStyle(fontSize: 12, color: Colors.blue)),
                ],
              ),
              SizedBox(width: 40), // Space for floating action button
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.settings, color: Colors.blue),
                  SizedBox(height: 4),
                  Text('Settings',
                      style: TextStyle(fontSize: 12, color: Colors.blue)),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: Colors.blue),
                  SizedBox(height: 4),
                  Text('Logout',
                      style: TextStyle(fontSize: 12, color: Colors.blue)),
                ],
              ),
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
        child: Icon(
          Icons.qr_code_scanner,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Container(
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
              padding: EdgeInsets.all(10),
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue.shade700, Colors.blue.shade400],
                ).createShader(bounds),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          SizedBox(height: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
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
