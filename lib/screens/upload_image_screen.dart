import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:newstrustai/services/api_service.dart'; // Assume this exists

class UploadImageScreen extends StatefulWidget {
  const UploadImageScreen({super.key});

  @override
  State<UploadImageScreen> createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  File? _selectedImage;
  bool _isScanning = false;
  final TextEditingController _extractedTextController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  // Track if we have successfully extracted text to change the UI layout
  bool _hasExtracted = false;

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // Close the bottom sheet
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _hasExtracted = false; // Reset previous extraction
          _extractedTextController.clear();
        });
        // Auto-start scanning (Optional UX choice)
        _scanImage();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to pick image")),
      );
    }
  }

  void _scanImage() async {
    if (_selectedImage == null) return;

    setState(() => _isScanning = true);

    // --- SIMULATE OCR / API CALL ---
    // In real app: await ApiService.extractTextFromImage(_selectedImage!);
    await Future.delayed(const Duration(seconds: 2)); 

    // Fake result for demo
    String fakeResult = "Breaking News: Scientists have discovered a new species of flying penguins in the Antarctic region. This discovery challenges all known biology laws.";

    if (!mounted) return;

    setState(() {
      _isScanning = false;
      _hasExtracted = true;
      _extractedTextController.text = fakeResult;
    });
  }

  void _verifyExtractedText() async {
    // Navigate to verification or call API directly
    // For now, let's just show a success message or navigate to result
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sending text to Fake News Detector...")),
    );
    
    // You can also reuse the logic from VerifyTextScreen here!
    // ApiService.verifyText(_extractedTextController.text)...
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Select Image Source", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _sourceOption(LucideIcons.camera, "Camera", () => _pickImage(ImageSource.camera)),
                _sourceOption(LucideIcons.image, "Gallery", () => _pickImage(ImageSource.gallery)),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _sourceOption(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
            child: Icon(icon, size: 30, color: Colors.blue[700]),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
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
        title: const Text("Scan Image", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image Preview Area
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                height: _selectedImage == null ? 200 : 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: _selectedImage == null 
                      ? Border.all(color: Colors.grey.shade300, width: 2) // Solid border for clean look
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: _selectedImage == null
                    ? InkWell(
                        onTap: _showImageSourceSheet,
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.uploadCloud, size: 48, color: Colors.blue[300]),
                            const SizedBox(height: 16),
                            Text(
                              "Tap to Upload Image",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Supports JPG, PNG",
                              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      )
                    : Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              _selectedImage!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Overlay for Scanning Loading State
                          if (_isScanning)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(color: Colors.white),
                                    SizedBox(height: 16),
                                    Text("Extracting Text...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                                  ],
                                ),
                              ),
                            ),
                          // Close button to remove image
                          if (!_isScanning)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: InkWell(
                                onTap: () => setState(() {
                                  _selectedImage = null;
                                  _hasExtracted = false;
                                  _extractedTextController.clear();
                                }),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                  ),
                                  child: const Icon(LucideIcons.x, size: 20, color: Colors.black),
                                ),
                              ),
                            ),
                        ],
                      ),
              ),

              const SizedBox(height: 25),

              // 2. Extracted Text Area (Only show if extraction is done)
              if (_hasExtracted) ...[
                const Text(
                  "Review Extracted Text",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                    ],
                  ),
                  child: TextField(
                    controller: _extractedTextController,
                    maxLines: 6,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                      hintText: "No text found...",
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                
                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _verifyExtractedText,
                    icon: const Icon(LucideIcons.shieldCheck, color: Colors.white),
                    label: const Text(
                      "Verify This Text",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600], // Orange to differentiate image action
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}