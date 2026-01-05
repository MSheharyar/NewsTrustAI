import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'result_parser.dart';
import 'result_view_model.dart';
import 'widgets/verdict_card.dart';
import 'widgets/matched_source_card.dart';
import 'widgets/debug_details_card.dart';
import '/services/firestore_history_service.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final String? originalText;
  final String? usedQuery;
  final String resultMode; // "text" | "link" | "image"

  const ResultScreen({
    super.key,
    required this.data,
    this.originalText,
    this.usedQuery,
    this.resultMode = "text",
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _history = FirestoreHistoryService();
  bool _saved = false;

  String _safeStr(dynamic v, [String fallback = ""]) {
    if (v == null) return fallback;
    return v.toString();
  }

  Future<void> _open(String url) async {
    final u = Uri.tryParse(url.trim());
    if (u == null) return;
    if (!await canLaunchUrl(u)) return;
    await launchUrl(u, mode: LaunchMode.externalApplication);
  }

  @override
  void initState() {
    super.initState();

    // ✅ Save once after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveToFirestoreOnce();
    });
  }

  Future<void> _saveToFirestoreOnce() async {
    if (_saved) return;
    _saved = true;

    // link input
    final String inputUrl = (widget.data["input_url"] ??
            (widget.resultMode == "link"
                ? (widget.originalText ?? widget.usedQuery ?? "")
                : ""))
        .toString()
        .trim();

    final String inputToStore = widget.resultMode == "link"
        ? inputUrl
        : (widget.originalText ?? widget.usedQuery ?? "").toString().trim();

    // parse vm
    final ResultViewModel vm = parseResultData(
      widget.data,
      usedQuery: widget.usedQuery,
      resultMode: widget.resultMode,
      inputUrl: widget.resultMode == "link" ? inputUrl : null,
    );

    // verdict string
    final String verdict = vm.isReal ? "verified" : (vm.isFake ? "fake" : "unverified");

    // source list
    final List<Map<String, dynamic>> topMatches = vm.sources.map((s) {
      return {
        "type": s.type,
        "source": s.source,
        "domain": s.domain,
        "url": s.url,
        "time": s.time,
        "score": s.score,
        "trusted": s.trusted,
        "rating": s.rating,
      };
    }).toList();

    try {
      await _history.saveVerification(
        rawResult: widget.data,
        inputType: widget.resultMode,
        input: inputToStore,
        usedQuery: vm.queryUsed.isNotEmpty ? vm.queryUsed : (widget.usedQuery ?? ""),
        verdict: verdict,
        confidence: vm.confidence,
        method: vm.method,
        reason: vm.reasonText,
        topMatches: topMatches,
      );
    } catch (_) {
      // ignore (do not break UI)
    }
  }

  @override
  Widget build(BuildContext context) {
    final ResultViewModel vm = parseResultData(
      widget.data,
      usedQuery: widget.usedQuery,
      resultMode: widget.resultMode,
      inputUrl: widget.resultMode == "link" ? (widget.originalText ?? widget.usedQuery) : null,
    );

    final String inputUrl = (widget.data["input_url"] ??
            (widget.resultMode == "link" ? (widget.originalText ?? widget.usedQuery ?? "") : ""))
        .toString()
        .trim();

    final String linkDomain = _safeStr(widget.data["link_domain"], vm.linkDomain).trim();
    final String tier = _safeStr(widget.data["source_tier"], vm.tier).trim().toLowerCase();

    Color tierColor() {
      if (tier == "main") return Colors.green;
      if (tier == "other") return Colors.orange;
      return Colors.grey;
    }

    String tierText() {
      if (tier == "main") return "Main site";
      if (tier == "other") return "Other site";
      return "Unknown";
    }

    // GROUP
    final factchecks = vm.sources.where((s) => s.type.toLowerCase() == "factcheck").toList();
    final dbSources = vm.sources.where((s) => s.type.toLowerCase() == "db").toList();
    final liveSources = vm.sources.where((s) => s.type.toLowerCase() == "live").toList();
    final unknown = vm.sources.where((s) {
      final t = s.type.toLowerCase();
      return t != "factcheck" && t != "db" && t != "live";
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Analysis Result",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VerdictCard(
                title: vm.verdictTitle,
                subtitle: vm.verdictSubtitle,
                confidence: vm.confidence,
                method: vm.method,
              ),
              const SizedBox(height: 14),

              if (widget.resultMode == "link" && inputUrl.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Verified link:", style: TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _open(inputUrl),
                        child: Text(
                          inputUrl,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Domain: ${linkDomain.isEmpty ? "unknown" : linkDomain}",
                              style: const TextStyle(color: Colors.black54, fontSize: 12),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: tierColor().withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              tierText(),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: tier == "main"
                                    ? Colors.green[700]
                                    : tier == "other"
                                        ? Colors.orange[700]
                                        : Colors.grey[700],
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(LucideIcons.info, size: 18, color: Colors.blue),
                        SizedBox(width: 8),
                        Text("Why this result?", style: TextStyle(fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(vm.reasonText, style: const TextStyle(color: Colors.black54, height: 1.4)),
                    const Divider(height: 22),
                    const Text("What we checked", style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(vm.whatCheckedText, style: const TextStyle(color: Colors.black54, height: 1.4)),
                    if (vm.queryUsed.trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        "Query used: ${vm.queryUsed}",
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                    const Divider(height: 22),
                    const Text("What you can do next", style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    ...vm.tips.map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•  ", style: TextStyle(color: Colors.black54)),
                            Expanded(child: Text(t, style: const TextStyle(color: Colors.black54))),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 14),

              if (vm.factsDebug != null) ...[
                DebugDetailsCard(factsDebug: vm.factsDebug!),
                const SizedBox(height: 16),
              ],

              const Text("Checked against:", style: TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),

              if (factchecks.isNotEmpty) ...[
                _groupHeader("Fact-check results", LucideIcons.badgeInfo),
                const SizedBox(height: 8),
                ...factchecks.map((s) => MatchedSourceCard(src: s)),
                const SizedBox(height: 6),
              ],
              if (dbSources.isNotEmpty) ...[
                _groupHeader("Database matches", LucideIcons.database),
                const SizedBox(height: 8),
                ...dbSources.map((s) => MatchedSourceCard(src: s)),
                const SizedBox(height: 6),
              ],
              if (liveSources.isNotEmpty) ...[
                _groupHeader("Live sources", LucideIcons.globe),
                const SizedBox(height: 8),
                ...liveSources.map((s) => MatchedSourceCard(src: s)),
                const SizedBox(height: 6),
              ],
              if (unknown.isNotEmpty) ...[
                _groupHeader("Other sources", LucideIcons.link),
                const SizedBox(height: 8),
                ...unknown.map((s) => MatchedSourceCard(src: s)),
              ],

              if (vm.sources.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    "No matched sources were returned.",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    "Verify Another",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _groupHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black87)),
      ],
    );
  }
}
