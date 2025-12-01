import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// --- IMPORTS FOR YOUR NEW SCREENS ---
import 'analytics_screen.dart';
import 'history_screen.dart';
import 'chatbot_screen.dart';
import 'profile_screen.dart';

// --- IMPORTS FOR FUNCTIONAL SCREENS ---
import 'verify_text_screen.dart';
import 'verify_link_screen.dart';
import 'upload_image_screen.dart';
import 'login_screen.dart';
import 'allnews_screen.dart'; // Make sure you saved the "See All" screen code

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // 1. Define the List of Screens
  // We use a getter or late final to access 'context' if needed, 
  // but since these are stateless/stateful widgets, a simple list works.
  final List<Widget> _screens = [
    const HomeTab(),      // The Dashboard (Index 0)
    const AnalyticsScreen(), // Index 1
    const HistoryScreen(),   // Index 2
    const ChatbotScreen(),   // Index 3
    const ProfileScreen(),   // Index 4
  ];

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We remove the background color here because each screen handles its own background
      body: _screens[_currentIndex], // <--- THIS SWITCHES THE TABS
      
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

// ==============================================================================
// 2. Extracted "HomeTab" 
// This contains all the UI that was previously inside HomeScreen's build method
// ==============================================================================

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample Data
    final List<Map<String, String>> newsItems = List.generate(5, (i) {
      return {
        'image': 'https://picsum.photos/seed/news$i/800/450',
        'title': 'Global News Headline #${i + 1}',
        'desc': 'This is a short summary of news item #${i + 1}. Tap to verify.',
        'accuracy': '${80 + (i % 5)}%'
      };
    });

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
              // Header
              _buildHeader(context),
              const SizedBox(height: 25),

              // Stats
              const StatsCard(),
              const SizedBox(height: 25),

              // Quick Verify Grid
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

              // News Feed Header
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
                        MaterialPageRoute(builder: (context) => AllNewsScreen(newsItems: newsItems)),
                      );
                    }, 
                    child: const Text("See All", style: TextStyle(color: Colors.blue)),
                  )
                ],
              ),
              const SizedBox(height: 10),

              // News Carousel
              SizedBox(
                height: 260,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.90),
                  padEnds: false,
                  itemCount: newsItems.length,
                  itemBuilder: (context, index) {
                    return NewsCard(item: newsItems[index]);
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
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
          icon: const Icon(LucideIcons.logOut, color: Colors.black54),
        )
      ],
    );
  }
}

// ==============================================================================
// 3. Reused Components (StatsCard, NewsCard, QuickActionTile)
// ==============================================================================

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

  Widget _statItem(String value, String label, Color color) {
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
    required this.icon, required this.title, required this.subtitle,
    required this.color, required this.iconColor, required this.onTap,
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
  final Map<String, String> item;

  const NewsCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Action when clicking news card
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Image.network(
                    item['image']!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(LucideIcons.image)),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title']!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['desc']!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.black54, fontSize: 11),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(LucideIcons.checkCircle, size: 14, color: Colors.green[600]),
                            const SizedBox(width: 4),
                            Text(
                              "Confidence: ${item['accuracy']}",
                              style: TextStyle(color: Colors.green[700], fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}