import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _ec2Ip = "3.107.16.132";
  static const int _port = 8000;

  static String get _base => "http://$_ec2Ip:$_port";

  static Future<Map<String, dynamic>> verifyNews(String text) async {
    try {
      final url = Uri.parse("$_base/verify");
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"query": text}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        "error": true,
        "message": "Server Error: ${response.statusCode}",
        "body": response.body
      };
    } catch (e) {
      return {"error": true, "message": "Connection Failed: $e"};
    }
  }

  static Future<Map<String, dynamic>> analyzeLink(String url) async {
    try {
      final cleanUrl = url.trim();
      final endpoint = Uri.parse("$_base/analyze-link");
      final res = await http
          .post(
            endpoint,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"url": cleanUrl}),
          )
          .timeout(const Duration(seconds: 20));

      if (res.statusCode == 200) return jsonDecode(res.body);

      return {
        "error": true,
        "message": "Server Error: ${res.statusCode}",
        "body": res.body
      };
    } catch (e) {
      return {"error": true, "message": "Connection Failed: $e"};
    }
  }

  static Future<Map<String, dynamic>> predictText(String text) async {
    try {
      final url = Uri.parse("$_base/predict-text");
      final res = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"text": text}),
          )
          .timeout(const Duration(seconds: 20));

      if (res.statusCode == 200) return jsonDecode(res.body);

      return {
        "error": true,
        "message": "Server Error: ${res.statusCode}",
        "body": res.body
      };
    } catch (e) {
      return {"error": true, "message": "Connection Failed: $e"};
    }
  }

  static Future<Map<String, dynamic>> analyzeText(String text) async {
    try {
      final url = Uri.parse("$_base/analyze-text");
      final res = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"text": text}),
          )
          .timeout(const Duration(seconds: 20));

      if (res.statusCode == 200) return jsonDecode(res.body);

      return {
        "error": true,
        "message": "Server Error: ${res.statusCode}",
        "body": res.body
      };
    } catch (e) {
      return {"error": true, "message": "Connection Failed: $e"};
    }
  }

  static Future<List<dynamic>> fetchTrending({bool force = false}) async {
    try {
      final url = Uri.parse("$_base/trending${force ? "?force=1" : ""}");
      final res = await http.get(url).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        return (decoded["items"] as List<dynamic>);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<List<dynamic>> fetchQuickExamples() async {
    final items = await fetchTrending(force: false);
    return items.take(5).toList();
  }

  static String? resolveNewsImageUrl(Map<String, dynamic> item) {
    final fixed = (item["imageFixedUrl"] ?? "").toString().trim();
    if (fixed.isNotEmpty) return "$_base$fixed";

    final img = (item["imageUrl"] ?? item["image"] ?? "").toString().trim();
    if (img.isEmpty) return null;
    return img;
  }
}
