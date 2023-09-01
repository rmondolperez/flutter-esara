import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  late final FlutterSecureStorage _storage;
  final _keyToken = "token";

  SecureStorage() {
    _storage = const FlutterSecureStorage();
  }

  Future<bool> setToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
    return true;
  }

  Future<String?> getToken() async {
    var userToken = await _storage.read(key: _keyToken);
    return userToken;
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _keyToken);
  }
}
