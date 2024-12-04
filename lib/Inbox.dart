import 'package:flutter/material.dart';

class Inbox extends StatefulWidget {
  const Inbox({super.key});

  @override
  _InboxState createState() => _InboxState();
}

class _InboxState extends State<Inbox> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const List<String> _tabs = ['Status Transaksi', 'Pending Transaksi'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        elevation: 0,
        toolbarHeight: 84,
        titleSpacing: 16,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
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
            margin: EdgeInsets.only(right: 16),
            height: 12,
            width: 12,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
      body: Padding(
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
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
              indicatorPadding: EdgeInsets.zero,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildStatusTransaksi(),
                  _buildPendingTransaksi(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTransaksi() {
    List<Map<String, String>> statusTransaksi = [];
    return statusTransaksi.isEmpty
        ? Center(
            child: Text(
              'Tidak ada Transaksi Terbaru',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          )
        : ListView.builder(
            itemCount: statusTransaksi.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  statusTransaksi[index]['title'] ?? '',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(statusTransaksi[index]['phone'] ?? ''),
                    Text(statusTransaksi[index]['date'] ?? ''),
                  ],
                ),
                trailing: Icon(Icons.notifications, color: Colors.blue),
              );
            },
          );
  }

  Widget _buildPendingTransaksi() {
    List<Map<String, String>> pendingTransaksi = [
      {
        'title': 'Undangan Anggota',
        'phone': '0123456789012',
        'date': '01 November 2024 09:27',
      },
    ];

    return pendingTransaksi.isEmpty
        ? Center(
            child: Text(
              'Tidak ada Transaksi Terbaru',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          )
        : ListView.builder(
            itemCount: pendingTransaksi.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
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
                              Text(
                                'DIGI Mobile',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w100,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Mengundang Anda untuk bergabung pada Goals "Pernikahan Kita 💍"',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 20),
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
                                        Navigator.pop(context);
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Container(
                                                width: 256,
                                                height: 256,
                                                padding:
                                                    const EdgeInsets.all(15),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'DIGI Mobile',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w100,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    SizedBox(height: 20),
                                                    Text(
                                                      'Anda telah menolak undangan untuk bergabung pada Goals "Pernikahan Kita 💍"',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    SizedBox(height: 20),
                                                    SizedBox(
                                                      width: double.infinity,
                                                      height: 37,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.yellow
                                                                  .shade700,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          'OK',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                                0XFF1F597F),
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
                                      child: Text(
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
                                        Navigator.pop(context);
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Container(
                                                width: 256,
                                                height: 256,
                                                padding:
                                                    const EdgeInsets.all(15),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'DIGI Mobile',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w100,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    SizedBox(height: 20),
                                                    Text(
                                                      'Selamat! Anda telah menjadi anggota Goals "Pernikahan Kita 💍"',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    SizedBox(height: 20),
                                                    SizedBox(
                                                      width: double.infinity,
                                                      height: 37,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.yellow
                                                                  .shade700,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          'OK',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                                0XFF1F597F),
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
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.yellow.shade700,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
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
                child: ListTile(
                  title: Text(
                    pendingTransaksi[index]['title'] ?? '',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pendingTransaksi[index]['phone'] ?? ''),
                      Text(pendingTransaksi[index]['date'] ?? ''),
                    ],
                  ),
                  trailing: Icon(Icons.notifications, color: Colors.blue),
                ),
              );
            },
          );
  }
}
