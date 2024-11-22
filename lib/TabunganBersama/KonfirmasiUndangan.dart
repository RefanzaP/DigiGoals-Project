import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class KonfirmasiUndangan extends StatefulWidget {
  const KonfirmasiUndangan({super.key});

  @override
  _KonfirmasiUndanganState createState() => _KonfirmasiUndanganState();
}

class _KonfirmasiUndanganState extends State<KonfirmasiUndangan> {
  final _formKey = GlobalKey<FormState>();
  final _namaTabunganController = TextEditingController();

  // Function to show the pop-up dialog
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          child: Container(
            width: 318, // Width of the dialog
            height: 241, // Height of the dialog
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title in the middle
                Text(
                  'Digi Mobile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20), // Space between title and content
                // Content text
                Text(
                  'Apakah Benar Anda Ingin Mengundang UMMI?',
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
                    // Button "Tidak" with transparent background and yellow border
                    Container(
                      width: 100,
                      height: 37,
                      margin: const EdgeInsets.only(right: 8), // Space between buttons
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(
                            color: Colors.yellow.shade700, // Yellow border
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Tidak',
                          style: TextStyle(
                            color: Color(0XFF1F597F), // Yellow text color
                          ),
                        ),
                      ),
                    ),
                    // Button "Ya" (No changes to this button)
                    Container(
                      width: 100, // Set width of button
                      height: 37, // Set height of button
                      margin: const EdgeInsets.only(left: 8), // Space between buttons
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                          // Add your further action for "Ya" here
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
                            color: Color(0XFF1F597F), // Yellow text color
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(156),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade700, Colors.blue.shade400],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  SizedBox(height: 32), // Jarak dari atas layar
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Ikon panah kembali
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Spacer(),
                      // Judul "Undang Anggota"
                      Text(
                        'Undang Anggota',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Spacer(),
                      // Bulatan hijau
                      Container(
                        height: 12,
                        width: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16), // Jarak antara dua baris konten AppBar
                  // Baris untuk status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Ikon bundar
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: SvgPicture.asset(
                            'assets/icons/party-popper-svgrepo-com 1.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      // Teks atas dan bawah
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nomor Rekening : ',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Nama Goals : ',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Tombol di kanan
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Ubah',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w200,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tabungan Tandamata - 12345678",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue.shade900,
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 47,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Color(0xFF4F6D85),
                  ),
                ),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Ummi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
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
              _showConfirmationDialog(); // Show the dialog when pressed
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
