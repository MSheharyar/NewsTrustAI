import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../services/api_service.dart';
import '../login_screen.dart';
import '../verify_text_screen.dart';
import '../verify_link_screen.dart';
import '../upload_image_screen.dart';
import '../allnews_screen.dart';

import 'widgets/stats_card.dart';
import 'widgets/quick_action_tile.dart';
import 'widgets/news_card.dart';

class HomeTab extends StatefulWidget {
  final String firstName;
  const HomeTab({super.key, required this.firstName});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<dynamic> _newsArticles = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTrendingNews();
  }

  Future<void> _loadTrendingNews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await ApiService.fetchTrending();
      if (!mounted) return;
      setState(() {
        _newsArticles = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = "Failed to load trending news.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 20;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 25),

              const StatsCard(),
              const SizedBox(height: 25),

              const Text(
                "Quick Verify",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
              ),
              const SizedBox(height: 15),

              QuickActionTile(
                icon: LucideIcons.fileText,
                title: "Verify Text",
                subtitle: "Paste text to analyze",
                color: Colors.blue[50]!,
                iconColor: Colors.blue[600]!,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VerifyTextScreen()),
                ),
              ),
              const SizedBox(height: 12),

              QuickActionTile(
                icon: LucideIcons.link,
                title: "Verify Link",
                subtitle: "Paste URL to check source",
                color: Colors.purple[50]!,
                iconColor: Colors.purple[600]!,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VerifyLinkScreen()),
                ),
              ),
              const SizedBox(height: 12),

              QuickActionTile(
                icon: LucideIcons.image,
                title: "Scan Image",
                subtitle: "Extract text from screenshot",
                color: Colors.orange[50]!,
                iconColor: Colors.orange[600]!,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UploadImageScreen()),
                ),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Trending News",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _newsArticles.isEmpty
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AllNewsScreen(newsItems: _newsArticles),
                                  ),
                                );
                              },
                        child: const Text("See All", style: TextStyle(color: Colors.blue)),
                      ),
                      IconButton(
                        tooltip: "Refresh",
                        onPressed: _loadTrendingNews,
                        icon: const Icon(LucideIcons.refreshCcw, size: 18),
                      )
                    ],
                  )
                ],
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 260,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (_error != null)
                        ? Center(
                            child: Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          )
                        : _newsArticles.isEmpty
                            ? const Center(child: Text("No news available"))
                            : PageView.builder(
                                controller: PageController(viewportFraction: 0.90),
                                padEnds: false,
                                itemCount: _newsArticles.length > 5 ? 5 : _newsArticles.length,
                                itemBuilder: (context, index) {
                                  return NewsCard(item: _newsArticles[index]);
                                },
                              ),
              ),

              SizedBox(height: bottomPadding),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, ${widget.firstName}!",
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            const Text("Ready to verify the truth?", style: TextStyle(color: Colors.black54, fontSize: 14)),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
          icon: const Icon(LucideIcons.logOut, color: Colors.black54),
        )
      ],
    );
  }
}