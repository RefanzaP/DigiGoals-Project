import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';

  // Simpan token
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  // Ambil token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  // Hapus token
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  // Periksa apakah token tersimpan
  Future<bool> hasToken() async {
     final token = await getToken();
      return token != null;
  }
}