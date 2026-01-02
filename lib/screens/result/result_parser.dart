import 'result_view_model.dart';

ResultViewModel parseResultData(Map<String, dynamic> data, {String? usedQuery}) {
  bool hasHybrid = data.containsKey("final_label") || data.containsKey("final_confidence");
  bool isBertFormat = data.containsKey("label") || data.containsKey("confidence");
  bool isVerifyFormat = data.containsKey("verified") || data.containsKey("top_matches");

  final String q = (data["query_used"] ?? usedQuery ?? "").toString().trim();

  // ✅ NEW backend fields (safe)
  final String verificationMethod =
      (data["verification_method"] ?? "").toString().toLowerCase().trim();
  final String sourceTier =
      (data["source_tier"] ?? "").toString().toLowerCase().trim();
  final String linkDomain =
      (data["link_domain"] ?? "").toString().trim();

  // defaults
  bool isFake = false;
  bool isUnverified = false;
  double? confidence;
  String mainTitle = "Unknown";
  String reason = "Analysis completed.";
  List<String> verifiedSources = [];
  List<dynamic> matches = [];
  final List<dynamic> matchedSources =
      (data["matched_sources"] is List) ? (data["matched_sources"] as List) : const [];
  int matchesFoundNumber = 0;

  bool isMainTrustedLink() {
    return verificationMethod == "main_trusted_link" ||
        verificationMethod == "main_trusted_link_no_extract" ||
        sourceTier == "main";
  }

  // -----------------------------
  // 1) Hybrid (your backend default)
  // -----------------------------
  if (hasHybrid) {
    final String finalLabel =
        (data["final_label"] ?? "unverified").toString().toLowerCase().trim();

    double? finalConf;
    if (data["final_confidence"] == null) {
      finalConf = null;
    } else if (data["final_confidence"] is num) {
      finalConf = (data["final_confidence"] as num).toDouble();
    } else {
      finalConf = double.tryParse(data["final_confidence"].toString());
    }
    confidence = finalConf;

    // ✅ Special: main trusted link is always verified real in your backend
    if (isMainTrustedLink()) {
      isFake = false;
      isUnverified = false;
      mainTitle = "Likely Authentic";
      reason = (data["final_reason"] ??
              "Verified as real because the link is from a main trusted source (ARY/DAWN/BBC/CNN).")
          .toString();

      // For main trusted link, matches_found will usually be 0 -> that's fine
      matchesFoundNumber = (data["matches_found"] is num)
          ? (data["matches_found"] as num).toInt()
          : matchedSources.length;

      return ResultViewModel(
        type: ResultType.hybrid,
        title: mainTitle,
        reason: reason,
        confidence: confidence,
        isFake: isFake,
        isUnverified: isUnverified,
        queryUsed: q,
        matchesFound: matchesFoundNumber,
        verifiedSources: const ["BBC", "CNN", "DAWN", "ARY"], // for chips highlight logic in UI
        matches: const [],
        matchedSources: const [],
        verificationMethod: verificationMethod,
        sourceTier: sourceTier,
        linkDomain: linkDomain,
      );
    }

    // ✅ Normal hybrid parsing (text or non-main link)
    if (finalLabel == "real") {
      isFake = false;
      isUnverified = false;
      mainTitle = "Likely Authentic";
    } else if (finalLabel == "fake") {
      isFake = true;
      isUnverified = false;
      mainTitle = "Suspicious Content";
    } else if (finalLabel == "likely_fake") {
      isFake = true;
      isUnverified = false;
      mainTitle = "Suspicious Content";
    } else {
      isFake = false;
      isUnverified = true;
      mainTitle = "Unverified (Insufficient Evidence)";
    }

    // If backend explicitly says not verified/unverified, lock it
    final String verdictState = (data["verdict_state"] ?? "").toString().toLowerCase();
    if (verdictState == "not_verified" || verdictState.contains("not_verified")) {
      isUnverified = true;
      isFake = false;
      mainTitle = "Unverified (Insufficient Evidence)";
      // keep confidence if backend returns capped confidence; don't force null
      // (your backend caps confidence to <= 60 even when unverified)
    }

    reason = (data["final_reason"] ?? "Hybrid analysis completed.").toString();

    // Hybrid results typically use matched_sources
    matchesFoundNumber = (data["matches_found"] is num)
        ? (data["matches_found"] as num).toInt()
        : matchedSources.length;

    // Support sources shown in matched_sources (already pre-parsed by backend)
    verifiedSources = matchedSources
        .map((m) => (m is Map ? (m["source"] ?? "").toString() : ""))
        .where((s) => s.trim().isNotEmpty)
        .toSet()
        .toList();

    // Some older flows still send top_matches (safe fallback)
    matches = (data["top_matches"] is List) ? (data["top_matches"] as List) : [];

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
      verificationMethod: verificationMethod,
      sourceTier: sourceTier,
      linkDomain: linkDomain,
    );
  }

  // -----------------------------
  // 2) Verify endpoint (old format)
  // -----------------------------
  if (isVerifyFormat) {
    final bool verified = data["verified"] == true;
    final int count =
        (data["count"] ?? 0) is int ? data["count"] : int.tryParse("${data["count"]}") ?? 0;

    matches = (data["top_matches"] is List) ? (data["top_matches"] as List) : [];
    matchesFoundNumber = count;

    if (verified && matches.isNotEmpty && matches[0] is Map && matches[0]["score"] != null) {
      confidence = (matches[0]["score"] is num)
          ? (matches[0]["score"] as num).toDouble()
          : double.tryParse(matches[0]["score"].toString());
    } else if (verified) {
      confidence = 70;
    } else {
      confidence = null;
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
      verificationMethod: verificationMethod,
      sourceTier: sourceTier,
      linkDomain: linkDomain,
    );
  }

  // -----------------------------
  // 3) BERT only
  // -----------------------------
  if (isBertFormat) {
    final String label = (data["label"] ?? "").toString().toLowerCase().trim();

    final double? conf = (data["confidence"] is num)
        ? (data["confidence"] as num).toDouble()
        : double.tryParse(data["confidence"]?.toString() ?? "");

    confidence = conf ?? 0;

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
      verificationMethod: verificationMethod,
      sourceTier: sourceTier,
      linkDomain: linkDomain,
    );
  }

  // -----------------------------
  // 4) Unknown
  // -----------------------------
  return ResultViewModel(
    type: ResultType.unknown,
    title: "Unknown",
    reason: "Analysis completed.",
    confidence: null,
    isFake: false,
    isUnverified: true,
    queryUsed: "",
    matchesFound: 0,
    verifiedSources: const [],
    matches: const [],
    matchedSources: const [],
    verificationMethod: verificationMethod,
    sourceTier: sourceTier,
    linkDomain: linkDomain,
  );
}