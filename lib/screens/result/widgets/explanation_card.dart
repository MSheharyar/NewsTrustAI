import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../result_view_model.dart';

class ExplanationCard extends StatelessWidget {
  final ResultViewModel vm;

  const ExplanationCard({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final bool unverified = vm.isUnverified;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.info, size: 18, color: Colors.blue[600]),
              const SizedBox(width: 10),
              const Text(
                "Why this result?",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            (vm.reason.isNotEmpty) ? vm.reason : "Analysis completed.",
            style: const TextStyle(fontSize: 14.5, height: 1.45, color: Colors.black54),
          ),

          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 10),

          // ✅ More realistic: explain process
          _miniHeader("What we checked"),
          const SizedBox(height: 6),
          Text(
            vm.isMainTrustedLink
                ? "We verified the publisher domain against our main trusted sources list."
                : "We searched our trusted database and performed a live source lookup for similar coverage.",
            style: const TextStyle(color: Colors.black54, height: 1.4),
          ),

          if (unverified) ...[
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 10),

            // ✅ Most important for realism: give next steps
            _miniHeader("What you can do next"),
            const SizedBox(height: 8),
            _tipRow("Try a shorter claim (1–2 lines) instead of full paragraphs."),
            _tipRow("Add key names/places (e.g., person + city + event)."),
            _tipRow("Verify again after a few minutes (sources update)."),
            _tipRow("If it’s from social media, verify the original publisher link."),
          ],
        ],
      ),
    );
  }

  Widget _miniHeader(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black87),
    );
  }

  Widget _tipRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.dot, size: 18, color: Colors.grey[500]),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black54, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}