// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:convert'; // Import untuk encoding dan decoding JSON
import 'package:digigoals_app/api/api_config.dart'; // Import konfigurasi API
import 'package:digigoals_app/auth/token_manager.dart'; // Import Token Manager untuk otentikasi
import 'package:flutter/material.dart'; // Import library Flutter Material Design
import 'package:intl/intl.dart'; // Import library untuk format tanggal
import 'package:shimmer/shimmer.dart'; // Import library Shimmer untuk efek loading
import 'package:http/http.dart'
    as http; // Import library HTTP untuk request API

// Model untuk merepresentasikan detail anggota tabungan bersama
class MemberDetail {
  final String memberId; // ID Member
  final String name; // Nama Member
  final String accountNumber; // Nomor Rekening Member
  final String role; // Role Member (Pemilik/Anggota)
  final DateTime joinDate; // Tanggal Bergabung Member
  final Color avatarColor; // Warna Avatar Member

  MemberDetail({
    required this.memberId,
    required this.name,
    required this.accountNumber,
    required this.role,
    required this.joinDate,
    required this.avatarColor,
  });

  // Factory constructor untuk membuat objek MemberDetail dari JSON
  factory MemberDetail.fromJson(Map<String, dynamic> json, int index) {
    final user = json['user']; // Data user dari JSON
    final customer = user['customer']; // Data customer dari JSON
    return MemberDetail(
      memberId: user['id'].toString(), // Konversi ID user ke String
      name:
          customer['name'] ?? 'N/A', // Ambil nama customer atau 'N/A' jika null
      accountNumber: json['account']?['account_number']?.toString() ??
          'N/A', // Ambil nomor rekening atau 'N/A' jika null
      role: json['role'] == 'ADMIN'
          ? 'Pemilik'
          : 'Anggota', // Set role berdasarkan nilai 'role' di JSON
      joinDate: json['join_date'] != null
          ? DateTime.parse(
              json['join_date']) // Parse tanggal bergabung jika tidak null
          : DateTime.now(), // Fallback ke tanggal sekarang jika join_date null
      avatarColor: Colors.primaries[index %
          Colors.primaries.length], // Pilih warna avatar berdasarkan index
    );
  }
}

// Widget Utama Halaman Rincian Anggota Bersama
class RincianAnggotaBersama extends StatefulWidget {
  final String savingGroupId; // ID Saving Group dari halaman sebelumnya
  final String goalsName; // Nama Goals dari halaman sebelumnya
  final bool isActive; // Status aktif tabungan (belum digunakan di UI saat ini)

  const RincianAnggotaBersama({
    super.key,
    required this.savingGroupId,
    required this.goalsName,
    this.isActive = false,
  });

  @override
  _RincianAnggotaBersamaState createState() => _RincianAnggotaBersamaState();
}

class _RincianAnggotaBersamaState extends State<RincianAnggotaBersama> {
  List<MemberDetail> members = []; // State untuk daftar member
  bool isLoading = true; // State untuk indikator loading
  String? _errorMessage; // State untuk pesan error
  late String tabunganName; // State untuk nama tabungan (diambil dari widget)
  int jumlahAnggota = 0; // State untuk jumlah anggota
  final TokenManager _tokenManager =
      TokenManager(); // Instance TokenManager untuk otentikasi

  @override
  void initState() {
    super.initState();
    tabunganName = widget.goalsName; // Inisialisasi nama tabungan
    _loadMembers(); // Panggil fungsi untuk memuat daftar anggota saat widget diinisialisasi
  }

