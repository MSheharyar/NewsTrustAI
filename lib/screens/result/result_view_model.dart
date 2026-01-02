import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum ResultType { hybrid, verify, bert, unknown }

class ResultViewModel {
  final ResultType type;

  final String title;
  final String reason;
  final double? confidence;
  final bool isFake;
  final bool isUnverified;

  final String queryUsed;
  final int matchesFound;

  final List<String> verifiedSources;
  final List<dynamic> matches;
  final List<dynamic> matchedSources;

  // ✅ NEW (from backend main.py)
  final String verificationMethod; // e.g. main_trusted_link, db_match, no_evidence
  final String sourceTier; // main / other
  final String linkDomain; // arynews.tv, dawn.com, etc.

  const ResultViewModel({
    required this.type,
    required this.title,
    required this.reason,
    required this.confidence,
    required this.isFake,
    required this.isUnverified,
    required this.queryUsed,
    required this.matchesFound,
    required this.verifiedSources,
    required this.matches,
    required this.matchedSources,

    // ✅ NEW (defaults handled in parser)
    required this.verificationMethod,
    required this.sourceTier,
    required this.linkDomain,
  });

  // ✅ Used by VerdictCard + ResultScreen
  bool get isMainTrustedLink =>
      verificationMethod == "main_trusted_link" ||
      verificationMethod == "main_trusted_link_no_extract" ||
      sourceTier == "main";

  Color get themeColor => isUnverified
      ? Colors.orange
      : (isFake ? Colors.red : Colors.green);

  Color get bgColor => isUnverified
      ? Colors.orange.shade50
      : (isFake ? Colors.red.shade50 : Colors.green.shade50);

  IconData get statusIcon => isUnverified
      ? LucideIcons.helpCircle
      : (isFake ? LucideIcons.alertTriangle : LucideIcons.shieldCheck);
}
