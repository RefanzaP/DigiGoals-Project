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

// Model untuk Saving Group (Model Unified untuk Tabungan Bersama dan Bergilir)
class SavingGroup {
  final String id;
  final String name;
  final String type;
  final String status;
  final DateTime createdAt;
  final int duration;
  final int targetAmount;
  double contributionAmount;
  List<Member> members;

  SavingGroup({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.duration,
    required this.targetAmount,
    this.contributionAmount = 0.0,
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

// Model untuk Member
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
  bool _isSnackBarShown =
      false; // Flag untuk menandai apakah SnackBar sudah ditampilkan

  @override
  void initState() {
    super.initState();
    _fetchGoals(); // Fetch goals saat inisialisasi widget
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pindahkan panggilan _checkDeletionSuccess ke didChangeDependencies untuk memastikan context tersedia
    if (!_isSnackBarShown) {
      // Cek apakah SnackBar sudah pernah ditampilkan
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkDeletionSuccess();
      });
    }
  }

  // Fungsi untuk memeriksa apakah penghapusan berhasil dan menampilkan snackbar
  void _checkDeletionSuccess() {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      if (arguments['deletionSuccess'] == true) {
        // Tampilkan SnackBar sukses penghapusan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tabungan berhasil dihapus!'),
            backgroundColor: Colors.green,
          ),
        );
        _isSnackBarShown =
            true; // Set flag menjadi true setelah SnackBar ditampilkan
      } else if (arguments['deletionSuccess'] == false) {
        // Tampilkan SnackBar gagal penghapusan
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

  // Fungsi untuk mengambil daftar goals dari API
  Future<void> _fetchGoals() async {
    if (!mounted) return; // Kondisi mounted di awal untuk menghindari error

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _goals = [];
    });

    String? token = await _tokenManager.getToken();
    if (token == null) {
      if (mounted) {
        setState(() {
          _errorMessage =
              "Sesi Anda telah berakhir. Mohon login kembali."; // Pesan error lebih user-friendly
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

          // Filter goals yang statusnya bukan ARCHIVED
          savingGroups =
              savingGroups.where((goal) => goal.status != 'ARCHIVED').toList();

          // Ambil member untuk setiap saving group
          for (var group in savingGroups) {
            List<Member> members = await _fetchMembers(group.id, token);
            group.members = members;
            group.contributionAmount =
                0.0; // Inisialisasi contribution amount (mungkin perlu dihitung dari API jika ada)
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
                "Gagal memuat goals. Status code: ${savingGroupsResponse.statusCode}."; // Pesan error lebih informatif
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              "Terjadi kesalahan saat memuat goals: ${e.toString()}"; // Pesan error lebih informatif
          _isLoading = false;
        });
      }
    }
  }

  // Fungsi untuk mengambil daftar member dari API untuk saving group tertentu
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
          return []; // Return empty list jika gagal mengambil data member
        }
      } else {
        return []; // Return empty list jika status code bukan 200
      }
    } catch (e) {
      return []; // Return empty list jika terjadi error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: _buildAppBar(context),
          body: RefreshIndicator(
            onRefresh:
                _fetchGoals, // Callback untuk refresh data saat pull-to-refresh
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildCreateGoalCard(context), // Card untuk membuat goal baru
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
                      ? _buildShimmerLoader(
                          5) // Tampilkan shimmer loader saat loading
                      : _errorMessage != null
                          ? Center(
                              child: Text(
                                  _errorMessage!), // Tampilkan pesan error jika ada error
                            )
                          : _goals.isNotEmpty
                              ? ListView.builder(
                                  // Tampilkan list goals jika data berhasil diambil
                                  key: const Key('goalsListView'),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  itemCount: _goals.length,
                                  itemBuilder: (context, index) {
                                    final goal = _goals[index];
                                    return GoalCard(
                                      goal: goal,
                                      onTap: () {
                                        _navigateToDetail(context, goal.id,
                                            goal.type); // Navigasi ke detail goal saat card di-tap
                                      },
                                    );
                                  },
                                )
                              : const Center(
                                  child: Text(
                                      'Belum ada goals yang dibuat.'), // Tampilkan pesan jika tidak ada goals
                                ),
                )
              ],
            ),
          ),
        ),
        if (_isNavigating)
          _buildNavigationOverlay(), // Tampilkan overlay saat navigasi ke halaman lain
      ],
    );
  }

  // AppBar Widget
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
          Navigator.pop(context); // Navigasi kembali ke halaman sebelumnya
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

  // Navigation Overlay Widget - Loading indicator saat navigasi
  Widget _buildNavigationOverlay() {
    return Stack(
      children: [
        ModalBarrier(
          color: Colors.black.withOpacity(0.5),
          dismissible: false, // Barrier tidak dapat ditutup oleh pengguna
        ),
        Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow.shade700),
          ),
        ),
      ],
    );
  }

  // Fungsi untuk navigasi ke halaman detail goal berdasarkan tipe goal
  void _navigateToDetail(
      BuildContext context, String savingGroupId, String goalType) {
    setState(() {
      _isNavigating =
          true; // Set state navigasi menjadi true saat navigasi dimulai
    });

    if (goalType == 'JOINT_SAVING') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailTabunganBersama(
              savingGroupId:
                  savingGroupId), // Navigasi ke detail tabungan bersama
        ),
      ).then((_) {
        setState(() {
          _isNavigating =
              false; // Set state navigasi menjadi false setelah halaman detail ditutup
        });
      });
    } else if (goalType == 'ROTATING_SAVING') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailTabunganBergilir(
              savingGroupId:
                  savingGroupId), // Navigasi ke detail tabungan bergilir dan mengirimkan savingGroupId
        ),
      ).then((_) {
        setState(() {
          _isNavigating =
              false; // Set state navigasi menjadi false setelah halaman detail ditutup
        });
      });
    }
  }

  // Card Widget untuk membuat Goal Baru
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
            ? null // Nonaktifkan onTap saat loading
            : () async {
                setState(() {
                  _isNavigating =
                      true; // Set state navigasi menjadi true saat card di-tap
                });

                await Future.delayed(
                    const Duration(seconds: 1)); // Simulasi loading

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PilihGoals(), // Navigasi ke halaman PilihGoals
                  ),
                ).then((value) {
                  setState(() {
                    _isNavigating =
                        false; // Set state navigasi menjadi false setelah halaman PilihGoals ditutup
                  });
                  _fetchGoals(); // Refresh data goals ketika kembali dari PilihGoals
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
                  'assets/images/bankbjb-logo.png', // Logo bank bjb pada card
                  width: 51,
                  height: 26,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCreateGoalIcon(), // Ikon "tambah" untuk membuat goal
                    const SizedBox(height: 16),
                    _buildCreateGoalTitle(), // Teks judul "Buat Goals Kamu!"
                    const SizedBox(height: 4),
                    _buildCreateGoalDescription(
                        context), // Deskripsi singkat tentang membuat goal
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Ikon "tambah" dalam card pembuatan goal
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

  // Judul card pembuatan goal
  Widget _buildCreateGoalTitle() {
    return const Text(
      'Buat Goals Kamu!',
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    );
  }

  // Deskripsi card pembuatan goal
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

  // Shimmer Loader Widget - Placeholder loading saat data goals sedang di-load
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

// Goal Card Widget - Widget untuk menampilkan informasi setiap goal dalam list
class GoalCard extends StatelessWidget {
  final SavingGroup goal;
  final VoidCallback? onTap;

  const GoalCard({required this.goal, super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'IDR ',
        decimalDigits: 2); // Format mata uang Indonesia
    final formattedTarget =
        currencyFormat.format(goal.targetAmount); // Format target amount

    List<Widget> memberAvatars = []; // List untuk menyimpan avatar member
    int maxAvatars = 2; // Maksimal avatar member yang ditampilkan
    int displayedCount = 0; // Counter avatar member yang sudah ditampilkan

    // Membuat avatar member jika ada member
    if (goal.members.isNotEmpty) {
      for (int i = 0; i < goal.members.length; i++) {
        String memberName = goal.members[i].name;
        if (displayedCount < maxAvatars) {
          memberAvatars.add(
            CircleAvatar(
              // CircleAvatar untuk avatar member
              radius: 12,
              backgroundColor: Colors.primaries[
                  i % Colors.primaries.length], // Warna avatar berbeda-beda
              child: Text(
                memberName
                    .substring(0, 1)
                    .toUpperCase(), // Ambil inisial nama member
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
            // CircleAvatar untuk menampilkan jumlah member yang tersisa
            radius: 12,
            backgroundColor: Colors.grey,
            child: Text(
              '+$remainingMembers', // Tampilkan jumlah member yang tersisa
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
        onTap: onTap, // Callback onTap untuk navigasi ke detail goal
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGoalCardHeader(goal,
                  memberAvatars), // Header card goal (tipe goal dan avatar member)
              const SizedBox(height: 5),
              _buildGoalNameText(goal), // Nama goal
              const SizedBox(height: 14),
              _buildGoalProgressText(formattedTarget), // Teks progress goal
              const SizedBox(height: 8),
              _buildProgressBar(), // Progress bar goal
              const SizedBox(height: 8),
              _buildGoalSummaryRow(
                  goal), // Baris summary goal (persentase progress dan sisa hari)
            ],
          ),
        ),
      ),
    );
  }

  // Header Card Goal - Bagian atas card yang menampilkan tipe goal dan avatar member
  Widget _buildGoalCardHeader(SavingGroup goal, List<Widget> memberAvatars) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildGoalTypeRow(goal), // Baris tipe goal
        _buildMemberAvatarsRow(memberAvatars), // Baris avatar member
      ],
    );
  }

  // Baris Tipe Goal - Menampilkan ikon dan teks tipe goal
  Widget _buildGoalTypeRow(SavingGroup goal) {
    return Row(
      children: [
        Icon(
          goal.type == 'ROTATING_SAVING'
              ? Icons.celebration
              : Icons.groups, // Ikon berbeda berdasarkan tipe goal
          color: Colors.blue,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          goal.type == 'ROTATING_SAVING'
              ? 'Tabungan Bergilir'
              : 'Tabungan Bersama', // Teks tipe goal berbeda berdasarkan tipe goal
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),
        ),
      ],
    );
  }

  // Baris Avatar Member - Menampilkan daftar avatar member
  Widget _buildMemberAvatarsRow(List<Widget> memberAvatars) {
    return Row(children: memberAvatars);
  }

  // Teks Nama Goal - Menampilkan nama goal dengan style tertentu
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

  // Teks Progress Goal - Menampilkan progress goal (contoh: 0 / target amount)
  Widget _buildGoalProgressText(String formattedTarget) {
    return Text(
      '0 / $formattedTarget', // TODO: Perlu diupdate dengan data progress yang sebenarnya dari API
      style: TextStyle(
          fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey[800]),
    );
  }

  // Progress Bar Widget - Menampilkan progress bar visual untuk goal
  Widget _buildProgressBar() {
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
          widthFactor:
              0.5, // TODO: Perlu diupdate dengan data progress yang sebenarnya dari API (misal: persentase progress)
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

  // Baris Summary Goal - Menampilkan persentase progress dan sisa hari
  Widget _buildGoalSummaryRow(SavingGroup goal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildProgressPercentageText(), // Teks persentase progress
        _buildRemainingDaysText(goal), // Teks sisa hari
      ],
    );
  }

  // Teks Persentase Progress - Menampilkan persentase progress goal
  Widget _buildProgressPercentageText() {
    return const Text(
      '50%', // TODO: Perlu diupdate dengan data progress yang sebenarnya dari API (misal: persentase progress)
      style: TextStyle(
          fontWeight: FontWeight.w600, fontSize: 12, color: Colors.black),
    );
  }

  // Teks Sisa Hari - Menampilkan sisa hari durasi goal
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
