// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'package:digigoals_app/PilihGoals.dart';
import 'package:digigoals_app/TabunganBergilir/DetailTabunganBergilir.dart';
import 'package:digigoals_app/TabunganBersama/DetailTabunganBersama.dart';
import 'package:digigoals_app/api/api_config.dart';
import 'package:digigoals_app/auth/token_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

// Model for Joint Saving Group
class JointSavingGroup {
  final String id;
  final String name;
  final int targetAmount;
  final String type;
  final String status;
  final int duration;
  final DateTime createdAt;

  JointSavingGroup({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.type,
    required this.status,
    required this.duration,
    required this.createdAt,
  });

  factory JointSavingGroup.fromJson(Map<String, dynamic> json) {
    return JointSavingGroup(
      id: json['id'],
      name: json['name'],
      targetAmount: json['target_amount'],
      type: json['type'],
      status: json['status'],
      duration: json['duration'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

// Model for Rotating Saving Group
class RotatingSavingGroup {
  final String id;
  final String name;
  final int targetAmount;
  final String type;
  final String status;
  final int duration;
  final DateTime createdAt;

  RotatingSavingGroup({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.type,
    required this.status,
    required this.duration,
    required this.createdAt,
  });

  factory RotatingSavingGroup.fromJson(Map<String, dynamic> json) {
    return RotatingSavingGroup(
      id: json['id'],
      name: json['name'],
      targetAmount: json['target_amount'] ?? 0,
      type: json['type'],
      status: json['status'],
      duration: json['duration'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class OurGoals extends StatefulWidget {
  const OurGoals({super.key});

  @override
  _OurGoalsState createState() => _OurGoalsState();
}

class _OurGoalsState extends State<OurGoals> {
  bool _isLoading = true;
  bool _isNavigating = false;
  String? _errorMessage;
  List<dynamic> _goals = [];
  final TokenManager _tokenManager = TokenManager();

  @override
  void initState() {
    super.initState();
    _fetchGoals();
  }

  Future<void> _fetchGoals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String? token = await _tokenManager.getToken();
    if (token == null) {
      setState(() {
        _errorMessage = "Token tidak ditemukan";
        _isLoading = false;
      });
      return;
    }

    try {
      final jointSavingUrl = Uri.parse('$baseUrl/api/v1/joint-saving-groups');
      final rotatingSavingUrl =
          Uri.parse('$baseUrl/api/v1/rotating-saving-groups');

      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
      };

      final jointSavingResponse =
          await http.get(jointSavingUrl, headers: headers);
      final rotatingSavingResponse =
          await http.get(rotatingSavingUrl, headers: headers);

      if (jointSavingResponse.statusCode == 200 &&
          rotatingSavingResponse.statusCode == 200) {
        final jointSavingData = json.decode(jointSavingResponse.body);
        final rotatingSavingData = json.decode(rotatingSavingResponse.body);

        List<dynamic> fetchedGoals = [];

        if (jointSavingData['code'] == 200 &&
            jointSavingData['status'] == 'OK' &&
            (jointSavingData['data'] as List).isNotEmpty) {
          List<JointSavingGroup> jointGroups = (jointSavingData['data'] as List)
              .map((item) => JointSavingGroup.fromJson(item))
              .toList();
          fetchedGoals.addAll(jointGroups
              .map((joint) => {
                    'goalsType': 'Tabungan Bersama',
                    'id': joint.id,
                    'goalsName': joint.name,
                    'target_amount': joint.targetAmount,
                    'status': joint.status,
                    'duration': joint.duration,
                    'creationDate': joint.createdAt,
                  })
              .toList());
        }

        if (rotatingSavingData['code'] == 200 &&
            rotatingSavingData['status'] == 'OK' &&
            (rotatingSavingData['data'] as List).isNotEmpty) {
          List<RotatingSavingGroup> rotatingGroups =
              (rotatingSavingData['data'] as List)
                  .map((item) => RotatingSavingGroup.fromJson(item))
                  .toList();
          fetchedGoals.addAll(rotatingGroups
              .map((rotating) => {
                    'goalsType': 'Tabungan Bergilir',
                    'id': rotating.id,
                    'goalsName': rotating.name,
                    'target_amount': rotating.targetAmount,
                    'status': rotating.status,
                    'duration': rotating.duration,
                    'creationDate': rotating.createdAt,
                  })
              .toList());
        }
        setState(() {
          _goals = fetchedGoals;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Gagal mengambil data goals";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Terjadi kesalahan: ${e.toString()}";
        _isLoading = false;
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
              onPressed: () {
                Navigator.pop(context);
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
                        : _goals.isNotEmpty
                            ? ListView.builder(
                                key: const Key('goalsListView'),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: _goals.length,
                                itemBuilder: (context, index) {
                                  final goal = _goals[index];
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
        onTap: _isLoading
            ? null
            : () async {
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

    final formattedTarget = currencyFormat.format(goal['target_amount'] ?? 0);
    // Inisialisasi list untuk menyimpan widget circle avatar
    List<Widget> memberAvatars = [];

    // Batasi hanya menampilkan 2 avatar dan sisanya tampilkan dalam 1 avatar
    int maxAvatars = 2;
    int displayedCount = 0;

    // if (goal['members'] != null) {
    //   for (int i = 0; i < goal['members'].length; i++) {
    //     String memberName = goal['members'][i];
    //     if (displayedCount < maxAvatars) {
    //       memberAvatars.add(
    //         CircleAvatar(
    //           radius: 12,
    //           backgroundColor: Colors.primaries[
    //               i % Colors.primaries.length], // Memberikan warna otomatis
    //           child: Text(
    //             memberName
    //                 .substring(0, 1)
    //                 .toUpperCase(), // Mengambil huruf pertama dan uppercase
    //             style: const TextStyle(color: Colors.white, fontSize: 12),
    //           ),
    //         ),
    //       );
    //       displayedCount++;
    //     }
    //   }
    //   if (goal['members'].length > maxAvatars) {
    //     int remainingMembers = goal['members'].length - maxAvatars;
    //     memberAvatars.add(
    //       CircleAvatar(
    //         radius: 12,
    //         backgroundColor: Colors.grey,
    //         child: Text(
    //           '+$remainingMembers',
    //           style: const TextStyle(color: Colors.white, fontSize: 12),
    //         ),
    //       ),
    //     );
    //   }
    // }

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
                        goal['goalsType'],
                        style: const TextStyle(
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF1F597F),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '0 / $formattedTarget',
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
                    widthFactor: goal['target_amount'] != 0 ? 0.0 : 0.0,
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
                    '0%',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.black),
                  ),
                  Text(
                    'Sisa ${goal['duration']} hari',
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
