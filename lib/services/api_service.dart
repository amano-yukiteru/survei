
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://sijala.biz.id/api/v1';
  static const String imageEndpoint = 'https://sijala.biz.id/api/image';

  // Fungsi untuk mengambil token dari HP
  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  // Fungsi untuk header standar (JSON)
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}