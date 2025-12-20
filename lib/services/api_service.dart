import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _ec2Ip = "3.107.16.132";
  static const int _port = 8000;

  static String get _base => "http://$_ec2Ip:$_port";

  // ----------------------------
  // VERIFY (OLD) - POST /verify
  // ----------------------------
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

  // ----------------------------
  // VERIFY LINK - POST /analyze-link
  // ----------------------------
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

  // ----------------------------
  // BERT ONLY - POST /predict-text
  // ----------------------------
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

  // ----------------------------
  // HYBRID - POST /analyze-text
  // ----------------------------
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

  // ----------------------------
  // TRENDING - GET /trending
  // force=true ensures you don't see 2-days old cached data
  // ----------------------------
  static Future<List<dynamic>> fetchTrending({bool force = false, int limit = 30}) async {
    try {
      final url = Uri.parse("$_base/trending?limit=$limit${force ? "&force=1" : ""}");
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

  // ----------------------------
  // QUICK EXAMPLES - Top 5 trending
  // (Use this for Verify Text screen "Quick Examples")
  // ----------------------------
  static Future<List<dynamic>> fetchQuickExamples() async {
    // simplest: reuse trending, force refresh optional
    return fetchTrending(force: false, limit: 5);
  }

  // ----------------------------
  // IMAGE FIX: for .webp links returned by backend as imageFixedUrl
  // If item has imageFixedUrl => return full URL
  // else return normal imageUrl
  // ----------------------------
  static String? resolveNewsImageUrl(Map<String, dynamic> item) {
    final fixed = (item["imageFixedUrl"] ?? "").toString().trim();
    if (fixed.isNotEmpty) return "$_base$fixed";

    final img = (item["imageUrl"] ?? item["image"] ?? "").toString().trim();
    if (img.isEmpty) return null;
    return img;
  }
}
