import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '/../services/api_service.dart';
import '../../verify_link_screen.dart';

class NewsCard extends StatelessWidget {
  final dynamic item;
  const NewsCard({super.key, required this.item});

  Map<String, dynamic> _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    return <String, dynamic>{};
  }

  String? extractNewsUrl(Map<String, dynamic> m) {
    dynamic v = m['url'] ??
        m['link'] ??
        m['articleUrl'] ??
        m['article_url'] ??
        m['newsUrl'] ??
        m['news_url'] ??
        m['sourceUrl'] ??
        m['source_url'] ??
        m['webUrl'] ??
        m['web_url'];

    if (v == null) return null;

    var s = v.toString().trim();
    if (s.isEmpty) return null;

    if (s.startsWith("//")) s = "https:$s";
    if (s.startsWith("www.")) s = "https://$s";
    if (!s.startsWith("http://") && !s.startsWith("https://")) {
      // if backend returns domain only
      s = "https://$s";
    }
    return s;
  }

  String stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final map = _asMap(item);

    final String title = (map['title'] ?? 'No Title').toString();
    final String descRaw = (map['summary'] ?? 'No summary available').toString();
    final String desc = stripHtml(descRaw);
    final String source = (map['source'] ?? 'News').toString();

    final String? url = extractNewsUrl(map);
    final String? imageUrl = ApiService.resolveNewsImageUrl(map);

    // ✅ Debug: uncomment for 1 run to see what's coming
    debugPrint("IMAGE URL => $imageUrl");

    return Container(
      margin: const EdgeInsets.only(right: 15, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 260, // keep fixed height for PageView
          child: Column(
            children: [
              // ✅ Image area fixed
              SizedBox(
                height: 140,
                width: double.infinity,
                child: (imageUrl != null && imageUrl.isNotEmpty)
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                        errorBuilder: (_, __, ___) => _imgFallback(),
                      )
                    : _imgFallback(),
              ),

              // ✅ Content area must NOT overflow
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Source chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          source,
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Title (fixed lines)
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),

                      // Description (take remaining space but stop overflow)
                      Expanded(
                        child: Text(
                          desc,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Button at bottom (always fits)
                      SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: OutlinedButton.icon(
                          onPressed: (url == null || url.isEmpty)
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => VerifyLinkScreen(initialUrl: url),
                                    ),
                                  );
                                },
                          icon: const Icon(LucideIcons.search, size: 16),
                          label: const Text("Verify Authenticity"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: BorderSide(color: Colors.blue.shade200),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imgFallback() {
    return Container(
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.imageOff, color: Colors.black38),
          SizedBox(height: 6),
          Text("No image", style: TextStyle(color: Colors.black45, fontSize: 12)),
        ],
      ),
    );
  }
}
