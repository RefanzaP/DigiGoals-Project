// token_manager.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart'; // Import jwt_jsonwebtoken package

class TokenManager {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';
  static const String _customerIdKey = 'customer_id';
  static const String _userIdKey = 'user_id';

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> saveCustomerId(String customerId) async {
    await _secureStorage.write(key: _customerIdKey, value: customerId);
  }

  Future<String?> getCustomerId() async {
    return await _secureStorage.read(key: _customerIdKey);
  }

  Future<void> saveUserId(String userId) async {
    await _secureStorage.write(key: _userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  Future<void> deleteCustomerAndUserId() async {
    await _secureStorage.delete(key: _customerIdKey);
    await _secureStorage.delete(key: _userIdKey);
  }

  Future<void> deleteAllData() async {
    await deleteToken();
    await deleteCustomerAndUserId();
  }

  // New method to extract user ID from JWT token
  String? getUserIdFromToken(String token) {
    try {
      final jwt = JWT.decode(token);
      // Assuming user ID is stored in the 'userId' claim in the JWT payload
      // You might need to adjust the claim name based on your JWT structure
      return jwt.payload?['userId']?.toString();
    } catch (e) {
      // Token is invalid or expired
      return null;
    }
  }
}