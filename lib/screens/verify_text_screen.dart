import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class VerifyTextScreen extends StatefulWidget {
  const VerifyTextScreen({super.key});

  @override
  State<VerifyTextScreen> createState() => _VerifyTextScreenState();
}

class _VerifyTextScreenState extends State<VerifyTextScreen> {
  final TextEditingController _controller = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Turns long pasted text into a shorter search query for better matching
  String _makeQuery(String text) {
    final clean = text
        .replaceAll(RegExp(r'[\n\r]+'), ' ')
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '')
        .toLowerCase();

    final words = clean.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    const stop = {
      "the","a","an","and","or","to","of","in","on","for","with","is","are","was","were",
      "this","that","it","as","at","by","from","be","has","have","had","will","would",
      "can","could","should","may","might","about","into","over","after","before","than",
      "then","they","them","their","there","here","what","when","where","why","how",
      "you","your","we","our","i","he","she","his","her"
    };

    final filtered = words.where((w) => w.length >= 4 && !stop.contains(w)).toList();

    // keep first 12 keywords
    final query = filtered.take(12).join(" ");

    // fallback if text is short or filtering removed everything
    return query.isNotEmpty ? query : text;
  }

  Future<void> _verifyText() async {
    final rawText = _controller.text.trim();

    // 1) Validation
    if (rawText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter text to verify"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Use extracted query (better results)
    final query = _makeQuery(rawText);

    // 2) Loading on
    setState(() => _isLoading = true);

    // 3) API call (FastAPI on EC2)
    final result = await ApiService.analyzeText(rawText);

    if (!mounted) return;

    // 4) Loading off
    setState(() => _isLoading = false);

    // 5) Error handling
    if (result["error"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"] ?? "Unknown error"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 6) Navigate to results screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          data: result,
          originalText: rawText,
          usedQuery: query,
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
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Verify Text",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Paste your article or message below",
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 15),

              // --- INPUT BOX ---
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
                  maxLines: 8,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                  decoration: InputDecoration(
                    hintText: "Enter the text you want to verify...",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                    suffixIcon: IconButton(
                      icon: const Icon(LucideIcons.x, size: 20, color: Colors.grey),
                      onPressed: () => setState(() => _controller.clear()),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // --- QUICK EXAMPLES ---
              const Text(
                "Quick Examples",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),

              _ExampleTile(
                text: "Breaking: Earth is flat and governments are hiding the truth...",
                onTap: () => setState(() => _controller.text =
                    "The Earth is flat and governments are hiding the truth."),
              ),
              const SizedBox(height: 10),

              _ExampleTile(
                text: "Coffee consumption reduces risk of heart disease according to new study...",
                onTap: () => setState(() => _controller.text =
                    "Coffee consumption reduces risk of heart disease according to a new study."),
              ),

              const SizedBox(height: 30),

              // --- MAIN ACTION BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyText,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                    shadowColor: Colors.blue.withOpacity(0.3),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(LucideIcons.sparkles, color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Text(
                              "Analyze Text",
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
    );
  }
}

class _ExampleTile extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _ExampleTile({required this.text, required this.onTap});

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
            const Icon(LucideIcons.quote, size: 16, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Colors.black87, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(LucideIcons.arrowUpLeft, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
