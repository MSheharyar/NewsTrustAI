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

  // backend fields
  final String verificationMethod; // e.g. main_trusted_link, db_match, soft_db_match
  final String sourceTier; // main / other
  final String linkDomain; // arynews.tv, dawn.com, etc.

  // ✅ NEW: paraphrase UI support
  final bool isParaphraseMatch;
  final String paraphraseNote;

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
    required this.verificationMethod,
    required this.sourceTier,
    required this.linkDomain,

    // ✅ keep optional defaults so nothing breaks
    this.isParaphraseMatch = false,
    this.paraphraseNote = "",
  });

  // ✅ ONLY true for link trusted shortcut
  bool get isMainTrustedLink {
    final m = verificationMethod.toLowerCase().trim();
    return m == "main_trusted_link" || m == "main_trusted_link_no_extract";
  }

  // ✅ show paraphrase badge when backend says so OR method is soft_db_match
  bool get showParaphraseBadge {
    final m = verificationMethod.toLowerCase().trim();
    return isParaphraseMatch || m == "soft_db_match";
  }

  Color get themeColor =>
      isUnverified ? Colors.orange : (isFake ? Colors.red : Colors.green);

  Color get bgColor => isUnverified
      ? Colors.orange.shade50
      : (isFake ? Colors.red.shade50 : Colors.green.shade50);

  IconData get statusIcon => isUnverified
      ? LucideIcons.helpCircle
      : (isFake ? LucideIcons.alertTriangle : LucideIcons.shieldCheck);
}
