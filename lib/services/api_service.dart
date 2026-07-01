import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://school-management-backend-6k06.onrender.com/api/v1';
  static const String _tokenKey = 'jwt_token';

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<dynamic> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(uri, headers: await _headers());
    return _handle(response);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body,
      {bool auth = true}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.post(uri,
        headers: await _headers(auth: auth), body: jsonEncode(body));
    return _handle(response);
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.put(uri,
        headers: await _headers(), body: jsonEncode(body));
    return _handle(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.delete(uri, headers: await _headers());
    return _handle(response);
  }

  dynamic _handle(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) return body;
    throw Exception(body['error'] ?? 'Something went wrong');
  }
}

final apiService = ApiService();