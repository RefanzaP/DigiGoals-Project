// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:digigoals_app/api/api_config.dart';
import 'package:digigoals_app/auth/token_manager.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class Account {
  final String namaRekening;
  final String nomorRekening;
  Account({
    required this.namaRekening,
    required this.nomorRekening,
  });
}

class MemberDetailTargetBergilir {
  final String memberId;
  final String name;
  final String accountNumber;
  final String role;
  final double lockedBalance;
  final Color avatarColor;
  final String status;

  MemberDetailTargetBergilir({
    required this.memberId,
    required this.name,
    required this.accountNumber,
    required this.role,
    required this.lockedBalance,
    required this.avatarColor,
    required this.status,
  });

  factory MemberDetailTargetBergilir.fromJson(
      Map<String, dynamic> json, int index, double contributionAmount) {
    final user = json['user'];
    final customer = user['customer'];
    final account = json['account'];
    final lockedBalance =
        (account?['total_locked_balance'] as num?)?.toDouble() ?? 0.0;
    final targetPerMember = contributionAmount;
    final isPaidOff = lockedBalance >= targetPerMember;

    return MemberDetailTargetBergilir(
      memberId: user['id'].toString(),
      name: customer['name'] ?? 'N/A',
      accountNumber: account?['account_number']?.toString() ?? 'N/A',
      role: json['role'] == 'ADMIN' ? 'Pemilik' : 'Anggota',
      lockedBalance: lockedBalance,
      avatarColor: Colors.primaries[index % Colors.primaries.length],
      status: isPaidOff ? 'Lunas' : 'Belum Lunas',
    );
  }
}

class DetailTargetTabunganBergilir extends StatefulWidget {
  final Map<String, dynamic> goalsData;
  final bool isActive;
  final double targetKontribusi;
  final String savingGroupId; // Add savingGroupId as a parameter

  const DetailTargetTabunganBergilir({
    super.key,
    required this.goalsData,
    required this.isActive,
    required this.targetKontribusi,
    required this.savingGroupId, // Make savingGroupId required
  });

  @override
  State<DetailTargetTabunganBergilir> createState() =>
      _DetailTargetTabunganBergilirState();
}

