import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  // 1. LOGIN
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/login'),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    ).timeout(const Duration(seconds: 15));

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Simpan Token & User ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['data']['token']);
      if (data['data'] != null) {
        await prefs.setString('user', jsonEncode(data['data']));
      }
      return data;
    } else {
      throw Exception(data['message'] ?? 'Email atau password salah.');
    }
  }

  // 2. REGISTER
  static Future<String> register({
    required String name,
    required String gender,
    required String email,
    required String phone,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/register'),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'gender': gender,
        'email': email,
        'phone': phone,
      }),
    ).timeout(const Duration(seconds: 15));

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (data['status'] == true) {
        return data['message'] ?? 'Registrasi berhasil.';
      }
      throw Exception(data['message'] ?? 'Registrasi gagal.');
    } else {
      throw Exception(data['message'] ?? 'Registrasi gagal.');
    }
  }

  // 3. LOGOUT
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }
}