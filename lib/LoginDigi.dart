// ignore_for_file: unnecessary_null_comparison, duplicate_ignore, use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'package:digigoals_app/Beranda.dart';
import 'package:digigoals_app/auth/login_response.dart';
import 'package:digigoals_app/auth/token_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:top_modal_sheet/top_modal_sheet.dart';
import 'package:provider/provider.dart';
import 'package:digigoals_app/api/api_config.dart';

// Model Account Statis
class Account {
  final String nomorRekening;
  final String namaRekening;
  final double saldoRekening;

  Account({
    required this.nomorRekening,
    required this.namaRekening,
    required this.saldoRekening,
  });
}

// Widget untuk menampilkan kartu akun
class AccountCard extends StatelessWidget {
  final Account account;
  final bool isSaldoVisible;
  final VoidCallback toggleSaldoVisibility;

  const AccountCard({
    super.key,
    required this.account,
    required this.isSaldoVisible,
    required this.toggleSaldoVisibility,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardMarginHorizontal = screenWidth * 0.04;
    final cardMarginVertical = screenWidth * 0.02;
    final paddingHorizontal = screenWidth * 0.025;
    final paddingVertical = screenWidth * 0.02;
    final logoSize = screenWidth * 0.08;
    final spacingSize = screenWidth * 0.025;

    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: cardMarginHorizontal, vertical: cardMarginVertical),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: paddingHorizontal, vertical: paddingVertical),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(width: spacingSize),
                Image.asset(
                  'assets/icons/logo-digi-biru.png',
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: spacingSize),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.nomorRekening,
                      style: TextStyle(
                        fontSize: _calculateFontSize(context, 14),
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Menampilkan saldo dengan format yang sesuai
                    SaldoText(
                      isSaldoVisible: isSaldoVisible,
                      balance: account.saldoRekening,
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                // Widget ikon untuk mengatur visibilitas saldo
                IconButton(
                  icon: VisibilityIcon(isSaldoVisible: isSaldoVisible),
                  tooltip: 'Toggle Balance Visibility',
                  onPressed: toggleSaldoVisibility,
                ),
                SizedBox(width: spacingSize),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 238, 202, 25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const ArrowForwardIcon(),
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
    );
  }
}

// Widget untuk menampilkan teks saldo
class SaldoText extends StatelessWidget {
  final bool isSaldoVisible;
  final double balance;

  const SaldoText({
    super.key,
    required this.isSaldoVisible,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFF0E99D1),
          Color(0xFF1C71B8),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bounds),
      child: Text(
        isSaldoVisible
            ? NumberFormat.currency(
                    locale: 'id_ID', symbol: 'IDR ', decimalDigits: 2)
                .format(balance)
            : 'IDR ******',
        style: TextStyle(
          fontSize: _calculateFontSize(context, 16),
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// Widget untuk ikon visibilitas saldo
class VisibilityIcon extends StatelessWidget {
  final bool isSaldoVisible;

  const VisibilityIcon({
    super.key,
    required this.isSaldoVisible,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFF0E99D1),
          Color(0xFF1C71B8),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bounds),
      child: Icon(
        isSaldoVisible ? Icons.visibility : Icons.visibility_off,
        color: Colors.white,
        size: _calculateIconSize(context, 24),
      ),
    );
  }
}

// Widget untuk ikon arrow forward
class ArrowForwardIcon extends StatelessWidget {
  const ArrowForwardIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFF0E99D1),
          Color(0xFF1C71B8),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bounds),
      child: Icon(Icons.arrow_forward_ios,
          size: _calculateIconSize(context, 20), color: Colors.white),
    );
  }
}

// Halaman utama login digi
class LoginDigi extends StatefulWidget {
  const LoginDigi({super.key});

  @override
  _LoginDigiState createState() => _LoginDigiState();
}

class _LoginDigiState extends State<LoginDigi> {
  // Data Statis
  final Account _dummyAccountData = Account(
    nomorRekening: '0123456789012',
    namaRekening: "ABI",
    saldoRekening: 1000000.00,
  );

  // Constants
  final double _bottomSheetHeight = 250.0;
  final _formKey = GlobalKey<FormState>();

  // State Variables
  bool _isBottomSheetVisible = false;
  bool _isSaldoVisible = false;
  bool _obscureText = true;
  String? _errorMessage;
  String? _loginError;
  String? _passwordError;
  String? _usernameError;
  late Account _dummyAccount;

  // Controllers
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  // Token Manager
  final TokenManager _tokenManager = TokenManager();

  @override
  void initState() {
    super.initState();
    _dummyAccount = _dummyAccountData;
  }

