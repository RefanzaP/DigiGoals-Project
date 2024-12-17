import 'package:digigoals_app/TabunganBergilir/BuatTabunganBergilir.dart';
import 'package:digigoals_app/TabunganBersama/BuatTabunganBersama.dart';
import 'package:flutter/material.dart';
import 'theme/theme.dart';

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
