// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:digigoals_app/TabunganBergilir/DetailTabunganBergilir.dart';
import 'package:digigoals_app/api/api_config.dart';
import 'package:digigoals_app/auth/token_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import 'package:http/http.dart' as http;

class AktivasiTabunganBergilir extends StatefulWidget {
  final List<String> allMembers;
  final String savingGroupId;
  const AktivasiTabunganBergilir(
      {super.key, required this.allMembers, required this.savingGroupId});

  @override
  _AktivasiTabunganBergilirState createState() =>
      _AktivasiTabunganBergilirState();
}

class _AktivasiTabunganBergilirState extends State<AktivasiTabunganBergilir> {
  final _formKey = GlobalKey<FormState>();
  final _nominalController = TextEditingController();
  late final TextEditingController _jumlahAnggotaController;
  final _durasiTabunganController = TextEditingController();
  final _periodeTabunganController = TextEditingController();
  final _jumlahPenagihanController = TextEditingController();
  bool isWeeklyEnabled = false;
  bool isDateEnabled = false;
  String? _selectedWeek;
  DateTime? _selectedDate;
  bool _termsAccepted = false; // State untuk checkbox terms & conditions
  final TokenManager _tokenManager = TokenManager();

  @override
  void initState() {
    super.initState();
    _jumlahAnggotaController =
        TextEditingController(text: widget.allMembers.length.toString());
  }

  @override
  void dispose() {
    _nominalController.dispose();
    _jumlahAnggotaController.dispose();
    _durasiTabunganController.dispose();
    _periodeTabunganController.dispose();
    _jumlahPenagihanController.dispose();
    super.dispose();
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

  void _updateDurasiTabungan() {
    setState(() {
      int anggota = int.parse(_jumlahAnggotaController.text);
      if (isWeeklyEnabled && _selectedWeek != null) {
        int weeks = int.parse(_selectedWeek!.split(' ')[0]);
        _durasiTabunganController.text = '${anggota * weeks} minggu';
      } else if (isDateEnabled && _selectedDate != null) {
        _durasiTabunganController.text =
            '$anggota bulan (estimasi)'; // Adjust text if needed based on date selection
      } else {
        _durasiTabunganController.text = '$anggota bulan';
      }
    });
  }

  // Fungsi untuk mengirim data ke API
  Future<void> _submitDataToAPI() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_termsAccepted) {
      _showErrorDialog(
          'Anda harus menyetujui Syarat & Ketentuan untuk melanjutkan.');
      return;
    }

    String? token = await _tokenManager.getToken();
    if (token == null) {
      _showErrorDialog('Token tidak ditemukan, mohon login kembali.');
      return;
    }

    String periodType;
    String? firstDueDate;

    if (isWeeklyEnabled && _selectedWeek != null) {
      int weeks = int.parse(_selectedWeek!.split(' ')[0]);
      if (weeks == 1) {
        periodType = 'WEEKLY';
      } else if (weeks == 2) {
        periodType = 'BI_WEEKLY';
      } else if (weeks == 3) {
        periodType = 'TRI_WEEKLY';
      } else {
        periodType =
            'MONTHLY'; // 4 weeks or more, treat as monthly for period type
      }

      // Calculate first due date based on selected weeks from today
      DateTime now = DateTime.now();
      DateTime calculatedDate = now.add(Duration(days: 7 * weeks));
      firstDueDate = DateFormat('yyyy-MM-dd').format(calculatedDate);
    } else if (isDateEnabled && _selectedDate != null) {
      periodType = 'CUSTOM';
      firstDueDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    } else {
      periodType =
          'MONTHLY'; // Default to monthly if no specific period is selected
      // Calculate first due date for monthly (approximately 1 month from today)
      DateTime now = DateTime.now();
      DateTime calculatedDate = DateTime(now.year, now.month + 1, now.day);
      firstDueDate = DateFormat('yyyy-MM-dd').format(calculatedDate);
    }

    final Map<String, dynamic> requestBody = {
      'period_type': periodType,
      'first_due_date': firstDueDate,
      'target_amount':
          int.parse(_nominalController.text.replaceAll(RegExp(r'[^0-9]'), '')),
    };

    final url = Uri.parse(
        '$baseUrl/saving-groups/rotating/${widget.savingGroupId}/activate');

