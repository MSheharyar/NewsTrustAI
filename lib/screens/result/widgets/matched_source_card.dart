import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../result_view_model.dart';

class MatchedSourceCard extends StatelessWidget {
  final SourceMatchVM src;
  const MatchedSourceCard({super.key, required this.src});

  Future<void> _open(String url) async {
    final u = Uri.tryParse(url.trim());
    if (u == null) return;
    if (!await canLaunchUrl(u)) return;
    await launchUrl(u, mode: LaunchMode.externalApplication);
  }

  String _typeLabel() {
    final t = src.type.toLowerCase();
    if (t == "factcheck") return "Fact-check";
    if (t == "live") return "Live sources";
    if (t == "db") return "Database";
    return "Source";
  }

  @override
  Widget build(BuildContext context) {
    final Color tagColor = src.trusted ? Colors.green : Colors.orange;

    final t = src.type.toLowerCase();
    final Color typeColor =
        (t == "factcheck") ? Colors.blue : (t == "live") ? Colors.purple : Colors.teal;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  src.source.isEmpty ? "Source" : src.source,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _typeLabel(),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: typeColor),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  src.trusted ? "Trusted" : "Other",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: tagColor),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          if (src.time != null && src.time!.trim().isNotEmpty)
            Text("Time: ${src.time}", style: const TextStyle(fontSize: 12, color: Colors.black54)),
          if (src.domain.trim().isNotEmpty)
            Text("Domain: ${src.domain}", style: const TextStyle(fontSize: 12, color: Colors.black54)),

          // ✅ Fact-check rating line
          if (src.rating != null && src.rating!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                "Rating: ${src.rating}",
                style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w700),
              ),
            ),

          const SizedBox(height: 8),
          Text("Match Score: ${src.score.toStringAsFixed(0)}%", style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 10),
          if (src.url.trim().isNotEmpty)
            InkWell(
              onTap: () => _open(src.url),
              child: Text(
                src.url,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
        ],
      ),
    );
  }
}