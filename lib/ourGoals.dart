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

class SavingGroup {
  final String id;
  final String name;
  final String type;
  final String status;
  final DateTime createdAt;
  final int duration;
  final int targetAmount;
  double goalsBalance;
  List<Member> members;

  SavingGroup({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.duration,
    required this.targetAmount,
    this.goalsBalance = 0.0,
    this.members = const [],
  });

  factory SavingGroup.fromJson(Map<String, dynamic> json) {
    final detail = json['detail'] as Map<String, dynamic>? ?? {};
    return SavingGroup(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      duration: detail['duration'] ?? 0,
      targetAmount: detail['target_amount'] ?? 0,
    );
  }
}

class Member {
  final String id;
  final String name;

  Member({
    required this.id,
    required this.name,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['user']['id'],
      name: json['user']['customer']['name'],
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
  List<SavingGroup> _goals = [];
  final TokenManager _tokenManager = TokenManager();
  bool _isSnackBarShown = false;

  @override
  void initState() {
    super.initState();
    _fetchGoals();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isSnackBarShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkDeletionSuccess();
      });
    }
  }

  void _checkDeletionSuccess() {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      if (arguments['deletionSuccess'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tabungan berhasil dihapus!'),
            backgroundColor: Colors.green,
          ),
        );
        _isSnackBarShown = true;
      } else if (arguments['deletionSuccess'] == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus tabungan.'),
            backgroundColor: Colors.red,
          ),
        );
        _isSnackBarShown = true;
      }
    }
  }

  Future<void> _fetchGoals() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _goals = [];
    });

    String? token = await _tokenManager.getToken();
    if (token == null) {
      if (mounted) {
        setState(() {
          _errorMessage = "Token tidak ditemukan";
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final savingGroupsUrl = Uri.parse('$baseUrl/saving-groups');

      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
      };

      final savingGroupsResponse =
          await http.get(savingGroupsUrl, headers: headers);

      if (savingGroupsResponse.statusCode == 200) {
        final responseBody = utf8.decode(savingGroupsResponse.bodyBytes);
        final savingGroupsData = json.decode(responseBody);

        List<SavingGroup> fetchedGoals = [];

        if (savingGroupsData['code'] == 200 &&
            savingGroupsData['status'] == 'OK' &&
            (savingGroupsData['data'] as List).isNotEmpty) {
          List<SavingGroup> savingGroups = (savingGroupsData['data'] as List)
              .map((item) => SavingGroup.fromJson(item))
              .toList();

          savingGroups =
              savingGroups.where((goal) => goal.status != 'ARCHIVED').toList();

          for (var group in savingGroups) {
            List<Member> members = await _fetchMembers(group.id, token);
            double balance = await _fetchGoalsBalance(
                group.id, token); // Fetch balance here, removed userId
            group.members = members;
            group.goalsBalance = balance; // Assign fetched balance
            fetchedGoals.add(group);
          }
        }

        if (mounted) {
          setState(() {
            _goals = fetchedGoals;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage =
                "Gagal mengambil data goals: Status Code ${savingGroupsResponse.statusCode}";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Terjadi kesalahan: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  Future<double> _fetchGoalsBalance(String savingGroupId, String token) async {
    // Removed userId parameter
    final balanceUrl =
        Uri.parse('$baseUrl/transactions/balance?savingGroupId=$savingGroupId');
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await http.get(balanceUrl, headers: headers);
      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final balanceData = json.decode(responseBody);
        // Log API response
        if (balanceData['code'] == 200 && balanceData['status'] == 'OK') {
          double totalBalance = 0;
          if (balanceData['data'] is List) {
            for (var balanceItem in balanceData['data']) {
              if (balanceItem['saving_group_id'] == savingGroupId) {
                //Keep savingGroupId filter only
                totalBalance += (balanceItem['balance'] as num).toDouble();
              }
            }
          }
          // Log calculated balance
          return totalBalance;
        } else {
          // Log API error
          return 0.0;
        }
      } else {
        // Log HTTP error
        return 0.0;
      }
    } catch (e) {
      // Log exceptions
      return 0.0;
    }
  }

  Future<List<Member>> _fetchMembers(String savingGroupId, String token) async {
    final membersUrl =
        Uri.parse('$baseUrl/members?savingGroupId=$savingGroupId');
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await http.get(membersUrl, headers: headers);
      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final membersData = json.decode(responseBody);
        if (membersData['code'] == 200 && membersData['status'] == 'OK') {
          List<Member> members = (membersData['data'] as List)
              .map((item) => Member.fromJson(item))
              .toList();
          return members;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: _buildAppBar(context),
          body: RefreshIndicator(
            onRefresh: _fetchGoals,
            child: Column(
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  itemCount: _goals.length,
                                  itemBuilder: (context, index) {
                                    final goal = _goals[index];
                                    return GoalCard(
                                      goal: goal,
                                      onTap: () {
                                        _navigateToDetail(
                                            context, goal.id, goal.type);
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
        ),
        if (_isNavigating) _buildNavigationOverlay(),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
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
          Navigator.pushReplacementNamed(context, '/beranda');
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
    );
  }

  Widget _buildNavigationOverlay() {
    return Stack(
      children: [
        ModalBarrier(
          color: Colors.black.withOpacity(0.5),
          dismissible: false,
        ),
        Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow.shade700),
          ),
        ),
      ],
    );
  }

  void _navigateToDetail(
      BuildContext context, String savingGroupId, String goalType) {
    setState(() {
      _isNavigating = true;
    });
    if (goalType == 'JOINT_SAVING') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DetailTabunganBersama(savingGroupId: savingGroupId),
        ),
      ).then((_) {
        setState(() {
          _isNavigating = false;
        });
      });
    } else if (goalType == 'ROTATING_SAVING') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DetailTabunganBergilir(savingGroupId: savingGroupId),
        ),
      ).then((_) {
        setState(() {
          _isNavigating = false;
        });
      });
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
                  _fetchGoals();
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
                    _buildCreateGoalIcon(),
                    const SizedBox(height: 16),
                    _buildCreateGoalTitle(),
                    const SizedBox(height: 4),
                    _buildCreateGoalDescription(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateGoalIcon() {
    return Container(
      width: 62,
      height: 62,
      decoration: const BoxDecoration(
        color: Color(0xFFFFC945),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(Icons.add, size: 32, color: Colors.blue),
      ),
    );
  }

  Widget _buildCreateGoalTitle() {
    return const Text(
      'Buat Goals Kamu!',
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCreateGoalDescription(BuildContext context) {
    return Text(
      'Sesuaikan Goals kamu untuk hal yang kamu inginkan',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
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
  final SavingGroup goal;
  final VoidCallback? onTap;

  const GoalCard({required this.goal, super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'IDR ',
        decimalDigits: 0); // Changed decimalDigits to 0
    final formattedTarget = currencyFormat.format(goal.targetAmount);
    List<Widget> memberAvatars = [];
    int maxAvatars = 2;
    int displayedCount = 0;

    if (goal.members.isNotEmpty) {
      for (int i = 0; i < goal.members.length; i++) {
        String memberName = goal.members[i].name;
        if (displayedCount < maxAvatars) {
          memberAvatars.add(
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.primaries[i % Colors.primaries.length],
              child: Text(
                memberName.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          );
          displayedCount++;
        }
      }
      if (goal.members.length > maxAvatars) {
        int remainingMembers = goal.members.length - maxAvatars;
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
              _buildGoalCardHeader(goal, memberAvatars),
              const SizedBox(height: 5),
              _buildGoalNameText(goal),
              const SizedBox(height: 14),
              _buildGoalProgressText(
                  formattedTarget,
                  currencyFormat
                      .format(goal.goalsBalance)), // Pass goalsBalance here
              const SizedBox(height: 8),
              _buildProgressBar(goal), // Pass goal to progressBar
              const SizedBox(height: 8),
              _buildGoalSummaryRow(goal),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCardHeader(SavingGroup goal, List<Widget> memberAvatars) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildGoalTypeRow(goal),
        _buildMemberAvatarsRow(memberAvatars),
      ],
    );
  }

  Widget _buildGoalTypeRow(SavingGroup goal) {
    return Row(
      children: [
        Icon(
          goal.type == 'ROTATING_SAVING' ? Icons.celebration : Icons.groups,
          color: Colors.blue,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          goal.type == 'ROTATING_SAVING'
              ? 'Tabungan Bergilir'
              : 'Tabungan Bersama',
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildMemberAvatarsRow(List<Widget> memberAvatars) {
    return Row(children: memberAvatars);
  }

  Widget _buildGoalNameText(SavingGroup goal) {
    return Text(
      goal.name,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Color(0xFF1F597F),
      ),
    );
  }

  Widget _buildGoalProgressText(
      String formattedTarget, String formattedBalance) {
    return Text(
      '$formattedBalance / $formattedTarget', // Display formattedBalance
      style: TextStyle(
          fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey[800]),
    );
  }

  Widget _buildProgressBar(SavingGroup goal) {
    double progressFactor = goal.targetAmount == 0
        ? 0
        : goal.goalsBalance / goal.targetAmount; // Prevent division by zero
    return Stack(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        FractionallySizedBox(
          widthFactor: progressFactor.isNaN || progressFactor.isNegative
              ? 0
              : progressFactor.clamp(0.0,
                  1.0), // Handle NaN and negative values, clamp between 0 and 1
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalSummaryRow(SavingGroup goal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildProgressPercentageText(goal), // Pass goal to percentage text
        _buildRemainingDaysText(goal),
      ],
    );
  }

  Widget _buildProgressPercentageText(SavingGroup goal) {
    double percentage = (goal.goalsBalance / goal.targetAmount) * 100;
    return Text(
      '${percentage.isNaN ? 0 : percentage.toStringAsFixed(0)}%', // Handle NaN case and format to 0 decimal places
      style: const TextStyle(
          fontWeight: FontWeight.w600, fontSize: 12, color: Colors.black),
    );
  }

  Widget _buildRemainingDaysText(SavingGroup goal) {
    return Text(
      'Sisa ${goal.duration} hari',
      style: const TextStyle(
        fontSize: 12,
        color: Colors.red,
      ),
    );
  }
}
