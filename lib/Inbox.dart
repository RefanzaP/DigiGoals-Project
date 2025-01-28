// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:convert';
import 'package:digigoals_app/auth/token_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:digigoals_app/Beranda.dart'; // Import Beranda.dart
import 'package:http/http.dart' as http;
import 'package:digigoals_app/api/api_config.dart';

class Inbox extends StatefulWidget {
  final String? token; // Tambahkan parameter token disini

  const Inbox(
      {super.key, this.token}); // Modifikasi konstruktor untuk menerima token

  @override
  _InboxState createState() => _InboxState();
}

class _InboxState extends State<Inbox> with TickerProviderStateMixin {
  late TabController _tabController;
  static const List<String> _tabs = ['Status Transaksi', 'Pending Transaksi'];

  // List untuk pending transaksi dari API
  List<Map<String, dynamic>> _pendingTransaksi = [];

  // List untuk status transaksi dari API
  List<Map<String, dynamic>> _statusTransaksi = [];

  bool _isLoading = false;
  bool _isInitialLoading = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _termsAccepted = false;
  final TokenManager _tokenManager = TokenManager(); // Instance TokenManager

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadInitialData();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    // Cetak token yang diterima untuk debugging
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isInitialLoading = true;
    });

    try {
      final token = widget.token;
      final userId = await _tokenManager.getUserId();

      if (token == null || userId == null) {
        // Handle token or userId missing, maybe redirect to login
        setState(() {
          _isInitialLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesi tidak valid, mohon login kembali'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/invitations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type':
              'application/json; charset=utf-8', // Explicitly set UTF-8
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(utf8
            .decode(response.bodyBytes)); // Decode response body using UTF-8
        if (responseData['data'] != null) {
          List<dynamic> invitations = responseData['data'];
          _pendingTransaksi = [];
          _statusTransaksi = [];

          for (var invitation in invitations) {
            Map<String, dynamic> formattedInvitation = {
              'id': invitation['id'],
              'goalsName': invitation['saving_group']['name'],
              'message': invitation['message'],
              'date': invitation['invited_at'],
              'status': invitation['status'],
              'inviterName': invitation['sender_user']['customer']['name'],
              'type': invitation['saving_group']['type'],
              'messageTitle': 'Undangan Anggota', // Static message title
            };

            if (invitation['status'] == 'PENDING') {
              _pendingTransaksi.add(formattedInvitation);
            } else {
              _statusTransaksi.add(formattedInvitation);
            }
          }
        }
      } else {
        // Handle error response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Gagal memuat inbox. Error code: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle exception
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan saat memuat inbox: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Fungsi untuk memindahkan transaksi dari pending ke status
  Future<void> _moveTransactionToStatus(
      Map<String, dynamic> transaction, String newStatus) async {
    setState(() {
      _isLoading = true;
      _animationController.forward();
    });

    try {
      final token = widget.token;
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Token tidak valid, mohon login kembali'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final invitationId = transaction['id'];
      final response = await http.patch(
        Uri.parse('$baseUrl/invitations/$invitationId/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type':
              'application/json; charset=utf-8', // Explicitly set UTF-8
        },
        body: json.encode({'status': newStatus.toUpperCase()}),
      );

      if (response.statusCode == 200) {
        setState(() {
          // Update status transaksi yang dipilih
          transaction['status'] = newStatus;

          // Pindahkan transaksi ke list status transaksi jika diterima atau ditolak
          if (newStatus == 'accepted') {
            _statusTransaksi.add(transaction);
          } else if (newStatus == 'rejected') {
            _statusTransaksi.add(transaction);
          }
          _pendingTransaksi.remove(transaction); // hapus dari pending
        });
      } else {
        // Handle error response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Gagal memperbarui status undangan. Error code: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle exception
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Terjadi kesalahan saat memperbarui status undangan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _animationController.reverse();
      });
    }
  }

  // Function to verify PIN using API
  Future<bool> _verifyPinApi(String pin) async {
    final token = widget.token;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token tidak valid, mohon login kembali'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-transaction-pin'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type':
              'application/json; charset=utf-8', // Explicitly set UTF-8
        },
        body: json.encode({'transaction_pin': pin}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
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
        toolbarHeight: 84,
        titleSpacing: 16,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Inbox',
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                  indicatorColor: Colors.blue,
                  indicatorWeight: 4,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.blue,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  indicatorPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      buildStatusTransaksi(),
                      buildPendingTransaksi(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            FadeTransition(
              opacity: _animation,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.amber),
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget buildStatusTransaksi() {
    if (_isInitialLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Colors.amber,
        ),
      );
    }
    return _statusTransaksi.isEmpty
        ? const EmptyTransactionMessage(message: 'Tidak ada Transaksi Terbaru')
        : ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: _statusTransaksi.length,
            itemBuilder: (context, index) {
              final transaction = _statusTransaksi[index];
              IconData icon = Icons.notifications; // Default icon
              Color iconColor = Colors.blue; // Default icon color

              if (transaction['status'].toUpperCase() == 'ACCEPTED') {
                icon = Icons.check_circle_outline;
                iconColor = Colors.green;
              } else if (transaction['status'].toUpperCase() == 'REJECTED') {
                icon = Icons.cancel_outlined;
                iconColor = Colors.red;
              }

              return Column(
                children: [
                  TransactionCard(
                    transaction: transaction,
                    icon: Icons.mail_outline,
                    iconColor: Colors.blue,
                    onTap: () {},
                    trailing: Icon(icon, color: iconColor),
                    messageTitle:
                        transaction['messageTitle'], // Pass messageTitle
                  ),
                  const SizedBox(height: 12), // Jarak antar card
                ],
              );
            },
          );
  }

  Widget buildPendingTransaksi() {
    if (_isInitialLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Colors.amber,
        ),
      );
    }
    return _pendingTransaksi.isEmpty
        ? const EmptyTransactionMessage(message: 'Tidak ada Transaksi Terbaru')
        : ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: _pendingTransaksi.length,
            itemBuilder: (context, index) {
              final transaction = _pendingTransaksi[index];
              return Column(
                children: [
                  TransactionCard(
                    transaction: transaction,
                    icon: Icons.mail_outline,
                    iconColor: Colors.blue,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          // Use a new context here
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              width: 256,
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                mainAxisSize: MainAxisSize
                                    .min, // Use min to adjust height
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                  const SizedBox(height: 8),
                                  Icon(Icons.mail_outline,
                                      size: 64,
                                      color: Colors.blue), // Ikon disini
                                  const SizedBox(height: 8),
                                  Text(
                                    transaction['message'] ??
                                        '', // Use message from API
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      // fontWeight: FontWeight.w500,
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
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: OutlinedButton(
                                          onPressed: () {
                                            Navigator.pop(
                                                dialogContext); // Close the confirmation dialog
                                            _showLoadingDialog(context,
                                                transaction, 'rejected');
                                          },
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                              color: Colors.yellow.shade700,
                                              width: 2,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(dialogContext);
                                            _showTermsAndConditions(
                                                transaction);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.yellow.shade700,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                        },
                      );
                    },
                    trailing:
                        const Icon(Icons.notifications, color: Colors.blue),
                    messageTitle:
                        transaction['messageTitle'], // Pass messageTitle
                  ),
                  const SizedBox(height: 12), // Jarak antar card
                ],
              );
            },
          );
  }

  // Function to show terms and conditions modal based on the goal type
  void _showTermsAndConditions(Map<String, dynamic> transaction) {
    if (transaction['type'] == 'JOINT_SAVING') {
      _showTermsAndConditionsTabunganBersama(transaction);
    } else if (transaction['type'] == 'ROTATING_SAVING') {
      _showTermsAndConditionsTabunganBergilir(transaction);
    }
  }

  void _showTermsAndConditionsTabunganBersama(
      Map<String, dynamic> transaction) {
    _termsAccepted = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTermsTitleTabunganBersama(),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: _buildTermsTextTabunganBersama(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTermsCheckbox(setModalState),
                      const SizedBox(height: 12),
                      _buildCreateButton(transaction),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTermsTitleTabunganBersama() {
    return Text(
      'Syarat & Ketentuan Tabungan Bersama',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue.shade900,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTermsTextTabunganBersama() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            "Dengan melanjutkan pembuatan Tabungan Bersama, Anda menyatakan bahwa:",
            style: TextStyle(color: Colors.black87),
          ),
        ),
        ListTile(
          leading: Icon(Icons.info_outline, color: Colors.blue.shade700),
          title: const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Anda ",
                ),
                TextSpan(
                  text: "bertanggung jawab penuh",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                TextSpan(
                  text:
                      " atas segala risiko kerugian yang timbul akibat tindakan atau keputusan anggota lain dalam grup Tabungan Bersama Anda.",
                ),
              ],
            ),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        ListTile(
          leading: Icon(Icons.info_outline, color: Colors.blue.shade700),
          title: const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Bank bjb ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      "tidak bertanggung jawab atas kerugian yang timbul akibat tindakan atau keputusan anggota lain tersebut.",
                ),
              ],
            ),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: ListTile(
            title: const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Syarat Tabungan Bersama:\n",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "•  ",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "Jumlah minimal target goals: Rp 5.000.000,00.\n",
                    style: TextStyle(fontSize: 13),
                  ),
                  TextSpan(
                    text: "•  ",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "Jumlah minimal anggota: 2 orang.\n",
                    style: TextStyle(fontSize: 13),
                  ),
                  TextSpan(
                    text: "•  ",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "Jumlah maksimal anggota: 100 orang.",
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
              textAlign: TextAlign.justify,
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        ListTile(
          title: const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Ketentuan Tabungan Bersama:\n",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: "•  ",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      "Anggota dapat menambah/menarik dana sesuai kontribusi.\n",
                  style: TextStyle(fontSize: 13),
                ),
                TextSpan(
                  text: "•  ",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      "Maksimal penambahan dana: Rp. Target / Durasi Tabungan, untuk memastikan setiap anggota berkontribusi secara proporsional.\n",
                  style: TextStyle(fontSize: 13),
                ),
                TextSpan(
                  text: "•  ",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      "Tabungan dapat dikunci untuk mendapatkan bunga lebih tinggi.\n",
                  style: TextStyle(fontSize: 13),
                ),
                TextSpan(
                  text: "•  ",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      "Admin dapat mengubah target dana/waktu maksimal 2 kali.\n",
                  style: TextStyle(fontSize: 13),
                ),
                TextSpan(
                  text: "•  ",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      "Admin dapat menambah anggota tanpa melebihi batas maksimal.\n",
                  style: TextStyle(fontSize: 13),
                ),
                TextSpan(
                  text: "•  ",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      "Anggota dapat keluar dengan persetujuan admin, dana dikembalikan sesuai kontribusi.\n",
                  style: TextStyle(fontSize: 13),
                ),
                TextSpan(
                  text: "•  ",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      "Alasan keluar dari Tabungan Bersama perlu disampaikan saat pengajuan.",
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
            textAlign: TextAlign.justify,
          ),
          contentPadding: EdgeInsets.zero,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: Text(
            "Kami menyarankan Anda untuk mempertimbangkan risiko ini sebelum melanjutkan pembuatan Tabungan Bersama.",
            style: TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  void _showTermsAndConditionsTabunganBergilir(
      Map<String, dynamic> transaction) {
    _termsAccepted = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTermsTitleTabunganBergilir(),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: _buildTermsTextTabunganBergilir(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTermsCheckbox(setModalState),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _termsAccepted
                              ? () {
                                  Navigator.pop(context);
                                  _submitToApi(transaction);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _termsAccepted
                                ? Colors.yellow.shade700
                                : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Setuju',
                            style: TextStyle(
                              color: _termsAccepted
                                  ? Colors.blue.shade800
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTermsTitleTabunganBergilir() {
    return Text(
      'Syarat & Ketentuan Tabungan Bergilir',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue.shade900,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTermsTextTabunganBergilir() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            "Dengan melanjutkan pembuatan Tabungan Bergilir, Anda menyatakan bahwa:",
            style: TextStyle(color: Colors.black87),
          ),
        ),
        ListTile(
          leading: Icon(Icons.info_outline, color: Colors.blue.shade700),
          title: const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Anda ",
                ),
                TextSpan(
                  text: "bertanggung jawab penuh",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                TextSpan(
                  text:
                      " atas segala risiko kerugian yang timbul akibat tindakan atau keputusan anggota lain dalam grup Tabungan Bergilir Anda.",
                ),
              ],
            ),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        ListTile(
          leading: Icon(Icons.info_outline, color: Colors.blue.shade700),
          title: const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Bank bjb ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      "tidak bertanggung jawab atas kerugian yang timbul akibat tindakan atau keputusan anggota lain tersebut.",
                ),
              ],
            ),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: ListTile(
            title: const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Syarat untuk mengaktifkan tabungan bergilir:\n",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "•  ",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "Jumlah minimal target goals: Rp 5.000.000,00.\n",
                    style: TextStyle(fontSize: 13),
                  ),
                  TextSpan(
                    text: "•  ",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "Jumlah minimal anggota: 5 orang.\n",
                    style: TextStyle(fontSize: 13),
                  ),
                  TextSpan(
                    text: "•  ",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "Jumlah maksimal anggota: 25 orang.",
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
              textAlign: TextAlign.justify,
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        ListTile(
          title: const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Ketentuan Tabungan Bergilir:\n",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: "•  ",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      "Nasabah beserta anggota goals dapat menambah ataupun menarik dana pada goals yang telah dibuat sesuai dengan kontribusinya masing-masing.\n",
                  style: TextStyle(fontSize: 13),
                ),
                TextSpan(
                  text: "•  ",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      "Terdapat biaya layanan (fee based) yang disematkan pada setiap setoran untuk semua anggota tabungan bergilir pada periode waktu tertentu sebesar Rp. 1.000,00.\n",
                  style: TextStyle(fontSize: 13),
                ),
                TextSpan(
                  text: "•  ",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      "Jumlah setoran tabungan bergilir untuk setiap anggotanya sudah termasuk biaya layanan tersebut. Misal anggota tabungan bergilir dengan jumlah 10 orang dan target 10.000.000 maka jumlah setoran yang perlu dibayar oleh setiap anggotanya adalah 1.000.000 + 1.000 = 1.001.000\n",
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
            textAlign: TextAlign.justify,
          ),
          contentPadding: EdgeInsets.zero,
        ),
        ListTile(
          title: const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text:
                      "Ketentuan Pengubahan Target Dana dan Target Waktu Goals:\n",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      "Nasabah pengelola goals/admin tidak dapat mengubah target dana dan target waktu goals jika tabungan bergilir telah dimulai karena akan mengganggu kenyamanan antar anggota tabungan bergilir.\n",
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
            textAlign: TextAlign.justify,
          ),
          contentPadding: EdgeInsets.zero,
        ),
        ListTile(
          title: const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Ketentuan Penambahan Anggota:\n",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      "Admin tidak dapat menambahkan anggota jika tabungan bergilir telah dimulai.\n",
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
            textAlign: TextAlign.justify,
          ),
          contentPadding: EdgeInsets.zero,
        ),
        ListTile(
          title: const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Ketentuan Keluar dari Goals:\n",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                    text:
                        "Anggota tidak dapat mengajukan untuk keluar dari goals jika tabungan bergilir telah dimulai.\n",
                    style: TextStyle(fontSize: 13)),
              ],
            ),
            textAlign: TextAlign.justify,
          ),
          contentPadding: EdgeInsets.zero,
        ),
        ListTile(
          title: const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text:
                      "Ketentuan Jika Terdapat Anggota yang Wanprestasi (tabungan bergilir):\n",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                    text:
                        "Wanprestasi adalah keadaan ketika anggota tabungan bergilir tidak dapat memenuhi kewajibannya untuk dapat membayar tagihan tabungan bergilir setiap periode penentuan giliran. Seorang anggota tabungan bergilir dapat dikatakan wanprestasi ketika anggota tabungan bergilir tersebut tidak dapat memenuhi kewajibannya untuk membayar tagihan maksimal 3 hari setelah tanggal jatuh tempo tabungan bergilir.\n",
                    style: TextStyle(fontSize: 13)),
              ],
            ),
            textAlign: TextAlign.justify,
          ),
          contentPadding: EdgeInsets.zero,
        ),
        ListTile(
          title: const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text:
                      "Jika terdapat anggota wanprestasi dan belum mendapatkan giliran:\n",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: "•  ",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                    text:
                        "Anggota tersebut akan dikeluarkan karena kelalaiannya sendiri yang dapat merugikan anggota lain\n",
                    style: TextStyle(fontSize: 13)),
                TextSpan(
                  text: "•  ",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                    text:
                        "Kontribusi yang telah diberikan akan hangus sebagai penalty\n",
                    style: TextStyle(fontSize: 13)),
                TextSpan(
                  text: "•  ",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                    text:
                        "Durasi dan tagihan tabungan bergilir tidak akan berubah\n",
                    style: TextStyle(fontSize: 13)),
                TextSpan(
                  text: "•  ",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                    text:
                        "Jumlah dana yang diberikan pada setiap penentuan giliran akan berkurang namun dana yang kurang tersebut akan digantikan pada akhir periode beserta dengan pembagian bonus dari kontribusi peserta yang wanprestasi\n",
                    style: TextStyle(fontSize: 13)),
              ],
            ),
            textAlign: TextAlign.justify,
          ),
          contentPadding: EdgeInsets.zero,
        ),
        ListTile(
          title: const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                    text:
                        "Jika terdapat anggota wanprestasi tetapi sudah mendapatkan giliran:\n",
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                TextSpan(
                  text: "•  ",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                    text:
                        "Anggota tersebut akan dikeluarkan karena kelalaiannya sendiri serta niat untuk menipu anggota lain.\n",
                    style: TextStyle(fontSize: 13)),
                TextSpan(
                  text: "•  ",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                    text:
                        "Bank bjb selaku penyedia layanan tabungan bergilir dapat memberikan kredit untuk anggota wanprestasi sesuai dengan jumlah sisa setoran yang perlu dibayarkan. Dana pada rekening anggota wanprestasi tersebut dapat langsung dipotong sesuai dengan jumlah sisa setoran yang perlu dibayarkan dan dana yang telah dipotong tersebut akan menjadi dana darurat tabungan bergilir\n",
                    style: TextStyle(fontSize: 13)),
                TextSpan(
                  text: "•  ",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                    text:
                        "Durasi, tagihan, dan jumlah dana yang diberikan pada setiap penentuan giliran tidak akan berubah.",
                    style: TextStyle(fontSize: 13)),
              ],
            ),
            textAlign: TextAlign.justify,
          ),
          contentPadding: EdgeInsets.zero,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: Text(
            "Kami menyarankan Anda untuk mempertimbangkan risiko ini sebelum melanjutkan pembuatan Tabungan Bergilir.",
            style: TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox(StateSetter setModalState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Theme(
                data: ThemeData(unselectedWidgetColor: Colors.grey),
                child: Checkbox(
                  value: _termsAccepted,
                  onChanged: (bool? value) {
                    setModalState(() {
                      _termsAccepted = value!;
                    });
                  },
                  activeColor: Colors.yellow.shade700,
                  shape: const CircleBorder(),
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.yellow.shade700;
                    }
                    return Colors.white;
                  }),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
            const Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Saya Setuju Dengan Syarat dan Ketentuan yang telah disampaikan diatas.",
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCreateButton(Map<String, dynamic> transaction) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _termsAccepted
            ? () async {
                Navigator.pop(context);
                _submitToApi(transaction);
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _termsAccepted ? Colors.yellow.shade700 : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Setuju',
          style: TextStyle(
            color: _termsAccepted ? Colors.blue.shade800 : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Function to submit to API after accepting terms
  Future<void> _submitToApi(Map<String, dynamic> transaction) async {
    final String? token =
        widget.token; // Gunakan token yang diterima dari Inbox

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token tidak ditemukan, mohon login kembali'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InputPin(
          token: token,
          onPinSuccess: () {
            _showLoadingDialog(context, transaction, 'accepted');
          },
          verifyPinApi: _verifyPinApi, // Pass the API verification function
        ),
      ),
    );
  }

  // Function to show loading dialog
  Future<void> _showLoadingDialog(BuildContext context,
      Map<String, dynamic> transaction, String status) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: 256,
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
                const SizedBox(height: 16),
                Text(
                  'Memproses...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    // Simulate loading delay before moving transaction and showing result dialog
    await Future.delayed(const Duration(milliseconds: 500));
    await _moveTransactionToStatus(transaction, status);
    //Close loading dialog
    Navigator.pop(context);
    _showResultDialog(context, transaction, status);
  }

  // Function to show result dialog
  Future<void> _showResultDialog(BuildContext context,
      Map<String, dynamic> transaction, String status) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        IconData icon;
        Color iconColor;
        String resultText;

        if (status == 'accepted') {
          icon = Icons.check_circle_outline;
          iconColor = Colors.green;
          resultText =
              'Selamat! Anda telah menjadi Anggota Goals \n"${transaction['goalsName']}"';
        } else {
          icon = Icons.cancel_outlined;
          iconColor = Colors.red;
          resultText =
              'Anda telah menolak undangan untuk bergabung pada Goals \n"${transaction['goalsName']}"';
        }
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: 256,
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 8),
                Icon(icon, size: 64, color: iconColor),
                const SizedBox(height: 20),
                Text(
                  resultText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 37,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close Result Dialog
                      // Navigate to Beranda.dart dan kirim token disini
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                            create: (context) => BerandaState(
                                accessToken: widget
                                    .token), // Kirim token saat create BerandaState
                            child: const Beranda(),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF1F597F),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// widget pesan kosong
