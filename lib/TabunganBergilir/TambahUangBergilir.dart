import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show NumberFormat;

class TambahUangBergilir extends StatefulWidget {
  const TambahUangBergilir({super.key});

  @override
  _TambahUangBergilirState createState() => _TambahUangBergilirState();
}

class _TambahUangBergilirState extends State<TambahUangBergilir> {
  final _formKey = GlobalKey<FormState>();
  final _nominalController = TextEditingController();
  final _waktuTransaksiController = TextEditingController(text: 'Sekarang');
  bool isTodayEnabled = true;
  bool isWeeklyEnabled = false;
  bool isDateEnabled = false;
  bool isSpecificDateEnabled = false;
  String? _selectedWeek;
  DateTime? _selectedDate;
  DateTime? _selectedSpecificDate;

  @override
  void dispose() {
    _nominalController.dispose();
    _waktuTransaksiController.dispose();
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

  void _showWaktuTransaksiModal() {
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
                        flex: 8,
                        child: Text('Sekarang', style: TextStyle(fontSize: 16)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Switch(
                          value: isTodayEnabled,
                          activeColor: Colors.yellow,
                          activeTrackColor: Colors.yellow.shade700,
                          inactiveTrackColor: Colors.grey,
                          onChanged: (value) {
                            setModalState(() {
                              isTodayEnabled = value;
                              if (isTodayEnabled) {
                                isDateEnabled = false;
                                isWeeklyEnabled = false;
                                isSpecificDateEnabled = false;
                                _waktuTransaksiController.text = 'Sekarang';
                              }
                            });
                            setState(() {
                              isTodayEnabled = value;
                              if (isTodayEnabled) {
                                isDateEnabled = false;
                                isWeeklyEnabled = false;
                                isSpecificDateEnabled = false;
                                _waktuTransaksiController.text = 'Sekarang';
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
                        child: Text('Pilih', style: TextStyle(fontSize: 16)),
                      ),
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: TextFormField(
                            controller: TextEditingController(
                                text: isSpecificDateEnabled &&
                                        _selectedSpecificDate != null
                                    ? _selectedSpecificDate!
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
                            onTap: isSpecificDateEnabled
                                ? () async {
                                    DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime(DateTime.now().year,
                                          DateTime.now().month),
                                      firstDate: DateTime(DateTime.now().year,
                                          DateTime.now().month),
                                      lastDate: DateTime(2101),
                                    );
                                    if (picked != null) {
                                      setModalState(() {
                                        _selectedSpecificDate = picked;
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
                          value: isSpecificDateEnabled,
                          activeColor: Colors.yellow,
                          activeTrackColor: Colors.yellow.shade700,
                          inactiveTrackColor: Colors.grey,
                          onChanged: (value) {
                            setModalState(() {
                              isSpecificDateEnabled = value;
                              if (isSpecificDateEnabled) {
                                isWeeklyEnabled = false;
                                isTodayEnabled = false;
                                isDateEnabled = false;
                              }
                            });
                            setState(() {
                              isSpecificDateEnabled = value;
                              if (isSpecificDateEnabled) {
                                isWeeklyEnabled = false;
                                isTodayEnabled = false;
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
                                isTodayEnabled = false;
                                isSpecificDateEnabled = false;
                              }
                            });
                            setState(() {
                              isWeeklyEnabled = value;
                              if (isWeeklyEnabled) {
                                isDateEnabled = false;
                                isTodayEnabled = false;
                                isSpecificDateEnabled = false;
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
                                isTodayEnabled = false;
                                isSpecificDateEnabled = false;
                              }
                            });
                            setState(() {
                              isDateEnabled = value;
                              if (isDateEnabled) {
                                isWeeklyEnabled = false;
                                isTodayEnabled = false;
                                isSpecificDateEnabled = false;
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
                            _waktuTransaksiController.text =
                                '${_selectedWeek!} dari tanggal hari ini: ${calculatedDate.toLocal().toString().split(' ')[0]}';
                          } else if (isDateEnabled && _selectedDate != null) {
                            _waktuTransaksiController.text = _selectedDate!
                                .toLocal()
                                .toString()
                                .split(' ')[0];
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
          'Tambah Uang',
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
                  "Nominal Tambah Uang",
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
                    hintText: 'Tentukan Nominal Tambah Uang',
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
                  validator: (value) {
                    try {
                      if (value == null || value.isEmpty) {
                        return 'Nominal Tambah Uang tidak boleh kosong';
                      }
                    } catch (e) {
                      return 'Input tidak valid, masukkan angka saja';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16),
                // Waktu Transaksi
                Text(
                  "Waktu Transaksi",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _waktuTransaksiController,
                  decoration: InputDecoration(
                    fillColor: Colors.blue.shade50,
                    filled: true,
                    hintText: 'Sekarang',
                    suffixIcon: Icon(Icons.edit_calendar),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  readOnly: true,
                  onTap: _showWaktuTransaksiModal,
                ),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => _KonfirmasiTambahUangBergilir(
                            nominal: _nominalController.text,
                            waktuTransaksi: _waktuTransaksiController.text,
                          )),
                );
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

class _KonfirmasiTambahUangBergilir extends StatelessWidget {
  final String nominal;
  final String waktuTransaksi;

  const _KonfirmasiTambahUangBergilir({
    required this.nominal,
    required this.waktuTransaksi,
  });

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
          'Konfirmasi Tambah Uang',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Text(
              "Konfirmasi Tambah Uang",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Nominal",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  nominal,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Waktu Transaksi",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  waktuTransaksi,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Tambah Uang Berhasil!"),
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    'Konfirmasi',
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
