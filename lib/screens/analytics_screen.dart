import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text("Verification Insights", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Overview Cards
            Row(
              children: [
                Expanded(child: _OverviewCard(label: "Total Scans", value: "313", color: Colors.blue, icon: LucideIcons.scan)),
                const SizedBox(width: 15),
                Expanded(child: _OverviewCard(label: "Fake Detected", value: "92", color: Colors.red, icon: LucideIcons.alertTriangle)),
              ],
            ),
            const SizedBox(height: 25),

            // 2. Weekly Activity Chart (Custom Built)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Weekly Breakdown", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _BarColumn(label: "Mon", height: 60, color: Colors.blue[100]!),
                      _BarColumn(label: "Tue", height: 80, color: Colors.blue[200]!),
                      _BarColumn(label: "Wed", height: 120, color: Colors.blue), // Peak
                      _BarColumn(label: "Thu", height: 90, color: Colors.blue[300]!),
                      _BarColumn(label: "Fri", height: 50, color: Colors.blue[100]!),
                      _BarColumn(label: "Sat", height: 30, color: Colors.blue[50]!),
                      _BarColumn(label: "Sun", height: 40, color: Colors.blue[50]!),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // 3. Top Fake Sources
            const Text("Most Frequent Fake Sources", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _SourceTile(name: "viral-news-24.xyz", count: 45, percentage: 0.8),
            const SizedBox(height: 10),
            _SourceTile(name: "whatsapp-forwards", count: 32, percentage: 0.6),
            const SizedBox(height: 10),
            _SourceTile(name: "clickbait-daily.net", count: 18, percentage: 0.3),
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _OverviewCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 15),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _BarColumn extends StatelessWidget {
  final String label;
  final double height;
  final Color color;

  const _BarColumn({required this.label, required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 12,
          height: height,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _SourceTile extends StatelessWidget {
  final String name;
  final int count;
  final double percentage;

  const _SourceTile({required this.name, required this.count, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text("$count detected", style: TextStyle(color: Colors.red[400], fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[100],
            color: Colors.red[400],
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }
}