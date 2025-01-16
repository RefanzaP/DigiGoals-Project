// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';

class Inbox extends StatefulWidget {
  const Inbox({super.key});

  @override
  _InboxState createState() => _InboxState();
}

class _InboxState extends State<Inbox> with TickerProviderStateMixin {
  late TabController _tabController;
  static const List<String> _tabs = ['Status Transaksi', 'Pending Transaksi'];

  // Data statis awal untuk pending transaksi
  final List<Map<String, dynamic>> _pendingTransaksi = [
    {
      'goalsName': 'Gudang Garam Jaya 🔥', // Nama Goals
      'message': 'Undangan Anggota', // Nama pesan
      'accountNumber': '0123456789012', // Nomor rekening
      'date': '01 November 2024 09:27', // tanggal undangan diterima/dikirim
      'status': 'pending', // status undangan di inbox
      'inviterName': 'John Doe', // Menambahkan nama pengirim undangan
    },
  ];

  // Data statis awal untuk status transaksi
  final List<Map<String, dynamic>> _statusTransaksi = [];

  bool _isLoading = false;
  bool _isInitialLoading = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

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
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isInitialLoading = true;
    });
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Load data dummy or call API here
    // For example:
    // _pendingTransaksi = await fetchDataPendingTransactions();
    // _statusTransaksi = await fetchDataStatusTransactions();

    setState(() {
      _isInitialLoading = false;
    });
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

    // Simulate a delay for loading effect
    await Future.delayed(const Duration(milliseconds: 500));

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
      _isLoading = false;
      _animationController.reverse();
    });
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
                  child: CircularProgressIndicator(),
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
          color: Colors.blue.shade700,
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

              if (transaction['status'] == 'accepted') {
                icon = Icons.check_circle_outline;
                iconColor = Colors.green;
              } else if (transaction['status'] == 'rejected') {
                icon = Icons.cancel_outlined;
                iconColor = Colors.red;
              }

              return TransactionCard(
                transaction: transaction,
                icon: Icons.mail_outline,
                iconColor: Colors.blue,
                onTap: () {},
                trailing: Icon(icon, color: iconColor),
              );
            },
          );
  }

  Widget buildPendingTransaksi() {
    if (_isInitialLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Colors.blue.shade700,
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
              return TransactionCard(
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
                            mainAxisSize:
                                MainAxisSize.min, // Use min to adjust height
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'DIGI Mobile',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Icon(Icons.mail_outline,
                                  size: 64, color: Colors.blue), // Ikon disini
                              const SizedBox(height: 8),
                              Text(
                                transaction['inviterName'] ??
                                    'Tidak Diketahui', // Menampilkan nama pengirim
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                transaction['accountNumber'] ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Mengundang Anda untuk bergabung pada Goals "${transaction['goalsName']}"',
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

                                        _showLoadingDialog(
                                            context, transaction, 'rejected');
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

                                        _showLoadingDialog(
                                            context, transaction, 'accepted');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.yellow.shade700,
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
                trailing: const Icon(Icons.notifications, color: Colors.blue),
              );
            },
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
              mainAxisSize: MainAxisSize.min, // Set mainAxisSize
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
              'Selamat! Anda telah menjadi anggota Goals "${transaction['goalsName']}"';
        } else {
          icon = Icons.cancel_outlined;
          iconColor = Colors.red;
          resultText =
              'Anda telah menolak undangan untuk bergabung pada Goals "${transaction['goalsName']}"';
        }
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: 256,
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Set mainAxisSize
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
                      Navigator.pop(context);
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
  const TransactionCard(
      {super.key,
      required this.transaction,
      this.icon,
      this.iconColor,
      this.onTap,
      this.trailing});

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
                transaction['message'] ?? '', // Menampilkan nama pesan
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    overflow: TextOverflow.ellipsis),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction['accountNumber'] ??
                        '', // Menampilkan nomor rekening
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
