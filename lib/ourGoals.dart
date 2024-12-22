import 'package:digigoals_app/Beranda.dart';
import 'package:digigoals_app/PilihGoals.dart';
import 'package:flutter/material.dart';
import 'theme/theme.dart';
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
  Future<List<Map<String, dynamic>>>? _goalsFuture;

  @override
  void initState() {
    super.initState();
    _goalsFuture = _fetchGoalsFromDatabase();
  }

  // Fungsi ini tidak lagi digunakan, karena data diambil dari _fetchGoalsFromDatabase()
  // Future<void> fetchGoalsData() async {
  //   try {
  //     setState(() {
  //       _isLoading = true;
  //       _errorMessage = null;
  //     });
  //     // Simulate API call/Database fetch
  //     await Future.delayed(const Duration(seconds: 1));
  //     setState(() {
  //       goalsList = [
  //         {
  //           'title': 'Tabungan Bersama',
  //           'goalName': 'Pernikahan Kita',
  //           'amount': 'IDR 160.000.00 / 200.000.000,00',
  //           'progress': 0.8,
  //           'daysLeft': 340,
  //           'members': [
  //             {'initial': 'A', 'color': Colors.blue},
  //             {'initial': 'U', 'color': Colors.orange},
  //             {'initial': '+2', 'color': Colors.grey},
  //           ],
  //         },
  //       ];
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _isLoading = false;
  //       _errorMessage = 'Failed to load goals.';
  //     });
  //   }
  // }

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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const Beranda()),
                (Route<dynamic> route) => false);
          },
        ),
        title: Text(
          'Our Goals',
          style: AppTextStyle.bodyText1.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
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
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildCreateGoalCard(context),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Goals Kamu Saat Ini',
                  style: AppTextStyle.bodyText1.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? _buildShimmerLoader(5) // Selalu tampilkan 5 shimmer
                    : _errorMessage != null
                        ? Center(
                            child: Text(_errorMessage!),
                          )
                        : FutureBuilder<List<Map<String, dynamic>>>(
                            future: _goalsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return _buildShimmerLoader(
                                    5); // Tetap tampilkan 5 shimmer saat menunggu
                              } else if (snapshot.hasError) {
                                return const Center(
                                  child: Text('Failed to load goals.'),
                                );
                              } else if (snapshot.hasData &&
                                  snapshot.data!.isNotEmpty) {
                                return ListView.builder(
                                  key: const Key('goalsListView'),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    final goal = snapshot.data![index];
                                    return GoalCard(
                                      goal: goal,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                GoalDetail(goal: goal),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              } else {
                                return const Center(
                                  child: Text('No goals available.'),
                                );
                              }
                            },
                          ),
              )
            ],
          ),
          if (_isNavigating)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue), // Set warna biru
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchGoalsFromDatabase() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate database fetch
    setState(() {
      _isLoading = true;
    });

    try {
      final List<Map<String, dynamic>> data = [
        {
          'title': 'Tabungan Bersama',
          'goalName': 'Pernikahan Kita',
          'amount': 'IDR 160.000.000,00 / 200.000.000,00',
          'progress': 0.8,
          'daysLeft': 340,
          'members': [
            {'initial': 'A', 'color': Colors.blue},
            {'initial': 'U', 'color': Colors.orange},
            {'initial': '+2', 'color': Colors.grey},
          ],
        },
      ];

      setState(() {
        _isLoading = false;
      });
      return data;
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load goals.';
      });
      return [];
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
                        color: AppColors.yellow1,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.add, size: 32, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Buat Tabungan Bersamamu!',
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
  final VoidCallback onTap;

  const GoalCard({required this.goal, super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
                      const Icon(
                        Icons.groups,
                        color: Colors.blue,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        goal['title'],
                        style: AppTextStyle.bodyMText1.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                  Row(
                    children: goal['members']
                        .map<Widget>((member) => CircleAvatar(
                              radius: 12,
                              backgroundColor: member['color'],
                              child: Text(
                                member['initial'],
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                goal['goalName'],
                style: AppTextStyle.bodyText1.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                goal['amount'],
                style: AppTextStyle.bodyMText1
                    .copyWith(color: Colors.grey[800], fontSize: 12),
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
                    widthFactor: goal['progress'],
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
                    '${(goal['progress'] * 100).toStringAsFixed(0)}%',
                    style: AppTextStyle.bodyMText1.copyWith(fontSize: 12),
                  ),
                  Text(
                    'Sisa ${goal['daysLeft']} hari',
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

// Tambahkan halaman detail
class GoalDetail extends StatelessWidget {
  final Map<String, dynamic> goal;
  const GoalDetail({super.key, required this.goal});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(goal['goalName']),
      ),
      body: Center(
        child: Text('Halaman Detail Goal: ${goal['goalName']}'),
      ),
    );
  }
}
