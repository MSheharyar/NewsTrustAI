import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _ec2Ip = "13.239.65.21";
  static const int _port = 8000;
  static String get _base => "http://$_ec2Ip:$_port";

  static Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> payload,
  ) async {
    try {
      final res = await http
          .post(
            Uri.parse("$_base$path"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 25));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
        return {"error": true, "message": "Invalid server response format"};
      }

      return {"error": true, "message": "Server error ${res.statusCode}"};
    } catch (e) {
      return {"error": true, "message": e.toString()};
    }
  }

  static Future<List<dynamic>> _getList(String path) async {
    try {
      final res = await http
          .get(Uri.parse("$_base$path"))
          .timeout(const Duration(seconds: 25));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);

        if (decoded is List) return decoded;

        if (decoded is Map && decoded["items"] is List) {
          return decoded["items"] as List;
        }
      }
    } catch (_) {}
    return [];
  }

  // ✅ UPDATED: supports query
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
    return _getList("/trending");
  }

  static Future<List<dynamic>> fetchQuickExamples() async {
    final items = await fetchTrending();
    return items.take(5).toList();
  }

  // ✅ Robust: fixes www., //, relative paths, "null"/"none"
  static String? resolveNewsImageUrl(Map<String, dynamic> item) {
    String s(dynamic v) => (v ?? "").toString().trim();

    bool bad(String v) {
      final x = v.trim().toLowerCase();
      return x.isEmpty || x == "null" || x == "none" || x == "na";
    }

    String normalize(String raw) {
      var url = raw.trim();

      // handle scheme-less urls
      if (url.startsWith("//")) url = "https:$url";
      if (url.startsWith("www.")) url = "https://$url";

      // absolute already
      if (url.startsWith("http://") || url.startsWith("https://")) return url;

      // relative -> attach backend base
      if (url.startsWith("/")) return "$_base$url";
      return "$_base/$url";
    }

    // backend fixed fields first
    final fixed = s(item["imageFixedUrl"]);
    if (!bad(fixed)) return normalize(fixed);

    final fixed2 = s(item["image_fixed_url"]);
    if (!bad(fixed2)) return normalize(fixed2);

    // common feed fields
    final img = s(item["imageUrl"]);
    if (!bad(img)) return normalize(img);

    final img2 = s(item["image_url"]);
    if (!bad(img2)) return normalize(img2);

    final img3 = s(item["image"]);
    if (!bad(img3)) return normalize(img3);

    final thumb = s(item["thumbnail"]);
    if (!bad(thumb)) return normalize(thumb);

    return null;
  }
}