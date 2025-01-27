// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:convert'; // Import untuk encoding dan decoding JSON

import 'package:digigoals_app/TabunganBersama/DetailTabunganBersama.dart'; // Import halaman DetailTabunganBersama
import 'package:digigoals_app/api/api_config.dart'; // Import konfigurasi API
import 'package:digigoals_app/auth/token_manager.dart'; // Import Token Manager untuk otentikasi
import 'package:flutter/material.dart'; // Import library Flutter Material Design
import 'package:flutter/services.dart'; // Import untuk input formatters
import 'package:provider/provider.dart'; // Import Provider untuk state management
import 'package:http/http.dart'
    as http; // Import library HTTP untuk request API

// Model Account untuk data akun yang diundang
class Account {
  final String nomorRekening;
  final String namaRekening;
  final String jenisTabungan;
  final String userId; // User ID dari akun yang diundang

  Account({
    required this.nomorRekening,
    required this.namaRekening,
    required this.jenisTabungan,
    required this.userId,
  });

  // Factory constructor untuk membuat objek Account dari JSON
  factory Account.fromJson(Map<String, dynamic> json) {
    final accountData =
        json['accounts'][0]; // Asumsi akun pertama adalah yang relevan
    return Account(
      userId: json['id'],
      nomorRekening: accountData['account_number'],
      namaRekening: json['customer']['name'],
      jenisTabungan: accountData['account_type'],
    );
  }
}

// Widget Utama Halaman Undang Anggota Bersama
class UndangAnggotaBersama extends StatefulWidget {
  final String savingGroupId; // ID Saving Group dari halaman sebelumnya
  final String goalsName; // Nama Goals dari halaman sebelumnya

  const UndangAnggotaBersama({
    super.key,
    required this.savingGroupId,
    required this.goalsName,
  });

  @override
  _UndangAnggotaBersamaState createState() => _UndangAnggotaBersamaState();
}

// State Provider untuk Mengelola State Halaman Undang Anggota Bersama
class UndangAnggotaBersamaStateProvider extends ChangeNotifier {
  String nomorRekening = ''; // State untuk nomor rekening yang diinput
  bool isLoading = false; // State untuk indikator loading
  String? errorMessage; // State untuk pesan error
  Account? invitedAccount; // State untuk data akun yang diundang

  final TokenManager _tokenManager =
      TokenManager(); // Instance TokenManager untuk otentikasi

  // Fungsi untuk memperbarui state nomor rekening
  void updateNomorRekening(String value) {
    nomorRekening = value;
    notifyListeners(); // Beritahu listener (UI) bahwa state telah berubah
  }

  // Fungsi untuk mengatur state loading
  void setLoading(bool value) {
    isLoading = value;
    notifyListeners(); // Beritahu listener (UI) bahwa state telah berubah
  }

  // Fungsi untuk mengambil data akun berdasarkan nomor rekening dari API
  Future<void> getAccountByAccountNumber() async {
    setLoading(true); // Set loading state menjadi true
    errorMessage = null; // Reset pesan error
    invitedAccount = null; // Reset data akun yang diundang
    notifyListeners(); // Beritahu listener (UI) bahwa state telah berubah

    String? token =
        await _tokenManager.getToken(); // Ambil token dari TokenManager
    if (token == null) {
      errorMessage =
          "Token tidak ditemukan"; // Set pesan error jika token tidak ada
      setLoading(false); // Set loading state menjadi false
      notifyListeners(); // Beritahu listener (UI) bahwa state telah berubah
      return;
    }

    final String accountNumber =
        nomorRekening; // Ambil nomor rekening dari state
    final String accountEndpoint =
        "/users/accounts/$accountNumber"; // Endpoint API untuk akun berdasarkan nomor rekening
    final String apiUrl =
        baseUrl + accountEndpoint; // Gabungkan base URL dan endpoint

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token'
        }, // Sertakan token di header otorisasi
      );

      if (response.statusCode == 200) {
        final responseData = json
            .decode(utf8.decode(response.bodyBytes)); // Decode response body
        if (responseData['code'] == 200 && responseData['status'] == 'OK') {
          invitedAccount = Account.fromJson(
              responseData['data']); // Parse data akun dari JSON
        } else {
          errorMessage = responseData['errors'] != null &&
                  (responseData['errors'] as List).isNotEmpty
              ? (responseData['errors'] as List)[0]
                  .toString() // Ambil pesan error dari API response
              : "Akun tidak ditemukan"; // Pesan error default jika tidak ada pesan spesifik dari API
        }
      } else {
        errorMessage =
            "Gagal mengambil data akun. Status code: ${response.statusCode}"; // Set pesan error dengan status code
      }
    } catch (e) {
      errorMessage =
          "Terjadi kesalahan: ${e.toString()}"; // Set pesan error jika terjadi exception
    } finally {
      setLoading(
          false); // Set loading state menjadi false setelah proses selesai (berhasil atau gagal)
      notifyListeners(); // Beritahu listener (UI) bahwa state telah berubah
    }
  }
}

