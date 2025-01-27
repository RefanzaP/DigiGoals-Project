// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:convert'; // Import untuk encoding dan decoding JSON, mengubah data JSON menjadi format lain dan sebaliknya
import 'package:digigoals_app/OurGoals.dart'; // Import halaman OurGoals, halaman utama yang menampilkan daftar goals
import 'package:digigoals_app/TabunganBersama/DetailKontribusiTabunganBersama.dart'; // Import halaman Detail Kontribusi Tabungan Bersama, halaman detail kontribusi anggota tabungan bersama
import 'package:digigoals_app/TabunganBersama/RincianAnggotaBersama.dart'; // Import halaman Rincian Anggota Bersama, halaman rincian informasi anggota tabungan bersama
import 'package:digigoals_app/TabunganBersama/TambahUangBersama.dart'; // Import halaman Tambah Uang Bersama, halaman untuk menambahkan uang ke tabungan bersama
import 'package:digigoals_app/TabunganBersama/TarikUangBersama.dart'; // Import halaman Tarik Uang Bersama, halaman untuk menarik uang dari tabungan bersama
import 'package:digigoals_app/TabunganBersama/UndangAnggotaBersama.dart'; // Import halaman Undang Anggota Bersama, halaman untuk mengundang anggota baru ke tabungan bersama
import 'package:digigoals_app/api/api_config.dart'; // Import konfigurasi API, berisi konstanta base URL API
import 'package:digigoals_app/auth/token_manager.dart'; // Import Token Manager untuk otentikasi, mengelola token JWT untuk otentikasi API
import 'package:flutter/material.dart'; // Import library Flutter Material Design, library dasar untuk membangun UI Flutter
import 'package:intl/intl.dart'; // Import library untuk format angka dan tanggal, untuk memformat mata uang dan tanggal
import 'package:shimmer/shimmer.dart'; // Import library Shimmer untuk efek loading, memberikan efek shimmer pada widget saat loading data
import 'package:http/http.dart'
    as http; // Import library HTTP untuk request API, library untuk melakukan HTTP request ke API

// Widget utama untuk halaman Detail Tabungan Bersama
class DetailTabunganBersama extends StatefulWidget {
  final String
      savingGroupId; // ID Saving Group yang diterima dari halaman sebelumnya, ID unik tabungan bersama yang detailnya akan ditampilkan

  const DetailTabunganBersama({super.key, required this.savingGroupId});

  @override
  State<DetailTabunganBersama> createState() => _DetailTabunganBersamaState();
}

// State class untuk DetailTabunganBersama
class _DetailTabunganBersamaState extends State<DetailTabunganBersama> {
  final TextEditingController cariTransaksiController =
      TextEditingController(); // Controller untuk input pencarian transaksi, mengontrol input field untuk mencari transaksi
  final TextEditingController _goalsNameController =
      TextEditingController(); // Controller untuk input nama goals (edit modal), mengontrol input field untuk mengubah nama goals di modal edit
  final GlobalKey<FormState> _formKey = GlobalKey<
      FormState>(); // Key untuk form validasi edit nama goals, key untuk form yang digunakan dalam modal edit nama goals untuk validasi input
  bool isLoading =
      true; // State untuk indikator loading, menandakan apakah data sedang dimuat atau tidak
  String?
      _goalsNameError; // State untuk pesan error validasi nama goals, menyimpan pesan error jika validasi nama goals gagal
  String?
      _errorMessage; // State untuk pesan error umum, menyimpan pesan error umum yang mungkin terjadi selama proses fetch data atau lainnya
  bool _isSnackBarShown =
      false; // State untuk mencegah SnackBar muncul berulang kali, flag untuk menandakan apakah SnackBar sudah pernah ditampilkan untuk menghindari tampilan berulang