class EmptyTransactionMessage extends StatelessWidget {
  final String message;
  const EmptyTransactionMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }
}

// Contoh widget TransactionCard untuk status transaksi
class TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? messageTitle; // Added messageTitle

  const TransactionCard({
    super.key,
    required this.transaction,
    this.icon,
    this.iconColor,
    this.onTap,
    this.trailing,
    this.messageTitle = 'Undangan Anggota', // Default messageTitle
  });

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.symmetric(horizontal: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: ListTile(
              leading: icon != null ? Icon(icon, color: iconColor) : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              title: Text(
                messageTitle ?? '', // Menampilkan messageTitle atau default
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    overflow: TextOverflow.ellipsis),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction['id'] ?? '',
                    style: const TextStyle(
                        fontSize: 14, overflow: TextOverflow.ellipsis),
                  ),
                  Text(
                    transaction['date'] ?? '',
                    style: const TextStyle(
                        fontSize: 12, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              trailing: trailing,
            ),
          ),
        ));
  }
}

class InputPin extends StatefulWidget {
  final VoidCallback onPinSuccess;
  final String? token;
  final Future<bool> Function(String)
      verifyPinApi; // Function to call API for PIN verification

  const InputPin({
    super.key,
    required this.onPinSuccess,
    this.token,
    required this.verifyPinApi, // Receive the API verification function
  });

