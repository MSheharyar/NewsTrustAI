import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../services/api_service.dart';
import 'result_screen.dart';

class VerifyLinkScreen extends StatefulWidget {
  const VerifyLinkScreen({super.key});

  @override
  State<VerifyLinkScreen> createState() => _VerifyLinkScreenState();
}

class _VerifyLinkScreenState extends State<VerifyLinkScreen> {
  final TextEditingController _controller = TextEditingController();

  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() {
        _controller.text = data!.text!.trim();
        _errorText = null;
      });
    }
  }

  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;
    if (!url.startsWith("http://") && !url.startsWith("https://")) return false;
    final parsed = Uri.tryParse(url);
    return parsed != null && parsed.hasScheme && parsed.host.isNotEmpty;
    // (your old check had issues sometimes)
  }

  Future<void> _verifyLink() async {
    final url = _controller.text.trim();

    // 1) Validate
    if (!_isValidUrl(url)) {
      setState(() => _errorText = "Please enter a valid URL (must start with http/https).");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid URL"), backgroundColor: Colors.orange),
      );
      return;
    }

    // 2) Start loading
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      // 3) Call backend with timeout so it never hangs silently
      final result = await ApiService.analyzeLink(url).timeout(
        const Duration(seconds: 20),
        onTimeout: () => {
          "error": true,
          "message": "Request timed out. Backend may be slow or /analyze-link not working."
        },
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      // Debug prints
      // ignore: avoid_print
      print("ANALYZE LINK RESULT: $result");

      // 4) Show errors clearly
      if (result["error"] == true) {
        final msg = (result["message"] ?? "Unknown error").toString();
        setState(() => _errorText = msg);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
        return;
      }

      // 5) Navigate to ResultScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            data: result,
            usedQuery: result["query_used"]?.toString(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorText = "Unexpected error: $e";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unexpected error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Verify Link",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Paste the news article link below",
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  const SizedBox(height: 15),

                  // INPUT BOX
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.url,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                      decoration: InputDecoration(
                        hintText: "https://example.com/news...",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(20),
                        prefixIcon: const Icon(LucideIcons.link, color: Colors.grey),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_controller.text.isEmpty)
                              IconButton(
                                icon: const Icon(LucideIcons.clipboard, size: 20, color: Colors.blue),
                                tooltip: "Paste",
                                onPressed: _pasteFromClipboard,
                              )
                            else
                              IconButton(
                                icon: const Icon(LucideIcons.x, size: 20, color: Colors.grey),
                                tooltip: "Clear",
                                onPressed: () {
                                  _controller.clear();
                                  setState(() => _errorText = null);
                                },
                              ),
                          ],
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),

                  if (_errorText != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ],

                  const SizedBox(height: 30),

                  // BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyLink,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(LucideIcons.search, color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text(
                            "Analyze Link",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ LOADING OVERLAY
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.15),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}