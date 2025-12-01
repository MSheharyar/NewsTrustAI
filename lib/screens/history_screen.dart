import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text("Scan History", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.trash2, color: Colors.grey),
            onPressed: () {}, // Clear history logic
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 8, // Dummy data count
        itemBuilder: (context, index) {
          // Dummy logic for variety
          bool isFake = index % 3 == 0; 
          String type = index % 2 == 0 ? "Link" : "Text";
          
          return _HistoryCard(
            title: isFake ? "Viral WhatsApp Forward #$index" : "BBC News Article #$index",
            date: "Today, 10:3$index AM",
            isFake: isFake,
            type: type,
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String title;
  final String date;
  final bool isFake;
  final String type;

  const _HistoryCard({required this.title, required this.date, required this.isFake, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Row(
        children: [
          // Status Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isFake ? Colors.red[50] : Colors.green[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFake ? LucideIcons.alertTriangle : LucideIcons.shieldCheck,
              color: isFake ? Colors.red : Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      type == "Link" ? LucideIcons.link : LucideIcons.fileText,
                      size: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text("$type • $date", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          
          // Arrow
          const Icon(LucideIcons.chevronRight, size: 18, color: Colors.grey),
        ],
      ),
    );
  }
}