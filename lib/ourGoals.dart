import 'package:digigoals_app/Beranda.dart';
import 'package:digigoals_app/PilihGoals.dart';
import 'package:flutter/material.dart';
import 'theme/theme.dart';

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
    // Simulate a network request to fetch data from the database
    await Future.delayed(Duration(seconds: 1));
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
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Beranda()),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16), // Jarak 16px dari AppBar
          Card(
            color: Colors.white,
            margin:
                EdgeInsets.symmetric(horizontal: 20), // Margin kanan-kiri 20px
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            shadowColor: Colors.black.withOpacity(0.5),
            elevation: 4,
            child: InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PilihGoals()));
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 20), // Padding atas-bawah 20px
                child: Stack(
                  clipBehavior: Clip
                      .none, // Membiarkan logo tetap di luar jika diperlukan
                  children: [
                    // Logo bank bjb di pojok kanan atas
                    Positioned(
                      top: 0,
                      right: 20,
                      child: Image.asset(
                        'assets/images/bankbjb-logo.png',
                        width: 51,
                        height: 26,
                      ),
                    ),
                    // Konten utama
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
                            child: Center(
                              child:
                                  Icon(Icons.add, size: 32, color: Colors.blue),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('Buat Tabungan Bersamamu!',
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
          ),
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
                ? Center(
                    child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.blue.shade900),
                  ))
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: goalsList.length,
                    itemBuilder: (context, index) {
                      final goal = goalsList[index];
                      return Card(
                        color: Colors.white,
                        margin: EdgeInsets.only(bottom: 16),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.groups,
                                          color: Colors.blue,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          goal['title'],
                                          style: AppTextStyle.bodyMText1
                                              .copyWith(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: goal['members']
                                          .map<Widget>((member) => Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5),
                                                child: CircleAvatar(
                                                  radius: 12,
                                                  backgroundColor:
                                                      member['color'],
                                                  child: Text(member['initial'],
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12)),
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
                                Row(
                                  children: [
                                    Text(
                                      goal['amount'],
                                      style: AppTextStyle.bodyMText1.copyWith(
                                          color: Colors.grey[800],
                                          fontSize: 12),
                                    ),
                                  ],
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
                                      '${(goal['progress'] * 100).toStringAsFixed(0)}%',
                                      style: AppTextStyle.bodyMText1
                                          .copyWith(fontSize: 12),
                                    ),
                                    Text(
                                      'Sisa ${goal['daysLeft']} hari',
                                      style: TextStyle(
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
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
