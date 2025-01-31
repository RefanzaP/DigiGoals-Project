// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:digigoals_app/TabunganBergilir/DetailTabunganBergilir.dart';
import 'package:digigoals_app/api/api_config.dart';
import 'package:digigoals_app/auth/token_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GilirTabungan extends StatefulWidget {
  final Map<String, dynamic> goalsData;
  final String savingGroupId; // Add savingGroupId
  final bool isActive;

  const GilirTabungan({
    super.key,
    required this.goalsData,
    required this.isActive,
    required this.savingGroupId, // Add savingGroupId to constructor
  });

  @override
  _GilirTabunganState createState() => _GilirTabunganState();
}

class _GilirTabunganState extends State<GilirTabungan>
    with SingleTickerProviderStateMixin {
  bool isChecked = false;
  String? warningMessage;
  late AnimationController _animationController;
  String? _winnerName; // Untuk menyimpan nama pemenang
  final TokenManager _tokenManager = TokenManager();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Function to fetch winner from API
  Future<void> _fetchWinnerFromApi(String savingGroupId) async {
    String? token = await _tokenManager.getToken();
    if (token == null) {
      setState(() {
        _winnerName = "Gagal mendapatkan pemenang (Token tidak valid)";
      });
      return;
    }

    final url =
        Uri.parse('$baseUrl/rotating-draw-schedule/$savingGroupId/draw');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('API Response Status Code: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final responseData = json.decode(responseBody);
        if (responseData['code'] == 200 && responseData['status'] == 'OK') {
          final winnerUserData = responseData['data']['winner_user'];
          if (winnerUserData != null &&
              winnerUserData is Map<String, dynamic>) {
            final customerData = winnerUserData['customer'];
            if (customerData != null && customerData is Map<String, dynamic>) {
              setState(() {
                _winnerName = customerData['name'];
                debugPrint('Winner Name set to: $_winnerName');
              });
            } else {
              setState(() {
                _winnerName = "Gagal mendapatkan data customer pemenang";
                debugPrint('Error: Gagal mendapatkan data customer pemenang');
              });
            }
          } else {
            setState(() {
              _winnerName = "Gagal mendapatkan data winner user";
              debugPrint('Error: Gagal mendapatkan data winner user');
            });
          }
        } else {
          setState(() {
            _winnerName =
                "Gagal mendapatkan pemenang dari API: ${responseData['errors'] ?? 'Unknown error'}";
            debugPrint(
                'Error: Gagal mendapatkan pemenang dari API: ${responseData['errors'] ?? 'Unknown error'}');
          });
        }
      } else if (response.statusCode == 500) {
        final responseBody = utf8.decode(response.bodyBytes);
        final responseData = json.decode(responseBody);
        if (responseData['errors'] == 'no eligible members') {
          setState(() {
            _winnerName =
                "Tidak ada anggota yang memenuhi syarat untuk undian.";
          });
        } else {
          setState(() {
            _winnerName =
                "Gagal mendapatkan pemenang dari API: Status Code ${response.statusCode}, Errors: ${responseData['errors'] ?? 'Unknown error'}";
          });
        }
      } else {
        setState(() {
          _winnerName =
              "Gagal mendapatkan pemenang dari API: Status Code ${response.statusCode}";
          debugPrint(
              'Error: Gagal mendapatkan pemenang dari API: Status Code ${response.statusCode}');
        });
      }
    } catch (e) {
      setState(() {
        _winnerName = "Gagal mendapatkan pemenang: ${e.toString()}";
        debugPrint('Error: Gagal mendapatkan pemenang: ${e.toString()}');
      });
    }
  }

  // Modify validateAndProceed to return Future<void>
  Future<void> validateAndProceed() async {
    setState(() {
      if (!isChecked) {
        warningMessage =
            'Harap mencentang lingkaran untuk menyetujui ketentuan!';
      } else {
        warningMessage = null;
        _showGiftAnimation();
        _fetchWinnerFromApi(widget.savingGroupId).then((_) {
          Future.delayed(Duration(seconds: 3), () {
            Navigator.of(context).pop();
            _showWinnerDialog();
          });
        });
      }
    });
  }

  void _showGiftAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RotationTransition(
                turns: Tween(begin: -0.05, end: 0.05).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Curves.elasticInOut,
                  ),
                ),
                child: Icon(
                  Icons.card_giftcard,
                  size: 100,
                  color: Colors.yellow,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Mengundi Pemenang...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWinnerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String dialogText;
        IconData dialogIcon = Icons.emoji_events; // Default icon

        if (_winnerName ==
            "Tidak ada anggota yang memenuhi syarat untuk undian.") {
          dialogText =
              "Maaf, semua anggota telah mendapatkan giliran. Tidak ada pemenang untuk saat ini.";
          dialogIcon = Icons.sentiment_dissatisfied;
        } else if (_winnerName != null &&
            !_winnerName!.startsWith("Gagal mendapatkan pemenang")) {
          dialogText = 'Selamat kepada Anggota $_winnerName yang beruntung!';
          dialogIcon = Icons.emoji_events;
        } else {
          dialogText = 'Pemenang belum dapat ditentukan. ${_winnerName ?? ""}';
          dialogIcon = Icons.error_outline; // Or a different error icon
        }

        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      'DIGI Mobile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Icon(
                    dialogIcon,
                    size: 100,
                    color: Colors.yellow.shade700,
                  ),
                  SizedBox(height: 16),
                  Text(
                    dialogText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => DetailTabunganBergilir(
                              savingGroupId: widget.savingGroupId,
                              isActive: true,
                            ),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'OK',
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
        toolbarHeight: MediaQuery.of(context).size.height * 0.1,
        titleSpacing: 16,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Gilir Tabungan',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Siapa yang akan menjadi anggota beruntung hari ini? Yuk, temukan sekarang!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Ketentuan Gilir Tabungan:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: Text('1.',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    title: Text(
                        'Nominal uang yang akan diterima oleh anggota yang beruntung merupakan akumulasi dari seluruh setoran anggota pada bulan tersebut.'),
                  ),
                  ListTile(
                    leading: Text('2.',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    title: Text(
                        'Setiap anggota hanya berkesempatan mendapatkan giliran satu kali selama program Tabungan Bergilir berlangsung.'),
                  ),
                  ListTile(
                    leading: Text('3.',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    title: Text(
                        'Anggota yang sudah menerima giliran tetap wajib melakukan setoran bulanan hingga program Tabungan Bergilir selesai.'),
                  ),
                ],
              ),
              if (warningMessage != null) ...[
                SizedBox(height: 16),
                Text(
                  warningMessage!,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = value!;
                      warningMessage = null;
                    });
                  },
                  activeColor: Colors.yellow.shade700,
                  shape: CircleBorder(),
                ),
                Expanded(
                  child: Text(
                    'Saya telah membaca dan memahami ketentuan dari program Gilir Tabungan.',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  await validateAndProceed();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Mulai',
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
