import 'package:digigoals_app/TabunganBergilir/DetailTabunganBergilir.dart';
import 'package:flutter/material.dart';

class BuatTabunganBergilir extends StatefulWidget {
  const BuatTabunganBergilir({super.key});

  @override
  _BuatTabunganBergilirState createState() => _BuatTabunganBergilirState();
}

class _BuatTabunganBergilirState extends State<BuatTabunganBergilir> {
  final _formKey = GlobalKey<FormState>();
  final _namaTabunganController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitToDatabase() async {
    try {
      // Simulasi pengiriman data ke database
      await Future.delayed(Duration(seconds: 1));
      // TODO: Implementasi logika penyimpanan ke database
      print("Nama Tabungan Bergilir: ${_namaTabunganController.text}");
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim data, coba lagi.'),
          ),
        );
      }
    }
  }

  Future<void> _navigateToDetailTabungan() async {
    await _submitToDatabase();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DetailTabunganBergilir(),
      ),
    );
  }

  @override
  void dispose() {
    _namaTabunganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
              tooltip: 'Kembali',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              'Buat Tabungan Bergilir Baru',
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
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nama Tabungan Bergilir",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _namaTabunganController,
                    decoration: InputDecoration(
                      fillColor: Colors.blue.shade50,
                      filled: true,
                      hintText: 'Buat Nama Tabungan Bergilir',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Mohon isi Nama Tabungan Bergilir';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });
                          await _navigateToDetailTabungan();
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Selanjutnya',
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.2),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade900),
              ),
            ),
          ),
      ],
    );
  }
}
