import 'package:digigoals_app/Beranda.dart';
import 'package:digigoals_app/TabunganBergilir/BuatTabunganBergilir.dart';
import 'package:digigoals_app/TabunganBersama/BuatTabunganBersama.dart';
import 'package:flutter/material.dart';
import 'theme/theme.dart';
import 'package:shimmer/shimmer.dart';

class OurGoals extends StatefulWidget {
  const OurGoals({super.key});

  @override
  _OurGoalsState createState() => _OurGoalsState();
}

class _OurGoalsState extends State<OurGoals> {
  bool isOnline = true;
  bool isLoading = true;
  List<Map<String, dynamic>> goalsList = [];

  @override
  void initState() {
    super.initState();
    fetchGoalsData();
  }

  Future<void> fetchGoalsData() async {
    try {
      setState(() {
        goalsList = List.generate(1, (index) => {}); // Misal data akan ada 1
      });
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        goalsList = [
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
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error
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
              style: AppTextStyle.bodyText1.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? _buildShimmerLoader(
                    goalsList.length > 0 ? goalsList.length : 3)
                : FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchGoalsFromDatabase(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildShimmerLoader(
                            goalsList.length > 0 ? goalsList.length : 3);
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Failed to load goals.'),
                        );
                      } else if (snapshot.hasData &&
                          snapshot.data!.isNotEmpty) {
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final goal = snapshot.data![index];
                            return GoalCard(goal: goal);
                          },
                        );
                      } else {
                        return Center(
                          child: Text('No goals available.'),
                        );
                      }
                    },
                  ),
          )
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchGoalsFromDatabase() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate database fetch
    return [
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
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => PilihGoals()));
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
                      decoration: BoxDecoration(
                        color: AppColors.yellow1,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                          child: Icon(Icons.add, size: 32, color: Colors.blue)),
                    ),
                    const SizedBox(height: 16),
                    const Text('Buat Tabungan Bersamamu!',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
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

  const GoalCard({required this.goal, super.key});

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
        onTap: () {
          // Navigate to the next page when the card is tapped
        },
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
                              child: Text(member['initial'],
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12)),
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

class PilihGoals extends StatelessWidget {
  const PilihGoals({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
          tooltip: 'Kembali',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Buat Goals',
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24),
                Text(
                  'Goals Apa yang ingin kamu capai?',
                  style: AppTextStyle.bodyText1.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                GoalsCard(
                  icon: Icons.group,
                  title: 'Tabungan Bersama',
                  description: 'Raih impian bersama keluarga ataupun temanmu!',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BuatTabunganBersama()));
                  },
                ),
                SizedBox(height: isSmallScreen ? 8 : 16),
                GoalsCard(
                  icon: Icons.celebration,
                  title: 'Tabungan Bergilir',
                  description:
                      'Mengumpulkan dana bersama dengan giliran menerima dana terkumpul sesuai jadwal yang disepakati',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BuatTabunganBergilir()));
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class GoalsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const GoalsCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      shadowColor: Colors.grey.withOpacity(0.5),
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.blue.withOpacity(0.2),
        highlightColor: Colors.blue.withOpacity(0.1),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.blue, semanticLabel: title),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyle.bodyText1.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
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
}
