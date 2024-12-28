import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:digigoals_app/data/account_model.dart';

class AccountService {
  // Persiapan untuk API
  Future<Account> getAccount() async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      // Data statis sementara
      return Account(
        nomorRekening: '0123456789012',
        namaRekening: "ABI",
        saldoRekening: 1000000.00,
      );

      // Implementasi API yang akan datang
      // final response = await http.get(Uri.parse('https://api.example.com/account'));
      // if(response.statusCode == 200){
      //   final jsonResponse = json.decode(response.body);
      //    return Account.fromJson(jsonResponse);
      // } else {
      //   throw Exception('Gagal mengambil data akun dari server: Status Code ${response.statusCode}');
      // }
    } catch (e) {
      throw Exception("Gagal memuat data akun");
    }
  }
}