class _DetailTargetTabunganBergilirState
    extends State<DetailTargetTabunganBergilir> {
  List<MemberDetailTargetBergilir> anggotaData = [];
  List<MemberDetailTargetBergilir> filteredData = [];
  String selectedFilter = 'None';
  late double targetTotal;
  late double saldoTabungan;
  bool isLoading = true;
  late String goalsName;
  late String statusTabungan;
  late double progressTabungan;
  late String durasiTabungan;
  late List<String> members;
  late List<Map<String, dynamic>> historiTransaksi;
  late String memberName;
  late double targetKontribusi;
  final TokenManager _tokenManager = TokenManager();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _fetchDataFromApi();
  }

  void _initializeData() {
    goalsName = widget.goalsData['goalsName'];
    saldoTabungan = widget.goalsData['saldoTabungan'];
    statusTabungan = widget.isActive ? 'Aktif' : 'Tidak Aktif';
    progressTabungan = widget.goalsData['progressTabungan'];
    targetTotal = widget.goalsData['targetTabungan'];
    durasiTabungan = widget.goalsData['durasiTabungan'];
    members = List<String>.from(widget.goalsData['members']);
    historiTransaksi =
        List<Map<String, dynamic>>.from(widget.goalsData['transactions']);
    memberName = widget.goalsData['members'].first;
    targetKontribusi =
        widget.targetKontribusi; // Initialize targetKontribusi from widget
  }

  Future<void> _fetchDataFromApi() async {
    setState(() => isLoading = true);

    String? token = await _tokenManager.getToken();
    if (token == null) {
      setState(() => isLoading = false);
      return;
    }

    final String savingGroupId =
        widget.savingGroupId; // Use widget.savingGroupId directly
    final membersUrl =
        Uri.parse('$baseUrl/members?savingGroupId=$savingGroupId');

    try {
      final response = await http.get(
        membersUrl,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final responseData = json.decode(responseBody);
        if (responseData['code'] == 200 && responseData['status'] == 'OK') {
          List<dynamic> memberDataList = responseData['data'];
          List<MemberDetailTargetBergilir> fetchedMembers = [];

          for (int i = 0; i < memberDataList.length; i++) {
            final memberDetail = MemberDetailTargetBergilir.fromJson(
                memberDataList[i], i, targetKontribusi);
            fetchedMembers.add(memberDetail);
          }

          setState(() {
            anggotaData = fetchedMembers;
            filteredData = List.from(anggotaData);
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _filterAnggota(String query) {
    setState(() {
      filteredData = anggotaData
          .where((anggota) =>
              anggota.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      switch (filter) {
        case 'Kontribusi Tertinggi':
          filteredData
              .sort((a, b) => b.lockedBalance.compareTo(a.lockedBalance));
          break;
        case 'Kontribusi Terendah':
          filteredData
              .sort((a, b) => a.lockedBalance.compareTo(b.lockedBalance));
          break;
        case 'Nama A-Z':
          filteredData.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'Nama Z-A':
          filteredData.sort((a, b) => b.name.compareTo(a.name));
          break;
        case 'Status Lunas':
          filteredData = anggotaData.where((a) => a.status == 'Lunas').toList();
          break;
        case 'Status Belum Lunas':
          filteredData =
              anggotaData.where((a) => a.status == 'Belum Lunas').toList();
          break;
        case 'None':
        default:
          filteredData = List.from(anggotaData);
      }
    });
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0)
        .format(amount.round());
  }

  @override
  Widget build(BuildContext context) {
    double overallProgress = progressTabungan;
    double totalTargetKeseluruhan = targetKontribusi * anggotaData.length;
    double totalSaldoKeseluruhan =
        anggotaData.fold(0, (sum, member) => sum + member.lockedBalance);
    overallProgress = totalTargetKeseluruhan > 0
        ? totalSaldoKeseluruhan / totalTargetKeseluruhan
        : 0.0;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProgressCard(
                overallProgress, totalTargetKeseluruhan, totalSaldoKeseluruhan),
            const SizedBox(height: 16),
            _buildSearchAndFilter(),
            const SizedBox(height: 16),
            _buildMemberList(),
          ],
        ),
      ),
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
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        'Detail Target Tabungan',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        textAlign: TextAlign.center,
      ),
      centerTitle: true,
    );
  }

  Widget _buildProgressCard(double overallProgress,
      double totalTargetKeseluruhan, double totalSaldoKeseluruhan) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressCardHeader(),
          const SizedBox(height: 14),
          _buildProgressCardBalance(
              totalSaldoKeseluruhan, totalTargetKeseluruhan),
          const SizedBox(height: 14),
          _buildProgressCardProgressBar(overallProgress),
          const SizedBox(height: 8),
          _buildProgressCardSummary(overallProgress),
        ],
      ),
    );
  }

  Widget _buildProgressCardHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.track_changes,
              color: Colors.blue,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Progress Tabungan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Tooltip(
          message: 'Total progress dari semua anggota',
          child: Icon(
            Icons.info_outline,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCardBalance(
      double totalSaldoKeseluruhan, double totalTargetKeseluruhan) {
    return isLoading
        ? _buildShimmerText(height: 18)
        : Text(
            '${_formatCurrency(totalSaldoKeseluruhan)} / ${_formatCurrency(totalTargetKeseluruhan)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.blue.shade900,
            ),
          );
  }

  Widget _buildProgressCardProgressBar(double overallProgress) {
    return LinearProgressIndicator(
      value: isLoading ? 0 : overallProgress,
      backgroundColor: Colors.grey.shade300,
      color: Colors.blue.shade400,
    );
  }

  Widget _buildProgressCardSummary(double overallProgress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${(overallProgress * 100).toStringAsFixed(1)}% Terpenuhi',
          style: TextStyle(fontSize: 12),
        ),
        Text(
          overallProgress < 1.0 ? 'Terus Menabung' : 'Target Tercapai!',
          style: TextStyle(
            fontSize: 12,
            color: Colors.blue.shade900,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  fillColor: Colors.blue.shade50,
                  filled: true,
                  hintText: 'Cari Anggota',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: _filterAnggota,
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: _applyFilter,
              icon: Icon(Icons.filter_list_rounded, color: Colors.blue),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'None', child: Text('None')),
                const PopupMenuItem(value: 'Nama A-Z', child: Text('Nama A-Z')),
                const PopupMenuItem(value: 'Nama Z-A', child: Text('Nama Z-A')),
                const PopupMenuItem(
                    value: 'Kontribusi Tertinggi',
                    child: Text('Kontribusi Tertinggi')),
                const PopupMenuItem(
                    value: 'Kontribusi Terendah',
                    child: Text('Kontribusi Terendah')),
                const PopupMenuItem(
                    value: 'Status Lunas', child: Text('Status Lunas')),
                const PopupMenuItem(
                    value: 'Status Belum Lunas',
                    child: Text('Status Belum Lunas')),
              ],
            ),
          ],
        ),
        if (selectedFilter != 'None')
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Filter: $selectedFilter',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMemberList() {
    return Expanded(
      child: isLoading
          ? ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildShimmerMemberCard();
              },
            )
          : ListView.builder(
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                final anggota = filteredData[index];
                double progress = anggota.lockedBalance / targetKontribusi;
                return _buildMemberCard(anggota, progress);
              },
            ),
    );
  }

  Widget _buildShimmerMemberCard() {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      shadowColor: Colors.black.withOpacity(0.5),
      elevation: 4,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.grey,
                        ),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 16,
                                width: double.infinity,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 12,
                                width: double.infinity,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 18,
                width: 100,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              Container(
                height: 8,
                width: double.infinity,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              Container(
                height: 12,
                width: 50,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCard(MemberDetailTargetBergilir anggota, double progress) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: anggota.avatarColor,
                  radius: 24,
                  child: Text(
                    anggota.name[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        anggota.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        anggota.accountNumber,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.notifications_active,
                      color: Colors.orange.shade700),
                  tooltip: 'Kirim Pengingat',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Pengingat dikirim ke ${anggota.name}'),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${_formatCurrency(anggota.lockedBalance)} / ${_formatCurrency(targetKontribusi)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.blue.shade900,
              ),
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
                  widthFactor: progress.isNaN
                      ? 0
                      : progress > 1.0
                          ? 1.0
                          : progress < 0
                              ? 0
                              : progress,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: progress < 1.0 ? Colors.blue : Colors.green,
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
                Text('${(progress * 100).toStringAsFixed(1)}% Tercapai',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(
                  anggota.status,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        anggota.status == 'Lunas' ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerText({double height = 20}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: height,
        color: Colors.grey,
      ),
    );
  }
}
