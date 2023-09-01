import '../secure_storage.dart';

class LocalSecureStorage {
  final _storage = SecureStorage();

  Future<bool> setToken(String token) async {
    await _storage.setToken(token);
    return true;
  }

  Future<String?> getToken() {
    return _storage.getToken();
  }

  Future<void> cleanToken() {
    return _storage.clearToken();
  }
}
