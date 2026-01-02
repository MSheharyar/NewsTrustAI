import 'package:flutter/material.dart';

class MatchedSourceCard extends StatelessWidget {
  final dynamic source;
  const MatchedSourceCard({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    if (source is! Map) return const SizedBox.shrink();
    final Map s = source as Map;

    final String name = (s["source"] ?? "Unknown").toString();
    final String url = (s["url"] ?? "").toString();

    final String publishedAt = (s["publishedAt"] ?? "").toString();
    final String scrapedAt = (s["scrapedAt"] ?? "").toString();
    final String time = publishedAt.isNotEmpty ? publishedAt : scrapedAt;

    final bool trusted = (s["trusted"] == true);

    // ✅ safer score parsing + cleaner display
    final double? score = (s["score"] is num)
        ? (s["score"] as num).toDouble()
        : double.tryParse((s["score"] ?? "").toString());

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trusted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    "Trusted",
                    style: TextStyle(
                      color: Colors.green[800],
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (time.isNotEmpty)
            Text("Time: $time", style: const TextStyle(color: Colors.black54, fontSize: 12)),
          if (score != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "Match Score: ${score.toStringAsFixed(0)}%",
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ),
          if (url.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              url,
              style: const TextStyle(color: Colors.blue, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
