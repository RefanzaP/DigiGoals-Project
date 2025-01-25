// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:digigoals_app/TabunganBergilir/BuatTabunganBergilir.dart';
import 'package:digigoals_app/TabunganBersama/BuatTabunganBersama.dart';

class PilihGoals extends StatefulWidget {
  const PilihGoals({super.key});

  @override
  _PilihGoalsState createState() => _PilihGoalsState();
}

class _PilihGoalsState extends State<PilihGoals> {
  bool _isLoading = false;

  Future<void> _navigateToPage(BuildContext context, Widget page) async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => page,
        ),
      ).then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
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
              tooltip: 'Kembali',
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Buat Goals',
              style: TextStyle(
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
          body: buildBody(context),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.yellow.shade700),
              ),
            ),
          )
      ],
    );
  }

  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Goals Apa yang ingin kamu capai?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              buildGoalsCard(
                context,
                icon: Icons.group,
                title: 'Tabungan Bersama',
                description: 'Raih impian bersama keluarga ataupun temanmu!',
                onTap: () =>
                    _navigateToPage(context, const BuatTabunganBersama()),
              ),
              SizedBox(height: isSmallScreen ? 8 : 16),
              buildGoalsCard(
                context,
                icon: Icons.celebration,
                title: 'Tabungan Bergilir',
                description:
                    'Mengumpulkan dana bersama dengan giliran menerima dana terkumpul sesuai jadwal yang disepakati',
                onTap: () =>
                    _navigateToPage(context, const BuatTabunganBergilir()),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildGoalsCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String description,
      required VoidCallback onTap}) {
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.blue, semanticLabel: title),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
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