// State Widget untuk UI Halaman Undang Anggota Bersama
class _UndangAnggotaBersamaState extends State<UndangAnggotaBersama> {
  final _formKey = GlobalKey<FormState>(); // Key untuk form validasi

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          UndangAnggotaBersamaStateProvider(), // Provide state provider
      child: Consumer<UndangAnggotaBersamaStateProvider>(
        builder: (context, state, _) => Stack(
          children: [
            Scaffold(
              appBar: _buildAppBar(context), // AppBar kustom
              body: _buildBody(context, state), // Body halaman
              bottomNavigationBar: _buildBottomNavigationBar(
                  context, state), // Bottom navigation bar
            ),
            if (state.isLoading)
              _buildLoadingOverlay(), // Loading overlay ditampilkan saat isLoading true
          ],
        ),
      ),
    );
  }

  // AppBar Widget
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
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
          Navigator.pop(context); // Navigasi kembali ke halaman sebelumnya
        },
      ),
      title: const Text(
        'Undang Anggota',
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
    );
  }

  // Body Widget Halaman Undang Anggota
  Widget _buildBody(
      BuildContext context, UndangAnggotaBersamaStateProvider state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nomor Rekening Yang Diundang",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              keyboardType: TextInputType.number, // Keyboard type number
              inputFormatters: [
                FilteringTextInputFormatter
                    .digitsOnly, // Hanya menerima input angka
                LengthLimitingTextInputFormatter(
                    13), // Batasan panjang input 13 digit
              ],
              decoration: InputDecoration(
                fillColor: Colors.blue.shade50, // Warna fill input
                filled: true, // Input terisi warna
                hintText: 'Masukkan Nomor Rekening', // Hint text
                errorText: state.errorMessage, // Pesan error dari state
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none, // Hilangkan border
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kamu perlu memasukkan nomor rekening!'; // Validasi tidak boleh kosong
                }
                return null; // Validasi berhasil
              },
              onChanged: (value) => state.updateNomorRekening(
                  value), // Update state nomor rekening saat input berubah
            ),
          ],
        ),
      ),
    );
  }

  // Bottom Navigation Bar Widget
  Widget _buildBottomNavigationBar(
      BuildContext context, UndangAnggotaBersamaStateProvider state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: state.isLoading
              ? null // Disable button saat loading
              : () async {
                  if (_formKey.currentState!.validate()) {
                    // Validasi form sebelum memanggil API
                    await state
                        .getAccountByAccountNumber(); // Panggil fungsi ambil akun berdasarkan nomor rekening
                    if (state.invitedAccount != null) {
                      // Jika akun ditemukan, navigasi ke halaman konfirmasi undangan
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => KonfirmasiUndanganBersama(
                            invitedAccount: state.invitedAccount!,
                            goalsName: widget.goalsName,
                            savingGroupId: widget.savingGroupId,
                          ),
                        ),
                      );
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
    );
  }

  // Loading Overlay Widget
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow.shade700),
        ),
      ),
    );
  }
}

// Widget Konfirmasi Undangan Bersama
class KonfirmasiUndanganBersama extends StatefulWidget {
  final Account invitedAccount; // Data akun yang diundang
  final String goalsName; // Nama Goals dari halaman sebelumnya
  final String savingGroupId; // ID Saving Group dari halaman sebelumnya

  const KonfirmasiUndanganBersama({
    super.key,
    required this.invitedAccount,
    required this.goalsName,
    required this.savingGroupId,
  });

  @override
  _KonfirmasiUndanganBersamaState createState() =>
      _KonfirmasiUndanganBersamaState();
}

class _KonfirmasiUndanganBersamaState extends State<KonfirmasiUndanganBersama> {
  bool _isLoading = false; // State untuk indikator loading dialog
  final TokenManager _tokenManager =
      TokenManager(); // Instance TokenManager untuk otentikasi

