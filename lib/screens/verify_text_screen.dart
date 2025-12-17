import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:newstrustai/services/api_service.dart';

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

  void _verifyText() async {
    String text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter text to verify")),
      );
      return;
    }

    // Show loading state
    setState(() => _isLoading = true);

    // Call API
    final result = await ApiService.verifyText(text);

    if (!mounted) return;
    setState(() => _isLoading = false);

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
                  isFake ? LucideIcons.alertTriangle : LucideIcons.checkCircle,
                  color: isFake ? Colors.red : Colors.green,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              
              // Title
              Text(
                isFake ? "Suspicious Content" : "Likely Authentic",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              // Details
              Text(
                "Our AI is ${confValue.toStringAsFixed(1)}% confident that this text is $label.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              
              // Button
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
      backgroundColor: const Color(0xFFF0F4F8), // Matches Home Screen
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
                      "Paste your article or message below",
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
                        maxLines: 8,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                        decoration: InputDecoration(
                          hintText: "Enter the text you want to verify...",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(20),
                          suffixIcon: IconButton(
                             icon: const Icon(LucideIcons.x, size: 20, color: Colors.grey),
                             onPressed: () => _controller.clear(),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      "Quick Examples",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),

                    _ExampleTile(
                      text: "The Earth is flat and governments are hiding...",
                      onTap: () => setState(() => _controller.text = "The Earth is flat and governments are hiding the truth."),
                    ),
                    const SizedBox(height: 10),
                    _ExampleTile(
                      text: "Coffee consumption reduces risk of heart disease...",
                      onTap: () => setState(() => _controller.text = "Coffee consumption reduces risk of heart disease according to new study."),
                    ),

                    const SizedBox(height: 30), // Spacer replacement
                    
                    // Main Action Button
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
                                width: 24, height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(LucideIcons.sparkles, color: Colors.white, size: 20), // AI icon
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
            );
          },
        ),
      ),
    );
  }
}

// Extracted for cleanliness
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