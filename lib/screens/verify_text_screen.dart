import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class VerifyTextScreen extends StatefulWidget {
  const VerifyTextScreen({super.key});

  @override
  State<VerifyTextScreen> createState() => _VerifyTextScreenState();
}

class _VerifyTextScreenState extends State<VerifyTextScreen> {
  final TextEditingController _controller = TextEditingController();

  void _verifyText() {
    String text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter text to verify")),
      );
    } else {
      // TODO: Integrate Django API here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verifying: \"$text\"")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFD5E8FA), // soft blue background
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 40 : 20,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar with back arrow
              Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.arrowLeft, size: 26),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    "Verify Text",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              const Text(
                "Paste or type any text you want to fact-check",
                style: TextStyle(color: Colors.black54, fontSize: 15),
              ),

              const SizedBox(height: 20),

              // Text field box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: 8,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: "Enter the text you want to verify...",
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Quick examples:",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 10),

              // Example 1
              _buildExample(
                "\"The Earth is flat and governments...\"",
                "The Earth is flat and governments...",
              ),

              const SizedBox(height: 10),

              // Example 2
              _buildExample(
                "\"Coffee consumption reduces...\"",
                "Coffee consumption reduces...",
              ),

              const Spacer(),

              // Verify Now button
              Center(
                child: ElevatedButton.icon(
                  onPressed: _verifyText,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[400],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    shadowColor: Colors.black26,
                    elevation: 4,
                  ),
                  icon: const Icon(
                    LucideIcons.send,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: const Text(
                    "Verify Now",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExample(String displayText, String fillText) {
    return InkWell(
      onTap: () {
        setState(() {
          _controller.text = fillText;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          displayText,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