  // Fungsi untuk mengirim undangan ke API
  Future<void> _sendInvitation() async {
    setState(() {
      _isLoading = true; // Set loading menjadi true
    });
    _showLoadingDialog(); // Tampilkan loading dialog

    String? token =
        await _tokenManager.getToken(); // Ambil token dari TokenManager
    String? senderUserId = await _tokenManager
        .getUserId(); // Ambil user ID pengirim dari TokenManager

    if (token == null || senderUserId == null) {
      Navigator.of(context).pop(); // Tutup loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Sesi tidak valid, mohon login kembali.'), // SnackBar error token tidak valid
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String invitationEndpoint =
        "/invitations"; // Endpoint API untuk undangan
    final String apiUrl =
        baseUrl + invitationEndpoint; // Gabungkan base URL dan endpoint

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization':
              'Bearer $token', // Sertakan token di header otorisasi
          'Content-Type': 'application/json', // Content type JSON
        },
        body: jsonEncode({
          "saving_group_id": widget.savingGroupId, // ID saving group
          "sender_user_id": senderUserId, // User ID pengirim
          "receiver_user_id":
              widget.invitedAccount.userId, // User ID penerima undangan
        }),
      );

      Navigator.of(context)
          .pop(); // Tutup loading dialog setelah request selesai

      if (response.statusCode == 201) {
        _showSuccessDialog(); // Tampilkan dialog sukses jika status code 201 (Created)
      } else {
        Navigator.of(context)
            .pop(); // Tutup loading dialog jika status code bukan 201
        final responseData = json
            .decode(utf8.decode(response.bodyBytes)); // Decode response body
        String message;
        if (responseData['errors'] != null) {
          if (responseData['errors'] is List) {
            message = (responseData['errors'] as List).isNotEmpty
                ? (responseData['errors'] as List)[0]
                    .toString() // Ambil pesan error pertama dari list error
                : "Gagal mengundang anggota, silahkan coba lagi!"; // Pesan error default
          } else if (responseData['errors'] is String) {
            message = responseData['errors']
                as String; // Gunakan pesan error string langsung
          } else {
            message =
                "Gagal mengundang anggota, silahkan coba lagi!"; // Pesan error fallback
          }
        } else {
          message =
              "Gagal mengundang anggota, silahkan coba lagi!"; // Pesan error fallback jika tidak ada errors di response
        }
        _showFailedDialog(message); // Tampilkan dialog gagal dengan pesan error
      }
    } catch (e) {
      Navigator.of(context)
          .pop(); // Tutup loading dialog jika terjadi exception
      _showFailedDialog(
          e.toString()); // Tampilkan dialog gagal dengan pesan exception
    } finally {
      setState(() {
        _isLoading = false; // Set loading state menjadi false
      });
    }
  }

  // Dialog Konfirmasi Undang Anggota
  void _showConfirmationDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dialog",
      transitionDuration: const Duration(milliseconds: 200),
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'DIGI Mobile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Apakah Benar Anda Ingin Mengundang ${widget.invitedAccount.namaRekening}?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 40,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context); // Tutup dialog konfirmasi
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.yellow.shade700),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Tidak',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 100,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            _sendInvitation(); // Panggil fungsi kirim undangan
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
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Dialog Loading saat Mengirim Undangan
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
                    'Mengundang Anggota...',
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

  // Dialog Sukses Undang Anggota
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
              borderRadius: BorderRadius.circular(0),
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
                    'Undang Anggota Telah Berhasil dilakukan!',
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
                        Navigator.pop(context); // Close success dialog
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailTabunganBersama(
                                savingGroupId: widget
                                    .savingGroupId), // Navigasi ke DetailTabunganBersama
                            settings: const RouteSettings(arguments: {
                              'invitationSuccess': true
                            }), // Kirim argumen sukses undangan
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

  // Dialog Gagal Undang Anggota
  void _showFailedDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Gagal'),
        content: Text(
            'Gagal mengundang anggota: $message'), // Tampilkan pesan error dari parameter
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog gagal
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue.shade700,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(
                  context), // Navigasi kembali ke halaman sebelumnya
            ),
            title: const Text(
              'Konfirmasi Undangan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue.shade700, Colors.blue.shade400],
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.group,
                        color: Colors.blue.shade700,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nomor Rekening: ${widget.invitedAccount.nomorRekening}', // Tampilkan nomor rekening akun yang diundang
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Nama Goals: ${widget.goalsName}', // Tampilkan nama goals
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(
                            context); // Navigasi kembali ke halaman undang anggota
                      },
                      icon:
                          const Icon(Icons.edit, color: Colors.white, size: 16),
                      label: const Text(
                        'Ubah',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tabungan ${widget.invitedAccount.jenisTabungan} - ${widget.invitedAccount.nomorRekening}', // Info jenis tabungan dan nomor rekening
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF4F6D85)),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          widget.invitedAccount
                              .namaRekening, // Tampilkan nama rekening
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _showConfirmationDialog, // Button konfirmasi undang anggota
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Konfirmasi Undang Anggota',
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
            color: Colors.black54,
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.yellow.shade700,
              ),
            ),
          ),
      ],
    );
  }
}

// Loading Overlay Widget (Reusable dari file lain)
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow.shade700),
        ),
      ),
    );
  }
}
