// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'package:digigoals_app/TabunganBergilir/AktivasiTabunganBergilir.dart';
import 'package:digigoals_app/TabunganBergilir/DetailTargetTabunganBergilir.dart';
import 'package:digigoals_app/TabunganBergilir/GilirTabungan.dart';
import 'package:digigoals_app/TabunganBergilir/RincianAnggotaBergilir.dart';
import 'package:digigoals_app/TabunganBergilir/TambahUangBergilir.dart';
import 'package:digigoals_app/TabunganBergilir/TarikUangBergilir.dart';
import 'package:digigoals_app/TabunganBergilir/UndangAnggotaBergilir.dart';
import 'package:digigoals_app/OurGoals.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:digigoals_app/api/api_config.dart'; // Import api_config.dart
import 'package:digigoals_app/auth/token_manager.dart'; // Import TokenManager
import 'package:http/http.dart' as http; // Import http package

class MemberDetailTargetBergilir {
  final String memberId;
  final String name;
  final String accountNumber;
  final String role; // Keep role as String
  final double lockedBalance;
  final Color avatarColor;
  final String status;

  MemberDetailTargetBergilir({
    required this.memberId,
    required this.name,
    required this.accountNumber,
    required this.role,
    required this.lockedBalance,
    required this.avatarColor,
    required this.status,
  });

  factory MemberDetailTargetBergilir.fromJson(
      Map<String, dynamic> json, int index, double contributionAmount) {
    final user = json['user'];
    final customer = user['customer'];
    final account = json['account'];
    final lockedBalance =
        (account?['total_locked_balance'] as num?)?.toDouble() ?? 0.0;
    final targetPerMember = contributionAmount;
    final isPaidOff = lockedBalance >= targetPerMember;
    final role = json['role']; // Extract role directly from json

    return MemberDetailTargetBergilir(
      memberId: user['id'].toString(),
      name: customer['name'] ?? 'N/A',
      accountNumber: account?['account_number']?.toString() ?? 'N/A',
      role: role, // Use extracted role
      lockedBalance: lockedBalance,
      avatarColor: Colors.primaries[index % Colors.primaries.length],
      status: isPaidOff ? 'Lunas' : 'Belum Lunas',
    );
  }
}

class DetailTabunganBergilir extends StatefulWidget {
  final String savingGroupId; // Add savingGroupId parameter
  final bool isActive;

  const DetailTabunganBergilir(
      {super.key,
      required this.savingGroupId,
      this.isActive = false}); // Modify constructor to require savingGroupId

  @override
  State<DetailTabunganBergilir> createState() => _DetailTabunganBergilirState();
}

class _DetailTabunganBergilirState extends State<DetailTabunganBergilir> {
  final TextEditingController cariTransaksiController = TextEditingController();
  final TextEditingController _goalsNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  String? _goalsNameError;
  String? _errorMessage; // Error message state
  bool _isSnackBarShown =
      false; // State to prevent SnackBar from showing repeatedly
  String? _userRole; // To store the current user's role
  String? savingGroupType; // Added to store saving group type

  late String goalsName = ''; // Initialize with empty string
  late String statusTabungan = 'INACTIVE'; // Initialize with default value
  double progressTabungan = 0.0;
  double saldoTabungan = 0.0;
  late int targetSaldoTabungan = 0; // Initialize with 0
  late int durasiTabungan = 0; // Initialize with 0
  List<String> members = [];
  List<Map<String, dynamic>> historiTransaksi = []; // Keep static
  late String memberName;
  Map<String, dynamic> _goalsData = {};
  late double targetKontribusi =
      0.0; // New variable to store contribution_amount

  late List<String> _allMembers = []; // Initialize as empty list
  final TokenManager _tokenManager = TokenManager(); // Token Manager Instance