  @override
  _InputPinState createState() => _InputPinState();
}

class _InputPinState extends State<InputPin> {
  String _pin = '';
  final int _pinLength = 6;
  bool _isVerifyingPin = false; // Loading state for PIN verification

  void _addPin(String number) {
    setState(() {
      if (_pin.length < _pinLength) {
        _pin = _pin + number;
      }
    });
    _validatePin();
  }

  void _removePin() {
    setState(() {
      if (_pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  void _validatePin() async {
    if (_pin.length == _pinLength) {
      setState(() {
        _isVerifyingPin = true;
      });
      final isPinValid =
          await widget.verifyPinApi(_pin); // Use the passed API function
      setState(() {
        _isVerifyingPin = false;
      });
      if (isPinValid) {
        widget.onPinSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pin yang Anda masukkan salah'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _pin = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        toolbarHeight: 84,
        titleSpacing: 16,
        automaticallyImplyLeading: false,
        title: const Text(
          'Input M-PIN Mobile Banking',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
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
      body: Stack(
        // Wrap body in Stack to show loading indicator
        children: [
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue.shade700, Colors.blue.shade400],
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 36,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          _pinLength,
                          (index) => Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 18),
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: index < _pin.length
                                      ? Colors.amber
                                      : Colors.grey[300],
                                ),
                              )),
                    ),
                    const SizedBox(
                      height: 36,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      ...[
                        '1',
                        '2',
                        '3',
                        '4',
                        '5',
                        '6',
                        '7',
                        '8',
                        '9',
                        '',
                        '0',
                        'backspace',
                      ].map(
                        (number) => InkWell(
                          onTap: () {
                            if (number == 'backspace') {
                              _removePin();
                            } else if (number.isNotEmpty) {
                              _addPin(number);
                            }
                          },
                          child: Center(
                            child: number == 'backspace'
                                ? Row(
                                    // Menggunakan Row untuk mengatur posisi ikon dan button
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Spacer(),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.backspace_rounded,
                                              color: Colors.amber),
                                          TextButton(
                                            onPressed: () {
                                              // todo: action lupa pin
                                            },
                                            child: const Text(
                                              'Lupa PIN',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.blue),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer()
                                    ],
                                  )
                                : Text(
                                    number,
                                    style: const TextStyle(
                                        fontSize: 24, color: Colors.black),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Kembali',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isVerifyingPin) // Show loading indicator when verifying PIN
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
