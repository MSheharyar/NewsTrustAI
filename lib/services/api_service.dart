import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _ec2Ip = "13.239.65.21";
  static const int _port = 8000;
  static String get _base => "http://$_ec2Ip:$_port";

  static Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> payload, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse("$_base$path"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(payload),
          )
          .timeout(timeout);

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
        return {"error": true, "message": "Invalid response format"};
      }

      return {
        "error": true,
        "message": "Server error ${res.statusCode}: ${res.body}",
      };
    } catch (e) {
      return {"error": true, "message": "Request failed: $e"};
    }
  }

  static Future<Map<String, dynamic>> verifyText(
    String text, {
    String? query,
  }) {
    final payload = <String, dynamic>{
      "text": text,
      if (query != null && query.trim().isNotEmpty) "query": query.trim(),
    };
    return _postJson("/verify-text", payload);
  }

  static Future<Map<String, dynamic>> analyzeLink(String url) {
    return _postJson("/analyze-link", {"url": url.trim()});
  }

  static Future<List<dynamic>> fetchTrending({bool force = false}) async {
    try {
      final res =
          await http.get(Uri.parse("$_base/trending")).timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) return [];

      final decoded = jsonDecode(res.body);
      if (decoded is List) return decoded;

      if (decoded is Map) {
        final d = Map<String, dynamic>.from(decoded);
        final a = d["items"];
        final b = d["results"];
        if (a is List) return a;
        if (b is List) return b;
      }
    } catch (_) {}

    return [];
  }

  static Future<List<dynamic>> fetchQuickExamples() async {
    final items = await fetchTrending();
    if (items.isEmpty) return [];
    return items.length <= 5 ? items : items.take(5).toList();
  }

  static String? resolveNewsImageUrl(Map<String, dynamic> item) {
    final fixed = (item["imageFixedUrl"] ?? "").toString().trim();
    if (fixed.isNotEmpty) {
      if (fixed.startsWith("http")) return fixed;
      return "$_base$fixed";
    }

    final img = (item["imageUrl"] ?? "").toString().trim();
    return img.isEmpty ? null : img;
  }
}