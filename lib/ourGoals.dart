// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'package:digigoals_app/Beranda.dart';
import 'package:digigoals_app/PilihGoals.dart';
import 'package:digigoals_app/TabunganBergilir/DetailTabunganBergilir.dart';
import 'package:digigoals_app/TabunganBersama/DetailTabunganBersama.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class OurGoals extends StatefulWidget {
  const OurGoals({super.key});

  @override
  _OurGoalsState createState() => _OurGoalsState();
}

class _OurGoalsState extends State<OurGoals> {
  bool _isLoading = true;
  bool _isNavigating = false;
  String? _errorMessage;

  // List statis untuk menyimpan data goals
  final List<Map<String, dynamic>> _databaseGoals = [
    {
      'goalsType': 'Tabungan Bersama',
      'goalsName': 'Liburan Keluarga 🏖️',
      'saldoTabungan': 6000000.00,
      'targetTabungan': 20000000.00,
      'progress': 0.3,
      'daysLeft': 90,
      'members': ['Fafa', 'Gina', 'Hani', 'Olaf'],
      'creationDate': '23-05-2024',
    },
    {
      'goalsType': 'Tabungan Bergilir',
      'goalsName': 'Gudang Garam Jaya 🔥',
      'saldoTabungan': 20000000.00,
      'targetTabungan': 50000000.00,
      'progress': 0.4,
      'daysLeft': 100,
      'members': [
        'Fafa',
        'Gina',
        'Hani',
        'Olaf',
      ],
      'creationDate': '24-05-2024',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  // Fungsi untuk load goals dan memicu rebuild
  void _loadGoals() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate loading
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const Beranda()),
                    (Route<dynamic> route) => false);
              },
            ),
            title: Text(
              'Our Goals',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildCreateGoalCard(context),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Goals Kamu Saat Ini',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? _buildShimmerLoader(5)
                    : _errorMessage != null
                        ? Center(
                            child: Text(_errorMessage!),
                          )
                        : _databaseGoals.isNotEmpty
                            ? ListView.builder(
                                key: const Key('goalsListView'),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: _databaseGoals.length,
                                itemBuilder: (context, index) {
                                  final goal = _databaseGoals[index];
                                  return GoalCard(
                                    goal: goal,
                                    onTap: () {
                                      _navigateToDetail(context, goal);
                                    },
                                  );
                                },
                              )
                            : const Center(
                                child: Text('No goals available.'),
                              ),
              )
            ],
          ),
        ),
        if (_isNavigating)
          Stack(
            children: [
              ModalBarrier(
                color: Colors.black.withOpacity(0.5),
                dismissible: false,
              ),
              Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.yellow.shade700),
                ),
              ),
            ],
          ),
      ],
    );
  }

  // Function to navigate to the detail page based on goal type
  void _navigateToDetail(BuildContext context, Map<String, dynamic> goal) {
    if (goal['goalsType'] == 'Tabungan Bersama') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DetailTabunganBersama(),
        ),
      );
    } else if (goal['goalsType'] == 'Tabungan Bergilir') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DetailTabunganBergilir(),
        ),
      );
    }
  }

  Widget _buildCreateGoalCard(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: Colors.black.withOpacity(0.5),
      elevation: 4,
      child: InkWell(
        onTap: () async {
          setState(() {
            _isNavigating = true;
          });

          await Future.delayed(const Duration(seconds: 1));

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PilihGoals(),
            ),
          ).then((value) {
            setState(() {
              _isNavigating = false;
            });
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 0,
                right: 20,
                child: Image.asset(
                  'assets/images/bankbjb-logo.png',
                  width: 51,
                  height: 26,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFC945),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.add, size: 32, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Buat Goals Kamu!',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sesuaikan Goals kamu untuk hal yang kamu inginkan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoader(int count) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: count,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 100,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}

class GoalCard extends StatelessWidget {
  final Map<String, dynamic> goal;
  final VoidCallback? onTap;

  const GoalCard({required this.goal, super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi formatter untuk mata uang Rupiah
    final currencyFormat = NumberFormat.currency(
        locale: 'id_ID', symbol: 'IDR ', decimalDigits: 2);

    // Format saldo dan target tabungan ke mata uang Rupiah
    final formattedSaldo = currencyFormat.format(goal['saldoTabungan']);
    final formattedTarget = currencyFormat.format(goal['targetTabungan']);

    // Inisialisasi list untuk menyimpan widget circle avatar
    List<Widget> memberAvatars = [];

    // Batasi hanya menampilkan 2 avatar dan sisanya tampilkan dalam 1 avatar
    int maxAvatars = 2;
    int displayedCount = 0; //untuk menghitung jumlah avatar yang ditampilkan
    if (goal['members'] != null) {
      for (int i = 0; i < goal['members'].length; i++) {
        String memberName = goal['members'][i];
        if (displayedCount < maxAvatars) {
          memberAvatars.add(
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.primaries[
                  i % Colors.primaries.length], // Memberikan warna otomatis
              child: Text(
                memberName
                    .substring(0, 1)
                    .toUpperCase(), // Mengambil huruf pertama dan uppercase
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          );
          displayedCount++;
        }
      }
      if (goal['members'].length > maxAvatars) {
        int remainingMembers = goal['members'].length - maxAvatars;
        memberAvatars.add(
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.grey,
            child: Text(
              '+$remainingMembers',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        );
      }
    }

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: Colors.black.withOpacity(0.5),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Menggunakan conditional untuk memilih icon
                      Icon(
                        goal['goalsType'] == 'Tabungan Bergilir'
                            ? Icons.celebration
                            : Icons.groups,
                        color: Colors.blue,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        goal['goalsType'], // Menampilkan jenis tabungan
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black),
                      ),
                    ],
                  ),
                  Row(children: memberAvatars // Menggunakan list circle avatar
                      ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                goal['goalsName'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF1F597F),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '$formattedSaldo / $formattedTarget', // Menampilkan saldo dan target dengan format Rupiah
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.grey[800]),
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
                    widthFactor: goal['progress'] ?? 0.0,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.blue,
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
                    '${((goal['progress'] ?? 0.0) * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.black),
                  ),
                  Text(
                    'Sisa ${goal['daysLeft'] ?? '-'} hari',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
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
