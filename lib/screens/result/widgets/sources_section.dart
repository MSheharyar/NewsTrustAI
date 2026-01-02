import 'package:flutter/material.dart';
import '../result_view_model.dart';
import 'source_chip.dart';
import 'matched_source_card.dart';
import 'match_tile.dart';

class SourcesSection extends StatelessWidget {
  final ResultViewModel vm;

  const SourcesSection({super.key, required this.vm});

  List<Widget> _chipsForNormalVerify() {
    if (vm.verifiedSources.isNotEmpty) {
      return vm.verifiedSources
          .map((s) => SourceChip(label: s, isMatch: true))
          .toList();
    }

    return const [
      SourceChip(label: "BBC", isMatch: false),
      SourceChip(label: "CNN", isMatch: false),
      SourceChip(label: "DAWN", isMatch: false),
      SourceChip(label: "ARY", isMatch: false),
      SourceChip(label: "ALJAZEERA", isMatch: false),
    ];
  }

  List<Widget> _chipsForMainTrustedLink() {
    final domain = vm.linkDomain.toLowerCase();

    final bool isBBC = domain.contains("bbc");
    final bool isCNN = domain.contains("cnn");
    final bool isDAWN = domain.contains("dawn");
    final bool isARY = domain.contains("ary");
    final bool isAJ = domain.contains("aljazeera") || domain.contains("al-jazeera");

    return [
      SourceChip(label: "BBC", isMatch: isBBC),
      SourceChip(label: "CNN", isMatch: isCNN),
      SourceChip(label: "DAWN", isMatch: isDAWN),
      SourceChip(label: "ARY", isMatch: isARY),
      SourceChip(label: "ALJAZEERA", isMatch: isAJ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bool isMainTrustedLink = vm.isMainTrustedLink;

    final bool hasAnyEvidence =
        vm.matchesFound > 0 || vm.matchedSources.isNotEmpty || vm.matches.isNotEmpty;

    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Checked against:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 10),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: isMainTrustedLink ? _chipsForMainTrustedLink() : _chipsForNormalVerify(),
        ),

        // If main trusted link, STOP here (no DB evidence block)
        if (isMainTrustedLink) const SizedBox(height: 0) else ...[
          const SizedBox(height: 18),

          if (!hasAnyEvidence && (vm.type == ResultType.hybrid || vm.type == ResultType.verify)) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Text(
                "No strong matching coverage was found in our trusted sources right now.",
                style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.4),
              ),
            ),
            const SizedBox(height: 12),
          ],


          // Show matched_sources (DB evidence) if present
          if (vm.matchedSources.isNotEmpty) ...[
            ...vm.matchedSources.take(3).map((s) => MatchedSourceCard(source: s)).toList(),
            const SizedBox(height: 12),
          ],

          // Show top_matches if present
          if (vm.matches.isNotEmpty) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Top Matches:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...vm.matches.take(3).map((m) => MatchTile(match: m)).toList(),
          ],
        ],
      ],
    );
  }
}