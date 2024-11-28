import 'package:digigoals_app/TabunganBergilir/AktifDetailTabunganBergilir.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show NumberFormat;

class AktivasiTabunganBergilir extends StatefulWidget {
  const AktivasiTabunganBergilir({super.key});

  @override
  _AktivasiTabunganBergilirState createState() =>
      _AktivasiTabunganBergilirState();
}

class _AktivasiTabunganBergilirState extends State<AktivasiTabunganBergilir> {
  final _formKey = GlobalKey<FormState>();
  final _nominalController = TextEditingController();
  final _jumlahAnggotaController = TextEditingController();
  final _durasiTabunganController = TextEditingController();
  final _periodeTabunganController = TextEditingController();
  final _jumlahPenagihanController = TextEditingController();
  bool isWeeklyEnabled = false;
  bool isDateEnabled = false;
  String? _selectedWeek;
  DateTime? _selectedDate;

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

  void _showConfirmationDialog() {
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
                  'Apakah Benar ingin Melakukan Aktivasi Tabungan Bergilir?',
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
                      margin: const EdgeInsets.only(right: 8),
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(
                            color: Colors.yellow.shade700,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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
                      margin: const EdgeInsets.only(left: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showSuccessDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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
  }

  void _showSuccessDialog() {
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
                  'Aktivasi Tabungan Bergilir Telah Berhasil di lakukan!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 37,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AktifDetailTabunganBergilir()),
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
                      Expanded(
                        flex: 3,
                        child: Text('Setiap', style: TextStyle(fontSize: 16)),
                      ),
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: EdgeInsets.only(right: 16.0),
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
                              }
                            });
                            setState(() {
                              isWeeklyEnabled = value;
                              if (isWeeklyEnabled) {
                                isDateEnabled = false;
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text('Setiap', style: TextStyle(fontSize: 16)),
                      ),
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: TextFormField(
                            controller: TextEditingController(
                                text: isDateEnabled && _selectedDate != null
                                    ? _selectedDate!
                                        .toLocal()
                                        .toString()
                                        .split(' ')[0]
                                    : ''),
                            decoration: InputDecoration(
                              fillColor: Colors.blue.shade50,
                              filled: true,
                              hintText: 'Atur Tanggal',
                              suffixIcon: Icon(Icons.calendar_today),
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
                              }
                            });
                            setState(() {
                              isDateEnabled = value;
                              if (isDateEnabled) {
                                isWeeklyEnabled = false;
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
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
                                '${_selectedWeek!} dari tanggal hari ini: ${calculatedDate.toLocal().toString().split(' ')[0]}';
                          } else if (isDateEnabled && _selectedDate != null) {
                            _periodeTabunganController.text = _selectedDate!
                                .toLocal()
                                .toString()
                                .split(' ')[0];
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
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
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
                SizedBox(height: 10),
                TextFormField(
                  controller: _nominalController,
                  decoration: InputDecoration(
                    fillColor: Colors.blue.shade50,
                    filled: true,
                    hintText: 'Tentukan Nominal Tabungan Bergilir',
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
                      if (_jumlahAnggotaController.text.isNotEmpty) {
                        int anggota = int.parse(_jumlahAnggotaController.text);
                        if (value.isNotEmpty &&
                            double.tryParse(
                                    value.replaceAll(RegExp(r'[^0-9]'), '')) !=
                                null) {
                          double nominal = double.parse(
                              value.replaceAll(RegExp(r'[^0-9]'), ''));
                          _jumlahPenagihanController.text = _formatCurrency(
                              (nominal / anggota).toStringAsFixed(0));
                        }
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mohon isi Nominal Tabungan Bergilir';
                    }
                    if (double.tryParse(
                            value.replaceAll(RegExp(r'[^0-9]'), '')) ==
                        null) {
                      return 'Mohon masukkan nominal yang valid';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Periode & Tanggal Penagihan
                Text(
                  "Periode & Tanggal Penagihan",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _periodeTabunganController,
                  decoration: InputDecoration(
                    fillColor: Colors.blue.shade50,
                    filled: true,
                    hintText: 'Atur Periode Penagihan',
                    suffixIcon: Icon(Icons.edit_calendar),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  readOnly: true,
                  onTap: _showPeriodePenagihanModal,
                ),
                SizedBox(height: 16),
                // Jumlah Anggota
                Text(
                  "Jumlah Anggota",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                SizedBox(height: 10),
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
                  onChanged: (value) {
                    setState(() {
                      if (isWeeklyEnabled &&
                          _selectedWeek != null &&
                          value.isNotEmpty) {
                        int weeks = int.parse(_selectedWeek!.split(' ')[0]);
                        int anggota = int.parse(value);
                        _durasiTabunganController.text =
                            '${weeks * anggota} minggu';
                      } else if (isDateEnabled &&
                          _selectedDate != null &&
                          value.isNotEmpty) {
                        int anggota = int.parse(value);
                        _durasiTabunganController.text = '${anggota} bulan';
                      } else {
                        _durasiTabunganController.text = '';
                      }
                      if (_nominalController.text.isNotEmpty) {
                        double nominal = double.parse(_nominalController.text
                            .replaceAll(RegExp(r'[^0-9]'), ''));
                        _jumlahPenagihanController.text = _formatCurrency(
                            (nominal / int.parse(value)).toStringAsFixed(0));
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mohon isi Jumlah Anggota';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Durasi Tabungan Bergilir
                Text(
                  "Durasi Tabungan Bergilir",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                SizedBox(height: 10),
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
                SizedBox(height: 16),
                // Jumlah Penagihan Uang (Auto Debet)
                Text(
                  "Jumlah Penagihan Uang (Auto Debet)",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _jumlahPenagihanController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                SizedBox(height: 16),
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
                _showConfirmationDialog();
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