  late String goalsName =
      ''; // State untuk nama goals, menyimpan nama goals tabungan bersama
  late double saldoTabungan =
      0.0; // State untuk saldo tabungan, menyimpan saldo tabungan bersama
  late String statusTabungan =
      ''; // State untuk status tabungan (belum digunakan di UI saat ini), menyimpan status tabungan bersama (misalnya aktif, tidak aktif), saat ini belum digunakan di UI
  late double progressTabungan =
      0.0; // State untuk progress tabungan (0.0 - 1.0), menyimpan progress tabungan dalam bentuk desimal (0 hingga 1)
  late int targetSaldoTabungan =
      0; // State untuk target saldo tabungan, menyimpan target saldo tabungan bersama
  String? durasiTabungan =
      ''; // State untuk durasi tabungan (format string), menyimpan durasi tabungan dalam format string (misalnya "3 Bulan")
  List<Member> members =
      []; // State untuk daftar member (saat ini tidak digunakan langsung di detail page, tapi di rincian anggota), menyimpan daftar member tabungan bersama, saat ini lebih banyak digunakan di halaman rincian anggota
  List<Map<String, dynamic>> historiTransaksi =
      []; // State untuk histori transaksi (saat ini placeholder), menyimpan histori transaksi tabungan bersama (saat ini hanya placeholder data)
  late String
      memberName; // State untuk nama member (belum digunakan secara spesifik di UI saat ini), menyimpan nama member, saat ini belum digunakan secara spesifik di UI detail tabungan bersama
  final Map<String, dynamic> _goalsData =
      {}; // State untuk menyimpan data goals secara keseluruhan (belum digunakan secara intensif), menyimpan data goals secara keseluruhan dalam bentuk Map, mungkin digunakan untuk passing data antar widget
  late List<Member> _allMembers =
      []; // State untuk menyimpan daftar semua member (digunakan untuk avatar dan rincian anggota), menyimpan daftar semua member yang diambil dari API, digunakan untuk menampilkan avatar dan di halaman rincian anggota
  final TokenManager _tokenManager =
      TokenManager(); // Instance TokenManager untuk mengelola token, membuat instance TokenManager untuk digunakan dalam class ini