  // Format mata uang Rupiah dengan IDR
  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'IDR ',
    decimalDigits: 2,
  );

  // Format tanggal
  final DateFormat dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isSnackBarShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkDeletionSuccess();
      });
    }
  }

  // Function to check if deletion was successful and show snackbar
  void _checkDeletionSuccess() {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      if (arguments['deletionSuccess'] == true) {
        if (mounted) {
          // ADD MOUNTED CHECK HERE
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tabungan berhasil dihapus!'),
              backgroundColor: Colors.green,
            ),
          );
          _isSnackBarShown = true;
        }
      } else if (arguments['deletionSuccess'] == false) {
        if (mounted) {
          // ADD MOUNTED CHECK HERE
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menghapus tabungan.'),
              backgroundColor: Colors.red,
            ),
          );
          _isSnackBarShown = true;
        }
      }
    }
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      _errorMessage = null; // Reset error message
    });

    await _fetchSavingGroupDetails();
    await _fetchMembers();
    List<MemberDetailTargetBergilir> memberData =
        await _fetchMemberDataForProgressCard(); // Fetch member data

    double totalTargetKeseluruhan = targetKontribusi * memberData.length;
    double totalSaldoKeseluruhan =
        memberData.fold(0, (sum, member) => sum + member.lockedBalance);
    progressTabungan = totalTargetKeseluruhan > 0
        ? totalSaldoKeseluruhan / totalTargetKeseluruhan
        : 0.0;
    saldoTabungan = totalSaldoKeseluruhan;

    if (mounted) {
      // ADD MOUNTED CHECK HERE
      setState(() {
        // Update _goalsData with calculated values, remove static values
        _goalsData['saldoTabungan'] =
            saldoTabungan; // Use calculated saldoTabungan
        _goalsData['progressTabungan'] =
            progressTabungan; // Use calculated progressTabungan
        isLoading = false;
      });
    }
  }

  // Function to fetch saving group details from API
  Future<void> _fetchSavingGroupDetails() async {
    String? token = await _tokenManager.getToken();
    if (token == null) {
      if (mounted) {
        // ADD MOUNTED CHECK HERE
        setState(() {
          _errorMessage = "Token tidak ditemukan";
        });
      }
      return;
    }

    final url = Uri.parse('$baseUrl/saving-groups/${widget.savingGroupId}');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseBody =
            utf8.decode(response.bodyBytes); // Decode response body using UTF-8
        final responseData = json.decode(responseBody);
        if (responseData['code'] == 200 && responseData['status'] == 'OK') {
          final data = responseData['data'];
          if (mounted) {
            // ADD MOUNTED CHECK HERE
            setState(() {
              _goalsData = data;
              goalsName = data['name'];
              _goalsNameController.text = goalsName;
              statusTabungan = data['status'];
              targetSaldoTabungan = data['detail']['target_amount'] ?? 0;
              durasiTabungan = data['detail']['duration'] ?? 0;
              targetKontribusi =
                  (data['detail']['contribution_amount'] as num?)?.toDouble() ??
                      0.0; // Get contribution_amount
              savingGroupType =
                  data['type']?.toString(); // Get saving group type
              // Static data initialization - keep for now as per instructions, adjust with API data when available
              _goalsData['goalsName'] = goalsName;
              _goalsData['targetTabungan'] = targetSaldoTabungan.toDouble();
              _goalsData['durasiTabungan'] = '$durasiTabungan Bulan';
              _goalsData['transactions'] = [
                // Static Value - Will be replaced by API later
                {
                  'jenisTransaksi': 'Setoran',
                  'tanggalTransaksi': DateTime(2024, 12, 10),
                  'jumlahTransaksi': 500000.00
                },
                {
                  'jenisTransaksi': 'Penarikan',
                  'tanggalTransaksi': DateTime(2024, 12, 12),
                  'jumlahTransaksi': 300000.00,
                },
              ];
              historiTransaksi = List<Map<String, dynamic>>.from(_goalsData[
                  'transactions']); // Static Value - Will be replaced by API later
              _goalsData['savingGroupType'] =
                  savingGroupType; // Include saving group type in _goalsData
            });
          }
        } else {
          if (mounted) {
            // ADD MOUNTED CHECK HERE
            setState(() {
              _errorMessage = responseData['errors'] != null &&
                      (responseData['errors'] as List).isNotEmpty
                  ? (responseData['errors'] as List)[0].toString()
                  : "Gagal memuat detail tabungan.";
            });
          }
        }
      } else {
        if (mounted) {
          // ADD MOUNTED CHECK HERE
          setState(() {
            _errorMessage =
                "Gagal memuat detail tabungan. Status code: ${response.statusCode}";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        // ADD MOUNTED CHECK HERE
        setState(() {
          _errorMessage =
              "Terjadi kesalahan saat memuat detail tabungan: ${e.toString()}";
        });
      }
    }
  }

  // Function to fetch members from API
  Future<void> _fetchMembers() async {
    String? token = await _tokenManager.getToken();
    if (token == null) return;

    final url =
        Uri.parse('$baseUrl/members?savingGroupId=${widget.savingGroupId}');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseBody =
            utf8.decode(response.bodyBytes); // Decode response body using UTF-8
        final responseData = json.decode(responseBody);
        if (responseData['code'] == 200 && responseData['status'] == 'OK') {
          List<dynamic> memberDataList = responseData['data'];

          String? currentUserId =
              await _tokenManager.getUserId(); // Get current user ID

          if (mounted) {
            // ADD MOUNTED CHECK HERE
            setState(() {
              _allMembers = memberDataList
                  .map((item) => item['user']['customer']['name'].toString())
                  .toList();
              members = _allMembers; // For consistent member list
              _goalsData['members'] = members; // Update static data for members
              memberName = members.isNotEmpty
                  ? members.first
                  : 'N/A'; // Default member name

              // Determine and set current user's role
              for (var memberJson in memberDataList) {
                final user = memberJson['user'];
                if (user['id'].toString() == currentUserId) {
                  _userRole = memberJson['role'];
                  break; // Exit loop once current user is found
                }
              }
            });
          }
        } else {
          if (mounted) {
            // ADD MOUNTED CHECK HERE
            setState(() {
              _errorMessage = responseData['errors'] != null &&
                      (responseData['errors'] as List).isNotEmpty
                  ? (responseData['errors'] as List)[0].toString()
                  : "Gagal memuat anggota.";
            });
          }
        }
      } else {
        if (mounted) {
          // ADD MOUNTED CHECK HERE
          setState(() {
            _errorMessage =
                "Gagal memuat anggota. Status code: ${response.statusCode}";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        // ADD MOUNTED CHECK HERE
        setState(() {
          _errorMessage =
              "Terjadi kesalahan saat memuat anggota: ${e.toString()}";
        });
      }
    }
  }

  Future<List<MemberDetailTargetBergilir>>
      _fetchMemberDataForProgressCard() async {
    String? token = await _tokenManager.getToken();
    if (token == null) {
      return []; // Return empty list if token is null
    }

    final String savingGroupId = widget.savingGroupId;
    final membersUrl =
        Uri.parse('$baseUrl/members?savingGroupId=$savingGroupId');

    try {
      final response = await http.get(
        membersUrl,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final responseData = json.decode(responseBody);
        if (responseData['code'] == 200 && responseData['status'] == 'OK') {
          List<dynamic> memberDataList = responseData['data'];
          List<MemberDetailTargetBergilir> fetchedMembers = [];

          for (int i = 0; i < memberDataList.length; i++) {
            final memberDetail = MemberDetailTargetBergilir.fromJson(
                memberDataList[i], i, targetKontribusi);
            fetchedMembers.add(memberDetail);
          }
          return fetchedMembers;
        } else {
          return []; // Return empty list on API error
        }
      } else {
        return []; // Return empty list on HTTP error
      }
    } catch (e) {
      return []; // Return empty list on exception
    }
  }

  @override
  void dispose() {
    cariTransaksiController.dispose();
    _goalsNameController.dispose();
    super.dispose();
  }

  /// Menampilkan modal bottom sheet untuk pengaturan tabungan.
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
                            'Edit Tabungan Bergilir',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _showEditTabunganModal();
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
                            'Hapus Tabungan Bergilir',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _archiveSavingGroupBergilir();
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

  /// Menampilkan modal bottom sheet untuk edit nama tabungan.
  void _showEditTabunganModal() {
    _goalsNameController.text =
        goalsName; // Set text field with current goalsName
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
                                'Edit Tabungan Bergilir',
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
                                    controller: _goalsNameController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Nama Tabungan tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      fillColor: Colors.blue.shade50,
                                      filled: true,
                                      hintText: 'Masukan Nama Tabungan',
                                      hintStyle: const TextStyle(
                                          color: Colors.black54),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 12),
                                      errorText: _goalsNameError,
                                      errorMaxLines: 2,
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
                                      String newName =
                                          _goalsNameController.text;
                                      Navigator.pop(context);
                                      await _updateSavingGroupNameBergilir(
                                          newName);
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
      if (mounted) {
        // ADD MOUNTED CHECK HERE
        setState(() {
          _goalsNameError = null;
        });
      }
    });
  }

  // Fungsi untuk mengarsipkan (menghapus) saving group bergilir
  Future<void> _archiveSavingGroupBergilir() async {
    String? token = await _tokenManager
        .getToken(); // Ambil token dari TokenManager, mengambil token otentikasi dari TokenManager
    if (token == null) {
      if (mounted) {
        // ADD MOUNTED CHECK HERE
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Token tidak ditemukan, mohon login kembali.'), // SnackBar error token, menampilkan SnackBar jika token tidak ditemukan
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final String savingGroupId = widget
        .savingGroupId; // Ambil savingGroupId dari widget, mendapatkan savingGroupId dari widget
    final String archiveEndpoint =
        "/saving-groups/rotating/$savingGroupId/archive"; // Endpoint API untuk archive, endpoint API untuk mengarsipkan tabungan bergilir
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
        final responseBody = utf8.decode(response.bodyBytes);
        final responseData = json.decode(responseBody);
        if (responseData['code'] == 200 && responseData['status'] == 'OK') {
          // Navigasi kembali ke OurGoals dengan flag sukses hapus, jika hapus berhasil, kembali ke halaman OurGoals
          if (mounted) {
            Navigator.popAndPushNamed(
              context,
              '/ourGoals',
              arguments: {'deletionSuccess': true},
            );
          }
        } else {
          // Tampilkan SnackBar error hapus, jika hapus gagal, tampilkan SnackBar error
          if (mounted) {
            // ADD MOUNTED CHECK HERE
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
              arguments: {
                'deletionSuccess': false
              }, // Changed to false to reflect failure
            );
          }
        }
      } else {
        // Tampilkan SnackBar error status code, jika status code response bukan 200, tampilkan SnackBar error
        if (mounted) {
          // ADD MOUNTED CHECK HERE
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "Gagal menghapus tabungan. Status code: ${response.statusCode}"), // Pesan error status code, menampilkan status code dari response API
              backgroundColor: Colors.red,
            ),
          );
          // Navigasi kembali ke OurGoals dengan flag gagal hapus, tetap kembali ke halaman OurGoals meskipun hapus gagal karena status code error
          Navigator.popAndPushNamed(
            context,
            '/ourGoals',
            arguments: {
              'deletionSuccess': false
            }, // Changed to false to reflect failure
          );
        }
      }
    } catch (e) {
      // Tampilkan SnackBar error exception, jika terjadi exception saat request API, tampilkan SnackBar error
      if (mounted) {
        // ADD MOUNTED CHECK HERE
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
          arguments: {
            'deletionSuccess': false
          }, // Changed to false to reflect failure
        );
      }
    }
  }

  // Fungsi untuk memperbarui nama saving group bergilir
  Future<void> _updateSavingGroupNameBergilir(String newName) async {
    _showLoadingOverlay(context);

    String? token = await _tokenManager.getToken();
    if (token == null) {
      _hideLoadingOverlay(context);
      if (mounted) {
        // ADD MOUNTED CHECK HERE
        setState(() {
          _errorMessage = "Token tidak ditemukan";
        });
      }
      return;
    }

    final String savingGroupId = widget.savingGroupId;
    final String updateNameEndpoint = "/saving-groups/rotating/$savingGroupId";
    final String apiUrl = baseUrl + updateNameEndpoint;

    try {
      final response = await http.patch(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': newName}),
      );

      if (response.statusCode == 200) {
        final responseBody =
            utf8.decode(response.bodyBytes); // Decode response body using UTF-8
        final responseData = json.decode(responseBody);
        if (responseData['code'] == 200 && responseData['status'] == 'OK') {
          await fetchData();
          if (mounted) {
            // ADD MOUNTED CHECK HERE
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Nama Tabungan berhasil diubah!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            // ADD MOUNTED CHECK HERE
            setState(() {
              _goalsNameError = responseData['errors'] != null &&
                      (responseData['errors'] as List).isNotEmpty
                  ? (responseData['errors'] as List)[0].toString()
                  : "Gagal mengubah nama tabungan, silahkan coba lagi!";
            });
          }
        }
      } else {
        if (mounted) {
          // ADD MOUNTED CHECK HERE
          setState(() {
            _errorMessage =
                "Gagal mengubah nama tabungan. Status code: ${response.statusCode}";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        // ADD MOUNTED CHECK HERE
        setState(() {
          _errorMessage =
              "Terjadi kesalahan saat mengubah nama tabungan: ${e.toString()}";
        });
      }
    } finally {
      _hideLoadingOverlay(context);
    }
  }

  // Method untuk menampilkan loading overlay
  void _showLoadingOverlay(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const LoadingOverlay();
      },
    );
  }

  // Method untuk menyembunyikan loading overlay
  void _hideLoadingOverlay(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: _userRole == 'ADMIN' // Conditional rendering here
                        ? IconButton(
                            icon: Icon(Icons.settings,
                                color: Colors.blue.shade900),
                            onPressed: _showSettingsModal,
                          )
                        : const SizedBox
                            .shrink(), // Or any other widget if you want to show something else when not admin
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.celebration,
                        size: 64,
                        color: Colors.blue.shade400,
                      ),
                      const SizedBox(height: 16),
                      isLoading
                          ? _buildShimmerText(height: 24)
                          : Text(
                              goalsName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                      const SizedBox(height: 8),
                      isLoading
                          ? _buildShimmerText(height: 32)
                          : Text(
                              currencyFormat.format(_goalsData[
                                  'saldoTabungan']), // Static Value Display - Will be replaced by API later
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                              textAlign: TextAlign.center,
                            ),
                      const SizedBox(height: 8),
                      isLoading
                          ? _buildShimmerText(height: 16)
                          : Text(
                              statusTabungan == 'ACTIVE'
                                  ? 'Aktif'
                                  : 'Tidak Aktif', // Updated status text here
                              style: TextStyle(
                                fontSize: 16,
                                color: statusTabungan == 'ACTIVE'
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                      const SizedBox(height: 24),
                      if (statusTabungan == 'INACTIVE')
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UndangAnggotaBergilir(
                                    savingGroupId: widget.savingGroupId,
                                    goalsName: goalsName,
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
                            child: Text(
                              'Undang Anggota',
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      if (statusTabungan == 'INACTIVE')
                        const SizedBox(height: 16),
                      // Circle Avatar Anggota Tabungan (muncul sebelum tombol aktivasi ketika tidak aktif)
                      if (statusTabungan == 'INACTIVE')
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RincianAnggotaBergilir(
                                      savingGroupId: widget
                                          .savingGroupId, // Menggunakan savingGroupId yang sudah ada di DetailTabunganBergilir
                                      goalsName:
                                          goalsName, // Menggunakan goalsName yang sudah ada di DetailTabunganBergilir
                                      isActive: widget.isActive,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                children: isLoading
                                    ? _buildShimmerCircleAvatars()
                                    : [
                                        ..._allMembers.take(2).map(
                                              (member) => CircleAvatar(
                                                radius: 20,
                                                backgroundColor: Colors
                                                    .primaries[_allMembers
                                                        .indexOf(member) %
                                                    Colors.primaries.length],
                                                child: Text(
                                                  member.isNotEmpty
                                                      ? member[0].toUpperCase()
                                                      : 'U',
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                        if (_allMembers.length > 3)
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Colors.purple,
                                            child: Text(
                                              '+${_allMembers.length - 2}',
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                      ],
                              ),
                            ),
                          ],
                        ),
                      if (statusTabungan == 'INACTIVE')
                        const SizedBox(height: 16),
                      if (statusTabungan == 'INACTIVE' &&
                          _userRole ==
                              'ADMIN') // Kondisi button aktivasi hanya untuk ADMIN
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AktivasiTabunganBergilir(
                                    allMembers: _allMembers,
                                    savingGroupId: widget.savingGroupId,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Aktivasi Tabungan Bergilir',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      // Circle Avatar Anggota Tabungan (hanya satu baris ketika aktif)
                      if (statusTabungan == 'ACTIVE')
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RincianAnggotaBergilir(
                                      savingGroupId: widget
                                          .savingGroupId, // Menggunakan savingGroupId yang sudah ada di DetailTabunganBergilir
                                      goalsName:
                                          goalsName, // Menggunakan goalsName yang sudah ada di DetailTabunganBergilir
                                      isActive: widget.isActive,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                children: isLoading
                                    ? _buildShimmerCircleAvatars()
                                    : [
                                        ..._allMembers.take(2).map(
                                              (member) => CircleAvatar(
                                                radius: 20,
                                                backgroundColor: Colors
                                                    .primaries[_allMembers
                                                        .indexOf(member) %
                                                    Colors.primaries.length],
                                                child: Text(
                                                  member.isNotEmpty
                                                      ? member[0].toUpperCase()
                                                      : 'U',
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                        if (_allMembers.length > 3)
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Colors.purple,
                                            child: Text(
                                              '+${_allMembers.length - 2}',
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                      ],
                              ),
                            ),
                            const Spacer(),
                            if (_userRole ==
                                'ADMIN') // Conditional rendering based on user role
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (BuildContext context) =>
                                          GilirTabungan(
                                        goalsData: _goalsData,
                                        isActive: widget.isActive,
                                        savingGroupId: widget
                                            .savingGroupId, // Pass savingGroupId here
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
                                child: Text(
                                  'Gilir Tabungan',
                                  style: TextStyle(
                                    color: Colors.blue.shade900,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else
                              const SizedBox
                                  .shrink(), // Or you can show a disabled button if you prefer, e.g., a greyed out button:  ElevatedButton(onPressed: null, child: Text('Gilir Tabungan', style: TextStyle(color: Colors.grey),)),
                          ],
                        ),
                      if (statusTabungan == 'ACTIVE')
                        const SizedBox(height: 12),
                      if (statusTabungan == 'ACTIVE')
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    DetailTargetTabunganBergilir(
                                  goalsData:
                                      _goalsData, // Mengirim data goalsData
                                  isActive:
                                      widget.isActive, // Mengirim data isActive
                                  targetKontribusi:
                                      targetKontribusi, // Pass targetKontribusi
                                  savingGroupId: widget.savingGroupId,
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
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildProgressHeader(),
                                  const SizedBox(height: 14),
                                  isLoading
                                      ? _buildShimmerText(height: 18)
                                      : Text(
                                          '${currencyFormat.format(_goalsData['saldoTabungan'])} / ${currencyFormat.format(targetSaldoTabungan)}', // Use _goalsData['saldoTabungan']
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.blue.shade900,
                                          ),
                                        ),
                                  const SizedBox(height: 8),
                                  isLoading
                                      ? _buildShimmerProgress()
                                      : LinearProgressIndicator(
                                          value: isLoading
                                              ? 0
                                              : progressTabungan.clamp(0.0,
                                                  1.0), // Use progressTabungan
                                          backgroundColor: Colors.grey.shade300,
                                          color: Colors.blue.shade400,
                                        ),
                                  const SizedBox(height: 8),
                                  _buildProgressFooter(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: cariTransaksiController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          fillColor: Colors.blue.shade50,
                          filled: true,
                          hintText: 'Cari Transaksi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      isLoading
                          ? _buildShimmerTransactionHistory()
                          : historiTransaksi.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 24.0),
                                  child: Text(
                                    'Belum ada transaksi',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: historiTransaksi.length,
                                  itemBuilder: (context, index) {
                                    final transaction = historiTransaksi[index];
                                    return ListTile(
                                      title:
                                          Text(transaction['jenisTransaksi']),
                                      subtitle: Text(dateFormat.format(
                                          transaction['tanggalTransaksi'])),
                                      trailing: Text(currencyFormat.format(
                                          transaction['jumlahTransaksi'])),
                                    );
                                  },
                                ),
                      if (statusTabungan == 'ACTIVE')
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TambahUangBergilir(goalsData: _goalsData),
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
                        ),
                      if (statusTabungan == 'ACTIVE')
                        const SizedBox(height: 16),
                      if (statusTabungan == 'ACTIVE')
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TarikUangBergilir(goalsData: _goalsData),
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
                        )
                    ],
                  ),
                ],
              ),
            ),
    );
  }

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
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const OurGoals()),
            (Route<dynamic> route) => false,
          );
        },
      ),
      title: Text(
        'Detail Tabungan Bergilir',
        style: const TextStyle(
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
        if (_userRole ==
            'ADMIN') // Conditional rendering for settings icon in AppBar
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: _showSettingsModal,
          )
        else
          const SizedBox
              .shrink(), // Or any other widget if you want to show something else when not admin
      ],
    );
  }

  Widget _buildProgressHeader() {
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
          message: 'Total progress dari semua anggota',
          child: Icon(
            Icons.info_outline,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        isLoading
            ? _buildShimmerText(width: 80)
            : Text(
                _goalsData['durasiTabungan'] ??
                    '', // Static Value Display - Will be replaced by API later
                style: TextStyle(color: Colors.blue.shade700)),
        isLoading
            ? _buildShimmerText(width: 50)
            : Text(
                isLoading
                    ? '0%'
                    : '${(progressTabungan * 100).toStringAsFixed(2)}%', // Use calculated progressTabungan
                style: TextStyle(color: Colors.blue.shade700),
              ),
      ],
    );
  }

  Widget _buildShimmerText({double height = 20, double? width}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        color: Colors.grey,
      ),
    );
  }

  List<Widget> _buildShimmerCircleAvatars() {
    return List.generate(
      3,
      (index) => Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey,
          ),
        ),
      ),
    );
  }

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

  Widget _buildShimmerProgress() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: LinearProgressIndicator(
        backgroundColor: Colors.grey.shade300,
        color: Colors.blue.shade400,
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
