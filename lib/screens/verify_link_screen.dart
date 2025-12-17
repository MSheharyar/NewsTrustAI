import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for Clipboard
import 'package:lucide_icons/lucide_icons.dart';
import 'package:newstrustai/services/api_service.dart';

class VerifyLinkScreen extends StatefulWidget {
  const VerifyLinkScreen({super.key});

  @override
  State<VerifyLinkScreen> createState() => _VerifyLinkScreenState();
}

class _VerifyLinkScreenState extends State<VerifyLinkScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Helper to paste from clipboard
  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() {
        _controller.text = data!.text!;
      });
    }
  }

  void _verifyLink() async {
    String url = _controller.text.trim();
    
    // 1. Basic Validation
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a URL to verify")),
      );
      return;
    }
    
    // Simple regex for URL validation
    if (!url.startsWith('http')) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid URL (starting with http/https)")),
      );
      return;
    }

    // 2. Loading State
    setState(() => _isLoading = true);

    // 3. API Call (Assumes you have a verifyLink method in ApiService)
    // If you haven't created it yet, this will just be a placeholder call.
    final result = await ApiService.verifyLink(url); 

    if (!mounted) return;
    setState(() => _isLoading = false);

    // 4. Handle Result
    if (result.containsKey("error")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["error"])),
      );
    } else {
      _showResultDialog(result["result"], result["confidence"]);
    }
  }

  void _showResultDialog(String label, dynamic confidence) {
    bool isFake = label == "Fake";
    double confValue = confidence is num ? confidence.toDouble() : 0.0;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isFake ? Colors.red[50] : Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFake ? LucideIcons.alertTriangle : LucideIcons.shieldCheck,
                  color: isFake ? Colors.red : Colors.green,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              
              Text(
                isFake ? "Unsafe Source" : "Trusted Source",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              Text(
                "Our analysis of the domain and content suggests this link is likely $label (${confValue.toStringAsFixed(1)}% confidence).",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFake ? Colors.red : Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Done", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Matches Home
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Enter the news article URL",
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    const SizedBox(height: 15),

                    // Input Box
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
                        keyboardType: TextInputType.url, // Optimized keyboard for URLs
                        style: const TextStyle(fontSize: 16, height: 1.5),
                        decoration: InputDecoration(
                          hintText: "https://example.com/news...",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(20),
                          // Prefix Icon
                          prefixIcon: const Icon(LucideIcons.link, color: Colors.grey),
                          // Suffix Icons (Paste & Clear)
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
                                  onPressed: () => setState(() => _controller.clear()),
                                ),
                            ],
                          ),
                        ),
                        onChanged: (val) => setState(() {}), // Update to show/hide suffix buttons
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      "Recent Risky Domains",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),

                    _LinkExampleTile(
                      url: "http://breaking-news-247.xyz/scam",
                      label: "Known Fake Site",
                      isDanger: true,
                      onTap: () => setState(() => _controller.text = "http://breaking-news-247.xyz/scam"),
                    ),
                    const SizedBox(height: 10),
                    _LinkExampleTile(
                      url: "https://bbc.com/news/world",
                      label: "Trusted Source Example",
                      isDanger: false,
                      onTap: () => setState(() => _controller.text = "https://bbc.com/news/world"),
                    ),

                    const SizedBox(height: 30),
                    
                    // Main Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _verifyLink,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[600], // Purple to distinguish from Text Verify
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                          shadowColor: Colors.purple.withOpacity(0.3),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24, height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Row(
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
            );
          },
        ),
      ),
    );
  }
}

// Extracted for cleanliness
class _LinkExampleTile extends StatelessWidget {
  final String url;
  final String label;
  final bool isDanger;
  final VoidCallback onTap;

  const _LinkExampleTile({
    required this.url,
    required this.label,
    required this.isDanger,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isDanger ? LucideIcons.alertCircle : LucideIcons.checkCircle,
              size: 20,
              color: isDanger ? Colors.red : Colors.green,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isDanger ? Colors.red[700] : Colors.green[700],
                      fontSize: 11,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    url,
                    style: const TextStyle(color: Colors.black87, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.arrowUpLeft, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}