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
      memberId: json['user_id'].toString(),
      name: customer['name'] ?? 'N/A',
      accountNumber: json['account']?['account_number']?.toString() ?? 'N/A',
      role: json['role'] == 'ADMIN'
          ? 'Pemilik'
          : 'Anggota', // Directly use role from API
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
  String? _loggedInUserRole;

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
      _loggedInUserRole = null;
    });

    String? token = await _tokenManager.getToken();
    String? userId = await _tokenManager.getUserId();
    if (token == null) {
      setState(() {
        isLoading = false;
        _errorMessage = "Sesi Anda telah berakhir. Mohon login kembali.";
      });
      return;
    }
    if (userId == null) {
      setState(() {
        isLoading = false;
        _errorMessage = "User ID tidak ditemukan.";
      });
      return;
    }

    final String savingGroupId = widget.savingGroupId;
    final membersUrl =
        Uri.parse('$baseUrl/members?savingGroupId=$savingGroupId');
    final memberRoleUrl =
        Uri.parse('$baseUrl/members/$userId?savingGroupId=$savingGroupId');

    try {
      final responses = await Future.wait([
        http.get(membersUrl, headers: {'Authorization': 'Bearer $token'}),
        http.get(memberRoleUrl, headers: {'Authorization': 'Bearer $token'}),
      ]);

      final membersResponse = responses[0];
      final memberRoleResponse = responses[1];

      if (membersResponse.statusCode == 200 &&
          memberRoleResponse.statusCode == 200) {
        final responseBody = utf8.decode(membersResponse.bodyBytes);
        final responseData = json.decode(responseBody);
        final memberRoleResponseBody =
            utf8.decode(memberRoleResponse.bodyBytes);
        final memberRoleData = json.decode(memberRoleResponseBody);

        if (responseData['code'] == 200 &&
            responseData['status'] == 'OK' &&
            memberRoleData['code'] == 200 &&
            memberRoleData['status'] == 'OK') {
          List<dynamic> memberDataList = responseData['data'];
          List<MemberDetail> fetchedMembers = [];
          for (int i = 0; i < memberDataList.length; i++) {
            fetchedMembers.add(MemberDetail.fromJson(memberDataList[i], i));
          }

          setState(() {
            members = fetchedMembers;
            jumlahAnggota = members.length;
            isLoading = false;
            _loggedInUserRole = memberRoleData['data']['role'];
          });
        } else {
          setState(() {
            isLoading = false;
            _errorMessage = responseData['errors'] != null &&
                    (responseData['errors'] as List).isNotEmpty
                ? (responseData['errors'] as List)[0].toString()
                : memberRoleData['errors'] != null &&
                        (memberRoleData['errors'] as List).isNotEmpty
                    ? (memberRoleData['errors'] as List)[0].toString()
                    : "Gagal mengambil data anggota atau informasi user, silahkan coba lagi.";
          });
        }
      } else {
        setState(() {
          isLoading = false;
          _errorMessage =
              "Gagal memuat data anggota. Status code Member: ${membersResponse.statusCode}, Status User Role: ${memberRoleResponse.statusCode}";
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
                                  _loggedInUserRole,
                                  member.memberId);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

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

  Widget _buildMemberTile(
      BuildContext context,
      String name,
      String accountNumber,
      String role,
      String subtitle,
      Color color,
      bool isSmallScreen,
      String? loggedInUserRole,
      String memberId) {
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
                if (loggedInUserRole == 'ADMIN' &&
                    role == 'Anggota' && // Only show delete for 'Anggota' role
                    !widget.isActive) // tambahan kondisi isActive
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmationDialog(name, memberId);
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

  void _showDeleteConfirmationDialog(String name, String memberId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteConfirmationDialog(
          name: name,
          onConfirm: () {
            _deleteMember(name, memberId);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Future<void> _deleteMember(String memberName, String memberId) async {
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
    final deleteMemberUrl = Uri.parse(
        '$baseUrl/members/$memberId/status?savingGroupId=$savingGroupId'); // PATCH endpoint for status update

    try {
      final response = await http.patch(
        // Use PATCH instead of DELETE
        deleteMemberUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json', // Specify content type for PATCH
        },
        body: json.encode({'status': 'LEFT'}), // Body for PATCH request
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        if (responseData['code'] == 200 && responseData['status'] == 'OK') {
          setState(() {
            members.removeWhere((member) => member.memberId == memberId);
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
              content: Text(responseData['errors'] != null &&
                      (responseData['errors'] as List).isNotEmpty
                  ? (responseData['errors'] as List)[0].toString()
                  : "Gagal menghapus anggota, silahkan coba lagi!"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Gagal menghapus anggota. Status code: ${response.statusCode}"),
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
              Text("Terjadi kesalahan saat menghapus anggota: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}

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
