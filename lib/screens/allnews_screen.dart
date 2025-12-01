import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AllNewsScreen extends StatelessWidget {
  final List<Map<String, String>> newsItems;

  const AllNewsScreen({super.key, required this.newsItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Matches Home background
      appBar: AppBar(
        title: const Text(
          "Trending News",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16), // Padding around the list
        itemCount: newsItems.length,
        itemBuilder: (context, index) {
          return VerticalNewsCard(item: newsItems[index]);
        },
      ),
    );
  }
}

class VerticalNewsCard extends StatelessWidget {
  final Map<String, String> item;

  const VerticalNewsCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16), // Space between cards
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // --- ACTION: Navigate to verification ---
              // Ideally, pass the text/url to the Verify screen here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Analyzing: ${item['title']}"),
                  action: SnackBarAction(label: "VERIFY", onPressed: () {
                     // Navigate to VerifyTextScreen with data
                  }),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Image (Full Width)
                AspectRatio(
                  aspectRatio: 16 / 9, // Standard video/news aspect ratio
                  child: Image.network(
                    item['image']!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: Icon(LucideIcons.image, size: 40, color: Colors.grey)),
                    ),
                  ),
                ),
                
                // 2. Content Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "Global News", // You can replace this with source name
                              style: TextStyle(color: Colors.blue[700], fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Spacer(),
                          Icon(LucideIcons.checkCircle, size: 14, color: Colors.green[600]),
                          const SizedBox(width: 4),
                          Text(
                            "${item['accuracy']} Trust Score",
                            style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Headline
                      Text(
                        item['title']!,
                        style: const TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Description
                      Text(
                        item['desc']!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // "Verify Now" Action Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                             // Duplicate the onTap logic here if needed
                             ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Opening AI Verification..."))
                             );
                          },
                          icon: const Icon(LucideIcons.scanLine, size: 16),
                          label: const Text("Verify Authenticity"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue[700],
                            side: BorderSide(color: Colors.blue.shade200),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}