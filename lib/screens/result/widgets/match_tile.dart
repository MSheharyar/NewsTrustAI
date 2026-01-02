import 'package:flutter/material.dart';

class MatchTile extends StatelessWidget {
  final dynamic match;
  const MatchTile({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final double score = (match is Map && match["score"] != null)
        ? ((match["score"] is num)
            ? (match["score"] as num).toDouble()
            : double.tryParse(match["score"].toString()) ?? 0.0)
        : 0.0;

    final Map<String, dynamic> article =
        (match is Map && match["article"] is Map) ? Map<String, dynamic>.from(match["article"]) : {};

    final String title = (article["title"] ?? "No Title").toString();
    final String source = (article["source"] ?? "Source").toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "${score.toStringAsFixed(0)}%",
              style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(source, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
