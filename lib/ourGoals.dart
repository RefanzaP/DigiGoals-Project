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
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PilihGoals()));
            },
            child: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: 20), // Margin kanan-kiri 20px
              width: MediaQuery.of(context).size.width - 40, // Responsif
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
                            width: 64,
                            height: 64,
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
                          Text(
                            'Buat Tabungan Bersamamu!',
                            style: AppTextStyle.bodyMText1,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sesuaikan Goals kamu untuk hal yang kamu inginkan',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
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
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              // Navigate to the next page when the card is tapped
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              width: MediaQuery.of(context).size.width - 40,
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
                            Icon(
                              Icons.groups,
                              color: Colors.blue,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tabungan Bersama',
                              style: AppTextStyle.bodyMText1
                                  .copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.blue,
                              child: Text('A',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)),
                            ),
                            // const SizedBox(width: 5),
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.orange,
                              child: Text('U',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)),
                            ),
                            // const SizedBox(width: 5),
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.grey,
                              child: Text('+2',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Pernikahan Kita',
                      style: AppTextStyle.bodyText1.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(
                          'IDR 160.000.000,00 / 200.000.000,00',
                          style: AppTextStyle.bodyMText1
                              .copyWith(color: Colors.grey[800], fontSize: 12),
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
                        Container(
                          height: 8,
                          width: MediaQuery.of(context).size.width * 0.8 - 40,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '80%',
                          style: AppTextStyle.bodyMText1.copyWith(fontSize: 12),
                        ),
                        Text(
                          'Sisa 340 hari',
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
          ),
        ],
      ),
    );
  }
}
