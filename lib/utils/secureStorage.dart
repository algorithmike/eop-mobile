import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _storage = FlutterSecureStorage();

  Future<void> setAuthToken(String token) async {
    return await _storage.write(key: 'EOP_JWT_TOKEN', value: token);
  }

  Future<String> getAuthToken() async {
    return await _storage.read(key: 'EOP_JWT_TOKEN');
  }

  Future<void> deleteAuthToken() async {
    return await _storage.delete(key: 'EOP_JWT_TOKEN');
  }
}
