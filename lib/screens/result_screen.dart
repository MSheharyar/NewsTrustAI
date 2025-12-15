import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

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

  bool get _hasHybrid => data.containsKey("final_label") || data.containsKey("final_confidence");
  bool get _isBertFormat => data.containsKey("label") || data.containsKey("confidence");
  bool get _isVerifyFormat => data.containsKey("verified") || data.containsKey("top_matches");

  @override
  Widget build(BuildContext context) {
    // ✅ Prefer hybrid (best), else verify, else bert
    final bool useHybrid = _hasHybrid;
    final bool useVerify = !useHybrid && _isVerifyFormat;
    final bool isBert = !useHybrid && !useVerify && _isBertFormat;

    // ✅ Query used (for verify/hybrid)
    final String q = (data["query_used"] ?? usedQuery ?? "").toString().trim();

    // Unified output variables
    bool isFake = false;
    bool isUnverified = false;
    double confidence = 0;
    String mainTitle = "Unknown";
    String reason = "Analysis completed.";
    List<String> verifiedSources = [];
    List<dynamic> matches = [];

    // -------------------------------
    // 1) HYBRID FORMAT: /analyze-text
    // -------------------------------
    if (useHybrid) {
      final String finalLabel = (data["final_label"] ?? "unverified").toString().toLowerCase().trim();
      final double finalConf = (data["final_confidence"] is num)
          ? (data["final_confidence"] as num).toDouble()
          : double.tryParse(data["final_confidence"]?.toString() ?? "") ?? 0;

      confidence = finalConf;

      // Decide UI state from final_label
      if (finalLabel.contains("real") || finalLabel.contains("true")) {
        isFake = false;
        isUnverified = false;
        mainTitle = "Likely Authentic";
      } else if (finalLabel.contains("fake") || finalLabel.contains("false")) {
        isFake = true;
        isUnverified = false;
        mainTitle = "Suspicious Content";
      } else {
        // ✅ The UI FIX YOU REQUESTED
        isFake = false;
        isUnverified = true;
        mainTitle = "Unverified (Insufficient Evidence)";
      }

      reason = (data["final_reason"] ?? "Hybrid analysis completed.").toString();

      // verify fields (optional in hybrid payload)
      matches = (data["top_matches"] is List) ? (data["top_matches"] as List) : [];
      verifiedSources = matches
          .map((m) {
            if (m is Map && m["article"] is Map) {
              return (m["article"]["source"] ?? "").toString();
            }
            return "";
          })
          .where((s) => s.trim().isNotEmpty)
          .toSet()
          .toList();
    }

    // -------------------------------
    // 2) VERIFY FORMAT: /verify
    // -------------------------------
    else if (useVerify) {
      final bool verified = data["verified"] == true;
      final int count = (data["count"] ?? 0) is int
          ? data["count"]
          : int.tryParse("${data["count"]}") ?? 0;

      matches = (data["top_matches"] is List) ? (data["top_matches"] as List) : [];

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
        // ✅ UI FIX: don’t call it “fake” if no evidence exists
        isFake = false;
        isUnverified = true;
        mainTitle = "Unverified (Insufficient Evidence)";
        reason =
            "No matching articles were found in our trusted sources database. This content may be missing context, edited, old, or not covered by our sources.";
      }

      verifiedSources = matches
          .map((m) {
            if (m is Map && m["article"] is Map) {
              return (m["article"]["source"] ?? "").toString();
            }
            return "";
          })
          .where((s) => s.trim().isNotEmpty)
          .toSet()
          .toList();
    }

    // -------------------------------
    // 3) BERT FORMAT: /predict-text
    // -------------------------------
    else if (isBert) {
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
    }

    // -------------------------------
    // Theme
    // -------------------------------
    final Color themeColor = isUnverified
        ? Colors.orange
        : (isFake ? Colors.red : Colors.green);

    final Color bgColor = isUnverified
        ? Colors.orange.shade50
        : (isFake ? Colors.red.shade50 : Colors.green.shade50);

    final IconData statusIcon = isUnverified
        ? LucideIcons.helpCircle
        : (isFake ? LucideIcons.alertTriangle : LucideIcons.shieldCheck);

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

            // --- 1) VERDICT CARD ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: themeColor.withOpacity(0.10),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                    child: Icon(statusIcon, size: 60, color: themeColor),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    mainTitle,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: themeColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${confidence.toStringAsFixed(0)}% Confidence",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),

                  if (useHybrid || useVerify) ...[
                    Text(
                      "Matches found: ${data["count"] ?? 0}",
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ] else if (isBert) ...[
                    const Text(
                      "Model: BERT (Sequence Classification)",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- 2) EXPLANATION ---
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
                      const Text(
                        "Why this result?",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(reason, style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black54)),

                  if (q.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text("Query used:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(q, style: const TextStyle(color: Colors.black87)),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- 3) SOURCES + MATCHES (for verify/hybrid) ---
            if (useHybrid || useVerify) ...[
              if (verifiedSources.isNotEmpty) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Matched Sources:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: verifiedSources.map((s) => _SourceChip(s, isMatch: true)).toList(),
                ),
              ] else ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Checked against:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "No matches found in our trusted database.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: const [
                    _SourceChip("BBC", isMatch: false),
                    _SourceChip("CNN", isMatch: false),
                    _SourceChip("DAWN", isMatch: false),
                    _SourceChip("ARY", isMatch: false),
                  ],
                ),
              ],

              const SizedBox(height: 18),

              if (matches.isNotEmpty) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Top Matches:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 12),
                ...matches.take(3).map((m) => _MatchTile(match: m)).toList(),
              ],
            ],            

            const SizedBox(height: 30),

            // --- 4) ACTION BUTTON ---
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

class _ProbCard extends StatelessWidget {
  final dynamic probabilities;

  const _ProbCard({required this.probabilities});

  @override
  Widget build(BuildContext context) {
    String real = "-";
    String fake = "-";

    if (probabilities is Map) {
      real = (probabilities["real"] ?? "-").toString();
      fake = (probabilities["fake"] ?? "-").toString();
    } else if (probabilities is List && probabilities.length >= 2) {
      fake = probabilities[0].toString();
      real = probabilities[1].toString();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("FAKE: $fake%", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text("REAL: $real%", style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _MatchTile extends StatelessWidget {
  final dynamic match;

  const _MatchTile({required this.match});

  @override
  Widget build(BuildContext context) {
    final int score = (match is Map && match["score"] != null)
        ? (match["score"] is int ? match["score"] : int.tryParse(match["score"].toString()) ?? 0)
        : 0;

    final Map<String, dynamic> article =
        (match is Map && match["article"] is Map) ? Map<String, dynamic>.from(match["article"]) : {};

    final String title = (article["title"] ?? "No Title").toString();
    final String source = (article["source"] ?? "Source").toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "$score%",
              style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(source, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceChip extends StatelessWidget {
  final String label;
  final bool isMatch;

  const _SourceChip(this.label, {required this.isMatch});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isMatch ? Colors.green[50] : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isMatch ? Colors.green.shade200 : Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMatch ? LucideIcons.checkCircle : LucideIcons.globe,
            size: 16,
            color: isMatch ? Colors.green[700] : Colors.grey[500],
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isMatch ? Colors.green[800] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}