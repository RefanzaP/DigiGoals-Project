// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:digigoals_app/auth/token_manager.dart';
import 'package:digigoals_app/api/api_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import 'package:http/http.dart' as http;
import 'dart:convert';

class TambahUangBergilir extends StatefulWidget {
  final Map<String, dynamic> goalsData;

  const TambahUangBergilir({super.key, required this.goalsData});

  @override
  _TambahUangBergilirState createState() => _TambahUangBergilirState();
}

class _TambahUangBergilirState extends _TambahUangBergilirStateBase {
  @override
  Widget build(BuildContext context) {
    return buildTambahUangBergilirPage(context);
  }
}

abstract class _TambahUangBergilirStateBase extends State<TambahUangBergilir> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nominalTambahUangController;
  late TextEditingController _waktuTransaksiController;

  bool isTodayEnabled = true;
  bool isWeeklyEnabled = false;
  bool isDateEnabled = false;
  bool isSpecificDateEnabled = false;

  // Inisialisasi data di depan
  late String goalsName;
  final String tanggalTransaksiDefault = 'Sekarang';

  @override
  void initState() {
    super.initState();
    goalsName = widget.goalsData['goalsName'];
    _nominalTambahUangController = TextEditingController();
    _waktuTransaksiController =
        TextEditingController(text: tanggalTransaksiDefault);
  }

  @override
  void dispose() {
    _nominalTambahUangController.dispose();
    _waktuTransaksiController.dispose();
    super.dispose();
  }

  String _formatCurrency(String value) {
    if (value.isEmpty) return '';
    final formatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    try {
      final parsedValue = int.parse(value.replaceAll(RegExp(r'[^0-9]'), ''));
      return formatter.format(parsedValue);
    } catch (e) {
      return value;
    }
  }

  Widget buildTambahUangBergilirPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade700, Colors.blue.shade400],
            ),
          ),
        ),
        elevation: 0,
        toolbarHeight: 84,
        titleSpacing: 16,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Uang',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            height: 12,
            width: 12,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nominal Tambah Uang
                Text(
                  "Nominal Tambah Uang",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nominalTambahUangController,
                  decoration: InputDecoration(
                    fillColor: Colors.blue.shade50,
                    filled: true,
                    hintText: 'Tentukan Nominal Tambah Uang',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      return newValue.copyWith(
                        text: _formatCurrency(newValue.text),
                        selection: TextSelection.collapsed(
                            offset: _formatCurrency(newValue.text).length),
                      );
                    }),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nominal Tambah Uang tidak boleh kosong';
                    }
                    final nominalTambahUang =
                        int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
                    if (nominalTambahUang == null ||
                        nominalTambahUang < 10000) {
                      return 'Nominal minimal adalah Rp 10.000';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Waktu Transaksi
                Text(
                  "Waktu Transaksi",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _waktuTransaksiController,
                  decoration: InputDecoration(
                    fillColor: Colors.blue.shade50,
                    filled: true,
                    hintText: 'Sekarang',
                    suffixIcon: const Icon(Icons.edit_calendar),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  readOnly: true,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PilihSumberDanaBergilir(
                      nominalTambahUang: _nominalTambahUangController.text,
                      goalsName: goalsName,
                      goalsData: widget.goalsData,
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Selanjutnya',
              style: TextStyle(
                color: Colors.blue.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PilihSumberDanaBergilir extends StatefulWidget {
  final String nominalTambahUang;
  final String goalsName;
  final Map<String, dynamic> goalsData;

  const PilihSumberDanaBergilir({
    super.key,
    required this.nominalTambahUang,
    required this.goalsName,
    required this.goalsData,
  });

  @override
  _PilihSumberDanaBergilirState createState() =>
      _PilihSumberDanaBergilirState();
}

class _PilihSumberDanaBergilirState extends State<PilihSumberDanaBergilir> {
  List<Map<String, dynamic>> sumberDanaList = [];
  ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);
  bool isLoading = true;
  String? errorMessage;
  final TokenManager _tokenManager = TokenManager();
  String? userName; // Initially nullable

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
  }

  Future<void> _fetchAccounts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    String? token = await _tokenManager.getToken();
    if (token == null) {
      setState(() {
        isLoading = false;
        errorMessage = "Token tidak ditemukan";
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Print the responseData to inspect the structure and types
        if (responseData['code'] == 200 && responseData['status'] == 'OK') {
          List<Map<String, dynamic>> fetchedAccounts = [];
          for (var account in responseData['data']['accounts']) {
            fetchedAccounts.add({
              'accountType': account['account_type'],
              'accountNumber': account['account_number'],
              'accountBalance': account['total_available_balance'],
              'accountId': int.tryParse(account['id'].toString()) ??
                  0, // Convert 'id' to int, default to 0 if parsing fails
            });
          }
          setState(() {
            sumberDanaList = fetchedAccounts;
            userName = responseData['data']['customer']['name'] ??
                'User Name Unavailable'; // Get username from customer data, with default value
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = responseData['errors'] != null &&
                    (responseData['errors'] as List).isNotEmpty
                ? (responseData['errors'] as List)[0].toString()
                : "Gagal mengambil data accountNumber, silahkan coba lagi!";
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              "Gagal mengambil data accountNumber. Status code: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Terjadi kesalahan: ${e.toString()}";
      });
    }
  }

  String _formatCurrency(num value) {
    final formatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 2);
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Uang',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Goals
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade700, Colors.blue.shade400],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.groups,
                    color: Colors.blue.shade700,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nominal: ${widget.nominalTambahUang}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nama Goals: ${widget.goalsName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                  label: const Text(
                    'Ubah',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Pilih Sumber Dana',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (errorMessage != null)
            Expanded(
              child: Center(
                child: Text(errorMessage!),
              ),
            )
          else
            ValueListenableBuilder<int>(
              valueListenable: selectedIndex,
              builder: (context, value, _) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: sumberDanaList.length,
                    itemBuilder: (context, index) {
                      final sumber = sumberDanaList[index];
                      return GestureDetector(
                        onTap: () => selectedIndex.value = index,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: value == index
                                ? Colors.yellow.shade700
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: value == index
                                  ? Colors.blue.shade700
                                  : Colors.grey.shade300,
                            ),
                            boxShadow: value == index
                                ? [
                                    BoxShadow(
                                      color: Colors.blue.shade100,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/bankbjb-logo.png',
                                width: 100,
                                height: 100,
                              ),
                              const SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sumber['accountType']!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: value == index
                                          ? Colors.blue.shade700
                                          : Colors.blue.shade700,
                                    ),
                                  ),
                                  Text(
                                    sumber['accountNumber']!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: value == index
                                          ? Colors.blue.shade700
                                          : Colors.blue.shade700,
                                    ),
                                  ),
                                  Text(
                                    _formatCurrency(sumber['accountBalance']!),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: value == index
                                          ? Colors.blue.shade700
                                          : Colors.yellow.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Icon(
                                value == index
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: value == index
                                    ? Colors.blue.shade700
                                    : Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
        ],
      ),
      bottomNavigationBar: isLoading
          ? const SizedBox.shrink()
          : Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, -1),
                    blurRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Tambah',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        widget.nominalTambahUang,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        final selectedSumberDana =
                            sumberDanaList[selectedIndex.value];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => KonfirmasiTambahUangBergilir(
                              nominalTambahUang: widget.nominalTambahUang,
                              accountType: selectedSumberDana['accountType']!,
                              accountNumber:
                                  selectedSumberDana['accountNumber']!,
                              accountBalance: _formatCurrency(
                                  sumberDanaList[selectedIndex.value]
                                      ['accountBalance']!),
                              goalsName: widget.goalsName,
                              goalsData: widget.goalsData,
                              userName:
                                  userName!, // Pass userName, now it's ensured not to be null
                              accountId: selectedSumberDana['accountId']
                                  as int, // Pass accountId as int
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Selanjutnya',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class KonfirmasiTambahUangBergilir extends StatefulWidget {
  final String nominalTambahUang;
  final String accountType;
  final String accountNumber;
  final String accountBalance;
  final String goalsName;
  final Map<String, dynamic> goalsData;
  final String userName;
  final int accountId;

  const KonfirmasiTambahUangBergilir({
    super.key,
    required this.nominalTambahUang,
    required this.accountType,
    required this.accountNumber,
    required this.accountBalance,
    required this.goalsName,
    required this.goalsData,
    required this.userName,
    required this.accountId,
  });

  @override
  _KonfirmasiTambahUangBergilirState createState() =>
      _KonfirmasiTambahUangBergilirState();
}

class _KonfirmasiTambahUangBergilirState
    extends State<KonfirmasiTambahUangBergilir> {
  String? accountTypeGoalsName;
  bool isLoadingAccount = true;

  @override
  void initState() {
    super.initState();
    _fetchAccountTypeGoals();
  }

  Future<void> _fetchAccountTypeGoals() async {
    setState(() {
      isLoadingAccount = true;
    });
    String? token = await TokenManager().getToken();
    if (token == null) {
      setState(() {
        isLoadingAccount = false;
        accountTypeGoalsName = ''; // Default value if token is not available
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/accounts/${widget.accountId}'), // Use accountId
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['code'] == 200 && responseData['status'] == 'OK') {
          setState(() {
            accountTypeGoalsName =
                responseData['data']['type']; // Get account type name
            isLoadingAccount = false;
          });
        } else {
          setState(() {
            isLoadingAccount = false;
            accountTypeGoalsName =
                'Tabungan Bergilir'; // Default value on error
          });
        }
      } else {
        setState(() {
          isLoadingAccount = false;
          accountTypeGoalsName = 'Tabungan Bergilir'; // Default value on error
        });
      }
    } catch (e) {
      setState(() {
        isLoadingAccount = false;
        accountTypeGoalsName =
            'Tabungan Bergilir'; // Default value on exception
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Uang',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade700, Colors.blue.shade400],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.groups,
                    color: Colors.blue.shade700,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nominal ${widget.nominalTambahUang}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nama Goals: ${widget.goalsName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                  label: const Text(
                    'Ubah',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.accountType} - ${widget.accountNumber} - ${widget.accountBalance}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF4F6D85)),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      widget.nominalTambahUang,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, -1),
              blurRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Tambah',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  widget.nominalTambahUang,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailTambahUangBergilir(
                        nominalTambahUang: widget.nominalTambahUang,
                        accountType: widget.accountType,
                        accountNumber: widget.accountNumber,
                        accountBalance: widget.accountBalance,
                        goalsName: widget.goalsName,
                        goalsData: widget.goalsData,
                        accountTypeGoals: accountTypeGoalsName ??
                            'Tabungan Bergilir', // Use fetched account type or default
                        userName: widget.userName, // Pass userName
                      ),
                    ),
                  );
                },
                child: Text(
                  'Selanjutnya',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailTambahUangBergilir extends StatelessWidget {
  final String nominalTambahUang;
  final String accountType;
  final String accountNumber;
  final String accountBalance;
  final String goalsName;
  final Map<String, dynamic> goalsData;
  final String accountTypeGoals; // Get from API now
  final String userName; // Get from API now

  // Inisialisasi data di depan (No longer used for dummy data)
  final String tanggalTransaksi =
      DateFormat('d MMMM yyyy').format(DateTime.now()); // Get current date

  DetailTambahUangBergilir({
    super.key,
    required this.nominalTambahUang,
    required this.accountType,
    required this.accountNumber,
    required this.accountBalance,
    required this.goalsName,
    required this.goalsData,
    required this.accountTypeGoals,
    required this.userName,
  });

  // Determine accountTypeGoals based on savingGroupType
  String getDisplayAccountTypeGoals(Map<String, dynamic> goalsData) {
    final savingGroupType = goalsData['savingGroupType'];
    if (savingGroupType == 'JOINT_SAVING') {
      return 'Tabungan Bergilir';
    } else if (savingGroupType == 'ROTATING_SAVING') {
      return 'Tabungan Bergilir';
    } else {
      return 'Jenis Tabungan Tidak Diketahui'; // Default case
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayAccountTypeGoals = getDisplayAccountTypeGoals(goalsData);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade700, Colors.blue.shade400],
            ),
          ),
        ),
        elevation: 0,
        toolbarHeight: 84,
        titleSpacing: 16,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Uang',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            height: 12,
            width: 12,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Informasi
            Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Jenis Goals',
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        displayAccountTypeGoals, // Use dynamically determined account type
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nama Goals',
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                      Expanded(
                        // Wrap Text with Expanded
                        child: Text(
                          goalsName,
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                          overflow:
                              TextOverflow.ellipsis, // Add overflow ellipsis
                          maxLines: 1, // Limit to one line
                          textAlign: TextAlign.end, // Align text to the end
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nama',
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        userName, // Use userName passed from previous screen
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nominal Tambah Uang',
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        nominalTambahUang,
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rekening Sumber',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tabungan $accountType - $accountNumber',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Tambah Uang',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      Text(
                        nominalTambahUang,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Divider()
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal Transaksi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    // SizedBox(height: 8),
                    const Text(
                      'Anda memilih transaksi segera',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tanggal',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      tanggalTransaksi,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                  ],
                )),
            const SizedBox(height: 8),
            const Divider(),
            Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  Text(
                    nominalTambahUang,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InputPinBergilir(
                  nominalTambahUang: nominalTambahUang,
                  accountType: accountType,
                  accountNumber: accountNumber,
                  accountBalance: accountBalance,
                  goalsName: goalsName,
                  accountTypeGoals:
                      displayAccountTypeGoals, // Pass dynamic account type
                  goalsData: goalsData,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            children: [
              Text(
                'Proses',
                style: TextStyle(
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                nominalTambahUang,
                style: TextStyle(
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InputPinBergilir extends StatefulWidget {
  final String nominalTambahUang;
  final String accountType;
  final String accountNumber;
  final String accountBalance;
  final String goalsName;
  final String accountTypeGoals;
  final Map<String, dynamic> goalsData;

  const InputPinBergilir(
      {super.key,
      required this.nominalTambahUang,
      required this.accountType,
      required this.accountTypeGoals,
      required this.accountNumber,
      required this.accountBalance,
      required this.goalsName,
      required this.goalsData});

  @override
  _InputPinBergilirState createState() => _InputPinBergilirState();
}

class _InputPinBergilirState extends State<InputPinBergilir> {
  String _pin = '';
  final int _pinLength = 6;
  final TokenManager _tokenManager = TokenManager();
  bool _isVerifyingPin = false;

  void _addPin(String number) {
    setState(() {
      if (_pin.length < _pinLength) {
        _pin = _pin + number;
      }
    });
    _validatePin();
  }

  void _removePin() {
    setState(() {
      if (_pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  Future<void> _validatePin() async {
    if (_pin.length == _pinLength) {
      setState(() {
        _isVerifyingPin = true;
      });
      final String? token = await _tokenManager.getToken();
      if (token == null) {
        _showErrorSnackbar("Token tidak ditemukan, silakan login ulang");
        setState(() {
          _isVerifyingPin = false;
        });
        return;
      }

      try {
        const String pinEndpoint = "/auth/verify-transaction-pin";
        final String apiUrl = baseUrl + pinEndpoint;

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'transaction_pin': _pin,
          }),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          if (responseData['code'] == 200 && responseData['status'] == 'OK') {
            if (responseData['data']['is_valid'] == true) {
              _createTransaction(); // Call create transaction after PIN is valid
            } else {
              _showErrorSnackbar("Pin yang Anda masukkan salah");
              setState(() {
                _pin = '';
                _isVerifyingPin = false;
              });
            }
          } else {
            _showErrorSnackbar(responseData['errors'] != null &&
                    (responseData['errors'] as List).isNotEmpty
                ? (responseData['errors'] as List)[0].toString()
                : "Terjadi kesalahan saat validasi PIN. Silahkan coba lagi!");
            setState(() {
              _pin = '';
              _isVerifyingPin = false;
            });
          }
        } else {
          _showErrorSnackbar(
              "Terjadi kesalahan saat verifikasi PIN, kode status : ${response.statusCode}. Silahkan coba lagi!");
          setState(() {
            _pin = '';
            _isVerifyingPin = false;
          });
        }
      } catch (e) {
        _showErrorSnackbar(
            "Terjadi kesalahan saat verifikasi PIN, pesan: ${e.toString()}. Silahkan coba lagi!");
        setState(() {
          _pin = '';
          _isVerifyingPin = false;
        });
      }
    }
  }

  Future<void> _createTransaction() async {
    final String? token = await _tokenManager.getToken();
    final String? userId = await _tokenManager.getUserId();
    if (token == null || userId == null) {
      _showErrorSnackbar(
          "Token atau User ID tidak ditemukan, silakan login ulang");
      setState(() {
        _isVerifyingPin = false;
      });
      return;
    }

    // Print all the data being used for transaction

    try {
      const String transactionEndpoint = "/transactions";
      final String apiUrl = baseUrl + transactionEndpoint;

      final Map<String, dynamic> requestBody = {
        "user_id": userId,
        "saving_group_id": widget.goalsData['savingGroupId'],
        "amount": int.parse(widget.nominalTambahUang
            .replaceAll(RegExp(r'[^0-9]'), '')), // Parse nominal to integer
        "transaction_type": "CREDIT"
      };

      // Print request body

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      setState(() {
        _isVerifyingPin = false; // Stop loading after transaction attempt
      });

      // Print status code
      // Print response body

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['code'] == 201 &&
            responseData['status'] == 'Created') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BerhasilTambahUangBergilir(
                nominalTambahUang: widget.nominalTambahUang,
                accountType: widget.accountType,
                accountNumber: widget.accountNumber,
                goalsName: widget.goalsName,
                tanggalTransaksi:
                    DateFormat('d MMMM yyyy').format(DateTime.now()),
                accountBalance: widget.accountBalance,
                accountTypeGoals: widget.accountTypeGoals,
                goalsData: widget.goalsData,
                transactionNumber: responseData['data']
                    ['transaction_number'], // Pass transaction number
              ),
            ),
          );
        } else {
          _showErrorSnackbar(responseData['errors'] != null &&
                  (responseData['errors'] as List).isNotEmpty
              ? (responseData['errors'] as List)[0].toString()
              : "Gagal membuat transaksi, silahkan coba lagi!");
        }
      } else {
        _showErrorSnackbar(
            "Gagal membuat transaksi, kode status : ${response.statusCode}. Silahkan coba lagi!");
      }
    } catch (e) {
      _showErrorSnackbar(
          "Terjadi kesalahan saat membuat transaksi, pesan: ${e.toString()}. Silahkan coba lagi!");
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        toolbarHeight: 84,
        titleSpacing: 16,
        automaticallyImplyLeading: false,
        title: const Text(
          'Input M-PIN Mobile Banking',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            height: 12,
            width: 12,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue.shade700, Colors.blue.shade400],
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 36,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          _pinLength,
                          (index) => Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 18),
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: index < _pin.length
                                      ? Colors.amber
                                      : Colors.grey[300],
                                ),
                              )),
                    ),
                    const SizedBox(
                      height: 36,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      ...[
                        '1',
                        '2',
                        '3',
                        '4',
                        '5',
                        '6',
                        '7',
                        '8',
                        '9',
                        '',
                        '0',
                        'backspace',
                      ].map(
                        (number) => InkWell(
                          onTap: () {
                            if (number == 'backspace') {
                              _removePin();
                            } else if (number.isNotEmpty) {
                              _addPin(number);
                            }
                          },
                          child: Center(
                            child: number == 'backspace'
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Spacer(),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.backspace_rounded,
                                              color: Colors.amber),
                                          TextButton(
                                            onPressed: () {
                                              // todo: action lupa pin
                                            },
                                            child: const Text(
                                              'Lupa PIN',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.blue),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer()
                                    ],
                                  )
                                : Text(
                                    number,
                                    style: const TextStyle(
                                        fontSize: 24, color: Colors.black),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Kembali',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isVerifyingPin)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class BerhasilTambahUangBergilir extends StatelessWidget {
  final String nominalTambahUang;
  final String accountType;
  final String accountTypeGoals;
  final String accountNumber;
  final String goalsName;
  final String tanggalTransaksi;
  final String accountBalance;
  final Map<String, dynamic> goalsData;
  final String? transactionNumber; // Add transactionNumber parameter

  const BerhasilTambahUangBergilir({
    super.key,
    required this.nominalTambahUang,
    required this.accountType,
    required this.accountNumber,
    required this.goalsName,
    required this.tanggalTransaksi,
    required this.accountBalance,
    required this.accountTypeGoals,
    required this.goalsData,
    this.transactionNumber, // Initialize transactionNumber
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'SUKSES',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('d MMMM yyyy HH:mm')
                          .format(DateTime.now()), // Current date and time
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'NO. REF',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        transactionNumber ??
                            '-', // Display transactionNumber or placeholder
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Jenis Goals',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      accountTypeGoals,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nama Goals',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Expanded(
                      // Wrap Text with Expanded
                      child: Row(
                        children: [
                          Expanded(
                            // Add Expanded to the inner Text as well
                            child: Text(
                              goalsName,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade800,
                              ),
                              overflow: TextOverflow
                                  .ellipsis, // Add overflow ellipsis here too
                              maxLines: 1, // Limit to one line
                              textAlign: TextAlign.end, // Align text to the end
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nominal Tambah Uang',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      nominalTambahUang,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rekening Sumber',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$accountType - $accountNumber',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.blue.shade700),
                            ),
                          ),
                          Text(
                            accountBalance,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tanggal Transaksi',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Anda memilih transfer segera untuk transaksi ini',
                  style: TextStyle(fontSize: 13, color: Colors.red),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tanggal',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                ),
                const SizedBox(height: 4),
                Text(
                  tanggalTransaksi,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800),
                    ),
                    Text(
                      nominalTambahUang,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 36,
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // todo: action bagikan
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'Bagikan',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            // todo: action simpan favorit
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.blue),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text(
                            'Simpan Favorit',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, '/beranda'); // Navigate to Beranda
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow.shade700,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            'Selesai',
                            style: TextStyle(color: Colors.blue.shade900),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
