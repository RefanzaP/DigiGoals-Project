// goal_data.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

List<Map<String, dynamic>> _dummyData = [
  {
    'goalName': 'Pernikahan Kita',
    'type': 'Tabungan Bersama', // Ditambahkan type
    'amount': 'IDR 160.000.000,00 / 200.000.000,00',
    'progress': 0.8,
    'daysLeft': 340,
    'members': [
      {'name': 'Abi'},
      {'name': 'Ummi'},
    ],
    'saldo': 'IDR 160.000.000,00',
    'status': 'Aktif',
    'targetAmount': 'Rp. 200.000.000',
    'targetDuration': '1 Tahun',
    'transactions': [
      {'title': 'Setoran', 'subtitle': '10 Des 2024', 'amount': 'Rp. 500.000'},
      {
        'title': 'Penarikan',
        'subtitle': '12 Des 2024',
        'amount': 'Rp. 300.000'
      },
    ],
  },
  {
    'goalName': 'Gudang Garam Jaya',
    'type': 'Tabungan Bergilir',
    'amount': 'IDR 50.000.000,00 / 100.000.000,00',
    'progress': 0.5,
    'daysLeft': 180,
    'members': [
      {'name': 'Budi'},
      {'name': 'Siti'},
      {'name': 'Anton'},
      {'name': 'Dodi'},
      {'name': 'Cahyo'},
      {'name': 'Jupri'},
    ],
    'saldo': 'IDR 50.000.000,00',
    'status': 'Aktif',
    'targetAmount': 'Rp. 100.000.000',
    'targetDuration': '5 Bulan',
    'transactions': [
      {'title': 'Setoran', 'subtitle': '10 Des 2024', 'amount': 'Rp. 500.000'},
      {
        'title': 'Penarikan',
        'subtitle': '12 Des 2024',
        'amount': 'Rp. 300.000'
      },
    ],
  },
  {
    'goalName': 'Liburan Keluarga',
    'type': 'Tabungan Bersama',
    'amount': 'IDR 20.000.000,00 / 50.000.000,00',
    'progress': 0.4,
    'daysLeft': 200,
    'members': [
      {'name': 'Ayah'},
      {'name': 'Ibu'},
    ],
    'saldo': 'IDR 20.000.000,00',
    'status': 'Tidak Aktif',
    'targetAmount': 'Rp. 50.000.000',
    'targetDuration': '12 Bulan',
    'transactions': [
      {'title': 'Setoran', 'subtitle': '10 Des 2024', 'amount': 'Rp. 500.000'},
      {
        'title': 'Penarikan',
        'subtitle': '12 Des 2024',
        'amount': 'Rp. 300.000'
      },
    ],
  },
];

Future<List<Map<String, dynamic>>> fetchGoalsFromApiOrDatabase() async {
  const String apiUrl =
      'https://your-api-endpoint.com/goals'; // Ganti dengan API endpoint Anda
  try {
    // Simulasi delay untuk melihat shimmer
    await Future.delayed(const Duration(seconds: 2));

    // Kode untuk mengambil data dari API (uncomment jika Anda punya API endpoint)
    // final response = await http.get(Uri.parse(apiUrl));
    // if (response.statusCode == 200) {
    //   final List<dynamic> jsonData = json.decode(response.body);
    //   return jsonData.map((item) => item as Map<String, dynamic>).toList();
    // } else {
    //    throw Exception('Failed to load goals from API');
    // }

    return _dummyData;
  } catch (e) {
    print('Error fetching goals: $e');
    return [];
  }
}

Future<void> saveNewGoal(Map<String, dynamic> newGoal) async {
  _dummyData.add(newGoal);
}
