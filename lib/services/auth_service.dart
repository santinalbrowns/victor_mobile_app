import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: "token");
    return token != null;
  }

  // Save token
  Future<void> saveToken(String token) async {
    await _storage.write(key: "token", value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: "token");
  }

  // Logout
  Future<void> logout() async {
    await _storage.delete(key: "token");
  }
}
