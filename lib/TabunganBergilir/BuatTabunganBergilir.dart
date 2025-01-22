// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:convert';
import 'package:digigoals_app/api/api_config.dart';
import 'package:digigoals_app/auth/token_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BuatTabunganBergilir extends StatefulWidget {
  const BuatTabunganBergilir({super.key});

  @override
  _BuatTabunganBergilirState createState() => _BuatTabunganBergilirState();
}

class _BuatTabunganBergilirState extends State<BuatTabunganBergilir> {
  final _formKey = GlobalKey<FormState>();
  final _namaTabunganBergilirController = TextEditingController();
  bool _termsAccepted = false;
  String _namaTabunganBergilir = '';
  final TokenManager _tokenManager = TokenManager();
  String? _goalType;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Menerima goalType dari argument
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String) {
      _goalType = args;
    }
  }

  Future<void> _submitToApi() async {
    if (!_formKey.currentState!.validate() || !_termsAccepted) {
      return; // Stop if form is invalid or terms not accepted
    }

    _namaTabunganBergilir = _namaTabunganBergilirController.text;

    _showLoadingDialog(context);

    try {
      final token = await _tokenManager.getToken();
      if (token == null) {
        throw Exception("Token tidak ditemukan");
      }

      // Konfigurasi Endpoint API
      const String createGoalsEndpoint = "/api/v1/rotating-saving-groups";
      final String apiUrl = baseUrl + createGoalsEndpoint;

      // Payload API
      final Map<String, dynamic> bodyData = {
        'name': _namaTabunganBergilir,
        'type': _goalType,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context); // Tutup Loading Dialog
        _showSuccessDialog();
      } else {
        Navigator.pop(context); // Tutup Loading Dialog
        final Map<String, dynamic> responseData = json.decode(response.body);
        throw Exception(
            "Gagal membuat tabungan bergilir. Status Code: ${response.statusCode}, Error: ${responseData['errors'] != null && (responseData['errors'] as List).isNotEmpty ? (responseData['errors'] as List)[0].toString() : 'Terjadi Kesalahan'}");
      }
    } catch (e) {
      Navigator.pop(context); // Tutup Loading Dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Gagal mengirim data, coba lagi. Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildSuccessDialog(
          icon: Icons.check_circle_outline,
          iconColor: Colors.green,
          namaTabunganBergilir: _namaTabunganBergilir,
        );
      },
    );
  }

  Widget _buildSuccessDialog({
    required IconData icon,
    required Color iconColor,
    required String namaTabunganBergilir,
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
              'Tabungan Bergilir \n"$namaTabunganBergilir" \n telah berhasil dibuat',
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
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.pushNamed(context, '/ourGoals');
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
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _termsAccepted
                              ? () {
                                  Navigator.pop(context);
                                  _submitToApi();
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
                            'Buat Tabungan Bergilir',
                            style: TextStyle(
                              color: _termsAccepted
                                  ? Colors.blue.shade800
                                  : Colors.black, // Ubah warna teks di sini
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

  Widget _buildTermsTitle() {
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

  Widget _buildTermsText() {
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

  Future<void> _showLoadingDialog(BuildContext context) async {
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
  }

  @override
  void dispose() {
    _namaTabunganBergilirController.dispose();
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          tooltip: 'Kembali',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
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
                "Nama Tabungan Bergilir",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _namaTabunganBergilirController,
                decoration: InputDecoration(
                  fillColor: Colors.blue.shade50,
                  filled: true,
                  hintText: 'Buat Nama Tabungan Bergilir',
                  hintStyle: const TextStyle(color: Colors.black54),
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
                onChanged: (value) {
                  _namaTabunganBergilir = value;
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
            onPressed: () {
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
                color: Colors.blue.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
