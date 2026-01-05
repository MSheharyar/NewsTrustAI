import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({super.key});

  User? get _user => FirebaseAuth.instance.currentUser;

  DateTime _todayStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<_StatsVm> _loadStats() async {
    final u = _user;
    if (u == null) {
      return const _StatsVm(today: 0, saved: 0, accuracyPct: null);
    }

    final ref = FirebaseFirestore.instance
        .collection("users")
        .doc(u.uid)
        .collection("verifications");

    final todayStart = Timestamp.fromDate(_todayStart());

    // Today count
    final todaySnap = await ref
        .where("createdAt", isGreaterThanOrEqualTo: todayStart)
        .get();
    final int todayCount = todaySnap.docs.length;

    // Total saved
    final totalSnap = await ref.get();
    final int savedCount = totalSnap.docs.length;


    // Accuracy: verified / (verified + fake)
    // (Using last 500 docs as a practical range; if you want perfect accuracy forever, we’ll store counters.)
    final snap = await ref.orderBy("createdAt", descending: true).limit(500).get();
    int verified = 0;
    int fake = 0;

    for (final d in snap.docs) {
      final m = d.data();
      final v = (m["verdict"] ?? "").toString().toLowerCase();
      if (v == "verified") verified++;
      if (v == "fake") fake++;
    }

    double? acc;
    final denom = verified + fake;
    if (denom > 0) {
      acc = (verified / denom) * 100.0;
    }

    return _StatsVm(today: todayCount, saved: savedCount, accuracyPct: acc);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_StatsVm>(
      future: _loadStats(),
      builder: (context, snap) {
        final loading = snap.connectionState == ConnectionState.waiting;
        final s = snap.data ?? const _StatsVm(today: 0, saved: 0, accuracyPct: null);

        final verificationsText = loading ? "—" : "${s.today} Today";
        final accuracyText = loading
            ? "—"
            : (s.accuracyPct == null ? "—" : "${s.accuracyPct!.toStringAsFixed(0)}%");
        final savedText = loading ? "—" : "${s.saved}";

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
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.shieldCheck, color: Colors.blue, size: 24),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Verifications", style: TextStyle(color: Colors.black54, fontSize: 12)),
                      Text(
                        verificationsText,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (loading) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statItem(accuracyText, "Accuracy", Colors.green),
                  Container(width: 1, height: 30, color: Colors.grey[200]),
                  _statItem(savedText, "Saved", Colors.orange),
                ],
              )
            ],
          ),
        );
      },
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

class _StatsVm {
  final int today;
  final int saved;
  final double? accuracyPct;
  const _StatsVm({required this.today, required this.saved, required this.accuracyPct});
}