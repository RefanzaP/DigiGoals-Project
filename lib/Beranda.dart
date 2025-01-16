// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:convert';
import 'package:digigoals_app/Inbox.dart';
import 'package:digigoals_app/LoginDigi.dart';
import 'package:digigoals_app/auth/token_manager.dart';
import 'package:digigoals_app/OurGoals.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

// Model Data Rekening
class Account {
  final String accountNumber;
  final String accountHolder;
  final double balance;

  Account({
    required this.accountNumber,
    required this.accountHolder,
    required this.balance,
  });
}

// Enum untuk State
enum DataState {
  initial,
  loading,
  loaded,
  error,
}

// Widget Shimmer Text dengan Animasi
Widget _buildShimmerText(
    {double? width, double? height, bool hasAnimation = false}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    enabled: hasAnimation,
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

// Widget Halaman Beranda
class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  _BerandaState createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  bool _isLoadingLogout = false; // State untuk loading logout
  final TokenManager _tokenManager = TokenManager(); // Instance TokenManager

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BerandaState(
          accessToken: ModalRoute.of(context)?.settings.arguments as String?),
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
                _buildIconButton(
                  context,
                  Icons.search,
                  () {},
                  'Search',
                ),
                _buildIconButton(
                  context,
                  Icons.mic_none,
                  () {},
                  'Voice Search',
                ),
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
                            if (state.dataState == DataState.error) {
                              return Text(
                                state.errorMessage ?? 'Terjadi kesalahan',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              );
                            }
                            return state.dataState == DataState.loading
                                ? _buildShimmerText(
                                    width: 150, height: 20, hasAnimation: true)
                                : Text(
                                    (state.account?.accountHolder ??
                                            state.defaultName ??
                                            'Error!')
                                        .toUpperCase(),
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
                    builder: (context, state, _) =>
                        state.dataState == DataState.loading
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
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final screenWidth = constraints.maxWidth;
                          return GridView.count(
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
                                  icon: Image.asset(
                                      'assets/icons/transfer@3x.png',
                                      width: 40,
                                      height: 40),
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
                                  icon: Image.asset(
                                      'assets/icons/cardless@3x.png',
                                      width: 40,
                                      height: 40),
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
                                  icon: Image.asset(
                                      'assets/icons/donasi@3x.png',
                                      width: 40,
                                      height: 40),
                                  label: 'Donasi',
                                  onTap: () {}),
                              MenuItem(
                                  icon: Image.asset(
                                      'assets/icons/collect-dana.png',
                                      width: 40,
                                      height: 40),
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
                                  icon: Image.asset(
                                      'assets/icons/our-goals.png',
                                      width: 40,
                                      height: 40),
                                  label: 'Our Goals',
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => OurGoals()));
                                  }),
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
              shape: const CircularNotchedRectangle(),
              notchMargin: 10,
              color: Colors.white,
              child: SizedBox(
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBottomNavItem(Icons.inbox, 'Inbox', () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Inbox()));
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
                      // Delete Token
                      await _tokenManager.deleteToken();

                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const LoginDigi()),
                            (Route<dynamic> route) => false);
                      }
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

  // Widget IconButton dengan Custom Style
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

  // Widget Item Navigation Bottom Bar
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
              color: Colors.white,
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

// Widget Item Menu Grid
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

// State Management Halaman Beranda
class BerandaState with ChangeNotifier {
  Account? _account;
  DataState _dataState = DataState.initial;
  bool isSaldoVisible = false;
  String? errorMessage;
  final String? accessToken;
  String? defaultName;
  // Cache Data
  Account? _cachedAccount;
  DateTime? _cacheTime;
  static const Duration cacheDuration = Duration(minutes: 5);

  DataState get dataState => _dataState;
  Account? get account => _account;

  void setAccount(Account account) {
    _account = account;
    _cachedAccount = account;
    _cacheTime = DateTime.now();
    _dataState = DataState.loaded;
    errorMessage = null;
    notifyListeners();
  }

  void setError(String message) {
    _dataState = DataState.error;
    errorMessage = message;
    notifyListeners();
  }

  void toggleSaldoVisibility() {
    isSaldoVisible = !isSaldoVisible;
    notifyListeners();
  }

  // Check Cache
  bool _isCacheValid() {
    if (_cachedAccount == null || _cacheTime == null) {
      return false;
    }
    return DateTime.now().difference(_cacheTime!) <= cacheDuration;
  }

  Future<void> fetchAccountData() async {
    if (_isCacheValid() && _cachedAccount != null) {
      _account = _cachedAccount;
      _dataState = DataState.loaded;
      notifyListeners();
      return;
    }
    _dataState = DataState.loading;
    notifyListeners();

    if (accessToken == null) {
      setError("Token tidak ditemukan");
      return;
    }

    try {
      // Konfigurasi Endpoint API
      const String baseUrl = "https://user-service-ourgoals.koyeb.app";
      const String profileEndpoint = "/api/v1/users/profile";
      const String accountEndpoint = "/api/v1/users/accounts";
      final String profileApiUrl = baseUrl + profileEndpoint;
      final String accountApiUrl = baseUrl + accountEndpoint;

      // Fetch profile data for accountHolder
      final profileResponse = await http.get(
        Uri.parse(profileApiUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (profileResponse.statusCode == 200) {
        final Map<String, dynamic> profileData =
            json.decode(profileResponse.body);
        if (profileData['code'] == 200 && profileData['status'] == 'OK') {
          final String accountHolder = profileData['data']['name'];
          defaultName = accountHolder;

          // Fetch account data for accountNumber and balance
          final accountResponse = await http.get(
            Uri.parse(accountApiUrl),
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          );

          if (accountResponse.statusCode == 200) {
            final Map<String, dynamic> accountData =
                json.decode(accountResponse.body);
            if (accountData['code'] == 200 &&
                accountData['status'] == 'OK' &&
                (accountData['data'] as List).isNotEmpty) {
              final dynamic account = (accountData['data'] as List)[0];

              final Account fetchedAccount = Account(
                accountNumber: account['account_number'] ?? 'N/A',
                accountHolder: accountHolder,
                balance:
                    (account['total_available_balance'] as num?)?.toDouble() ??
                        0.0,
              );

              setAccount(fetchedAccount);
            } else {
              setError(accountData['errors'] != null &&
                      (accountData['errors'] as List).isNotEmpty
                  ? (accountData['errors'] as List)[0].toString()
                  : "Gagal mengambil data akun, silahkan coba lagi!");
            }
          } else {
            setError(
                "Gagal mengambil data akun, kode status: ${accountResponse.statusCode}. Silahkan coba lagi!");
          }
        } else {
          setError(profileData['errors'] != null &&
                  (profileData['errors'] as List).isNotEmpty
              ? (profileData['errors'] as List)[0].toString()
              : "Gagal mengambil data user, silahkan coba lagi!");
        }
      } else {
        setError(
            "Gagal mengambil data user, kode status: ${profileResponse.statusCode}. Silahkan coba lagi!");
      }
    } catch (e) {
      setError(
          "Terjadi kesalahan saat mengambil data user, pesan error: ${e.toString()}");
    }
  }

  BerandaState({this.accessToken}) {
    fetchAccountData();
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
                            fontWeight: FontWeight.w500,
                          ),
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
                      ).createShader(
                        bounds,
                      ),
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

// Widget Account Card saat Loading
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
                        width: 120, height: 18, hasAnimation: true),
                    _buildShimmerText(
                        width: 150, height: 18, hasAnimation: true),
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
}
