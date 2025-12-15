import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../services/api_service.dart';

import 'analytics_screen.dart';
import 'history_screen.dart';
import 'chatbot_screen.dart';
import 'profile_screen.dart';
import 'verify_text_screen.dart';
import 'verify_link_screen.dart';
import 'upload_image_screen.dart';
import 'welcome_screen.dart';
import 'allnews_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeTab(),
    AnalyticsScreen(),
    HistoryScreen(),
    ChatbotScreen(),
    ProfileScreen(),
  ];

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey[400],
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.barChart3), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.bot), label: 'Chatbot'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.user), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<dynamic> _newsArticles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrendingNews();
  }

  Future<void> _loadTrendingNews() async {
    final items = await ApiService.fetchTrending();
    setState(() {
      _newsArticles = items;
      _isLoading = false;
    });
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

              _QuickActionTile(
                icon: LucideIcons.fileText,
                title: "Verify Text",
                subtitle: "Paste text to analyze",
                color: Colors.blue[50]!,
                iconColor: Colors.blue[600]!,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VerifyTextScreen())),
              ),
              const SizedBox(height: 12),

              _QuickActionTile(
                icon: LucideIcons.link,
                title: "Verify Link",
                subtitle: "Paste URL to check source",
                color: Colors.purple[50]!,
                iconColor: Colors.purple[600]!,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VerifyLinkScreen())),
              ),
              const SizedBox(height: 12),

              _QuickActionTile(
                icon: LucideIcons.image,
                title: "Scan Image",
                subtitle: "Extract text from screenshot",
                color: Colors.orange[50]!,
                iconColor: Colors.orange[600]!,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadImageScreen())),
              ),

              const SizedBox(height: 30),

              // ✅ Trending Header with See All
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Trending News",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AllNewsScreen(newsItems: _newsArticles)),
                      );
                    },
                    child: const Text("See All", style: TextStyle(color: Colors.blue)),
                  )
                ],
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 280,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
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
          children: const [
            Text("Hello, User!", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.black87)),
            SizedBox(height: 4),
            Text("Ready to verify the truth?", style: TextStyle(color: Colors.black54, fontSize: 14)),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const WelcomeScreen())),
          icon: const Icon(LucideIcons.logOut, color: Colors.black54),
        )
      ],
    );
  }
}

class StatsCard extends StatelessWidget {
  const StatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
                child: const Icon(LucideIcons.shieldCheck, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: 15),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Verifications", style: TextStyle(color: Colors.black54, fontSize: 12)),
                  Text("14 Today", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem("92%", "Accuracy", Colors.green),
              Container(width: 1, height: 30, color: Colors.grey[200]),
              _statItem("110", "Saved", Colors.orange),
            ],
          )
        ],
      ),
    );
  }

  static Widget _statItem(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 12)),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: Colors.black26, size: 20)
          ],
        ),
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final dynamic item;

  const NewsCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final String title = (item['title'] ?? 'No Title').toString();
    final String desc = (item['summary'] ?? 'No summary available').toString();
    final String source = (item['source'] ?? 'News').toString();
    final String? imageUrl = item['imageUrl']?.toString();
    final String? url = item['url']?.toString();

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
        child: Column(
          children: [
            SizedBox(
              height: 150,
              width: double.infinity,
              child: (imageUrl != null && imageUrl.isNotEmpty)
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Center(child: Icon(LucideIcons.image)),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Center(child: Icon(LucideIcons.newspaper)),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, height: 1.2),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black54, fontSize: 12, height: 1.2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(LucideIcons.globe, size: 14, color: Colors.blue[600]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            source,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: (url == null || url.isEmpty)
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => VerifyLinkScreen(key: ValueKey(url)),
                                    ),
                                  );
                                },
                          icon: const Icon(LucideIcons.search, size: 16),
                          label: const Text("Verify"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            foregroundColor: Colors.blue,
                            side: BorderSide(color: Colors.blue.shade200),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
