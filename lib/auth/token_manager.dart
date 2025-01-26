// token_manager.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';
  static const String _customerIdKey = 'customer_id';
  static const String _userIdKey = 'user_id';

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
    return token != null &&
        token.isNotEmpty; // Tambah pengecekan token tidak kosong
  }

  // Simpan Customer ID
  Future<void> saveCustomerId(String customerId) async {
    await _secureStorage.write(key: _customerIdKey, value: customerId);
  }

  // Ambil Customer ID
  Future<String?> getCustomerId() async {
    return await _secureStorage.read(key: _customerIdKey);
  }

  // Simpan User ID
  Future<void> saveUserId(String userId) async {
    await _secureStorage.write(key: _userIdKey, value: userId);
  }

  // Ambil User ID
  Future<String?> getUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  // Hapus Customer dan User ID
  Future<void> deleteCustomerAndUserId() async {
    await _secureStorage.delete(key: _customerIdKey);
    await _secureStorage.delete(key: _userIdKey);
  }

  // Hapus Semua Data Token dan User Info
  Future<void> deleteAllData() async {
    await deleteToken();
    await deleteCustomerAndUserId();
  }
}
