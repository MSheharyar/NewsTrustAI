import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/api_service.dart';
import 'result/result_screen.dart';

class VerifyLinkScreen extends StatefulWidget {
  final String? initialUrl;
  const VerifyLinkScreen({super.key, this.initialUrl});

  @override
  State<VerifyLinkScreen> createState() => _VerifyLinkScreenState();
}

class _VerifyLinkScreenState extends State<VerifyLinkScreen> {
  final TextEditingController _controller = TextEditingController();  
  bool _isLoading = false;
  bool _loadingTrending = false;
  String? _errorText;
  List<dynamic> _trendingLinks = [];

  @override
  void initState() {
    super.initState();

    // Prefill URL if coming from Home card
    final preset = widget.initialUrl?.trim() ?? "";
    if (preset.isNotEmpty) {
      _controller.text = preset;
      _errorText = null;
    }

    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _loadTrendingLinks();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isValidUrl(String url) {
    final u = Uri.tryParse(url);
    return u != null &&
        (u.scheme == "http" || u.scheme == "https") &&
        u.host.isNotEmpty;
  }

  Future<void> _loadTrendingLinks() async {
    if (_loadingTrending) return;

    setState(() {
      _loadingTrending = true;
    });

    try {
      final items = await ApiService.fetchTrending();
      final links = items
          .where((e) =>
              e is Map &&
              (e["url"] ?? "").toString().trim().isNotEmpty)
          .take(5)
          .toList();

      if (!mounted) return;
      setState(() => _trendingLinks = links);
    } catch (_) {
      if (!mounted) return;
      setState(() => _trendingLinks = []);
    } finally {
      if (mounted) {
        setState(() => _loadingTrending = false);
      }
    }
  }

  Future<void> _verifyLink() async {
    final url = _controller.text.trim();

    // Validate
    if (url.isEmpty) {
      setState(() => _errorText = "Please enter a URL.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("URL is empty"), backgroundColor: Colors.orange),
      );
      return;
    }

    if (!_isValidUrl(url)) {
      setState(() => _errorText = "Please enter a valid URL (http/https).");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid URL"), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final result = await ApiService.analyzeLink(url);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result["error"] == true) {
      final msg = (result["message"] ?? "Error").toString();
      setState(() => _errorText = msg);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          data: result,
          originalText: result["link_title"]?.toString() ?? url,
          usedQuery: result["query_used"]?.toString(),
          resultMode: "link",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Verify Link", style: TextStyle(color: Colors.black87)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Paste the news article link below",
                  style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 12),

              TextField(
                controller: _controller,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  hintText: "https://example.com/news...",
                  filled: true,
                  fillColor: Colors.white,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  errorText: _errorText,
                  prefixIcon: const Icon(LucideIcons.link, color: Colors.grey),
                  suffixIcon: _controller.text.trim().isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(LucideIcons.x, size: 18),
                          onPressed: () {
                            setState(() {
                              _controller.clear();
                              _errorText = null;
                            });
                          },
                        ),
                ),
                onChanged: (_) => setState(() => _errorText = null),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyLink,
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
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "Analyze Link",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  const Text("Trending Links",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(LucideIcons.refreshCw, size: 18),
                    onPressed: _loadingTrending ? null : _loadTrendingLinks,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_loadingTrending)
                const Center(child: CircularProgressIndicator())
              else if (_trendingLinks.isEmpty)
                const Text("No trending links available right now.",
                    style: TextStyle(color: Colors.black54))
              else
                Column(
                  children: _trendingLinks.map((it) {
                    final title = (it["title"] ?? "Trending article").toString();
                    final url = (it["url"] ?? "").toString();

                    return ListTile(
                      leading: const Icon(LucideIcons.trendingUp),
                      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
                      onTap: () async {
                        setState(() {
                          _controller.text = url;
                          _errorText = null;
                        });
                        await _verifyLink();
                      },
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