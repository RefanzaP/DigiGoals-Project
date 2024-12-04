import 'package:flutter/material.dart';
import 'dart:math';

class GilirTabungan extends StatefulWidget {
  const GilirTabungan({super.key});

  @override
  _GilirTabunganState createState() => _GilirTabunganState();
}

class _GilirTabunganState extends State<GilirTabungan>
    with SingleTickerProviderStateMixin {
  bool isChecked = false;
  String? warningMessage;
  late AnimationController _animationController;

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

  void validateAndProceed() {
    setState(() {
      if (!isChecked) {
        warningMessage =
            'Harap mencentang lingkaran untuk menyetujui ketentuan!';
      } else {
        warningMessage = null;
        _showGiftAnimation();
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

    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pop();
      _showWinnerDialog();
    });
  }

  void _showWinnerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
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
                  Icons.emoji_events,
                  size: 100,
                  color: Colors.yellow.shade700,
                ),
                SizedBox(height: 16),
                Text(
                  'Selamat kepada Anggota ${_getRandomName()} yang beruntung!',
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
                      Navigator.of(context).pop();
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
        );
      },
    );
  }

  String _getRandomName() {
    List<String> names = ["Andi", "Budi", "Citra", "Dewi", "Eka"];
    return names[Random().nextInt(names.length)];
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
                        'Ada potongan sebesar 2% untuk biaya pengelolaan Tabungan Bergilir yang akan diberikan kepada pengelola.'),
                  ),
                  ListTile(
                    leading: Text('3.',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    title: Text(
                        'Setiap anggota hanya berkesempatan mendapatkan giliran satu kali selama program Tabungan Bergilir berlangsung.'),
                  ),
                  ListTile(
                    leading: Text('4.',
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
                onPressed: validateAndProceed,
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