  // Fungsi untuk memuat daftar anggota dari API
  Future<void> _loadMembers() async {
    setState(() {
      isLoading = true; // Set state loading menjadi true
      _errorMessage = null; // Reset pesan error
      members = []; // Bersihkan daftar member sebelumnya
      jumlahAnggota = 0; // Reset jumlah anggota
    });

    String? token =
        await _tokenManager.getToken(); // Ambil token dari TokenManager
    if (token == null) {
      setState(() {
        isLoading = false; // Set state loading menjadi false
        _errorMessage =
            "Sesi Anda telah berakhir. Mohon login kembali."; // Pesan error user-friendly
      });
      return;
    }

    final String savingGroupId =
        widget.savingGroupId; // Ambil savingGroupId dari widget
    final membersUrl = Uri.parse(
        '$baseUrl/members?savingGroupId=$savingGroupId'); // Endpoint API untuk daftar member

    try {
      final response = await http.get(
        membersUrl,
        headers: {
          'Authorization': 'Bearer $token'
        }, // Sertakan token di header otorisasi
      );

      if (response.statusCode == 200) {
        final responseBody =
            utf8.decode(response.bodyBytes); // Decode response body bytes
        final responseData =
            json.decode(responseBody); // Decode response body JSON
        if (responseData['code'] == 200 && responseData['status'] == 'OK') {
          List<dynamic> memberDataList =
              responseData['data']; // Ambil list data member dari response
          List<MemberDetail> fetchedMembers =
              []; // List untuk menyimpan objek MemberDetail
          for (int i = 0; i < memberDataList.length; i++) {
            fetchedMembers.add(MemberDetail.fromJson(
                memberDataList[i], i)); // Map setiap item ke objek MemberDetail
          }

          setState(() {
            members =
                fetchedMembers; // Set state members dengan data yang diambil dari API
            jumlahAnggota = members.length; // Update jumlah anggota
            isLoading = false; // Set state loading menjadi false
          });
        } else {
          setState(() {
            isLoading = false; // Set state loading menjadi false
            _errorMessage = responseData['errors'] != null &&
                    (responseData['errors'] as List).isNotEmpty
                ? (responseData['errors'] as List)[0]
                    .toString() // Ambil pesan error dari API response
                : "Gagal mengambil data anggota tabungan, silahkan coba lagi."; // Pesan error default
          });
        }
      } else {
        setState(() {
          isLoading = false; // Set state loading menjadi false
          _errorMessage =
              "Gagal memuat data anggota. Status code: ${response.statusCode}"; // Pesan error dengan status code
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Set state loading menjadi false
        _errorMessage =
            "Terjadi kesalahan saat memuat data anggota: ${e.toString()}"; // Pesan error exception
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // Lebar layar
    final isSmallScreen = screenWidth < 600; // Kondisi layar kecil

    return Scaffold(
      appBar: _buildAppBar(context), // AppBar kustom
      body: _errorMessage != null
          ? Center(
              child: Text(_errorMessage!)) // Tampilkan pesan error jika ada
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
                            ? _buildShimmerLoader(
                                height: 24,
                                width:
                                    200) // Shimmer loading untuk nama tabungan
                            : Text(
                                tabunganName, // Tampilkan nama tabungan
                                style: TextStyle(
                                  fontSize: isSmallScreen
                                      ? 20
                                      : 24, // Ukuran font responsif
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                  isLoading
                      ? _buildShimmerLoader(
                          height: 16,
                          width: 150) // Shimmer loading untuk jumlah anggota
                      : Text(
                          '$jumlahAnggota Anggota Bergabung', // Tampilkan jumlah anggota
                          style: TextStyle(
                            fontSize: isSmallScreen
                                ? 14
                                : 16, // Ukuran font responsif
                            color: Colors.grey,
                          ),
                        ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: isLoading
                        ? ListView.builder(
                            itemCount: 5, // Jumlah shimmer item saat loading
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: _buildShimmerLoader(
                                    height: 80,
                                    width: double
                                        .infinity), // Shimmer loading untuk list item
                              );
                            },
                          )
                        : ListView.builder(
                            itemCount: members
                                .length, // Jumlah item list sesuai data member
                            itemBuilder: (context, index) {
                              final member =
                                  members[index]; // Ambil data member per index
                              return _buildMemberTile(
                                context,
                                member.name,
                                member.accountNumber,
                                member.role,
                                'Bergabung pada ${DateFormat('dd MMM yyyy').format(member.joinDate)}', // Format tanggal bergabung
                                member.avatarColor,
                                isSmallScreen,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  // AppBar Widget
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
          Navigator.pop(context); // Navigasi kembali ke halaman sebelumnya
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

  // Shimmer Loader Widget (Reusable)
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

  // Widget untuk menampilkan tile member dalam list
  Widget _buildMemberTile(
      BuildContext context,
      String name,
      String accountNumber,
      String role,
      String subtitle,
      Color color,
      bool isSmallScreen) {
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
                        backgroundColor: color, // Warna avatar dari model
                        child: Text(
                          name[0].toUpperCase(), // Inisial nama member
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
                                  name, // Nama member
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isSmallScreen
                                        ? 16
                                        : 18, // Ukuran font responsif
                                  ),
                                ),
                                Text(
                                  role, // Role member (Pemilik/Anggota)
                                  style: TextStyle(
                                    color: role == 'Pemilik'
                                        ? Colors.blue
                                        : Colors
                                            .orange, // Warna role berbeda untuk Pemilik dan Anggota
                                    fontWeight: FontWeight.bold,
                                    fontSize: isSmallScreen
                                        ? 14
                                        : 16, // Ukuran font responsif
                                  ),
                                ),
                              ],
                            ),
                            // const SizedBox(height: 4),
                            Text(
                              '$accountNumber\n$subtitle', // Nomor rekening dan subtitle (tanggal bergabung)
                              style: TextStyle(
                                fontSize: isSmallScreen
                                    ? 12
                                    : 14, // Ukuran font responsif
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (role != 'Pemilik' &&
                    !widget
                        .isActive) // Tampilkan icon delete hanya jika bukan pemilik dan tabungan tidak aktif
                  IconButton(
                    icon: const Icon(Icons.delete,
                        color: Colors.red), // Ikon delete
                    onPressed: () {
                      _showDeleteConfirmationDialog(
                          name); // Tampilkan dialog konfirmasi hapus
                    },
                  )
                else
                  const SizedBox
                      .shrink(), // Widget kosong jika bukan kondisi di atas
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk menampilkan dialog konfirmasi hapus anggota
  void _showDeleteConfirmationDialog(String name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteConfirmationDialog(
          name: name,
          onConfirm: () {
            _deleteMember(name); // Panggil fungsi untuk hapus member dari API
            Navigator.pop(context); // Tutup dialog konfirmasi
          },
        );
      },
    );
  }

  // Fungsi untuk menghapus member dari API (BELUM IMPLEMENTASI API CALL)
  Future<void> _deleteMember(String memberName) async {
    setState(() {
      isLoading = true; // Set loading state menjadi true
    });

    String? token =
        await _tokenManager.getToken(); // Ambil token dari TokenManager
    if (token == null) {
      setState(() {
        isLoading = false; // Set loading state menjadi false
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Token tidak ditemukan, mohon login kembali.'), // SnackBar error token
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Implementasi API call untuk delete member disini
    // Contoh placeholder API call (perlu diganti dengan implementasi sebenarnya)
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      isLoading =
          false; // Set loading state menjadi false setelah API call (simulasi)
      members.removeWhere((member) =>
          member.name == memberName); // Hapus member dari list lokal
      jumlahAnggota = members.length; // Update jumlah anggota
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Anggota $memberName berhasil dihapus.'), // SnackBar sukses hapus anggota
      ),
    );
  }
}

// Widget Dialog Konfirmasi Hapus Anggota (Reusable)
class DeleteConfirmationDialog extends StatelessWidget {
  final String name; // Nama member yang akan dihapus
  final VoidCallback onConfirm; // Callback function saat konfirmasi hapus

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
              'Apakah Benar Anda Ingin Menghapus Anggota $name?', // Pesan konfirmasi hapus
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
                      Navigator.pop(context); // Tutup dialog tanpa menghapus
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
                      Navigator.pop(context); // Tutup dialog
                      onConfirm(); // Panggil callback onConfirm untuk hapus member
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
