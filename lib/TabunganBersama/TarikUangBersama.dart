// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:digigoals_app/Beranda.dart';
import 'package:digigoals_app/OurGoals.dart'; // Import file OurGoals.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'dart:math';

class TarikUangBersama extends StatefulWidget {
  final Map<String, dynamic> goalsData;
  const TarikUangBersama({super.key, required this.goalsData});

  @override
  _TarikUangBersamaState createState() => _TarikUangBersamaState();
}

class _TarikUangBersamaState extends State<TarikUangBersama> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nominalController;
  late TextEditingController _waktuTransaksiController;

  bool isTodayEnabled = true;
  bool isWeeklyEnabled = false;
  bool isDateEnabled = false;
  bool isSpecificDateEnabled = false;

  late String namaGoals; // Nama goals dari widget.goalsData
  final String tanggalTransaksiDefault = 'Sekarang';

  @override
  void initState() {
    super.initState();
    namaGoals = widget.goalsData['goalsName'] ?? 'Nama Goals Tidak Tersedia';
    _nominalController = TextEditingController();
    _waktuTransaksiController =
        TextEditingController(text: tanggalTransaksiDefault);
  }

  @override
  void dispose() {
    _nominalController.dispose();
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

  @override
  Widget build(BuildContext context) {
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
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tarik Uang',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            height: 12,
            width: 12,
            decoration: BoxDecoration(
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
                // Nominal Tarik Uang
                Text(
                  "Nominal Tarik Uang",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nominalController,
                  decoration: InputDecoration(
                    fillColor: Colors.blue.shade50,
                    filled: true,
                    hintText: 'Tentukan Nominal Tarik Uang',
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
                      return 'Nominal Tarik Uang tidak boleh kosong';
                    }
                    final nominal =
                        int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
                    if (nominal == null || nominal < 10000) {
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
                    suffixIcon: Icon(Icons.edit_calendar),
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
                    builder: (context) => PilihSumberDanaTarikBersama(
                      nominal: _nominalController.text,
                      sumberDana: 'Tabungan Tandamata',
                      saldo: 'IDR 234.567.890,00',
                      namaGoals: namaGoals,
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

class PilihSumberDanaTarikBersama extends StatelessWidget {
  final String nominal;
  final String sumberDana;
  final String saldo;
  final String namaGoals;
  final Map<String, dynamic> goalsData;

  PilihSumberDanaTarikBersama({
    super.key,
    required this.nominal,
    required this.sumberDana,
    required this.saldo,
    required this.namaGoals,
    required this.goalsData,
  });

  // Inisialisasi data sumber dana di depan (sesuaikan dengan kebutuhan aplikasi Anda)
  final List<Map<String, String>> sumberDanaList = [
    {
      'jenis': 'Tabungan Tandamata',
      'rekening': '0123456789012',
      'saldo': 'IDR 234.567.890,00'
    },
    {
      'jenis': 'Tabungan Tandamata Gold',
      'rekening': '0987654321098',
      'saldo': 'IDR 100.000.000,00'
    },
    {
      'jenis': 'Tabungan Tandamata',
      'rekening': '1122334455667',
      'saldo': 'IDR 50.000.000,00'
    },
  ];

  @override
  Widget build(BuildContext context) {
    ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tarik Uang',
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
                    Icons.savings,
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
                        'Nominal: $nominal',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nama Goals: $namaGoals',
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
                                  sumber['jenis']!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: value == index
                                        ? Colors.blue.shade700
                                        : Colors.blue.shade700,
                                  ),
                                ),
                                Text(
                                  sumber['rekening']!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: value == index
                                        ? Colors.blue.shade700
                                        : Colors.blue.shade700,
                                  ),
                                ),
                                Text(
                                  sumber['saldo']!,
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
                  'Total Tarik',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  nominal,
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
                      builder: (context) => KonfirmasiTarikUangBersama(
                        nominal: nominal,
                        jenis: selectedSumberDana['jenis']!,
                        rekening: selectedSumberDana['rekening']!,
                        saldo: selectedSumberDana['saldo']!,
                        namaGoals: namaGoals,
                        goalsData: goalsData,
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

class KonfirmasiTarikUangBersama extends StatelessWidget {
  final String nominal;
  final String jenis;
  final String rekening;
  final String saldo;
  final String namaGoals;
  final Map<String, dynamic> goalsData;

  const KonfirmasiTarikUangBersama({
    super.key,
    required this.nominal,
    required this.jenis,
    required this.rekening,
    required this.saldo,
    required this.namaGoals,
    required this.goalsData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tarik Uang',
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
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    Icons.savings,
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
                        'Nominal $nominal',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nama Goals: $namaGoals',
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
                    '$jenis - $rekening - $saldo',
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
                      nominal,
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
                  'Total Tarik',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  nominal,
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
                      builder: (context) => DetailTarikUangBersama(
                        nominal: nominal,
                        jenis: jenis,
                        rekening: rekening,
                        saldo: saldo,
                        namaGoals: namaGoals,
                        goalsData: goalsData,
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

class DetailTarikUangBersama extends StatelessWidget {
  final String nominal;
  final String jenis;
  final String rekening;
  final String saldo;
  final String namaGoals;
  final Map<String, dynamic> goalsData;

  // Inisialisasi data di depan
  final String jenisGoals = 'Bersama'; // Ubah sesuai untuk tabungan bersama
  final String namaPengguna =
      'ABI'; // Bisa ambil dari data pengguna atau _goalsData
  final String tanggalTransaksi = '1 November 2024';

  const DetailTarikUangBersama({
    super.key,
    required this.nominal,
    required this.jenis,
    required this.rekening,
    required this.saldo,
    required this.namaGoals,
    required this.goalsData,
  });

  @override
  Widget build(BuildContext context) {
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
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Tarik Uang',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            height: 12,
            width: 12,
            decoration: BoxDecoration(
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
                        jenisGoals,
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
                      Text(
                        namaGoals,
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
                        'Nama',
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        namaPengguna,
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
                        'Nominal Tarik Uang',
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        nominal,
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
                    '$jenis - $rekening',
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
                        'Total Tarik Uang',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      Text(
                        nominal,
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
              ),
            ),
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
                    nominal,
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
                builder: (context) => InputPinTarikBersama(
                  nominal: nominal,
                  jenis: jenis,
                  rekening: rekening,
                  saldo: saldo,
                  namaGoals: namaGoals,
                  jenisGoals: jenisGoals,
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
                nominal,
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

class InputPinTarikBersama extends StatefulWidget {
  final String nominal;
  final String jenis;
  final String rekening;
  final String saldo;
  final String namaGoals;
  final String jenisGoals;
  final Map<String, dynamic> goalsData;

  const InputPinTarikBersama({
    super.key,
    required this.nominal,
    required this.jenis,
    required this.jenisGoals,
    required this.rekening,
    required this.saldo,
    required this.namaGoals,
    required this.goalsData,
  });

  @override
  _InputPinTarikBersamaState createState() => _InputPinTarikBersamaState();
}

class _InputPinTarikBersamaState extends State<InputPinTarikBersama> {
  String _pin = '';
  final int _pinLength = 6;

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

  void _validatePin() {
    if (_pin.length == _pinLength) {
      // Simulasi validasi PIN (ganti dengan logika validasi API Anda)
      if (_pin == '123456') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BerhasilTarikUangBersama(
              nominal: widget.nominal,
              jenis: widget.jenis,
              rekening: widget.rekening,
              namaGoals: widget.namaGoals,
              tanggalTransaksi: '1 November 2024',
              saldo: widget.saldo,
              jenisGoals: widget.jenisGoals,
              goalsData: widget.goalsData, // mengirim data goals
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pin yang Anda masukkan salah'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _pin = '';
        });
      }
    }
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
      body: Column(
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
              )),
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
                                // Menggunakan Row untuk mengatur posisi ikon dan button
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Spacer(), // Spacer untuk mendorong ikon ke tengah
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
                                              fontSize: 12, color: Colors.blue),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer() // Spacer agar ikon dan text tetap di tengah
                                ],
                              )
                            : Text(
                                number,
                                style: TextStyle(
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
    );
  }
}

class BerhasilTarikUangBersama extends StatelessWidget {
  final String nominal;
  final String jenis;
  final String jenisGoals;
  final String rekening;
  final String namaGoals;
  final String tanggalTransaksi;
  final String saldo;
  final Map<String, dynamic> goalsData; // Menerima data goals

  const BerhasilTarikUangBersama({
    super.key,
    required this.nominal,
    required this.jenis,
    required this.rekening,
    required this.namaGoals,
    required this.tanggalTransaksi,
    required this.saldo,
    required this.jenisGoals,
    required this.goalsData, // Menerima data goals
  });

  String _generateRandomRef() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        16, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  String _generateRandomRRN() {
    Random random = Random();
    return random.nextInt(999999).toString().padLeft(6, '0');
  }

  @override
  Widget build(BuildContext context) {
    final String randomRef = _generateRandomRef();
    final String randomRRN = _generateRandomRRN();

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
                      '1 November 2024 09:15',
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
                        randomRef,
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
                      'RRN',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      randomRRN,
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
                      'Jenis Goals',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      jenisGoals,
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
                    Row(
                      children: [
                        Text(
                          namaGoals,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nominal Tarik Uang',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      nominal,
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
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$jenis - $rekening',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.blue.shade700),
                            ),
                          ),
                          Text(
                            saldo,
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
                      nominal,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800),
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // todo: action bagikan
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Simpan Favorit',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement<void, void>(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    const Beranda(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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
