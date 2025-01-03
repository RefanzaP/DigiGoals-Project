// ignore_for_file: deprecated_member_use

import 'package:digigoals_app/Inbox.dart';
import 'package:digigoals_app/LoginDigi.dart';
import 'package:digigoals_app/OurGoals.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

// 1. Model Data Rekening
class Account {
  final String accountNumber;
  final String accountHolder;
  final double balance;

  Account(
      {required this.accountNumber,
      required this.accountHolder,
      required this.balance});
}

class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  _BerandaState createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  bool _isLoadingLogout = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ChangeNotifierProvider(
      create: (_) => BerandaState(),
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue.shade700,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(22),
                height: 8,
                width: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              actions: [
                _buildIconButton(context, Icons.search, () {
                  showSearch(
                      context: context, delegate: CustomSearchDelegate());
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
                    Colors.blue.shade700,
                    Colors.blue.shade400,
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<BerandaState>(
                          builder: (context, state, _) {
                            if (state.errorMessage != null) {
                              return Text(
                                state.errorMessage!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              );
                            }
                            return state.isLoading
                                ? _buildShimmerText(width: 150, height: 20)
                                : Text(
                                    state.account?.accountHolder ??
                                        'Nama Pengguna',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                          },
                        ),
                        Row(
                          children: [
                            const Text(
                              'Loyalty Point',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.refresh,
                                  color: Colors.white, size: 18),
                              label: const Text(
                                'Reload',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.white70.withOpacity(0.25),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Consumer<BerandaState>(
                    builder: (context, state, _) => state.isLoading
                        ? const AccountCardShimmer()
                        : const AccountCard(),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: GridView.count(
                        crossAxisCount: screenWidth > 600 ? 6 : 4,
                        mainAxisSpacing: 12.0,
                        crossAxisSpacing: 8.0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        childAspectRatio: 0.838,
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        clipBehavior: Clip.none,
                        children: [
                          MenuItem(
                              icon: Image.asset(
                                  'assets/icons/manajemen-keuangan@3x.png',
                                  width: 40,
                                  height: 40),
                              label: 'Manajemen Keuangan',
                              onTap: () {}),
                          MenuItem(
                              icon: Image.asset('assets/icons/transfer@3x.png',
                                  width: 40, height: 40),
                              label: 'Transfer',
                              onTap: () {}),
                          MenuItem(
                              icon: Image.asset('assets/icons/bayar@3x.png',
                                  width: 40, height: 40),
                              label: 'Bayar',
                              onTap: () {}),
                          MenuItem(
                              icon: Image.asset('assets/icons/beli@3x.png',
                                  width: 40, height: 40),
                              label: 'Beli',
                              onTap: () {}),
                          MenuItem(
                              icon: Image.asset('assets/icons/cardless@3x.png',
                                  width: 40, height: 40),
                              label: 'Cardless',
                              onTap: () {}),
                          MenuItem(
                              icon: Image.asset(
                                  'assets/icons/buka-rekening@3x.png',
                                  width: 40,
                                  height: 40),
                              label: 'Buka Rekening',
                              onTap: () {}),
                          MenuItem(
                              icon: Image.asset(
                                  'assets/icons/bjb-deposito@3x.png',
                                  width: 40,
                                  height: 40),
                              label: 'bjb Deposito',
                              onTap: () {}),
                          MenuItem(
                              icon: Image.asset('assets/icons/flip.png',
                                  width: 40, height: 40),
                              label: 'Flip',
                              onTap: () {}),
                          MenuItem(
                              icon: Image.asset('assets/icons/donasi@3x.png',
                                  width: 40, height: 40),
                              label: 'Donasi',
                              onTap: () {}),
                          MenuItem(
                              icon: Image.asset('assets/icons/collect-dana.png',
                                  width: 40, height: 40),
                              label: 'Collect Dana',
                              onTap: () {}),
                          MenuItem(
                              icon: Image.asset(
                                  'assets/icons/pinjaman asn@3x.png',
                                  width: 40,
                                  height: 40),
                              label: 'Pinjaman ASN',
                              onTap: () {}),
                          MenuItem(
                              icon: Image.asset('assets/icons/our-goals.png',
                                  width: 40, height: 40),
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
              shape: const CircularNotchedRectangle(),
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
                    const SizedBox(width: 40),
                    _buildBottomNavItem(Icons.settings, 'Settings'),
                    _buildBottomNavItem(Icons.logout, 'Logout', () async {
                      setState(() {
                        _isLoadingLogout = true;
                      });
                      await Future.delayed(
                          const Duration(seconds: 1)); // Simulate loading
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => LoginDigi()),
                        (Route<dynamic> route) => false,
                      );
                      setState(() {
                        _isLoadingLogout = false;
                      });
                    }),
                  ],
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: FloatingActionButton(
              shape: const CircleBorder(),
              elevation: 4,
              onPressed: () {},
              tooltip: 'Scan QR Code',
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade700,
                      Colors.blue.shade400,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          if (_isLoadingLogout)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.yellow.shade700),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan Shimmer
  Widget _buildShimmerText({double? width, double? height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width ?? 100, // Default width jika tidak ada input
        height: height ?? 16,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon,
      VoidCallback onPressed, String tooltip) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
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
            offset: const Offset(0, 2),
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
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Colors.blue.shade700,
                Colors.blue.shade400,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds),
            child: Icon(
              icon,
              color: Colors.white, // Warna harus putih agar gradient terlihat
            ),
          ),
          const SizedBox(height: 4),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Colors.blue.shade700,
                Colors.blue.shade400,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds),
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final Widget icon;
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: icon,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// 2. BerandaState yang Diperbarui
class BerandaState with ChangeNotifier {
  // Data Statis
  final Account _dummyAccountData = Account(
      accountNumber: "0123456789012",
      accountHolder: "ABI",
      balance: 1000000.00);

  Account? _account;
  bool isOnline = true;
  bool isSaldoVisible = false;
  bool isLoading = true;
  String? errorMessage;
  late Future<void> _fetchDataFuture;

  Account? get account => _account;
  Future<void> get fetchDataFuture => _fetchDataFuture;

  void setAccount(Account account) {
    _account = account;
    isLoading = false;
    errorMessage = null;
    notifyListeners();
  }

  void setError(String message) {
    isLoading = false;
    errorMessage = message;
    notifyListeners();
  }

  void toggleSaldoVisibility() {
    isSaldoVisible = !isSaldoVisible;
    notifyListeners();
  }

  Future<void> fetchAccountData() async {
    isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 1));

      setAccount(_dummyAccountData);
    } catch (e) {
      setError("Failed to fetch account data: $e");
    }
  }

  BerandaState() {
    _fetchDataFuture = fetchAccountData();
  }
}

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
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

// Widget Account Card
class AccountCard extends StatelessWidget {
  const AccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
        child: Consumer<BerandaState>(
          builder: (_, state, __) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 5,
                  ),
                  Image.asset(
                    'assets/icons/logo-digi-biru.png',
                    width: 35,
                    height: 35,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.account?.accountNumber ?? 'Nomor Rekening',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            Colors.blue.shade700,
                            Colors.blue.shade400,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(bounds),
                        child: Text(
                          state.isSaldoVisible
                              ? NumberFormat.currency(
                                      locale: 'id_ID',
                                      symbol: 'IDR ',
                                      decimalDigits: 2)
                                  .format(state.account?.balance)
                              : 'IDR ******',
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          Colors.blue.shade700,
                          Colors.blue.shade400,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds),
                      child: Icon(
                        state.isSaldoVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.white,
                      ),
                    ),
                    tooltip: 'Toggle Balance Visibility',
                    onPressed: state.toggleSaldoVisibility,
                  ),
                  const SizedBox(width: 5),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 238, 202, 25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            Colors.blue.shade700,
                            Colors.blue.shade400,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(bounds),
                        child: const Icon(Icons.arrow_forward_ios,
                            size: 20, color: Colors.white),
                      ),
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
    );
  }
}

class AccountCardShimmer extends StatelessWidget {
  const AccountCardShimmer({super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 5,
                ),
                Image.asset(
                  'assets/icons/logo-digi-biru.png',
                  width: 35,
                  height: 35,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerText(
                        width: 120, height: 18), // Shimmer untuk nomor rekening
                    _buildShimmerText(
                        width: 150, height: 18), // Shimmer untuk saldo
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: const Icon(
                    Icons.visibility_off,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 5),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: const Icon(Icons.arrow_forward_ios,
                      size: 20, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerText({double? width, double? height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width ?? 100,
        height: height ?? 16,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
