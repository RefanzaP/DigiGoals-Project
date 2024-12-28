import 'package:digigoals_app/data/account_service.dart';
import 'package:digigoals_app/data/account_model.dart';

class AuthService {
  final AccountService _accountService;

  AuthService(this._accountService);

  Future<Account?> login(String username, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final Map<String, String> users = {
        '081234567890': 'password123',
        '089876543210': 'securepass',
      };

      if (users.containsKey(username) && users[username] == password) {
        final account = await _accountService.getAccount();
        return account;
      } else {
        throw Exception("Nomor telepon atau password salah.");
      }
    } catch (e) {
      throw Exception("Nomor telepon atau password salah.");
    }
  }
}
