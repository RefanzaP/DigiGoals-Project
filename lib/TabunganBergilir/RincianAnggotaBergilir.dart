// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:convert';
import 'package:digigoals_app/api/api_config.dart';
import 'package:digigoals_app/auth/token_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

class MemberDetail {
  final String memberId;
  final String name;
  final String accountNumber;
  final String role;
  final DateTime joinDate;
  final Color avatarColor;

  MemberDetail({
    required this.memberId,
    required this.name,
    required this.accountNumber,
    required this.role,
    required this.joinDate,
    required this.avatarColor,
  });

  factory MemberDetail.fromJson(Map<String, dynamic> json, int index) {
    final user = json['user'];
    final customer = user['customer'];
    return MemberDetail(
      memberId: user['id'].toString(),
      name: customer['name'] ?? 'N/A',
      accountNumber: json['account']?['account_number']?.toString() ?? 'N/A',
      role: json['role'] == 'ADMIN' ? 'Pemilik' : 'Anggota',
      joinDate: json['join_date'] != null
          ? DateTime.parse(json['join_date'])
          : DateTime.now(),
      avatarColor: Colors.primaries[index % Colors.primaries.length],
    );
  }
}

class RincianAnggotaBergilir extends StatefulWidget {
  final String savingGroupId;
  final String goalsName;
  final bool isActive;

  const RincianAnggotaBergilir({
    super.key,
    required this.savingGroupId,
    required this.goalsName,
    this.isActive = false,
  });

  @override
  _RincianAnggotaBergilirState createState() => _RincianAnggotaBergilirState();
}

class _RincianAnggotaBergilirState extends State<RincianAnggotaBergilir> {
  List<MemberDetail> members = [];
  bool isLoading = true;
  String? _errorMessage;
  late String tabunganName;
  int jumlahAnggota = 0;
  final TokenManager _tokenManager = TokenManager();
  String? _loggedInUserRole; // State untuk menyimpan role user yang login

