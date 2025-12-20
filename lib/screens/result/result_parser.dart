import 'result_view_model.dart';

ResultViewModel parseResultData(Map<String, dynamic> data, {String? usedQuery}) {
  bool hasHybrid = data.containsKey("final_label") || data.containsKey("final_confidence");
  bool isBertFormat = data.containsKey("label") || data.containsKey("confidence");
  bool isVerifyFormat = data.containsKey("verified") || data.containsKey("top_matches");

  final String q = (data["query_used"] ?? usedQuery ?? "").toString().trim();

  // defaults
  bool isFake = false;
  bool isUnverified = false;
  double confidence = 0;
  String mainTitle = "Unknown";
  String reason = "Analysis completed.";
  List<String> verifiedSources = [];
  List<dynamic> matches = [];
  final List<dynamic> matchedSources = (data["matched_sources"] is List) ? (data["matched_sources"] as List) : const [];
  int matchesFoundNumber = 0;

  // 1) Hybrid
  if (hasHybrid) {
    final String finalLabel = (data["final_label"] ?? "unverified").toString().toLowerCase().trim();
    final double finalConf = (data["final_confidence"] is num)
        ? (data["final_confidence"] as num).toDouble()
        : double.tryParse(data["final_confidence"]?.toString() ?? "") ?? 0;

    confidence = finalConf;

    if (finalLabel.contains("real") || finalLabel.contains("true") || finalLabel.contains("authentic")) {
      isFake = false;
      isUnverified = false;
      mainTitle = "Likely Authentic";
    } else if (finalLabel.contains("fake") || finalLabel.contains("false") || finalLabel.contains("suspicious")) {
      isFake = true;
      isUnverified = false;
      mainTitle = "Suspicious Content";
    } else {
      isFake = false;
      isUnverified = true;
      mainTitle = "Unverified (Insufficient Evidence)";
    }

    reason = (data["final_reason"] ?? "Hybrid analysis completed.").toString();

    matches = (data["top_matches"] is List) ? (data["top_matches"] as List) : [];

    verifiedSources = matches
        .map((m) {
          if (m is Map && m["article"] is Map) return (m["article"]["source"] ?? "").toString();
          return "";
        })
        .where((s) => s.trim().isNotEmpty)
        .toSet()
        .toList();

    matchesFoundNumber = (data["matches_found"] is num) ? (data["matches_found"] as num).toInt() : matchedSources.length;

    return ResultViewModel(
      type: ResultType.hybrid,
      title: mainTitle,
      reason: reason,
      confidence: confidence,
      isFake: isFake,
      isUnverified: isUnverified,
      queryUsed: q,
      matchesFound: matchesFoundNumber,
      verifiedSources: verifiedSources,
      matches: matches,
      matchedSources: matchedSources,
    );
  }

  // 2) Verify
  if (isVerifyFormat) {
    final bool verified = data["verified"] == true;
    final int count = (data["count"] ?? 0) is int ? data["count"] : int.tryParse("${data["count"]}") ?? 0;

    matches = (data["top_matches"] is List) ? (data["top_matches"] as List) : [];
    matchesFoundNumber = count;

    if (matches.isNotEmpty && matches[0] is Map && matches[0]["score"] != null) {
      confidence = (matches[0]["score"] is num)
          ? (matches[0]["score"] as num).toDouble()
          : double.tryParse(matches[0]["score"].toString()) ?? 0;
    } else {
      confidence = verified ? 70 : 0;
    }

    if (verified) {
      isFake = false;
      isUnverified = false;
      mainTitle = "Likely Authentic";
      reason = "We found $count matching article(s) in our trusted sources database.";
    } else {
      isFake = false;
      isUnverified = true;
      mainTitle = "Unverified (Insufficient Evidence)";
      reason =
          "No matching articles were found in our trusted sources database. This content may be missing context, edited, old, or not covered by our sources.";
    }

    verifiedSources = matches
        .map((m) {
          if (m is Map && m["article"] is Map) return (m["article"]["source"] ?? "").toString();
          return "";
        })
        .where((s) => s.trim().isNotEmpty)
        .toSet()
        .toList();

    return ResultViewModel(
      type: ResultType.verify,
      title: mainTitle,
      reason: reason,
      confidence: confidence,
      isFake: isFake,
      isUnverified: isUnverified,
      queryUsed: q,
      matchesFound: matchesFoundNumber,
      verifiedSources: verifiedSources,
      matches: matches,
      matchedSources: matchedSources,
    );
  }

  // 3) BERT
  if (isBertFormat) {
    final String label = (data["label"] ?? "").toString().toLowerCase().trim();
    final double conf = (data["confidence"] is num)
        ? (data["confidence"] as num).toDouble()
        : double.tryParse(data["confidence"]?.toString() ?? "") ?? 0;

    confidence = conf;

    if (label.contains("real") || label.contains("true")) {
      isFake = false;
      isUnverified = false;
      mainTitle = "Likely Authentic";
      reason = "Our BERT model predicts this text is likely REAL based on patterns learned during training.";
    } else if (label.contains("fake") || label.contains("false")) {
      isFake = true;
      isUnverified = false;
      mainTitle = "Suspicious Content";
      reason = "Our BERT model predicts this text is likely FAKE based on patterns learned during training.";
    } else {
      isFake = false;
      isUnverified = true;
      mainTitle = "Unverified (Insufficient Evidence)";
      reason = "Model output was unclear. Please verify using trusted sources.";
    }

    return ResultViewModel(
      type: ResultType.bert,
      title: mainTitle,
      reason: reason,
      confidence: confidence,
      isFake: isFake,
      isUnverified: isUnverified,
      queryUsed: q,
      matchesFound: 0,
      verifiedSources: const [],
      matches: const [],
      matchedSources: const [],
    );
  }

  return const ResultViewModel(
    type: ResultType.unknown,
    title: "Unknown",
    reason: "Analysis completed.",
    confidence: 0,
    isFake: false,
    isUnverified: true,
    queryUsed: "",
    matchesFound: 0,
    verifiedSources: [],
    matches: [],
    matchedSources: [],
  );
}
