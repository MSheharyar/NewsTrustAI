import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'result_parser.dart';
import 'result_view_model.dart';
import 'widgets/verdict_card.dart';
import 'widgets/explanation_card.dart';
import 'widgets/sources_section.dart';
import 'widgets/verify_another_button.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final String? originalText;
  final String? usedQuery;

  final String resultMode;

  const ResultScreen({
    super.key,
    required this.data,
    this.originalText,
    this.usedQuery,
    this.resultMode = "text",
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

            // explanation widget
            ExplanationCard(vm: vm),

            const SizedBox(height: 24),

            if (vm.isUnverified) ...[
              const SizedBox(height: 8),
              const Text(
                "We couldn't verify this claim with enough strong evidence.",
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 12),
            ],

            // sources + evidence widget
            SourcesSection(vm: vm),

            const SizedBox(height: 30),

            const VerifyAnotherButton(),
          ],
        ),
      ),
    );
  }
}