import 'package:flutter/material.dart';
import '../result_view_model.dart';

class VerdictCard extends StatelessWidget {
  final ResultViewModel vm;

  const VerdictCard({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final String headline = vm.title;
    final String confidenceText = _confidenceLabel();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: vm.themeColor.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(color: vm.bgColor, shape: BoxShape.circle),
            child: Icon(vm.statusIcon, size: 58, color: vm.themeColor),
          ),
          const SizedBox(height: 18),
          Text(
            headline,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: vm.themeColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            confidenceText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          _buildSubtitle(),
        ],
      ),
    );
  }

  String _lowRangeText(double? c) {
    final double base = (c == null || c <= 0) ? 55.0 : c;
    final int low = (base - 5).round().clamp(40, 70);
    final int high = (base + 5).round().clamp(45, 75);
    return "Low confidence ($low–$high%)";
  }

  String _confidenceLabel() {
    if (vm.isMainTrustedLink) {
      return vm.confidence == null
          ? "Verified via trusted source"
          : "${vm.confidence!.toStringAsFixed(0)}% Confidence";
    }

    if (vm.isUnverified) {
      return _lowRangeText(vm.confidence);
    }

    if (vm.confidence == null) return "Confidence unavailable";
    return "${vm.confidence!.toStringAsFixed(0)}% Confidence";
  }

  Widget _buildSubtitle() {
    // ✅ NEW: Paraphrase badge text for soft_db_match
    if (vm.showParaphraseBadge) {
      final String note = vm.paraphraseNote.trim().isNotEmpty
          ? vm.paraphraseNote.trim()
          : "Paraphrased from original source (facts match, wording differs).";
      return Text(
        note,
        style: const TextStyle(color: Colors.black54),
        textAlign: TextAlign.center,
      );
    }

    // Main trusted link (ONLY for actual link shortcut)
    if (vm.isMainTrustedLink) {
      final domain = vm.linkDomain.trim();
      return Text(
        domain.isEmpty ? "Source: Main trusted publisher" : "Source: $domain",
        style: const TextStyle(color: Colors.black54),
        textAlign: TextAlign.center,
      );
    }

    // Verify/hybrid
    if (vm.type == ResultType.hybrid || vm.type == ResultType.verify) {
      if (vm.isUnverified) {
        return const Text(
          "We couldn’t confirm this claim with strong evidence.",
          style: TextStyle(color: Colors.black54),
          textAlign: TextAlign.center,
        );
      }

      return Text(
        "Matches found: ${vm.matchesFound}",
        style: const TextStyle(color: Colors.black54),
        textAlign: TextAlign.center,
      );
    }

    if (vm.type == ResultType.bert) {
      return const Text(
        "Model: BERT (text-only)",
        style: TextStyle(color: Colors.black54),
        textAlign: TextAlign.center,
      );
    }

    return const SizedBox.shrink();
  }
}