  @override
  void initState() {
    super.initState();
    tabunganName = widget.goalsName;
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      isLoading = true;
      _errorMessage = null;
      members = [];
      jumlahAnggota = 0;
      _loggedInUserRole = null; // Reset role user saat loading baru
    });

    String? token = await _tokenManager.getToken();
    if (token == null) {
      setState(() {
        isLoading = false;
        _errorMessage = "Sesi Anda telah berakhir. Mohon login kembali.";
      });
      return;
    }

    final String savingGroupId = widget.savingGroupId;
    final membersUrl =
        Uri.parse('$baseUrl/members?savingGroupId=$savingGroupId');
    final introspectUrl = Uri.parse(
        '$baseUrl/auth/introspect'); // Endpoint untuk introspect role user

    try {
      final responses = await Future.wait([
        http.get(membersUrl, headers: {'Authorization': 'Bearer $token'}),
        http.get(introspectUrl, headers: {
          'Authorization': 'Bearer $token'
        }), // Request introspect user
      ]);

      final membersResponse = responses[0];
      final introspectResponse = responses[1];

      if (membersResponse.statusCode == 200 &&
          introspectResponse.statusCode == 200) {
        final responseBody = utf8.decode(membersResponse.bodyBytes);
        final responseData = json.decode(responseBody);
        final introspectData =
            json.decode(utf8.decode(introspectResponse.bodyBytes));

        if (responseData['code'] == 200 &&
            responseData['status'] == 'OK' &&
            introspectData['code'] == 200 &&
            introspectData['status'] == 'OK') {
          List<dynamic> memberDataList = responseData['data'];
          List<MemberDetail> fetchedMembers = [];
          for (int i = 0; i < memberDataList.length; i++) {
            fetchedMembers.add(MemberDetail.fromJson(memberDataList[i], i));
          }

          setState(() {
            members = fetchedMembers;
            jumlahAnggota = members.length;
            isLoading = false;
            _loggedInUserRole =
                introspectData['data']['role']; // Set role user yang login
          });
        } else {
          setState(() {
            isLoading = false;
            _errorMessage = responseData['errors'] != null &&
                    (responseData['errors'] as List).isNotEmpty
                ? (responseData['errors'] as List)[0].toString()
                : introspectData['errors'] != null &&
                        (introspectData['errors'] as List).isNotEmpty
                    ? (introspectData['errors'] as List)[0].toString()
                    : "Gagal mengambil data anggota atau informasi user, silahkan coba lagi.";
          });
        }
      } else {
        setState(() {
          isLoading = false;
          _errorMessage =
              "Gagal memuat data anggota. Status code Member: ${membersResponse.statusCode}, Status User: ${introspectResponse.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        _errorMessage =
            "Terjadi kesalahan saat memuat data anggota: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: isLoading
                            ? _buildShimmerLoader(height: 24, width: 200)
                            : Text(
                                tabunganName,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 20 : 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                  isLoading
                      ? _buildShimmerLoader(height: 16, width: 150)
                      : Text(
                          '$jumlahAnggota Anggota Bergabung',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: Colors.grey,
                          ),
                        ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: isLoading
                        ? ListView.builder(
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: _buildShimmerLoader(
                                    height: 80, width: double.infinity),
                              );
                            },
                          )
                        : ListView.builder(
                            itemCount: members.length,
                            itemBuilder: (context, index) {
                              final member = members[index];
                              return _buildMemberTile(
                                  context,
                                  member.name,
                                  member.accountNumber,
                                  member.role,
                                  'Bergabung pada ${DateFormat('dd MMM yyyy').format(member.joinDate)}',
                                  member.avatarColor,
                                  isSmallScreen,
                                  _loggedInUserRole // Kirim role user yang login ke _buildMemberTile
                                  );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  // AppBar Widget (sama seperti sebelumnya)
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
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
      title: const Text(
        'Rincian Anggota',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
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

  // Shimmer Loader Widget (sama seperti sebelumnya)
  Widget _buildShimmerLoader({required double height, required double width}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Widget untuk menampilkan tile member dalam list (Diperbarui dengan parameter loggedInUserRole)
  Widget _buildMemberTile(
      BuildContext context,
      String name,
      String accountNumber,
      String role,
      String subtitle,
      Color color,
      bool isSmallScreen,
      String? loggedInUserRole // Parameter baru untuk role user yang login
      ) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      shadowColor: Colors.black.withOpacity(0.5),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: isSmallScreen
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: color,
                        child: Text(
                          name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8.0,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isSmallScreen ? 16 : 18,
                                  ),
                                ),
                                Text(
                                  role,
                                  style: TextStyle(
                                    color: role == 'Pemilik'
                                        ? Colors.blue
                                        : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isSmallScreen ? 14 : 16,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '$accountNumber\n$subtitle',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Kondisional menampilkan icon delete berdasarkan role user login dan role member
                if (_loggedInUserRole == 'ADMIN' &&
                    role != 'Pemilik' &&
                    !widget.isActive)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmationDialog(name);
                    },
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk menampilkan dialog konfirmasi hapus anggota (sama seperti sebelumnya)
  void _showDeleteConfirmationDialog(String name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteConfirmationDialog(
          name: name,
          onConfirm: () {
            _deleteMember(name);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  // Fungsi untuk menghapus member dari API (sama seperti sebelumnya, perlu implementasi API Call)
  Future<void> _deleteMember(String memberName) async {
    setState(() {
      isLoading = true;
    });

    String? token = await _tokenManager.getToken();
    if (token == null) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token tidak ditemukan, mohon login kembali.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String savingGroupId = widget.savingGroupId;
    Uri.parse('$baseUrl/members?savingGroupId=$savingGroupId');
    final memberToDelete =
        members.firstWhere((member) => member.name == memberName);
    final deleteMemberUrl =
        Uri.parse('$baseUrl/members/${memberToDelete.memberId}');

    try {
      final response = await http.delete(
        deleteMemberUrl,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
          members.removeWhere((member) => member.name == memberName);
          jumlahAnggota = members.length;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Anggota $memberName berhasil dihapus.'),
          ),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus anggota $memberName.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Terjadi kesalahan saat menghapus anggota: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Widget Dialog Konfirmasi Hapus Anggota (sama seperti sebelumnya)
class DeleteConfirmationDialog extends StatelessWidget {
  final String name;
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog(
      {super.key, required this.name, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: 256,
        height: 256,
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'DIGI Mobile',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Apakah Benar Anda Ingin Menghapus Anggota $name?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 37,
                  margin: const EdgeInsets.only(right: 8),
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: BorderSide(
                        color: Colors.yellow.shade700,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Tidak',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF1F597F),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 100,
                  height: 37,
                  margin: const EdgeInsets.only(left: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Ya',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF1F597F),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
