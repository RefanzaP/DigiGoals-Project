import 'package:digigoals_app/TabunganBergilir/AktivasiTabunganBergilir.dart';
import 'package:digigoals_app/TabunganBergilir/DetailTargetTabunganBergilir.dart';
import 'package:digigoals_app/TabunganBergilir/GilirTabungan.dart';
import 'package:digigoals_app/TabunganBergilir/RincianAnggotaBergilir.dart';
import 'package:digigoals_app/TabunganBergilir/TambahUangBergilir.dart';
import 'package:digigoals_app/TabunganBergilir/TarikUangBergilir.dart';
import 'package:digigoals_app/TabunganBergilir/UndangAnggotaBergilir.dart';
import 'package:digigoals_app/OurGoals.dart';
import 'package:digigoals_app/data/goal_data.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DetailTabunganBergilir extends StatefulWidget {
  final bool isActive;

  const DetailTabunganBergilir({super.key, this.isActive = false});

  @override
  State<DetailTabunganBergilir> createState() => _DetailTabunganBergilirState();
}

class _DetailTabunganBergilirState extends State<DetailTabunganBergilir> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController _tabunganNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> members = [];
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;
  String? _tabunganNameError;

  late String tabunganName;
  late String saldo;
  late String status;
  double targetProgress = 0.0;
  String targetAmount = 'Rp. 0';
  String targetDuration = '0 Bulan';
  Map<String, dynamic>? _goalData; // Menyimpan data goal

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    final data = await _getTabunganData();
    if (data != null) {
      setState(() {
        _goalData = data; // Simpan data goal
        tabunganName = data['goalName'] ?? 'Gudang Garam Jaya 🔥';
        _tabunganNameController.text = tabunganName;
        saldo = data['saldo'] ?? 'IDR 0,00';
        status = data['status'] ?? (widget.isActive ? 'Aktif' : 'Tidak Aktif');
        targetProgress = data['progress'] ?? 0.0;
        targetAmount = data['targetAmount'] ?? 'Rp. 100.000.000';
        targetDuration = data['targetDuration'] ?? '5 Bulan';
        members = (data['members'] as List<dynamic>?)
                ?.map((member) => member['name'] as String)
                .toList() ??
            [];
        transactions = (data['transactions'] as List<dynamic>?)
                ?.map((transaction) => transaction as Map<String, dynamic>)
                .toList() ??
            [];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load tabungan data.'),
        ),
      );
    }
  }

  Future<Map<String, dynamic>?> _getTabunganData() async {
    try {
      final goals = await fetchGoalsFromApiOrDatabase();
      // Ambil data goal berdasarkan nama tabungan yang dikirim dari BuatTabunganBergilir
      // Mengambil data terakhir karena data baru akan berada di akhir list setelah di buat
      final tabunganData = goals.lastWhere(
        (goal) => goal['type'] == 'Tabungan Bergilir',
      );
      return tabunganData;
    } catch (e) {
      print('Error fetching tabungan data: $e');
      return null;
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _tabunganNameController.dispose();
    super.dispose();
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
                            style: TextStyle(
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

  void _showEditTabunganModal() {
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
                                'DIGI Mobile',
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
                                    controller: _tabunganNameController,
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
                                      errorText: _tabunganNameError,
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
                                        tabunganName =
                                            _tabunganNameController.text;
                                        if (_goalData != null) {
                                          _goalData!['goalName'] = tabunganName;
                                          _updateGoalData(_goalData!);
                                        }
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
        _tabunganNameError = null;
      });
    });
  }

  Future<void> _updateGoalData(Map<String, dynamic> updatedGoal) async {
    try {
      final goals = await fetchGoalsFromApiOrDatabase();
      final index = goals.indexWhere((goal) =>
          goal['type'] == 'Tabungan Bergilir' &&
          goal['goalName'] == _goalData!['goalName']);
      if (index != -1) {
        goals[index] = updatedGoal;
      } else {
        print("Data tidak ditemukan");
      }
    } catch (e) {
      print('Gagal mengupdate data: $e');
    }
  }

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
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const DetailTabunganBergilir(),
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
      body: isLoading
          ? _buildShimmerPlaceholder()
          : SingleChildScrollView(
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
                        tabunganName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        saldo,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        status,
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
                                  builder: (context) =>
                                      UndanganAnggotaBergilir(),
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
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RincianAnggotaDeaktivasi(),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            ...members.take(2).map((member) => CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.primaries[
                                      members.indexOf(member) %
                                          Colors.primaries.length],
                                  child: Text(
                                    member,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )),
                            if (members.length > 3)
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.purple,
                                child: Text(
                                  '+${members.length - 2}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                          ],
                        ),
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
                                  builder: (context) =>
                                      AktivasiTabunganBergilir(),
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
                      if (widget.isActive)
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RincianAnggotaBergilir(),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  ...members.take(2).map((member) =>
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.primaries[
                                            members.indexOf(member) %
                                                Colors.primaries.length],
                                        child: Text(
                                          member,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      )),
                                  if (members.length > 3)
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.purple,
                                      child: Text(
                                        '+${members.length - 2}',
                                        style: TextStyle(color: Colors.white),
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
                                    builder: (BuildContext context) =>
                                        GilirTabungan(),
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
                                    DetailTargetTabunganBergilir(),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                            'Total progress dari semua anggota',
                                        child: Icon(
                                          Icons.info_outline,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    targetAmount,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: targetProgress,
                                    backgroundColor: Colors.grey.shade300,
                                    color: Colors.blue.shade400,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(targetDuration,
                                          style: TextStyle(
                                              color: Colors.blue.shade700)),
                                      Text('${(targetProgress * 100).toInt()}%',
                                          style: TextStyle(
                                              color: Colors.blue.shade700)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: searchController,
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
                      transactions.isEmpty
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
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                final transaction = transactions[index];
                                return ListTile(
                                  title: Text(transaction['title']),
                                  subtitle: Text(transaction['subtitle']),
                                  trailing: Text(transaction['amount']),
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

  Widget _buildShimmerPlaceholder() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 200,
              height: 20,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 150,
              height: 30,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 100,
              height: 20,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(
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
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 60,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
