import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailTargetTabunganBergilir extends StatefulWidget {
  const DetailTargetTabunganBergilir({super.key});

  @override
  State<DetailTargetTabunganBergilir> createState() =>
      _DetailTargetTabunganBergilirState();
}

class _DetailTargetTabunganBergilirState
    extends State<DetailTargetTabunganBergilir> {
  List<Map<String, dynamic>> anggotaData = [];
  List<Map<String, dynamic>> filteredData = [];
  String selectedFilter = 'None';
  double targetTotal = 100000000;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      setState(() => isLoading = true);
      // Placeholder for fetching data from any source (API, SQLite, Firestore, etc.)
      // Replace this part when integrating with a specific database
      await Future.delayed(
          Duration(seconds: 2)); // Simulate network or DB delay

      // Sample static data for now
      anggotaData = [
        {
          'name': 'ABI',
          'id': '0123456789001',
          'role': 'Pemilik',
          'color': Colors.blue,
          'amount': 10000000,
          'status': 'Belum Lunas'
        },
        {
          'name': 'INTAN',
          'id': '0123456789002',
          'role': 'Anggota',
          'color': Colors.orange,
          'amount': 5000000,
          'status': 'Lunas'
        },
        {
          'name': 'UMI',
          'id': '0123456789003',
          'role': 'Anggota',
          'color': Colors.pink,
          'amount': 10000000,
          'status': 'Belum Lunas'
        },
        {
          'name': 'EDI',
          'id': '0123456789004',
          'role': 'Anggota',
          'color': Colors.purple,
          'amount': 2000000,
          'status': 'Lunas'
        },
        {
          'name': 'OMEN',
          'id': '0123456789005',
          'role': 'Anggota',
          'color': Colors.deepOrange,
          'amount': 10000000,
          'status': 'Belum Lunas'
        },
      ];

      setState(() {
        filteredData = List.from(anggotaData);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() => isLoading = false);
    }
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
        case 'Status Lunas':
          filteredData =
              anggotaData.where((a) => a['status'] == 'Lunas').toList();
          break;
        case 'Status Belum Lunas':
          filteredData =
              anggotaData.where((a) => a['status'] == 'Belum Lunas').toList();
          break;
        case 'None':
        default:
          filteredData = List.from(anggotaData);
      }
    });
  }

  String _formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0)
        .format(amount);
  }

  double _calculateProgress() {
    double totalContributed =
        anggotaData.fold(0, (sum, item) => sum + item['amount']);
    return totalContributed / targetTotal;
  }

  @override
  Widget build(BuildContext context) {
    double overallProgress = _calculateProgress();
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
          'Detail Target Tabungan',
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
                    '${_formatCurrency((overallProgress * targetTotal).toInt())} / ${_formatCurrency(targetTotal.toInt())}',
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
                        const PopupMenuItem(
                            value: 'Status Lunas', child: Text('Status Lunas')),
                        const PopupMenuItem(
                            value: 'Status Belum Lunas',
                            child: Text('Status Belum Lunas')),
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
            // Daftar anggota
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        final anggota = filteredData[index];
                        double progress = anggota['amount'] / targetTotal;
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
                                    IconButton(
                                      icon: Icon(Icons.notifications_active,
                                          color: Colors.orange.shade700),
                                      tooltip: 'Kirim Pengingat',
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Pengingat dikirim ke ${anggota['name']}'),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '${_formatCurrency(anggota['amount'])} / ${_formatCurrency(targetTotal.toInt())}',
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
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    Text(
                                      anggota['status'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: anggota['status'] == 'Lunas'
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
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
