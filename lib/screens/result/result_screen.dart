import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'result_parser.dart';
import 'result_view_model.dart';

import 'widgets/matched_source_card.dart';
import 'widgets/match_tile.dart';
import 'widgets/source_chip.dart';
import 'widgets/verdict_card.dart';


class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final String? originalText;
  final String? usedQuery;

  const ResultScreen({
    super.key,
    required this.data,
    this.originalText,
    this.usedQuery,
  });

  @override
  Widget build(BuildContext context) {
    final ResultViewModel vm = parseResultData(data, usedQuery: usedQuery);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Analysis Result",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 10),
            VerdictCard(vm: vm),
            const SizedBox(height: 24),
            // Explanation Card (kept inline for now)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                      Icon(LucideIcons.info, size: 20, color: Colors.blue[600]),
                      const SizedBox(width: 10),
                      const Text("Why this result?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(vm.reason, style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black54)),
                  if (vm.queryUsed.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text("Query used:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(vm.queryUsed, style: const TextStyle(color: Colors.black87)),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (vm.type == ResultType.hybrid || vm.type == ResultType.verify) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Checked against:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
              ),

              if (vm.matchedSources.isNotEmpty) ...[
                const SizedBox(height: 10),
                ...vm.matchedSources.take(3).map((s) => MatchedSourceCard(source: s)).toList(),
                const SizedBox(height: 12),
              ] else ...[
                const SizedBox(height: 5),
                const Text("No matches found in our trusted database.",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 12),
              ],

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: (vm.verifiedSources.isNotEmpty)
                    ? vm.verifiedSources.map((s) => SourceChip(label: s, isMatch: true)).toList()
                    : const [
                        SourceChip(label: "BBC", isMatch: false),
                        SourceChip(label: "CNN", isMatch: false),
                        SourceChip(label: "DAWN", isMatch: false),
                        SourceChip(label: "ARY", isMatch: false),
                      ],
              ),

              const SizedBox(height: 18),

              if (vm.matches.isNotEmpty) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Top Matches:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 12),
                ...vm.matches.take(3).map((m) => MatchTile(match: m)).toList(),
              ],
            ],

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                child: const Text(
                  "Verify Another",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