  // UI Builders
  // Widget untuk membuat form input
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    bool obscureText = false,
    bool isUsername = false,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? errorText,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: _calculateFontSize(context, 16),
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        SizedBox(height: _calculateSpacing(context, 10)),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
              fontWeight: FontWeight.w500), // Tambahkan style font bold disini
          decoration: InputDecoration(
            fillColor: Colors.blue.shade50,
            filled: true,
            hintText: hintText,
            hintStyle: const TextStyle(
                color: Colors.black54, fontWeight: FontWeight.bold),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: _calculatePadding(context, 10),
              horizontal: _calculatePadding(context, 12),
            ),
            errorText: errorText,
            errorMaxLines: 2,
            suffixIcon: suffixIcon,
            errorStyle: TextStyle(
                color: Colors.red, fontSize: _calculateFontSize(context, 12)),
          ),
          inputFormatters: isUsername
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(13),
                ]
              : null,
        ),
      ],
    );
  }

  // Widget untuk membuat item menu
  List<Widget> _buildMenuItems(BuildContext context) {
    final double iconSize = _calculateIconSize(context, 65);

    final List<Widget> menuItems = [
      MenuItem(
        icon: Image.asset('assets/icons/bayar@3x.png',
            width: iconSize, height: iconSize),
        label: 'Bayar',
        onTap: () {},
      ),
      MenuItem(
        icon: Image.asset('assets/icons/beli@3x.png',
            width: iconSize, height: iconSize),
        label: 'Beli',
        onTap: () {},
      ),
      MenuItem(
        icon: Image.asset('assets/icons/flip.png',
            width: iconSize, height: iconSize),
        label: 'Flip',
        onTap: () {},
      ),
      MenuItem(
        icon: MenuIcon(iconData: Icons.widgets_rounded, size: iconSize),
        label: 'Lainnya',
        onTap: () {},
      ),
      MenuItem(
        icon: MenuIcon(iconData: Icons.qr_code_scanner, size: iconSize),
        label: 'QRIS',
        onTap: () {},
      ),
    ];

    final List<Widget> rows = [];
    for (int i = 0; i < menuItems.length; i += 2) {
      final List<Widget> currentRow = [];
      currentRow.add(menuItems[i]);
      if (i + 1 < menuItems.length) {
        currentRow.add(SizedBox(width: _calculateSpacing(context, 50)));
        currentRow.add(menuItems[i + 1]);
      }
      rows.add(Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: currentRow,
          )));
    }
    return rows;
  }

  // Method untuk toggle visibilitas saldo
  void _toggleSaldoVisibility() {
    setState(() {
      _isSaldoVisible = !_isSaldoVisible;
    });
  }

  // Method untuk toggle visibilitas password
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  // method untuk menampilkan top modal sheet
  void _showTopModalSheet() {
    showTopModalSheet(
      context,
      Container(
        height: _bottomSheetHeight,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: ListView(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.025,
                            vertical:
                                MediaQuery.of(context).size.width * 0.025),
                        child: _dummyAccount != null
                            ? AccountCard(
                                account: _dummyAccount,
                                isSaldoVisible: _isSaldoVisible,
                                toggleSaldoVisibility: () => setState(() {
                                  _toggleSaldoVisibility();
                                }),
                              )
                            : Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  width: double.infinity,
                                  height: _calculatePadding(context, 100),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15)),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: GestureDetector(
                        // Bungkus dengan GestureDetector
                        onTap: () {
                          Navigator.of(context)
                              .pop(); // Tutup bottom sheet saat diklik
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Divider(color: Colors.grey[300]),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Cek saldo anda",
                                  style: TextStyle(
                                      color: const Color(0XFF1F597F),
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          _calculateFontSize(context, 18)),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_up,
                                  size: _calculateIconSize(context, 24),
                                  color: const Color(0XFF1F597F),
                                )
                              ],
                            ),
                          ],
                        )),
                  ),
                )
              ],
            );
          },
        ),
      ),
    ).whenComplete(() {
      setState(() {
        _isBottomSheetVisible = false;
      });
    });
  }

  // method untuk menampilkan modal bottom sheet untuk login
  void _showLoginDialog() {
    // Reset input fields and errors when dialog is opened
    _usernameController.text = '';
    _passwordController.text = '';
    _usernameError = null;
    _passwordError = null;
    _loginError = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return SafeArea(
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.all(_calculatePadding(context, 15)),
                        constraints: BoxConstraints(
                          minHeight: constraints.minHeight,
                          maxHeight: MediaQuery.of(context).size.height * 0.8,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'DIGI Mobile',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: _calculateFontSize(context, 18),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: _calculateSpacing(context, 16)),
                              _buildTextFormField(
                                controller: _usernameController,
                                labelText: 'Nomor Telepon',
                                hintText: 'Masukan Nomor Telepon',
                                isUsername: true,
                                keyboardType: TextInputType.number,
                                errorText: _usernameError,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nomor telepon tidak boleh kosong';
                                  }
                                  if (value.length < 10) {
                                    return 'Nomor telepon minimal 10 digit';
                                  }
                                  if (value.length > 13) {
                                    return 'Nomor telepon maksimal 13 digit';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: _calculateSpacing(context, 16)),
                              _buildTextFormField(
                                controller: _passwordController,
                                labelText: 'Password',
                                hintText: 'Masukan Password',
                                obscureText: _obscureText,
                                isPassword: true,
                                errorText: _passwordError,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setStateDialog(() {
                                      _togglePasswordVisibility();
                                    });
                                  },
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                    size: _calculateIconSize(context, 24),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password tidak boleh kosong';
                                  }
                                  if (value.length < 8) {
                                    return 'Password minimal 8 karakter';
                                  }
                                  return null;
                                },
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.only(
                                        top: _calculatePadding(context, 10)),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Lupa Password',
                                    style: TextStyle(
                                      fontSize: _calculateFontSize(context, 13),
                                      color: const Color(0XFF1F597F),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: _calculateSpacing(context, 10)),
                              SizedBox(
                                width: double.infinity,
                                height: _calculatePadding(
                                    context, 48), // Reverted to fixed height
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await _validateLogin(
                                        context, setStateDialog);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.yellow.shade700,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Masuk',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: _calculateFontSize(context, 15),
                                      color: const Color(0XFF1F597F),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      // Reset input fields and errors when dialog is closed
      setState(() {
        _usernameController.text = '';
        _passwordController.text = '';
        _usernameError = null;
        _passwordError = null;
        _loginError = null;
      });
    });
  }

  // method untuk validasi login
  Future<void> _validateLogin(
      BuildContext context, StateSetter setStateDialog) async {
    if (_formKey.currentState!.validate()) {
      setStateDialog(() {});

      _showLoadingOverlay(context);

      final String username = _usernameController.text;
      final String password = _passwordController.text;

      // Konfigurasi Endpoint API
      const String loginEndpoint = "/auth/login";
      final String apiUrl = baseUrl + loginEndpoint;

      // Payload API
      final Map<String, String> bodyData = {
        'username': username,
        'password': password,
      };

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(bodyData),
        );

        // Log response untuk debugging

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          if (responseData['code'] == 200 && responseData['status'] == 'OK') {
            final LoginResponse loginResponse =
                LoginResponse.fromJson(responseData['data']);

            if (loginResponse.accessToken != null) {
              await _tokenManager.saveToken(loginResponse.accessToken!);

              // Endpoint untuk introspect user
              const String introspectEndpoint = "/auth/introspect";
              final String introspectApiUrl = baseUrl + introspectEndpoint;

              final introspectResponse = await http.get(
                Uri.parse(introspectApiUrl),
                headers: {
                  'Authorization': 'Bearer ${loginResponse.accessToken}',
                  'Content-Type': 'application/json'
                },
              );

              if (introspectResponse.statusCode == 200) {
                final Map<String, dynamic> introspectData =
                    json.decode(introspectResponse.body);
                if (introspectData['code'] == 200 &&
                    introspectData['status'] == 'OK') {
                  final String customerId =
                      introspectData['data']['customer_id'];
                  final String userId = introspectData['data']['user_id'];

                  // Simpan customer_id dan user_id
                  await _tokenManager.saveCustomerId(customerId);
                  await _tokenManager.saveUserId(userId);

                  if (context.mounted) {
                    _hideLoadingOverlay(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (context) => BerandaState(
                              accessToken: loginResponse.accessToken!),
                          child: const Beranda(),
                        ),
                        settings:
                            RouteSettings(arguments: loginResponse.accessToken),
                      ),
                      (route) => false,
                    );
                  }
                } else {
                  if (mounted) {
                    _hideLoadingOverlay(context);
                    setStateDialog(() {
                      _loginError = introspectData['errors'] != null &&
                              (introspectData['errors'] as List).isNotEmpty
                          ? (introspectData['errors'] as List)[0].toString()
                          : "Gagal introspect user, silahkan coba lagi!";
                      _passwordError = _loginError;
                      _usernameError = _loginError;
                    });
                  }
                }
              } else {
                if (mounted) {
                  _hideLoadingOverlay(context);
                  setStateDialog(() {
                    _loginError =
                        "Gagal introspect user, kode status: ${introspectResponse.statusCode}. Silakan coba lagi";
                    _passwordError = _loginError;
                    _usernameError = _loginError;
                  });
                }
              }
            } else {
              if (mounted) {
                _hideLoadingOverlay(context);
                setStateDialog(() {
                  _loginError = "Gagal login, silahkan coba lagi!";
                  _passwordError = _loginError;
                  _usernameError = _loginError;
                });
              }
            }
          } else {
            if (mounted) {
              _hideLoadingOverlay(context);
              setStateDialog(() {
                _loginError = responseData['errors'] != null &&
                        (responseData['errors'] as List).isNotEmpty
                    ? (responseData['errors'] as List)[0].toString()
                    : "Gagal login, silahkan coba lagi!";
                _passwordError = _loginError;
                _usernameError = _loginError;
              });
            }
          }
        } else {
          // Handle status code lainnya selain 200
          if (mounted) {
            _hideLoadingOverlay(context);
            setStateDialog(() {
              _loginError =
                  "Terjadi kesalahan saat login, kode status: ${response.statusCode}. Silakan coba lagi";
              _passwordError = _loginError;
              _usernameError = _loginError;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          _hideLoadingOverlay(context);
          setStateDialog(() {
            _loginError =
                "Terjadi kesalahan saat login, pesan error: ${e.toString()}. Silakan coba lagi";
            _passwordError = _loginError;
            _usernameError = _loginError;
          });
        }
      }
    } else {
      setState(() {
        _errorMessage = null;
      });
      return;
    }
  }

  // Method untuk menampilkan loading overlay
  void _showLoadingOverlay(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const LoadingOverlay();
      },
    );
  }

  // Method untuk menyembunyikan loading overlay
  void _hideLoadingOverlay(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  // Build Method
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
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
          ),
          SafeArea(
            child: Column(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/icons/logo-digi-bank-bjb-home.png',
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: MediaQuery.of(context).size.width * 0.3,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: _calculatePadding(context, 10),
                          vertical: _calculatePadding(context, 20)),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Halo,",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: _calculateFontSize(context, 20),
                                  color: Colors.white),
                            ),
                            SizedBox(height: _calculateSpacing(context, 5)),
                            Text(
                              'Selamat Beraktivitas!',
                              style: TextStyle(
                                fontSize: _calculateFontSize(context, 25),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: screenHeight * 0.01),
                    padding: EdgeInsets.all(_calculatePadding(context, 10)),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: _calculatePadding(context, 15)),
                          child: Column(
                            children: _buildMenuItems(context),
                          ),
                        ),
                        if (_errorMessage != null)
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: _calculatePadding(context, 16),
                                vertical: _calculatePadding(context, 5)),
                            child: Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: _calculateFontSize(context, 13),
                              ),
                            ),
                          ),
                        if (_loginError != null)
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: _calculatePadding(context, 16),
                                vertical: _calculatePadding(context, 5)),
                            child: Text(
                              _loginError!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: _calculateFontSize(context, 13),
                              ),
                            ),
                          ),
                        const Spacer(),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: _calculatePadding(context, 16),
                              vertical: _calculatePadding(context, 5)),
                          child: SizedBox(
                            width: double.infinity,
                            height: _calculatePadding(
                                context, 48), // Reverted to fixed height
                            child: ElevatedButton(
                              onPressed: () {
                                _showLoginDialog();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellow.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: const Color(0XFF1F597F),
                                  fontWeight: FontWeight.bold,
                                  fontSize: _calculateFontSize(context, 15),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(_calculatePadding(context, 10)),
        child: Text(
          'V.1.0 - ITDP Batch 2 - 2024 - Kelompok 7',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.grey, fontSize: _calculateFontSize(context, 12)),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

// Helper Functions
double _calculateFontSize(BuildContext context, double baseSize) {
  final screenWidth = MediaQuery.of(context).size.width;
  final double scaleFactor = screenWidth / 375;
  return baseSize * scaleFactor;
}

double _calculatePadding(BuildContext context, double basePadding) {
  final screenWidth = MediaQuery.of(context).size.width;
  final double scaleFactor = screenWidth / 375;
  return basePadding * scaleFactor;
}

double _calculateSpacing(BuildContext context, double baseSpacing) {
  final screenWidth = MediaQuery.of(context).size.width;
  final double scaleFactor = screenWidth / 375;
  return baseSpacing * scaleFactor;
}

double _calculateIconSize(BuildContext context, double baseSize) {
  final screenWidth = MediaQuery.of(context).size.width;
  final double scaleFactor = screenWidth / 375;
  return baseSize * scaleFactor;
}

// Widget untuk ikon menu
class MenuIcon extends StatelessWidget {
  final IconData iconData;
  final double size;

  const MenuIcon({
    super.key,
    required this.iconData,
    this.size = 65,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFF25D0FE),
          Color(0xFF2D74DE),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bounds),
      child: Icon(
        iconData,
        size: size,
        color: Colors.white,
      ),
    );
  }
}

// Widget item menu
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
            padding: EdgeInsets.all(_calculatePadding(context, 10)),
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
          SizedBox(height: _calculateSpacing(context, 6)),
          Text(
            label,
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: _calculateFontSize(context, 12),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Loading Overlay Widget
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow.shade700),
        ),
      ),
    );
  }
}
