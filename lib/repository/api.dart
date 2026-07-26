import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  static const String baseUrl = 'https://rotaja.wasmer.app/index.php/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String caminho) async {
    final url = Uri.parse('$baseUrl$caminho');
    final headers = await _getHeaders();
    return await http.get(url, headers: headers);
  }

  Future<http.Response> post(String caminho, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$caminho');
    final headers = await _getHeaders();
    return await http.post(url, headers: headers, body: jsonEncode(body));
  }
}