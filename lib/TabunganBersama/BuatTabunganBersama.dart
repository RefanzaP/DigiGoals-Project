// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../OurGoals.dart';

class Account {
  final String nomorRekening;
  final String namaRekening;

  Account({
    required this.nomorRekening,
    required this.namaRekening,
  });
}

class BuatTabunganBersama extends StatefulWidget {
  const BuatTabunganBersama({super.key});

  @override
  _BuatTabunganBersamaState createState() => _BuatTabunganBersamaState();
}

class _BuatTabunganBersamaState extends State<BuatTabunganBersama> {
  final _formKey = GlobalKey<FormState>();
  final _namaTabunganController = TextEditingController();
  final _nominalGoalsController = TextEditingController();
  String? _durasiGoals;
  final List<String> _durasiOptions = [
    '1 bulan',
    '3 bulan',
    '6 bulan',
    '1 tahun'
  ];
  bool _isLoading = false;
  String _namaTabunganBersama = '';
  bool _termsAccepted = false;

  // Data Tabungan
  late String _creationDate;
  late String _member; // ID Member (nomor rekening)
  final String _goalsType = 'Tabungan Bersama';
  final double _saldoTabungan = 0.0;
  final String _statusTabungan = 'Tidak Aktif';
  final double _progressTabungan = 0.0;
  double? _targetSaldoTabungan;
  // final String? _durasiTabungan = null;
  final List _historiTransaksi = [];

  final Account _dummyAccountData = Account(
    nomorRekening: '0123456789012',
    namaRekening: "ABI",
  );

  @override
  void initState() {
    super.initState();
    _creationDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _member = _dummyAccountData.nomorRekening;
  }

  String _formatCurrency(String value) {
    if (value.isEmpty) return '';
    final formatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    try {
      final parsedValue = int.parse(value.replaceAll(RegExp(r'[^0-9]'), ''));
      return formatter.format(parsedValue);
    } catch (e) {
      return value;
    }
  }

  Future<void> _submitToDatabase() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Simulasi pengiriman data ke database
      await Future.delayed(const Duration(seconds: 1));

      // Data Tabungan yang akan disimpan ke database
      final Map<String, dynamic> dataTabunganBersama = {
        'goalsName': _namaTabunganBersama,
        'goalsType': _goalsType,
        'creationDate': _creationDate,
        'member': _member,
        'saldoTabungan': _saldoTabungan,
        'statusTabungan': _statusTabungan,
        'progressTabungan': _progressTabungan,
        'targetSaldoTabungan': _targetSaldoTabungan,
        'durasiTabungan': _durasiGoals,
        'historiTransaksi': _historiTransaksi,
        'members': [_dummyAccountData.namaRekening],
      };
      setState(() {
        _isLoading = false;
      });

      // Navigasi ke OurGoals setelah tabungan berhasil dibuat
      _navigateToOurGoals();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Gagal mengirim data, coba lagi. Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToOurGoals() async {
    if (!_isLoading) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildSuccessDialog(
          icon: Icons.check_circle_outline,
          iconColor: Colors.green,
          namaTabunganBersama: _namaTabunganBersama,
        );
      },
    );
  }

  Widget _buildSuccessDialog({
    required IconData icon,
    required Color iconColor,
    required String namaTabunganBersama,
  }) {
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
            const SizedBox(height: 10),
            const Text(
              'Berhasil!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tabungan Bersama \n"$namaTabunganBersama" \n telah berhasil dibuat',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OurGoals(),
                    ),
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
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaTabunganController.dispose();
    _nominalGoalsController.dispose();
    super.dispose();
  }

  void _showTermsAndConditions() {
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
                      _buildTermsTitle(),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: _buildTermsText(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTermsCheckbox(setModalState),
                      const SizedBox(height: 12),
                      _buildCreateButton(),
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

  Widget _buildTermsTitle() {
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

  Widget _buildTermsText() {
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

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _termsAccepted
            ? () async {
                Navigator.pop(context);
                await _submitToDatabase();
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
          'Buat Tabungan Bersama',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
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
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Text(
              'Buat Tabungan Bersama Baru',
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
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nama Tabungan Bersama",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _namaTabunganController,
                    decoration: InputDecoration(
                      fillColor: Colors.blue.shade50,
                      filled: true,
                      hintText: 'Buat Nama Tabungan Bersama',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Mohon isi Nama Tabungan Bersama';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _namaTabunganBersama = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Nominal Tabungan Bersama",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _nominalGoalsController,
                    decoration: InputDecoration(
                      fillColor: Colors.blue.shade50,
                      filled: true,
                      hintText: 'Tentukan Nominal Tabungan Bersama',
                      helperText: 'Nominal minimal adalah Rp 5.000.000',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        return newValue.copyWith(
                          text: _formatCurrency(newValue.text),
                          selection: TextSelection.collapsed(
                              offset: _formatCurrency(newValue.text).length),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        try {
                          if (value.isNotEmpty) {
                            final nominal = double.parse(
                                value.replaceAll(RegExp(r'[^0-9]'), ''));

                            _targetSaldoTabungan = nominal;
                          } else {
                            _targetSaldoTabungan = null;
                          }
                        } catch (e) {
                          debugPrint("Error parsing nominal: $e");
                        }
                      });
                    },
                    validator: (value) {
                      try {
                        if (value == null || value.isEmpty) {
                          return 'Nominal tabungan tidak boleh kosong';
                        }
                        final nominal = double.parse(
                            value.replaceAll(RegExp(r'[^0-9]'), ''));
                        if (nominal < 5000000) {
                          return 'Nominal minimal adalah Rp 5.000.000';
                        }
                      } catch (e) {
                        return 'Input tidak valid, masukkan angka saja';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Target Goals (Durasi)",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _durasiGoals,
                    hint: const Text('Tentukan Target Goals'),
                    dropdownColor: Colors.blue.shade50,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      fillColor: Colors.blue.shade50,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: _durasiOptions
                        .map((durasi) => DropdownMenuItem(
                              value: durasi,
                              child: Text(durasi),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _durasiGoals = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Mohon pilih Durasi Goals';
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
                          _showTermsAndConditions();
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
                    color: Theme.of(context).textTheme.bodyMedium?.color,
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
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.yellow.shade700),
              ),
            ),
          ),
      ],
    );
  }
}
