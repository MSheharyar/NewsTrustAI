import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/api_service.dart';
import 'result/result_screen.dart';

class VerifyTextScreen extends StatefulWidget {
  const VerifyTextScreen({super.key});

  @override
  State<VerifyTextScreen> createState() => _VerifyTextScreenState();
}

class _VerifyTextScreenState extends State<VerifyTextScreen> {
  final TextEditingController _controller = TextEditingController();

  bool _isLoading = false;
  bool _loadingTrending = false;
  List<dynamic> _trending = [];

  @override
  void initState() {
    super.initState();
    _loadTrending();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadTrending() async {
    if (_loadingTrending) return;
    setState(() => _loadingTrending = true);

    try {
      final dynamic items = await ApiService.fetchQuickExamples();
      if (!mounted) return;

      List<dynamic> list = [];

      if (items is List) {
        list = items;
      } else if (items is Map<String, dynamic>) {
        final dynamic inner = items["items"];
        if (inner is List) list = inner;
      }

      setState(() => _trending = list);
    } catch (_) {
      if (!mounted) return;
      setState(() => _trending = []);
    } finally {
      if (mounted) setState(() => _loadingTrending = false);
    }
  }


  String _makeQuery(String text) {
    final clean = text
        .replaceAll(RegExp(r'[\n\r]+'), ' ')
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '')
        .toLowerCase();

    final words = clean.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    const stop = {
      "the","a","an","and","or","to","of","in","on","for","with","is","are","was","were","this","that","it","as","at","by","from","be","has","have","had","will","would","can","could","should","may","might","about","into","over","after","before","than","then","they","them","their","there","here","what","when","where","why","how","you","your","we","our","i","he","she","his","her"
    };

    final filtered = words.where((w) => w.length >= 4 && !stop.contains(w)).toList();
    final query = filtered.take(12).join(" ");
    return query.isNotEmpty ? query : text;
  }

  Future<void> _safeVerifyText() async {
    if (_isLoading) return;
    await verifyText();
  }

  Future<void> verifyText() async {
    final rawText = _controller.text.trim();
    if (rawText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter some text to verify."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final query = _makeQuery(rawText);

    setState(() => _isLoading = true);

    final result = await ApiService.verifyText(
      rawText,
      query: query,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result["error"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text((result["message"] ?? "Error").toString()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          data: result,
          originalText: rawText,
          usedQuery: query,
          resultMode: "text",
        ),
      ),
    );
  }

  String _pickTrendingText(dynamic it) {
    if (it == null) return "";
    final t = (it["summary"] ?? it["title"] ?? it["text"] ?? "").toString().trim();
    return t;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Verify Text", style: TextStyle(color: Colors.black87)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: "Refresh trending",
            onPressed: _loadingTrending ? null : _loadTrending,
            icon: const Icon(LucideIcons.refreshCw, color: Colors.black54, size: 20),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Paste text below", style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 12),

              TextField(
                controller: _controller,
                maxLines: 8,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: "Enter text to verify...",
                  filled: true,
                  fillColor: Colors.white,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(14)),
                    borderSide: BorderSide(color: Colors.blue.shade300, width: 1.2),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _safeVerifyText,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    disabledBackgroundColor: Colors.blue[200],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Analyze Text",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 30),

              Row(
                children: const [
                  Text("Trending Examples", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),

              if (_loadingTrending)
                const Center(child: CircularProgressIndicator())
              else if (_trending.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    "No trending items available right now.",
                    style: TextStyle(color: Colors.black54),
                  ),
                )
              else
                Column(
                  children: _trending.map((it) {
                    final text = _pickTrendingText(it);
                    if (text.isEmpty) return const SizedBox.shrink();

                    return GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () async {
                              _controller.text = text;
                              await _safeVerifyText();
                            },
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(LucideIcons.trendingUp, color: Colors.green[600], size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                text,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}