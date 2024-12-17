import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shimmer/shimmer.dart';

class RincianAnggotaBergilir extends StatefulWidget {
  const RincianAnggotaBergilir({super.key});

  @override
  _RincianAnggotaBergilirState createState() => _RincianAnggotaBergilirState();
}

class _RincianAnggotaBergilirState extends State<RincianAnggotaBergilir> {
  List<Map<String, dynamic>> members = [];
  bool isLoading = true;
  String tabunganName = "Gudang Garam Jaya 🔥";
  int jumlahAnggota = 5;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      members = [
        {
          'name': 'ABI',
          'id': '0123456789001',
          'role': 'Pemilik',
          'subtitle': 'Membuat Goals pada 01 November 2024',
          'color': Colors.blue
        },
        {
          'name': 'INTAN',
          'id': '0123456789002',
          'role': 'Anggota',
          'subtitle': 'Bergabung pada 01 November 2024',
          'color': Colors.orange
        },
        {
          'name': 'UMI',
          'id': '0123456789003',
          'role': 'Anggota',
          'subtitle': 'Bergabung pada 02 November 2024',
          'color': Colors.pink
        },
        {
          'name': 'EDI',
          'id': '0123456789004',
          'role': 'Anggota',
          'subtitle': 'Bergabung pada 03 November 2024',
          'color': Colors.purple
        },
        {
          'name': 'OMEN',
          'id': '0123456789005',
          'role': 'Anggota',
          'subtitle': 'Bergabung pada 04 November 2024',
          'color': Colors.deepOrange
        },
      ];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
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
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
            const SizedBox(height: 8),
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
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                          member['name'],
                          member['id'],
                          member['role'],
                          member['subtitle'],
                          member['color'],
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

  Widget _buildMemberTile(BuildContext context, String name, String id,
      String role, String subtitle, Color color, bool isSmallScreen) {
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
                          name[0],
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
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
                            const SizedBox(height: 4),
                            Text(
                              '$id\n$subtitle',
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
                // role != 'Pemilik'
                //     ? IconButton(
                //         icon: const Icon(Icons.delete, color: Colors.red),
                //         onPressed: null, // Di-comment atau nonaktif
                //       )
                //     //  onPressed: () {
                //     //    _showDeleteConfirmationDialog(name);
                //     //  },
                //     : const SizedBox.shrink(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
