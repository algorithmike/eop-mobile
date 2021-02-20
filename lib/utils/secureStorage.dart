import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _storage = FlutterSecureStorage();

  Future setAuthToken(String token) async {
    return await _storage.write(key: 'EOP_JWT_TOKEN', value: token);
  }

  Future getAuthToken() async {
    return await _storage.read(key: 'EOP_JWT_TOKEN');
  }

  Future deleteAuthToken() async {
    return await _storage.delete(key: 'EOP_JWT_TOKEN');
  }
}
