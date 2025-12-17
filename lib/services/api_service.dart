import 'dart:convert';
import 'package:http/http.dart' as http;

/// Handles all API communication with the Django backend
class ApiService {
  // 👇 Change this to your actual Django server URL
  static const String baseUrl = "http://10.0.2.2:8000/api"; 
  // For physical device: use http://YOUR_LOCAL_IP:8000/api

  /// Verify text-based news
  static Future<Map<String, dynamic>> verifyText(String text) async {
    final url = Uri.parse("$baseUrl/verify-text/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": text}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": "Server error: ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": "Connection failed: $e"};
    }
  }

  /// (For later) Verify link-based news
  static Future<Map<String, dynamic>> verifyLink(String link) async {
    final url = Uri.parse("$baseUrl/verify-link/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"link": link}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": "Server error: ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": "Connection failed: $e"};
    }
  }

  /// (For later) Verify image-based news (OCR + model)
  static Future<Map<String, dynamic>> verifyImage(String base64Image) async {
    final url = Uri.parse("$baseUrl/verify-image/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"image": base64Image}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": "Server error: ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": "Connection failed: $e"};
    }
  }
}
