import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final storage = const FlutterSecureStorage();

  Future<void> saveTokens(String access, String refresh) async {
    await storage.write(key: "access_token", value: access);
    await storage.write(key: "refresh_token", value: refresh);
  }

  Future<void> saveCafeId(int cafeId) async {
    await storage.write(key: "cafe_id", value: cafeId.toString());
  }

  Future<String?> getAccessToken() => storage.read(key: "access_token");
  Future<String?> getRefreshToken() => storage.read(key: "refresh_token");
  Future<int?> getCafeId() async {
    final val = await storage.read(key: "cafe_id");
    if (val != null) return int.tryParse(val);
    return null;
  }

  Future<void> clear() async {
    await storage.deleteAll();
  }
}