    try {
      _showLoadingDialog();
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context); // Close loading dialog
        _showSuccessDialog();
      } else {
        Navigator.pop(context); // Close loading dialog
        final responseData = json.decode(response.body);
        String errorMessage = 'Gagal mengaktifkan Tabungan Bergilir.';
        if (responseData != null && responseData['errors'] != null) {
          errorMessage = responseData['errors'].toString();
        }
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorDialog('Terjadi kesalahan: ${e.toString()}');
    }
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
      'Syarat & Ketentuan Aktivasi Tabungan Bergilir',
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

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _termsAccepted
            ? () async {
                Navigator.pop(context);
                await _submitDataToAPI();
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
          'Aktivasi Tabungan Bergilir',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showLoadingDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Loading",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: Tween(begin: 0.7, end: 1.0).animate(animation),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              width: 250,
              height: 250,
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.yellow.shade700),
                  const SizedBox(height: 20),
                  const Text(
                    'Mengaktifkan Tabungan...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Success",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              width: 250,
              height: 250,
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'DIGI Mobile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 48,
                  ),
                  const Text(
                    'Aktivasi Tabungan Berhasil Dilakukan!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 37,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context)
                            .pop(); // Pop AktivasiTabunganBergilir page
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => DetailTabunganBergilir(
                              savingGroupId: widget.savingGroupId,
                              isActive: true, // Indicate that it's now active
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
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPeriodePenagihanModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        flex: 3,
                        child: Text('Setiap', style: TextStyle(fontSize: 16)),
                      ),
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: DropdownButtonFormField<String>(
                            value: isWeeklyEnabled ? _selectedWeek : null,
                            items:
                                ['1 Minggu', '2 Minggu', '3 Minggu', '4 Minggu']
                                    .map((week) => DropdownMenuItem(
                                          value: week,
                                          child: Text(week),
                                        ))
                                    .toList(),
                            onChanged: isWeeklyEnabled
                                ? (value) {
                                    setModalState(() {
                                      _selectedWeek = value;
                                    });
                                    _updateDurasiTabungan();
                                  }
                                : null,
                            decoration: InputDecoration(
                              fillColor: Colors.blue.shade50,
                              filled: true,
                              hintText: 'Pilih Periode',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Switch(
                          value: isWeeklyEnabled,
                          activeColor: Colors.yellow,
                          activeTrackColor: Colors.yellow.shade700,
                          inactiveTrackColor: Colors.grey,
                          onChanged: (value) {
                            setModalState(() {
                              isWeeklyEnabled = value;
                              if (isWeeklyEnabled) {
                                isDateEnabled = false;
                                _selectedDate =
                                    null; // Reset selected date when switching to weekly
                              }
                            });
                            setState(() {
                              isWeeklyEnabled = value;
                              if (isWeeklyEnabled) {
                                isDateEnabled = false;
                                _selectedDate =
                                    null; // Reset selected date when switching to weekly
                              }
                              _updateDurasiTabungan();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        flex: 3,
                        child: Text('Setiap Tanggal',
                            style: TextStyle(fontSize: 16)),
                      ),
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: TextFormField(
                            controller: TextEditingController(
                                text: isDateEnabled && _selectedDate != null
                                    ? DateFormat('dd MMMM yyyy')
                                        .format(_selectedDate!)
                                    : ''),
                            decoration: InputDecoration(
                              fillColor: Colors.blue.shade50,
                              filled: true,
                              hintText: 'Atur Tanggal',
                              suffixIcon: const Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            readOnly: true,
                            onTap: isDateEnabled
                                ? () async {
                                    DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime(DateTime.now().year,
                                          DateTime.now().month + 1, 1),
                                      firstDate: DateTime(DateTime.now().year,
                                          DateTime.now().month + 1, 1),
                                      lastDate: DateTime(2101),
                                    );
                                    if (picked != null) {
                                      setModalState(() {
                                        _selectedDate = picked;
                                      });
                                    }
                                  }
                                : null,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Switch(
                          value: isDateEnabled,
                          activeColor: Colors.yellow,
                          activeTrackColor: Colors.yellow.shade700,
                          inactiveTrackColor: Colors.grey,
                          onChanged: (value) {
                            setModalState(() {
                              isDateEnabled = value;
                              if (isDateEnabled) {
                                isWeeklyEnabled = false;
                                _selectedWeek =
                                    null; // Reset selected week when switching to date
                              }
                            });
                            setState(() {
                              isDateEnabled = value;
                              if (isDateEnabled) {
                                isWeeklyEnabled = false;
                                _selectedWeek =
                                    null; // Reset selected week when switching to date
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          if (isWeeklyEnabled && _selectedWeek != null) {
                            int weeks = int.parse(_selectedWeek!.split(' ')[0]);
                            DateTime calculatedDate =
                                DateTime.now().add(Duration(days: 7 * weeks));
                            _periodeTabunganController.text =
                                '${_selectedWeek!} mulai ${DateFormat('dd MMMM yyyy').format(calculatedDate)}';
                          } else if (isDateEnabled && _selectedDate != null) {
                            _periodeTabunganController.text =
                                'Setiap tanggal ${DateFormat('dd MMMM yyyy').format(_selectedDate!)}';
                          } else {
                            _periodeTabunganController.text =
                                'Setiap Bulan'; // Default text if none selected
                          }

                          if (_nominalController.text.isNotEmpty &&
                              _jumlahAnggotaController.text.isNotEmpty) {
                            double nominal = double.parse(_nominalController
                                .text
                                .replaceAll(RegExp(r'[^0-9]'), ''));
                            int anggota =
                                int.parse(_jumlahAnggotaController.text);
                            _jumlahPenagihanController.text = _formatCurrency(
                                (nominal / anggota).toStringAsFixed(0));
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Simpan',
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
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
        toolbarHeight: 84,
        titleSpacing: 16,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Aktivasi Tabungan Bergilir',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nominal Tabungan Bergilir
                Text(
                  "Nominal Tabungan Bergilir",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nominalController,
                  decoration: InputDecoration(
                    fillColor: Colors.blue.shade50,
                    filled: true,
                    hintText: 'Tentukan Nominal Tabungan Bergilir',
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
                          offset: _formatCurrency(newValue.text).length,
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      try {
                        // Parsing angka dengan validasi tambahan
                        if (value.isNotEmpty &&
                            _jumlahAnggotaController.text.isNotEmpty) {
                          final nominal = double.parse(
                              value.replaceAll(RegExp(r'[^0-9]'), ''));
                          final anggota =
                              int.parse(_jumlahAnggotaController.text);

                          if (anggota > 0) {
                            _jumlahPenagihanController.text = _formatCurrency(
                                (nominal / anggota).toStringAsFixed(0));
                          }
                        }
                      } catch (e) {
                        // Menangani error parsing
                        debugPrint("Error parsing nominal: $e");
                        _jumlahPenagihanController.text = '';
                      }
                    });
                  },
                  validator: (value) {
                    try {
                      if (value == null || value.isEmpty) {
                        return 'Nominal tabungan tidak boleh kosong';
                      }
                      final nominal =
                          double.parse(value.replaceAll(RegExp(r'[^0-9]'), ''));
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
                // Periode & Tanggal Penagihan
                Text(
                  "Periode & Tanggal Penagihan",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _periodeTabunganController,
                  decoration: InputDecoration(
                    fillColor: Colors.blue.shade50,
                    filled: true,
                    hintText: 'Atur Periode Penagihan',
                    suffixIcon: const Icon(Icons.edit_calendar),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  readOnly: true,
                  onTap: _showPeriodePenagihanModal,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Periode Penagihan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Jumlah Anggota
                Text(
                  "Jumlah Anggota",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _jumlahAnggotaController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    fillColor: Colors.blue.shade50,
                    filled: true,
                    hintText: 'Jumlah Anggota',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 16),
                // Durasi Tabungan Bergilir
                Text(
                  "Durasi Tabungan Bergilir",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _durasiTabunganController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    fillColor: Colors.blue.shade50,
                    filled: true,
                    hintText: 'Durasi disesuaikan dengan jumlah anggota',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mohon isi Durasi Tabungan Bergilir';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Jumlah Penagihan Uang (Auto Debet)
                Text(
                  "Jumlah Penagihan Uang (Auto Debet)",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _jumlahPenagihanController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    fillColor: Colors.blue.shade50,
                    filled: true,
                    hintText: 'Nominal / Jumlah Anggota',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mohon isi Jumlah Penagihan Uang';
                    }
                    if (double.tryParse(
                            value.replaceAll(RegExp(r'[^0-9]'), '')) ==
                        null) {
                      return 'Mohon masukkan nominal yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
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
                color: Colors.blue.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
