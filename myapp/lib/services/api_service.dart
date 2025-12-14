import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Android emulator -> 10.0.2.2 backend'e erişir
  static const baseUrl = "http://10.0.2.2:8000";

  /// LOGIN - user_id + password gönderiyoruz
  static Future<Map<String, dynamic>> login(
    String userId,
    String password,
  ) async {
    final url = Uri.parse("$baseUrl/api/login/");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": userId, "password": password}),
    );

    return jsonDecode(response.body);
  }

  static Future<bool> register(Map<String, dynamic> userData) async {
    final url = Uri.parse("$baseUrl/api/register/");

    final response = await http.post(url, body: userData);

    if (response.statusCode == 201) {
      return true;
    }
    return false;
  }
}
