// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'package:digigoals_app/OurGoals.dart';
import 'package:digigoals_app/TabunganBersama/DetailKontribusiTabunganBersama.dart';
import 'package:digigoals_app/TabunganBersama/RincianAnggotaBersama.dart';
import 'package:digigoals_app/TabunganBersama/TambahUangBersama.dart';
import 'package:digigoals_app/TabunganBersama/TarikUangBersama.dart';
import 'package:digigoals_app/TabunganBersama/UndangAnggotaBersama.dart';
import 'package:digigoals_app/api/api_config.dart';
import 'package:digigoals_app/auth/token_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

class DetailTabunganBersama extends StatefulWidget {
  final String savingGroupId;

  const DetailTabunganBersama({super.key, required this.savingGroupId});

  @override
  State<DetailTabunganBersama> createState() => _DetailTabunganBersamaState();
}

class _DetailTabunganBersamaState extends State<DetailTabunganBersama> {
  final TextEditingController cariTransaksiController = TextEditingController();
  final TextEditingController _goalsNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  String? _goalsNameError;
  String? _errorMessage;
  bool _isSnackBarShown = false;
  String? currentUserRole; // Added to store current user's role

  late String goalsName = '';
  late double saldoTabungan = 0.0;
  late String statusTabungan = '';
  late double progressTabungan = 0.0;
  late int targetSaldoTabungan = 0;
  String? durasiTabungan = '';
  List<Member> members = [];
  List<Map<String, dynamic>> historiTransaksi = [];
  late String memberName;
  final Map<String, dynamic> _goalsData = {};
  late List<Member> _allMembers = [];
  final TokenManager _tokenManager = TokenManager();

  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'IDR ',
    decimalDigits: 2,
  );

  final DateFormat dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    fetchSavingGroupDetails();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isSnackBarShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkInvitationSuccess();
      });
    }
  }

  void _checkInvitationSuccess() {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      if (arguments['invitationSuccess'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Undang Anggota Telah Berhasil Dilakukan!'),
            backgroundColor: Colors.green,
          ),
        );
        _isSnackBarShown = true;
      } else if (arguments['invitationSuccess'] == false) {
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
        _isSnackBarShown = true;
      }
    }
  }

  @override
  void dispose() {
    cariTransaksiController.dispose();
    _goalsNameController.dispose();
    super.dispose();
  }

  Future<void> fetchSavingGroupDetails() async {
    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    String? token = await _tokenManager.getToken();
    if (token == null) {
      setState(() {
        isLoading = false;
        _errorMessage = "Token tidak ditemukan";
      });
      return;
    }

    try {
      final savingGroupUrl =
          Uri.parse('$baseUrl/saving-groups/${widget.savingGroupId}');
      final membersUrl =
          Uri.parse('$baseUrl/members?savingGroupId=${widget.savingGroupId}');

      final headers = {'Authorization': 'Bearer $token'};

      final responses = await Future.wait([
        http.get(savingGroupUrl, headers: headers),
        http.get(membersUrl, headers: headers),
      ]);

      final groupResponse = responses[0];
      final membersResponse = responses[1];

      if (groupResponse.statusCode == 200 &&
          membersResponse.statusCode == 200) {
        final groupData = json.decode(utf8.decode(groupResponse.bodyBytes));
        final membersData = json.decode(utf8.decode(membersResponse.bodyBytes));

        if (groupData['code'] == 200 && groupData['status'] == 'OK') {
          final savingGroupDetail = groupData['data'];
          if (membersData['code'] == 200 && membersData['status'] == 'OK') {
            List<Member> fetchedMembers = (membersData['data'] as List)
                .map((item) => Member.fromJson(item))
                .toList();

            String? currentUserId = await _tokenManager.getUserId();
            if (currentUserId != null) {
              Member? currentUserMember = fetchedMembers.firstWhere(
                (member) => member.userId == currentUserId,
                orElse: () => Member.empty(),
              );
              if (!currentUserMember.isEmpty) {
                currentUserRole = currentUserMember.role;
              } else {
                currentUserRole = null;
                print("Current user not found in members list.");
              }
            } else {
              currentUserRole = null;
              print("Could not retrieve user ID from token.");
            }

            setState(() {
              goalsName = savingGroupDetail['name'] ?? 'Nama Goals';
              _goalsNameController.text = goalsName;
              saldoTabungan =
                  (savingGroupDetail['balance'] as num?)?.toDouble() ?? 0.0;
              progressTabungan =
                  (savingGroupDetail['progress'] as num?)?.toDouble() ?? 0.0;
              targetSaldoTabungan =
                  savingGroupDetail['detail']['target_amount'] ?? 0;
              durasiTabungan = savingGroupDetail['detail']['duration'] != null
                  ? '${(savingGroupDetail['detail']['duration'] / 30).floor()} Bulan'
                  : 'Durasi Tidak Ditentukan';
              _allMembers = fetchedMembers;
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
              _errorMessage = membersData['errors'] != null &&
                      (membersData['errors'] as List).isNotEmpty
                  ? (membersData['errors'] as List)[0].toString()
                  : "Gagal mengambil data anggota tabungan, silahkan coba lagi!";
            });
          }
        } else {
          setState(() {
            isLoading = false;
            _errorMessage = groupData['errors'] != null &&
                    (groupData['errors'] as List).isNotEmpty
                ? (groupData['errors'] as List)[0].toString()
                : "Gagal mengambil detail tabungan, silahkan coba lagi!";
          });
        }
      } else {
        setState(() {
          isLoading = false;
          _errorMessage =
              "Gagal mengambil data. Status Group: ${groupResponse.statusCode}, Status Members: ${membersResponse.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        _errorMessage = "Terjadi kesalahan: ${e.toString()}";
      });
    }
  }

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
                            'Hapus Tabungan Bersama',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _archiveSavingGroup();
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

  Future<void> _archiveSavingGroup() async {
    String? token = await _tokenManager.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token tidak ditemukan, mohon login kembali.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String savingGroupId = widget.savingGroupId;
    final String archiveEndpoint =
        "/saving-groups/joint/$savingGroupId/archive";
    final String apiUrl = baseUrl + archiveEndpoint;

    try {
      final response = await http.patch(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        if (responseData['code'] == 200 && responseData['status'] == 'OK') {
          Navigator.popAndPushNamed(
            context,
            '/ourGoals',
            arguments: {'deletionSuccess': true},
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['errors'] != null &&
                      (responseData['errors'] as List).isNotEmpty
                  ? (responseData['errors'] as List)[0].toString()
                  : "Gagal menghapus tabungan, silahkan coba lagi!"),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.popAndPushNamed(
            context,
            '/ourGoals',
            arguments: {'deletionSuccess': true},
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Gagal menghapus tabungan. Status code: ${response.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.popUntil(context, ModalRoute.withName('/ourGoals'));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Terjadi kesalahan saat menghapus tabungan: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.popAndPushNamed(
        context,
        '/ourGoals',
        arguments: {'deletionSuccess': true},
      );
    }
  }

  Future<void> _updateSavingGroupName(String newName) async {
    _showLoadingOverlay(context);

    String? token = await _tokenManager.getToken();
    if (token == null) {
      _hideLoadingOverlay(context);
      setState(() {
        _errorMessage = "Token tidak ditemukan";
      });
      return;
    }

    final String savingGroupId = widget.savingGroupId;
    final String updateNameEndpoint = "/saving-groups/joint/$savingGroupId";
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
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        if (responseData['code'] == 200 && responseData['status'] == 'OK') {
          await fetchSavingGroupDetails();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nama Tabungan berhasil diubah!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            _goalsNameError = responseData['errors'] != null &&
                    (responseData['errors'] as List).isNotEmpty
                ? (responseData['errors'] as List)[0].toString()
                : "Gagal mengubah nama tabungan, silahkan coba lagi!";
          });
        }
      } else {
        setState(() {
          _errorMessage =
              "Gagal mengubah nama tabungan. Status code: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            "Terjadi kesalahan saat mengubah nama tabungan: ${e.toString()}";
      });
    } finally {
      _hideLoadingOverlay(context);
    }
  }

  void _showEditTabunganModal() {
    _goalsNameController.text = goalsName;
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
                                      await _updateSavingGroupName(newName);
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
        _goalsNameError = null;
      });
    });
  }

  void _showLoadingOverlay(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const LoadingOverlay();
      },
    );
  }

  void _hideLoadingOverlay(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: currentUserRole ==
                              'ADMIN' // Conditionally show settings icon
                          ? IconButton(
                              icon: Icon(Icons.settings,
                                  color: Colors.blue.shade900),
                              onPressed: _showSettingsModal,
                            )
                          : SizedBox
                              .shrink(), // Or any other widget if you want to show something else when not admin
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          children: [
                            Icon(
                              Icons.groups,
                              size: 64,
                              color: Colors.blue.shade400,
                            ),
                            const SizedBox(height: 16),
                            isLoading
                                ? _buildShimmerText(height: 32)
                                : Text(
                                    isLoading ? ' ' : goalsName,
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
                                    currencyFormat.format(saldoTabungan),
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade900,
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
                                        _isSnackBarShown = false;
                                      });
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        _checkInvitationSuccess();
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
                                      savingGroupId: widget.savingGroupId,
                                      goalsName: goalsName,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: isLoading
                                    ? _buildShimmerCircleAvatars()
                                    : [
                                        ..._allMembers.take(2).map(
                                              (member) => Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8.0),
                                                child: CircleAvatar(
                                                  radius: 20,
                                                  backgroundColor: Colors
                                                      .primaries[_allMembers
                                                          .indexOf(member) %
                                                      Colors.primaries.length],
                                                  child: Text(
                                                    member.name.isNotEmpty
                                                        ? member.name[0]
                                                            .toUpperCase()
                                                        : 'U',
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        if (_allMembers.length > 2)
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Colors.grey,
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
                        const SizedBox(height: 24),
                        _buildProgressCard(),
                        const SizedBox(height: 16),
                        _buildTransactionSearchField(),
                        const SizedBox(height: 16),
                        _buildTransactionHistoryList(),
                        const SizedBox(height: 16),
                        _buildTambahUangButton(),
                        const SizedBox(height: 16),
                        _buildTarikUangButton(),
                      ],
                    ),
                  ],
                ),
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
          Navigator.pop(context);
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
        currentUserRole ==
                'ADMIN' // Conditionally show settings icon in AppBar (Alternative)
            ? IconButton(
                icon: Icon(Icons.settings, color: Colors.white),
                onPressed: _showSettingsModal,
              )
            : SizedBox.shrink(),
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

  Widget _buildProgressCard() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailKontribusiTabunganBersama(
              goalsData: {
                'savingGroupId': widget.savingGroupId,
                'goalsName': goalsName,
                'saldoTabungan': saldoTabungan,
                'progressTabungan': progressTabungan,
                'targetTabungan': targetSaldoTabungan,
                'members': _allMembers,
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
              _buildProgressCardHeader(),
              const SizedBox(height: 14),
              _buildProgressCardBalance(),
              const SizedBox(height: 8),
              _buildProgressCardProgressBar(),
              const SizedBox(height: 8),
              _buildProgressCardSummary(),
            ],
          ),
        ),
      ),
    );
  }

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
          message: 'Total progress dari semua anggota',
          child: Icon(
            Icons.info_outline,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCardBalance() {
    return isLoading
        ? _buildShimmerText(height: 18)
        : Text(
            '${currencyFormat.format(saldoTabungan)} / ${currencyFormat.format(targetSaldoTabungan)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.blue.shade900,
            ),
          );
  }

  Widget _buildProgressCardProgressBar() {
    return LinearProgressIndicator(
      value: isLoading ? 0 : progressTabungan,
      backgroundColor: Colors.grey.shade300,
      color: Colors.blue.shade400,
    );
  }

  Widget _buildProgressCardSummary() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(durasiTabungan ?? '',
            style: TextStyle(color: Colors.blue.shade700)),
        Text(
          isLoading ? '0%' : '${(progressTabungan * 100).toStringAsFixed(2)}%',
          style: TextStyle(color: Colors.blue.shade700),
        ),
      ],
    );
  }

  Widget _buildTransactionSearchField() {
    return TextFormField(
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
    );
  }

  Widget _buildTransactionHistoryList() {
    return isLoading
        ? _buildShimmerTransactionHistory()
        : historiTransaksi.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
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
                    title: Text(transaction['jenisTransaksi']),
                    subtitle: Text(
                        dateFormat.format(transaction['tanggalTransaksi'])),
                    trailing: Text(
                        currencyFormat.format(transaction['jumlahTransaksi'])),
                  );
                },
              );
  }

  Widget _buildTambahUangButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TambahUangBersama(goalsData: _goalsData),
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

  Widget _buildTarikUangButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TarikUangBersama(goalsData: _goalsData),
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

class Member {
  const Member({
    required this.userId,
    required this.name,
    required this.role,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      userId: json['user_id']?.toString() ?? '',
      name: json['user']?['customer']?['name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }

  static Member empty() {
    return const Member(userId: '', name: '', role: '');
  }

  bool get isEmpty => userId == '';

  final String userId;
  final String name;
  final String role;
}
