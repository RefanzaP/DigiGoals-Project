// ignore_for_file: use_build_context_synchronously

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

class Account {
  final String namaRekening;

  Account({
    required this.namaRekening,
  });
}

class DetailTabunganBergilir extends StatefulWidget {
  final bool isActive;

  const DetailTabunganBergilir({super.key, this.isActive = false});

  @override
  State<DetailTabunganBergilir> createState() => _DetailTabunganBergilirState();
}

class _DetailTabunganBergilirState extends State<DetailTabunganBergilir> {
  final TextEditingController cariTransaksiController = TextEditingController();
  final TextEditingController _goalsNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  String? _goalsNameError;

  late String goalsName;
  late double saldoTabungan;
  late String statusTabungan;
  double progressTabungan = 0.0;
  late double targetSaldoTabungan;
  String? durasiTabungan;
  List<String> members = [];
  List<Map<String, dynamic>> historiTransaksi = [];
  late String memberName;
  Map<String, dynamic> _goalsData = {};

  late List<String> _allMembers;

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

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    // Simulate loading
    await Future.delayed(const Duration(seconds: 2));

    // Static data for demonstration
    _goalsData = {
      'goalsName': 'Gudang Garam Jaya 🔥',
      'goalsType': 'Tabungan Bergilir',
      'creationDate': '24-05-2024',
      'members': ['Fafa', 'Gina', 'Hani', 'Olaf'],
      'saldoTabungan': 20000000.00,
      'statusTabungan': widget.isActive ? 'Aktif' : 'Tidak Aktif',
      'progressTabungan': 0.4,
      'targetTabungan': 50000000.00,
      'durasiTabungan': '5 Bulan',
      'transactions': [
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
      ],
    };
    // Initialize data from the static data
    setState(() {
      goalsName = _goalsData['goalsName'];
      _goalsNameController.text = goalsName;
      saldoTabungan = _goalsData['saldoTabungan'];
      statusTabungan = _goalsData['statusTabungan'];
      progressTabungan = _goalsData['progressTabungan'];
      targetSaldoTabungan = _goalsData['targetTabungan'];
      durasiTabungan = _goalsData['durasiTabungan'];
      members = List<String>.from(_goalsData['members']);
      historiTransaksi =
          List<Map<String, dynamic>>.from(_goalsData['transactions']);
      isLoading = false;
      memberName = _goalsData['members'].first;
      _allMembers = List<String>.from(members);
    });
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
                          icon: Icon(widget.isActive
                              ? Icons.not_interested
                              : Icons.delete),
                          label: Text(
                            widget.isActive
                                ? 'Deaktivasi Tabungan Bergilir'
                                : 'Hapus Tabungan Bergilir',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            if (widget.isActive) {
                              _showDeactivationConfirmation();
                            }
                            // Add your delete logic here
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
                                      setState(() {
                                        goalsName = _goalsNameController.text;
                                        _goalsData['goalsName'] = goalsName;
                                      });
                                      Navigator.pop(context);
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

  /// Menampilkan dialog konfirmasi deaktivasi tabungan.
  void _showDeactivationConfirmation() {
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
                  const Text(
                    'DIGI Mobile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    'Apakah Anda yakin ingin melakukan deaktivasi tabungan?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
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
                            Navigator.pop(context);
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
                            Navigator.pop(context);
                            _deactivateSavings();
                            _showLoadingAndSuccess();
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

  /// Fungsi untuk menonaktifkan tabungan dan mengubah status.
  Future<void> _deactivateSavings() async {
    setState(() {
      statusTabungan = 'Tidak Aktif';
      _goalsData['statusTabungan'] = 'Tidak Aktif';
    });
  }

  /// Menampilkan dialog loading dan simulasi proses deaktivasi.
  void _showLoadingAndSuccess() {
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
                    'Memproses Deaktivasi...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      _showSuccessDialog();
    });
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
                    'Tabungan Bergilir Berhasil Dinonaktifkan!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) =>
                                  DetailTabunganBergilir(isActive: false)),
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
                          color: Colors.blue.shade900,
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
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.settings, color: Colors.blue.shade900),
                onPressed: _showSettingsModal,
              ),
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
                Text(
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
                        textAlign: TextAlign.center,
                      ),
                const SizedBox(height: 8),
                Text(
                  isLoading ? ' ' : statusTabungan,
                  style: TextStyle(
                    fontSize: 16,
                    color: widget.isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (!widget.isActive)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UndangAnggotaBergilir(),
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
                if (!widget.isActive) const SizedBox(height: 16),
                // Circle Avatar Anggota Tabungan (muncul sebelum tombol aktivasi ketika tidak aktif)
                if (!widget.isActive)
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RincianAnggotaBergilir(
                                goalsData: _goalsData,
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
                                          backgroundColor: Colors.primaries[
                                              _allMembers.indexOf(member) %
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
                if (!widget.isActive) const SizedBox(height: 16),
                if (!widget.isActive)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AktivasiTabunganBergilir(
                              allMembers: _allMembers,
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
                if (widget.isActive)
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RincianAnggotaBergilir(
                                goalsData: _goalsData,
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
                                          backgroundColor: Colors.primaries[
                                              _allMembers.indexOf(member) %
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
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) => GilirTabungan(
                                goalsData: _goalsData,
                                isActive: widget.isActive,
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
                      ),
                    ],
                  ),
                if (widget.isActive) const SizedBox(height: 12),
                if (widget.isActive)
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              DetailTargetTabunganBergilir(
                            goalsData: _goalsData, // Mengirim data goalsData
                            isActive: widget.isActive, // Mengirim data isActive
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
                            Row(
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
                            ),
                            const SizedBox(height: 14),
                            isLoading
                                ? _buildShimmerText(height: 18)
                                : Text(
                                    '${currencyFormat.format(saldoTabungan)} / ${currencyFormat.format(targetSaldoTabungan)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: isLoading
                                  ? 0
                                  : (saldoTabungan / targetSaldoTabungan)
                                      .clamp(0.0, 1.0),
                              backgroundColor: Colors.grey.shade300,
                              color: Colors.blue.shade400,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_goalsData['durasiTabungan'] ?? '',
                                    style:
                                        TextStyle(color: Colors.blue.shade700)),
                                Text(
                                  isLoading
                                      ? '0%'
                                      : '${((saldoTabungan / targetSaldoTabungan) * 100).toStringAsFixed(2)}%',
                                  style: TextStyle(color: Colors.blue.shade700),
                                ),
                              ],
                            ),
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
                                title: Text(transaction['jenisTransaksi']),
                                subtitle: Text(dateFormat
                                    .format(transaction['tanggalTransaksi'])),
                                trailing: Text(currencyFormat
                                    .format(transaction['jumlahTransaksi'])),
                              );
                            },
                          ),
                if (widget.isActive)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const TambahUangBergilir(),
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
                if (widget.isActive) const SizedBox(height: 16),
                if (widget.isActive)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const TarikUangBergilir(),
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
}
