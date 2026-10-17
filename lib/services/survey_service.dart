import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../models/survey.dart';

class SurveyService {
  // 1. AMBIL DAFTAR SURVEY
  static Future<List<Survey>> getSurveys() async {
    final headers = await ApiService.getHeaders();
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/surveys'),
      headers: headers,
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final dataList = decoded['data'];
      if (dataList is List) {
        return dataList.map((item) => Survey.fromJson(item)).toList();
      }
    } else if (response.statusCode == 401) {
      throw Exception('UNAUTHORIZED');
    }
    throw Exception('Gagal memuat daftar survey (${response.statusCode})');
  }

  // 2. AMBIL DETAIL SURVEY
  static Future<Survey> getSurveyDetail(int id) async {
    final headers = await ApiService.getHeaders();
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/surveys/$id'),
      headers: headers,
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'];
      final Map<String, dynamic> mapData = data['survey'] is Map 
          ? Map<String, dynamic>.from(data['survey']) 
          : Map<String, dynamic>.from(data);
      return Survey.fromJson(mapData);
    } else if (response.statusCode == 401) {
      throw Exception('UNAUTHORIZED');
    } else if (response.statusCode == 404) {
      throw Exception('NOT_FOUND');
    }
    throw Exception('Gagal memuat detail (${response.statusCode})');
  }

  // 3. AMBIL KATEGORI
  static Future<List<Map<String, dynamic>>> getCategories() async {
    final headers = await ApiService.getHeaders();
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/categories'),
      headers: headers,
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      if (data is List) return List<Map<String, dynamic>>.from(data);
    }
    throw Exception('Gagal memuat kategori survey.');
  }

  // 4. AMBIL GAMBAR SURVEY
  static Future<Uint8List?> getImage(String fileName) async {
    try {
      final token = await ApiService.getToken();
      final uri = fileName.startsWith('http') 
          ? Uri.parse(fileName) 
          : Uri.parse('${ApiService.imageEndpoint}/$fileName');

      final response = await http.get(
        uri, headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 5. SIMPAN SURVEY (TAMBAH/EDIT)
  static Future<String> saveSurvey({
    required Map<String, String> fields,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    final token = await ApiService.getToken();
    final uri = Uri.parse('${ApiService.baseUrl}/surveys/save');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);

    if (imageBytes != null && imageName != null) {
      request.files.add(http.MultipartFile.fromBytes('photo', imageBytes, filename: imageName));
    }

    final streamedResponse = await request.send().timeout(const Duration(seconds: 25));
    final response = await http.Response.fromStream(streamedResponse);
    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return decoded['message'] ?? 'Survey berhasil disimpan.';
    } else if (response.statusCode == 422) {
      throw Exception('Data yang dikirim tidak valid.');
    } else if (response.statusCode == 401) {
      throw Exception('UNAUTHORIZED');
    }
    throw Exception('Gagal menyimpan survey (${response.statusCode}).');
  }

  // 6. HAPUS SURVEY
  static Future<bool> deleteSurvey(int id) async {
    final headers = await ApiService.getHeaders();
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/surveys/$id/delete'),
      headers: headers,
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) return true;
    if (response.statusCode == 401) throw Exception('UNAUTHORIZED');
    throw Exception('Gagal menghapus survey (${response.statusCode})');
  }
}