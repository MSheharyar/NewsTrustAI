import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum ResultType { hybrid, verify, bert, unknown }

class ResultViewModel {
  final ResultType type;

  final String title;
  final String reason;
  final double confidence;
  final bool isFake;
  final bool isUnverified;

  final String queryUsed;
  final int matchesFound;

  final List<String> verifiedSources;
  final List<dynamic> matches;
  final List<dynamic> matchedSources;

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
  });

  Color get themeColor => isUnverified ? Colors.orange : (isFake ? Colors.red : Colors.green);

  Color get bgColor =>
      isUnverified ? Colors.orange.shade50 : (isFake ? Colors.red.shade50 : Colors.green.shade50);

  IconData get statusIcon =>
      isUnverified ? LucideIcons.helpCircle : (isFake ? LucideIcons.alertTriangle : LucideIcons.shieldCheck);
}
