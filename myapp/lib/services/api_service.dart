import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Android emulator → backend erişim
  static const String baseUrl = "http://10.0.2.2:8000/api";

  static Uri buildUri(String endpoint) {
    return Uri.parse("$baseUrl/$endpoint");
  }

  // ------------------ LOGIN ------------------ //
  static Future<Map<String, dynamic>> login(
    String userId,
    String password,
  ) async {
    final url = buildUri("login/");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": userId, "password": password}),
    );

    return _safeJson(response);
  }

  static Future<Map<String, dynamic>> getCampaignResult(
    int userId,
    int campaignId,
  ) async {
    final res = await http.get(
      Uri.parse(
        "http://10.0.2.2:8000/api/customer_campaign/$userId/$campaignId/",
      ),
    );
    return json.decode(res.body);
  }

  // ------------------ CUSTOMER PROFILE ------------------ //
  static Future<Map<String, dynamic>> getCustomerProfile(int userId) async {
    final url = buildUri("customer_profile/$userId/");
    final response = await http.get(url);
    return _safeJson(response);
  }

  static Future<bool> updateCustomerProfile(
    int userId,
    Map<String, dynamic> data,
  ) async {
    final url = buildUri("customer_profile/$userId/update/");
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    return response.statusCode == 200;
  }

  // ------------------ REGISTER ------------------ //
  static Future<Map<String, dynamic>?> register(
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  // ------------------ TREND ------------------ //
  static Future<Map<String, dynamic>> getCustomerTrend(int userId) async {
    // *** EN ÖNEMLİ DÜZELTME ***
    final url = buildUri("customer_trend/$userId/");

    final response = await http.get(url);

    return _safeJson(response);
  }

  static Future<List<dynamic>> getAdminLogs() async {
    final url = Uri.parse("http://10.0.2.2:8000/api/admin/logs/");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Loglar alınamadı: ${response.statusCode}");
    }
  }

  // ------------------ AVAILABLE MONTHS ------------------ //
  static Future<List<String>> getAvailableMonths(int userId) async {
    final url = buildUri("customer_months/$userId/");
    final response = await http.get(url);

    final data = _safeJson(response);

    // Backend { "months": [...] } döndürüyorsa:
    if (data is Map && data["months"] is List) {
      return List<String>.from(data["months"]);
    }

    // Direkt liste dönerse:
    if (data is List) {
      return List<String>.from(data);
    }

    return [];
  }

  // ------------------ MONTHLY USAGE ------------------ //
  static Future<Map<String, dynamic>> getMonthlyUsage(
    int userId,
    String month,
  ) async {
    final url = buildUri("customer_monthly_usage/$userId?month=$month");
    final response = await http.get(url);

    return _safeJson(response);
  }

  // ------------------ SAFE JSON PARSE ------------------ //
  static dynamic _safeJson(http.Response response) {
    final contentType = response.headers["content-type"] ?? "";

    if (!contentType.contains("application/json")) {
      print("⚠ SUNUCU JSON DEĞİL HTML DÖNDÜ!");
      print(response.body);
      return {}; // uygulama çökmiyor!
    }

    return jsonDecode(utf8.decode(response.bodyBytes));
  }
}
