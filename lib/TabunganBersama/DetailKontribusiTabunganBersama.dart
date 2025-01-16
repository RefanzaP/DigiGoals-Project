// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class Account {
  final String namaRekening;
  final String nomorRekening;
  Account({
    required this.namaRekening,
    required this.nomorRekening,
  });
}

class DetailKontribusiTabunganBersama extends StatefulWidget {
  final Map<String, dynamic> goalsData;

  const DetailKontribusiTabunganBersama({
    super.key,
    required this.goalsData,
  });

  @override
  State<DetailKontribusiTabunganBersama> createState() =>
      _DetailKontribusiTabunganBersamaState();
}

class _DetailKontribusiTabunganBersamaState
    extends State<DetailKontribusiTabunganBersama> {
  List<Map<String, dynamic>> anggotaData = [];
  List<Map<String, dynamic>> filteredData = [];
  String selectedFilter = 'None';
  late double targetTotal;
  late double saldoTabungan;
  late double progressTabungan;
  bool isLoading = true;
  late String goalsName;
  late List<String> members;
  late List<String> _allMembers;

  final _dummyAccountData = Account(
    namaRekening: "ABI",
    nomorRekening: '0123456789012',
  );

  @override
  void initState() {
    super.initState();
    _initializeData();
    _fetchData();
  }

  void _initializeData() {
    goalsName = widget.goalsData['goalsName'];
    saldoTabungan = widget.goalsData['saldoTabungan'];
    progressTabungan = widget.goalsData['progressTabungan'];
    targetTotal = widget.goalsData['targetTabungan'];
    members = List<String>.from(widget.goalsData['members']);
    _allMembers = [_dummyAccountData.namaRekening, ...members];
  }

  Future<void> _fetchData() async {
    try {
      setState(() => isLoading = true);
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network or DB delay

      // Calculate the total target per member (including the owner/dummy account)
      final double targetPerMember = targetTotal / _allMembers.length;

      anggotaData = _allMembers.map((member) {
        double amount = 0;
        String nomerRekening = _generateRandomAccountNumber();

        if (member == _dummyAccountData.namaRekening) {
          amount = saldoTabungan * progressTabungan;
          nomerRekening = _dummyAccountData.nomorRekening;
        } else {
          amount = targetPerMember * progressTabungan;
        }

        return {
          'name': member,
          'id': nomerRekening,
          'role':
              member == _dummyAccountData.namaRekening ? 'Pemilik' : 'Anggota',
          'color': _generateRandomColor(), // Generate random color
          'amount': amount,
        };
      }).toList();
      setState(() {
        filteredData = List.from(anggotaData);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  String _generateRandomAccountNumber() {
    Random random = Random();
    String accountNumber = '';
    for (int i = 0; i < 15; i++) {
      accountNumber += random.nextInt(10).toString();
    }
    return accountNumber;
  }

  Color _generateRandomColor() {
    // Generate a random color
    return Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }

  void _filterAnggota(String query) {
    setState(() {
      filteredData = anggotaData
          .where((anggota) =>
              anggota['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      switch (filter) {
        case 'Kontribusi Tertinggi':
          filteredData.sort((a, b) => b['amount'].compareTo(a['amount']));
          break;
        case 'Kontribusi Terendah':
          filteredData.sort((a, b) => a['amount'].compareTo(b['amount']));
          break;
        case 'Nama A-Z':
          filteredData.sort((a, b) => a['name'].compareTo(b['name']));
          break;
        case 'Nama Z-A':
          filteredData.sort((a, b) => b['name'].compareTo(a['name']));
          break;
        case 'None':
        default:
          filteredData = List.from(anggotaData);
      }
    });
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0)
        .format(amount.round());
  }

  @override
  Widget build(BuildContext context) {
    double overallProgress = progressTabungan;

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
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Detail Kontribusi Tabungan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Visualisasi progress grup yang diperbarui
            Container(
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.track_changes,
                            color: Colors.blue,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Progress Tabungan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Tooltip(
                        message: 'Total progress dari semua anggota',
                        child: Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${_formatCurrency((overallProgress * targetTotal))} / ${_formatCurrency(targetTotal)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: overallProgress,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: overallProgress < 1.0
                                ? Colors.blue
                                : Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(overallProgress * 100).toStringAsFixed(1)}% Terpenuhi',
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        overallProgress < 1.0
                            ? 'Terus Menabung'
                            : 'Target Tercapai!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Search bar dan sorting
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          fillColor: Colors.blue.shade50,
                          filled: true,
                          hintText: 'Cari Anggota',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: _filterAnggota,
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      onSelected: _applyFilter,
                      icon: Icon(Icons.filter_list_rounded, color: Colors.blue),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'None', child: Text('None')),
                        const PopupMenuItem(
                            value: 'Nama A-Z', child: Text('Nama A-Z')),
                        const PopupMenuItem(
                            value: 'Nama Z-A', child: Text('Nama Z-A')),
                        const PopupMenuItem(
                            value: 'Kontribusi Tertinggi',
                            child: Text('Kontribusi Tertinggi')),
                        const PopupMenuItem(
                            value: 'Kontribusi Terendah',
                            child: Text('Kontribusi Terendah')),
                      ],
                    ),
                  ],
                ),
                if (selectedFilter != 'None')
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Filter: $selectedFilter',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        final anggota = filteredData[index];
                        double progress = anggota['amount'] /
                            (targetTotal / _allMembers.length);
                        return Card(
                          color: Colors.white,
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: anggota['color'],
                                      radius: 24,
                                      child: Text(
                                        anggota['name'][0],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            anggota['name'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${anggota['id']}',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _formatCurrency(anggota['amount']),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Stack(
                                  children: [
                                    Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: progress,
                                      child: Container(
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: progress < 1.0
                                              ? Colors.blue
                                              : Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        '${(progress * 100).toStringAsFixed(1)}% Tercapai',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