  // Format mata uang Indonesia
  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'IDR ',
    decimalDigits: 2,
  );

  // Format tanggal Indonesia
  final DateFormat dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    fetchSavingGroupDetails(); // Panggil fungsi fetch detail tabungan saat widget diinisialisasi, fungsi untuk mengambil detail tabungan bersama akan dipanggil saat initState
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cek apakah ada argumen sukses undangan dan tampilkan SnackBar jika ada, pengecekan dilakukan saat dependensi widget berubah
    if (!_isSnackBarShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkInvitationSuccess(); // Panggil fungsi untuk memeriksa keberhasilan undangan
      });
    }
  }

  // Fungsi untuk memeriksa dan menampilkan SnackBar setelah undangan anggota
  void _checkInvitationSuccess() {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      if (arguments['invitationSuccess'] == true) {
        // Tampilkan SnackBar sukses undangan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Undang Anggota Telah Berhasil Dilakukan!'),
            backgroundColor: Colors.green,
          ),
        );
        _isSnackBarShown =
            true; // Set flag agar SnackBar tidak ditampilkan lagi, setelah SnackBar ditampilkan, flag di set agar tidak muncul lagi
      } else if (arguments['invitationSuccess'] == false) {
        // Tampilkan SnackBar gagal undangan dengan pesan error jika ada
        if (arguments['message'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Gagal mengundang anggota: ${arguments['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mengundang anggota.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        _isSnackBarShown =
            true; // Set flag agar SnackBar tidak ditampilkan lagi, setelah SnackBar ditampilkan (baik sukses maupun gagal), flag di set agar tidak muncul lagi
      }
    }
  }

  @override
  void dispose() {
    cariTransaksiController
        .dispose(); // Dispose controller pencarian transaksi, membebaskan sumber daya yang digunakan oleh controller
    _goalsNameController
        .dispose(); // Dispose controller nama goals, membebaskan sumber daya yang digunakan oleh controller
    super.dispose();
  }

  // Fungsi untuk mengambil detail tabungan bersama dari API
  Future<void> fetchSavingGroupDetails() async {
    setState(() {
      isLoading =
          true; // Set state loading menjadi true, mulai proses loading data
      _errorMessage =
          null; // Reset pesan error, memastikan tidak ada pesan error sebelumnya yang ditampilkan
    });

    String? token = await _tokenManager
        .getToken(); // Ambil token dari TokenManager, mengambil token otentikasi dari TokenManager
    if (token == null) {
      setState(() {
        isLoading =
            false; // Set state loading menjadi false, proses loading gagal karena token tidak ada
        _errorMessage =
            "Token tidak ditemukan"; // Set pesan error token tidak ditemukan, memberikan informasi bahwa token tidak ditemukan
      });
      return;
    }

    try {
      // Endpoint untuk detail saving group dan members
      final savingGroupUrl =
          Uri.parse('$baseUrl/saving-groups/${widget.savingGroupId}');
      final membersUrl =
          Uri.parse('$baseUrl/members?savingGroupId=${widget.savingGroupId}');

      final headers = {
        'Authorization': 'Bearer $token'
      }; // Header otorisasi dengan token, header yang akan disertakan dalam request API, berisi token otentikasi

      // Lakukan request API secara paralel menggunakan Future.wait untuk efisiensi, mengirimkan request untuk detail group dan members secara bersamaan
      final responses = await Future.wait([
        http.get(savingGroupUrl, headers: headers),
        http.get(membersUrl, headers: headers),
      ]);

      final groupResponse = responses[0]; // Response untuk detail group
      final membersResponse = responses[1]; // Response untuk daftar members

      if (groupResponse.statusCode == 200 &&
          membersResponse.statusCode == 200) {
        // Decode response body bytes menggunakan UTF-8, memastikan karakter non-ASCII dapat dihandle dengan benar
        final groupData = json.decode(utf8.decode(groupResponse.bodyBytes));
        final membersData = json.decode(utf8.decode(membersResponse.bodyBytes));

        if (groupData['code'] == 200 && groupData['status'] == 'OK') {
          final savingGroupDetail =
              groupData['data']; // Data detail saving group dari response API
          if (membersData['code'] == 200 && membersData['status'] == 'OK') {
            // Map data member dari API response ke model Member, mengubah data JSON member menjadi list objek Member
            List<Member> fetchedMembers = (membersData['data'] as List)
                .map((item) => Member.fromJson(item))
                .toList();

            setState(() {
              goalsName = savingGroupDetail['name'] ??
                  'Nama Goals'; // Set nama goals dari API atau default, jika nama goals null, gunakan 'Nama Goals' sebagai default
              _goalsNameController.text =
                  goalsName; // Set text controller nama goals untuk edit modal, mengisi input field modal edit dengan nama goals saat ini
              saldoTabungan = (savingGroupDetail['balance'] as num?)
                      ?.toDouble() ??
                  0.0; // Set saldo tabungan dari API atau default, handle null, jika saldo null, gunakan 0.0 sebagai default
              progressTabungan = (savingGroupDetail['progress'] as num?)
                      ?.toDouble() ??
                  0.0; // Set progress tabungan dari API atau default, handle null, jika progress null, gunakan 0.0 sebagai default
              targetSaldoTabungan = savingGroupDetail['detail']
                      ['target_amount'] ??
                  0; // Set target saldo dari API atau default, jika target saldo null, gunakan 0 sebagai default
              durasiTabungan = savingGroupDetail['detail']['duration'] != null
                  ? '${(savingGroupDetail['detail']['duration'] / 30).floor()} Bulan' // Format durasi ke bulan, konversi durasi hari ke bulan (integer)
                  : 'Durasi Tidak Ditentukan'; // Pesan default jika durasi tidak ada, jika durasi null, gunakan pesan default
              _allMembers =
                  fetchedMembers; // Set daftar semua member, menyimpan daftar member yang berhasil diambil
              isLoading =
                  false; // Set state loading menjadi false, proses loading data selesai dan berhasil
            });
          } else {
            setState(() {
              isLoading =
                  false; // Set state loading menjadi false jika gagal ambil member, proses loading gagal pada pengambilan data member
              _errorMessage = membersData['errors'] != null &&
                      (membersData['errors'] as List).isNotEmpty
                  ? (membersData['errors'] as List)[0]
                      .toString() // Set pesan error dari API atau default, mengambil pesan error pertama dari response API jika ada
                  : "Gagal mengambil data anggota tabungan, silahkan coba lagi!"; // Pesan error default jika tidak ada pesan error spesifik dari API
            });
          }
        } else {
          setState(() {
            isLoading =
                false; // Set state loading menjadi false jika gagal ambil detail tabungan, proses loading gagal pada pengambilan detail tabungan
            _errorMessage = groupData['errors'] != null &&
                    (groupData['errors'] as List).isNotEmpty
                ? (groupData['errors'] as List)[0]
                    .toString() // Set pesan error dari API atau default, mengambil pesan error pertama dari response API jika ada
                : "Gagal mengambil detail tabungan, silahkan coba lagi!"; // Pesan error default jika tidak ada pesan error spesifik dari API
          });
        }
      } else {
        setState(() {
          isLoading =
              false; // Set state loading menjadi false jika status code bukan 200, request API gagal
          _errorMessage =
              "Gagal mengambil data. Status Group: ${groupResponse.statusCode}, Status Members: ${membersResponse.statusCode}"; // Set pesan error status code, menampilkan status code dari kedua response API
        });
      }
    } catch (e) {
      setState(() {
        isLoading =
            false; // Set state loading menjadi false jika terjadi exception, terjadi error saat proses request API
        _errorMessage =
            "Terjadi kesalahan: ${e.toString()}"; // Set pesan error exception, menampilkan pesan exception yang terjadi
      });
    }
  }

  // Fungsi untuk menampilkan modal bottom sheet pengaturan tabungan
  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return SafeArea(
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Pengaturan Tabungan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow.shade700,
                            foregroundColor: Colors.blue.shade900,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.edit),
                          label: const Text(
                            'Edit Tabungan Bersama',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(
                                context); // Tutup bottom sheet pengaturan, menutup modal pengaturan
                            _showEditTabunganModal(); // Tampilkan modal edit nama tabungan, menampilkan modal untuk mengedit nama tabungan
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.delete),
                          label: const Text(
                            'Hapus Tabungan Bersama',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(
                                context); // Tutup bottom sheet pengaturan, menutup modal pengaturan
                            _archiveSavingGroup(); // Panggil fungsi hapus tabungan, memanggil fungsi untuk menghapus tabungan bersama
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Fungsi untuk mengarsipkan (menghapus) saving group
  Future<void> _archiveSavingGroup() async {
    String? token = await _tokenManager
        .getToken(); // Ambil token dari TokenManager, mengambil token otentikasi dari TokenManager
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Token tidak ditemukan, mohon login kembali.'), // SnackBar error token, menampilkan SnackBar jika token tidak ditemukan
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String savingGroupId = widget
        .savingGroupId; // Ambil savingGroupId dari widget, mendapatkan savingGroupId dari widget
    final String archiveEndpoint =
        "/saving-groups/joint/$savingGroupId/archive"; // Endpoint API untuk archive, endpoint API untuk mengarsipkan tabungan bersama
    final String apiUrl = baseUrl +
        archiveEndpoint; // Gabungkan base URL dan endpoint, membentuk URL lengkap untuk request API

    try {
      final response = await http.patch(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token'
        }, // Header otorisasi, header yang disertakan dalam request, berisi token otentikasi
      );

      if (response.statusCode == 200) {
        // Decode response body bytes menggunakan UTF-8, memastikan karakter non-ASCII dihandle dengan benar
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        if (responseData['code'] == 200 && responseData['status'] == 'OK') {
          // Navigasi kembali ke OurGoals dengan flag sukses hapus, jika hapus berhasil, kembali ke halaman OurGoals
          Navigator.popAndPushNamed(
            context,
            '/ourGoals',
            arguments: {'deletionSuccess': true},
          );
        } else {
          // Tampilkan SnackBar error hapus, jika hapus gagal, tampilkan SnackBar error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['errors'] != null &&
                      (responseData['errors'] as List).isNotEmpty
                  ? (responseData['errors'] as List)[0]
                      .toString() // Pesan error dari API atau default, mengambil pesan error pertama dari response API jika ada
                  : "Gagal menghapus tabungan, silahkan coba lagi!"), // Pesan error default jika tidak ada pesan error spesifik dari API
              backgroundColor: Colors.red,
            ),
          );
          // Navigasi kembali ke OurGoals dengan flag gagal hapus, tetap kembali ke halaman OurGoals meskipun hapus gagal
          Navigator.popAndPushNamed(
            context,
            '/ourGoals',
            arguments: {'deletionSuccess': true},
          );
        }
      } else {
        // Tampilkan SnackBar error status code, jika status code response bukan 200, tampilkan SnackBar error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Gagal menghapus tabungan. Status code: ${response.statusCode}"), // Pesan error status code, menampilkan status code dari response API
            backgroundColor: Colors.red,
          ),
        );
        // Navigasi kembali ke OurGoals dengan flag gagal hapus, tetap kembali ke halaman OurGoals meskipun hapus gagal karena status code error
        Navigator.popUntil(context, ModalRoute.withName('/ourGoals'));
      }
    } catch (e) {
      // Tampilkan SnackBar error exception, jika terjadi exception saat request API, tampilkan SnackBar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Terjadi kesalahan saat menghapus tabungan: ${e.toString()}"), // Pesan error exception, menampilkan pesan exception yang terjadi
          backgroundColor: Colors.red,
        ),
      );
      // Navigasi kembali ke OurGoals dengan flag gagal hapus, tetap kembali ke halaman OurGoals meskipun hapus gagal karena exception
      Navigator.popAndPushNamed(
        context,
        '/ourGoals',
        arguments: {'deletionSuccess': true},
      );
    }
  }

  // Fungsi untuk memperbarui nama saving group
  Future<void> _updateSavingGroupName(String newName) async {
    _showLoadingOverlay(
        context); // Tampilkan loading overlay, memulai tampilan loading overlay

    String? token = await _tokenManager
        .getToken(); // Ambil token dari TokenManager, mengambil token otentikasi dari TokenManager
    if (token == null) {
      _hideLoadingOverlay(
          context); // Sembunyikan loading overlay, menyembunyikan loading overlay karena token tidak ditemukan
      setState(() {
        _errorMessage =
            "Token tidak ditemukan"; // Set pesan error token tidak ditemukan, memberikan informasi bahwa token tidak ditemukan
      });
      return;
    }

    final String savingGroupId = widget
        .savingGroupId; // Ambil savingGroupId dari widget, mendapatkan savingGroupId dari widget
    final String updateNameEndpoint =
        "/saving-groups/joint/$savingGroupId"; // Endpoint API untuk update nama, endpoint API untuk memperbarui nama tabungan bersama
    final String apiUrl = baseUrl +
        updateNameEndpoint; // Gabungkan base URL dan endpoint, membentuk URL lengkap untuk request API

    try {
      final response = await http.patch(
        Uri.parse(apiUrl),
        headers: {
          'Authorization':
              'Bearer $token', // Header otorisasi, header yang disertakan dalam request, berisi token otentikasi
          'Content-Type':
              'application/json', // Content type JSON, memberitahukan API bahwa body request adalah JSON
        },
        body: jsonEncode({
          'name': newName
        }), // Body request dengan nama baru, body request dalam format JSON, berisi nama baru
      );

      if (response.statusCode == 200) {
        // Decode response body bytes menggunakan UTF-8, memastikan karakter non-ASCII dihandle dengan benar
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        if (responseData['code'] == 200 && responseData['status'] == 'OK') {
          await fetchSavingGroupDetails(); // Refresh detail tabungan setelah update nama, mengambil ulang detail tabungan setelah nama berhasil diupdate
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Nama Tabungan berhasil diubah!'), // SnackBar sukses update nama, menampilkan SnackBar sukses update nama
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            _goalsNameError = responseData['errors'] != null &&
                    (responseData['errors'] as List).isNotEmpty
                ? (responseData['errors'] as List)[0]
                    .toString() // Set pesan error dari API atau default, mengambil pesan error pertama dari response API jika ada
                : "Gagal mengubah nama tabungan, silahkan coba lagi!"; // Pesan error default jika tidak ada pesan error spesifik dari API
          });
        }
      } else {
        setState(() {
          _errorMessage =
              "Gagal mengubah nama tabungan. Status code: ${response.statusCode}"; // Set pesan error status code, menampilkan status code dari response API
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            "Terjadi kesalahan saat mengubah nama tabungan: ${e.toString()}"; // Set pesan error exception, menampilkan pesan exception yang terjadi
      });
    } finally {
      _hideLoadingOverlay(
          context); // Sembunyikan loading overlay di blok finally, memastikan loading overlay selalu disembunyikan setelah proses update selesai, baik berhasil maupun gagal
    }
  }

  // Fungsi untuk menampilkan modal bottom sheet edit nama tabungan
  void _showEditTabunganModal() {
    _goalsNameController.text =
        goalsName; // Set nilai awal controller dengan nama goals saat ini, mengisi input field modal edit dengan nama goals saat ini
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return SafeArea(
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        constraints: BoxConstraints(
                          minHeight: constraints.minHeight,
                          maxHeight: MediaQuery.of(context).size.height * 0.8,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Edit Nama Tabungan Bersama',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nama Tabungan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller:
                                        _goalsNameController, // Controller untuk input nama goals, menggunakan controller yang sudah didefinisikan
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Nama Tabungan tidak boleh kosong'; // Validasi tidak boleh kosong, memastikan input nama tabungan tidak kosong
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      fillColor: Colors.blue.shade50,
                                      filled: true,
                                      hintText:
                                          'Masukan Nama Tabungan', // Hint text input, placeholder text untuk input field
                                      hintStyle: const TextStyle(
                                          color: Colors
                                              .black54), // Style hint text, style untuk hint text
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide
                                            .none, // Hilangkan border, menghilangkan border input field
                                      ),
                                      contentPadding: const EdgeInsets
                                          .symmetric(
                                          vertical: 10,
                                          horizontal:
                                              12), // Padding content, mengatur padding di dalam input field
                                      errorText:
                                          _goalsNameError, // Tampilkan pesan error validasi, menampilkan pesan error validasi di bawah input field jika ada
                                      errorMaxLines:
                                          2, // Maksimal baris pesan error, membatasi jumlah baris pesan error
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      // Validasi form sebelum submit, memastikan form valid sebelum memproses update nama
                                      String newName = _goalsNameController
                                          .text; // Ambil nama baru dari controller, mengambil nilai dari input field
                                      Navigator.pop(
                                          context); // Tutup bottom sheet sebelum update, menutup modal edit sebelum melakukan update nama
                                      await _updateSavingGroupName(
                                          newName); // Panggil fungsi update nama, memanggil fungsi untuk memperbarui nama tabungan bersama
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.yellow.shade700,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Simpan',
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
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      setState(() {
        _goalsNameError =
            null; // Reset pesan error validasi saat modal ditutup, memastikan pesan error validasi hilang saat modal ditutup
      });
    });
  }

  // Method untuk menampilkan loading overlay
  void _showLoadingOverlay(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // User tidak bisa menutup overlay dengan tap luar, mencegah user menutup loading overlay secara tidak sengaja
      builder: (BuildContext context) {
        return const LoadingOverlay(); // Widget LoadingOverlay (dari file lain), menampilkan widget LoadingOverlay sebagai indikator loading
      },
    );
  }

  // Method untuk menyembunyikan loading overlay
  void _hideLoadingOverlay(BuildContext context) {
    Navigator.of(context, rootNavigator: true)
        .pop(); // Pop dialog loading overlay, menutup dialog loading overlay dari navigator
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(
          context), // AppBar kustom, memanggil widget _buildAppBar untuk app bar halaman
      body: _errorMessage != null
          ? Center(
              child: Text(
                  _errorMessage!)) // Tampilkan pesan error jika ada, jika _errorMessage tidak null, tampilkan pesan error di tengah layar
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(Icons.settings,
                            color: Colors.blue
                                .shade900), // Ikon settings di AppBar kanan atas, ikon settings untuk membuka modal pengaturan
                        onPressed:
                            _showSettingsModal, // Panggil modal settings saat ikon di-tap, memanggil fungsi _showSettingsModal saat ikon settings ditekan
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          children: [
                            Icon(
                              Icons.groups,
                              size: 64,
                              color: Colors.blue
                                  .shade400, // Ikon groups besar di atas nama goals, ikon groups yang merepresentasikan tabungan bersama
                            ),
                            const SizedBox(height: 16),
                            isLoading
                                ? _buildShimmerText(
                                    height:
                                        32) // Shimmer loading untuk nama goals, menampilkan shimmer effect saat nama goals sedang loading
                                : Text(
                                    isLoading
                                        ? ' '
                                        : goalsName, // Tampilkan nama goals atau spasi saat loading, menampilkan nama goals jika loading selesai, jika tidak menampilkan spasi
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                            const SizedBox(height: 8),
                            isLoading
                                ? _buildShimmerText(
                                    height:
                                        32) // Shimmer loading untuk saldo tabungan, menampilkan shimmer effect saat saldo tabungan sedang loading
                                : Text(
                                    currencyFormat.format(
                                        saldoTabungan), // Tampilkan saldo tabungan yang diformat, menampilkan saldo tabungan yang sudah diformat ke mata uang Indonesia
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue
                                          .shade900, // Warna teks saldo, warna teks saldo tabungan
                                    ),
                                  ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UndangAnggotaBersama(
                                        savingGroupId: widget.savingGroupId,
                                        goalsName: goalsName,
                                      ),
                                    ),
                                  ).then((value) {
                                    if (value is bool && value == true) {
                                      setState(() {
                                        _isSnackBarShown =
                                            false; // Reset flag, mereset flag SnackBar agar dapat ditampilkan kembali
                                      });
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        _checkInvitationSuccess(); // Panggil fungsi cek sukses undangan setelah halaman kembali
                                      });
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
                                  'Undang Anggota',
                                  style: TextStyle(
                                    color: Colors.blue.shade900,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RincianAnggotaBersama(
                                      savingGroupId: widget
                                          .savingGroupId, // Kirim savingGroupId ke RincianAnggotaBersama, mengirimkan savingGroupId ke halaman rincian anggota
                                      goalsName:
                                          goalsName, // Kirim goalsName ke RincianAnggotaBersama, mengirimkan goalsName ke halaman rincian anggota
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: isLoading
                                    ? _buildShimmerCircleAvatars() // Shimmer loading untuk avatar member, menampilkan shimmer effect saat avatar member sedang loading
                                    : [
                                        ..._allMembers.take(2).map(
                                              // Tampilkan maksimal 2 avatar member, menampilkan maksimal 2 avatar member dari daftar member
                                              (member) => Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8.0),
                                                child: CircleAvatar(
                                                  radius: 20,
                                                  backgroundColor: Colors
                                                      .primaries[_allMembers
                                                          .indexOf(member) %
                                                      Colors.primaries
                                                          .length], // Warna avatar berbeda-beda, memberikan warna avatar yang berbeda-beda dari daftar warna primer
                                                  child: Text(
                                                    member.name.isNotEmpty
                                                        ? member.name[0]
                                                            .toUpperCase() // Inisial nama member, mengambil inisial nama member dari nama lengkap
                                                        : 'U', // Default inisial 'U' jika nama kosong, jika nama member kosong, gunakan 'U' sebagai inisial default
                                                    style: const TextStyle(
                                                        color: Colors
                                                            .white), // Style teks inisial, style untuk teks inisial di dalam avatar
                                                  ),
                                                ),
                                              ),
                                            ),
                                        if (_allMembers.length > 2)
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Colors.grey,
                                            child: Text(
                                              '+${_allMembers.length - 2}', // Tampilkan jumlah member lebih dari 2, menampilkan jumlah member yang tidak ditampilkan avatarnya
                                              style: const TextStyle(
                                                  color: Colors
                                                      .white), // Style teks jumlah member, style untuk teks jumlah member
                                            ),
                                          ),
                                      ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildProgressCard(), // Widget Card Progress Tabungan, memanggil widget _buildProgressCard untuk menampilkan card progress tabungan
                        const SizedBox(height: 16),
                        _buildTransactionSearchField(), // Widget Input Pencarian Transaksi, memanggil widget _buildTransactionSearchField untuk input pencarian transaksi
                        const SizedBox(height: 16),
                        _buildTransactionHistoryList(), // Widget List Histori Transaksi, memanggil widget _buildTransactionHistoryList untuk menampilkan list histori transaksi
                        const SizedBox(height: 16),
                        _buildTambahUangButton(), // Widget Button Tambah Uang, memanggil widget _buildTambahUangButton untuk button tambah uang
                        const SizedBox(height: 16),
                        _buildTarikUangButton(), // Widget Button Tarik Uang, memanggil widget _buildTarikUangButton untuk button tarik uang
                      ],
                    ),
                  ],
                ),
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
          Navigator.pop(
              context); // Navigasi kembali ke halaman sebelumnya, fungsi untuk navigasi kembali ke halaman sebelumnya
        },
      ),
      title: const Text(
        'Detail Tabungan Bersama',
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

  // Widget Card Progress Tabungan
  // Widget Card Progress Tabungan
  Widget _buildProgressCard() {
    return InkWell(
      onTap: () {
        // Navigasi ke DetailKontribusiTabunganBersama saat card di-tap, fungsi untuk navigasi ke halaman detail kontribusi saat card progress di-tap
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailKontribusiTabunganBersama(
              goalsData: {
                'savingGroupId': widget
                    .savingGroupId, // Kirim savingGroupId, mengirimkan savingGroupId ke halaman detail kontribusi
                'goalsName':
                    goalsName, // Kirim goalsName, mengirimkan goalsName ke halaman detail kontribusi
                'saldoTabungan':
                    saldoTabungan, // Kirim saldoTabungan, mengirimkan saldoTabungan ke halaman detail kontribusi
                'progressTabungan':
                    progressTabungan, // Kirim progressTabungan, mengirimkan progressTabungan ke halaman detail kontribusi
                'targetTabungan':
                    targetSaldoTabungan, // Kirim targetSaldoTabungan, mengirimkan targetSaldoTabungan ke halaman detail kontribusi
                'members':
                    _allMembers, // Kirim daftar members, mengirimkan daftar members ke halaman detail kontribusi
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressCardHeader(), // Header card progress, memanggil widget _buildProgressCardHeader untuk header card progress
              const SizedBox(height: 14),
              _buildProgressCardBalance(), // Teks saldo progress, memanggil widget _buildProgressCardBalance untuk teks saldo progress
              const SizedBox(height: 8),
              _buildProgressCardProgressBar(), // Progress bar, memanggil widget _buildProgressCardProgressBar untuk progress bar
              const SizedBox(height: 8),
              _buildProgressCardSummary(), // Summary durasi dan persentase progress, memanggil widget _buildProgressCardSummary untuk summary progress
            ],
          ),
        ),
      ),
    );
  }

  // Header Card Progress Tabungan
  Widget _buildProgressCardHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.track_changes,
              color: Colors.blue,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Progress Tabungan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Tooltip(
          message:
              'Total progress dari semua anggota', // Tooltip info progress, menampilkan tooltip info saat hover atau long press
          child: Icon(
            Icons.info_outline,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  // Teks Saldo Progress Tabungan
  Widget _buildProgressCardBalance() {
    return isLoading
        ? _buildShimmerText(
            height:
                18) // Shimmer loading untuk teks saldo progress, menampilkan shimmer effect saat teks saldo progress sedang loading
        : Text(
            '${currencyFormat.format(saldoTabungan)} / ${currencyFormat.format(targetSaldoTabungan)}', // Tampilkan saldo dan target saldo yang diformat, menampilkan saldo dan target saldo yang sudah diformat ke mata uang Indonesia
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.blue
                  .shade900, // Warna teks saldo progress, warna teks saldo progress
            ),
          );
  }

  // Progress Bar Card Progress Tabungan
  Widget _buildProgressCardProgressBar() {
    return LinearProgressIndicator(
      value: isLoading
          ? 0
          : progressTabungan, // Value progress bar (0-1) atau 0 saat loading, value progress bar berdasarkan progressTabungan, jika loading value 0
      backgroundColor: Colors.grey
          .shade300, // Warna background progress bar, warna background progress bar
      color: Colors.blue.shade400, // Warna progress bar, warna progress bar
    );
  }

  // Summary Card Progress Tabungan (Durasi dan Persentase)
  Widget _buildProgressCardSummary() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
            durasiTabungan ??
                '', // Tampilkan durasi tabungan atau string kosong jika null, menampilkan durasi tabungan, jika durasi null tampilkan string kosong
            style: TextStyle(
                color: Colors.blue
                    .shade700)), // Style teks durasi, style untuk teks durasi
        Text(
          isLoading
              ? '0%' // Tampilkan 0% saat loading, jika loading tampilkan 0%
              : '${(progressTabungan * 100).toStringAsFixed(2)}%', // Tampilkan persentase progress yang diformat, menampilkan persentase progress dengan 2 angka desimal
          style: TextStyle(
              color: Colors.blue
                  .shade700), // Style teks persentase, style untuk teks persentase
        ),
      ],
    );
  }

  // Widget Input Pencarian Transaksi
  Widget _buildTransactionSearchField() {
    return TextFormField(
      controller:
          cariTransaksiController, // Controller untuk input pencarian transaksi, menggunakan controller yang sudah didefinisikan
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons
            .search), // Ikon search di prefix, menambahkan ikon search di prefix input field
        fillColor: Colors
            .blue.shade50, // Warna fill input, warna background input field
        filled:
            true, // Input terisi warna, input field diisi dengan warna background
        hintText:
            'Cari Transaksi', // Hint text input, placeholder text untuk input field
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide
              .none, // Hilangkan border, menghilangkan border input field
        ),
      ),
    );
  }

  // Widget List Histori Transaksi
  Widget _buildTransactionHistoryList() {
    return isLoading
        ? _buildShimmerTransactionHistory() // Shimmer loading untuk histori transaksi, menampilkan shimmer effect saat histori transaksi sedang loading
        : historiTransaksi.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Belum ada transaksi', // Pesan jika tidak ada transaksi, pesan yang ditampilkan jika histori transaksi kosong
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(), // Disable scroll listview di dalam scrollview utama, menonaktifkan scrolling pada listview karena sudah berada di dalam SingleChildScrollView
                itemCount: historiTransaksi
                    .length, // Jumlah item histori transaksi, jumlah item yang akan ditampilkan di listview
                itemBuilder: (context, index) {
                  final transaction = historiTransaksi[
                      index]; // Ambil data transaksi per index, mengambil data transaksi dari list histori transaksi berdasarkan index
                  return ListTile(
                    title: Text(transaction[
                        'jenisTransaksi']), // Judul list tile (jenis transaksi), menampilkan jenis transaksi sebagai judul list tile
                    subtitle: Text(dateFormat.format(transaction[
                        'tanggalTransaksi'])), // Subtitle list tile (tanggal transaksi yang diformat), menampilkan tanggal transaksi yang sudah diformat sebagai subtitle list tile
                    trailing: Text(currencyFormat.format(transaction[
                        'jumlahTransaksi'])), // Trailing list tile (jumlah transaksi yang diformat), menampilkan jumlah transaksi yang sudah diformat sebagai trailing list tile
                  );
                },
              );
  }

  // Widget Button Tambah Uang
  Widget _buildTambahUangButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TambahUangBersama(
                  goalsData:
                      _goalsData), // Navigasi ke TambahUangBersama, navigasi ke halaman TambahUangBersama saat button ditekan
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
          'Tambah Uang',
          style: TextStyle(
            color: Colors.blue.shade900,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Widget Button Tarik Uang
  Widget _buildTarikUangButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TarikUangBersama(
                  goalsData:
                      _goalsData), // Navigasi ke TarikUangBersama, navigasi ke halaman TarikUangBersama saat button ditekan
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.yellow.shade700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Tarik Uang',
          style: TextStyle(
            color: Colors.yellow.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Shimmer Text Widget
  Widget _buildShimmerText({double height = 20}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: height,
        color: Colors.grey,
      ),
    );
  }

  // Shimmer Circle Avatars Widget
  List<Widget> _buildShimmerCircleAvatars() {
    return List.generate(
      3,
      (index) => Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey,
          ),
        ),
      ),
    );
  }

  // Shimmer Transaction History Widget
  Widget _buildShimmerTransactionHistory() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(
          5,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              height: 60,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

// Loading Overlay Widget
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
