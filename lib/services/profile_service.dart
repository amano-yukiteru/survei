import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ProfileService {
  // 1. AMBIL DATA PROFIL
  static Future<Map<String, dynamic>> getProfile() async {
    final headers = await ApiService.getHeaders();
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/profile'),
      headers: headers,
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? data; // Kadang API langsung return map, kadang dibungkus 'data'
    } else if (response.statusCode == 401) {
      throw Exception('UNAUTHORIZED');
    }
    throw Exception('Gagal memuat profil.');
  }

  // 2. AMBIL GAMBAR PROFIL
  static Future<Uint8List?> getProfileImage(String fileName) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.get(
        Uri.parse('${ApiService.imageEndpoint}/$fileName'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) return response.bodyBytes;
      return null;
    } catch (_) {
      return null;
    }
  }

  // 3. UPDATE PROFIL (Ganti Foto & Data)
  static Future<String> updateProfile({
    required Map<String, String> fields,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    final token = await ApiService.getToken();
    final uri = Uri.parse('${ApiService.baseUrl}/profile/update');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);

    if (imageBytes != null && imageName != null) {
      request.files.add(http.MultipartFile.fromBytes('photo', imageBytes, filename: imageName));
    }

    final streamedResponse = await request.send().timeout(const Duration(seconds: 25));
    final response = await http.Response.fromStream(streamedResponse);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['message'] ?? 'Profil berhasil diperbarui.';
    } else if (response.statusCode == 422) {
      throw Exception('Validasi gagal. Periksa kembali form Anda.');
    } else if (response.statusCode == 401) {
      throw Exception('UNAUTHORIZED');
    }
    throw Exception(data['message'] ?? 'Gagal memperbarui profil.');
  }
}