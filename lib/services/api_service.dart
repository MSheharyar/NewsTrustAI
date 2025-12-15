import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _ec2Ip = "3.107.16.132";
  static const int _port = 8000;

  static String get _base => "http://$_ec2Ip:$_port";

  // POST /verify  body: {"query": "..."}
  static Future<Map<String, dynamic>> verifyNews(String text) async {
    try {
      final url = Uri.parse("$_base/verify");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"query": text}),
      );

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
    final endpoint = Uri.parse("$_base/analyze-link");
    final res = await http.post(
      endpoint,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"url": url}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return {"error": true, "message": "Server Error: ${res.statusCode}", "body": res.body};
  } catch (e) {
    return {"error": true, "message": "Connection Failed: $e"};
  }
}

static Future<Map<String, dynamic>> predictText(String text) async {
  try {
    final url = Uri.parse("$_base/predict-text");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"text": text}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return {"error": true, "message": "Server Error: ${res.statusCode}", "body": res.body};
  } catch (e) {
    return {"error": true, "message": "Connection Failed: $e"};
  }
}

static Future<Map<String, dynamic>> analyzeText(String text) async {
  try {
    final url = Uri.parse("$_base/analyze-text");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"text": text}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return {"error": true, "message": "Server Error: ${res.statusCode}", "body": res.body};
  } catch (e) {
    return {"error": true, "message": "Connection Failed: $e"};
  }
}


  // GET /trending
  static Future<List<dynamic>> fetchTrending() async {
    try {
      final url = Uri.parse("$_base/trending");
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        return (decoded["items"] as List<dynamic>);
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}