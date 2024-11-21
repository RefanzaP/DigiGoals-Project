import 'package:digigoals_app/TabunganBersama/DetailTabunganBersama.dart';
import 'package:flutter/material.dart';

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
                "Nama Tabungan Bersama",
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
              ),
              SizedBox(height: 16),
              Text(
                "Nominal Goals",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _nominalGoalsController,
                decoration: InputDecoration(
                  fillColor: Colors.blue.shade50,
                  filled: true,
                  hintText: 'Berapa Nominal Goals',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: _nominalGoalsController.text.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(
                              left: 12.0, right: 4.0, top: 8.0),
                          child: Text('Rp',
                              style: TextStyle(
                                  color: Colors.blue.shade900, fontSize: 16)),
                        )
                      : null,
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  setState(() {});
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon isi Nominal Goals';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Mohon masukkan nominal yang valid';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                "Target Goals (Durasi)",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _durasiGoals,
                hint: Text('Tentukan Target Goals'),
                dropdownColor: Colors.blue.shade50,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DetailTabunganBersama()));
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
