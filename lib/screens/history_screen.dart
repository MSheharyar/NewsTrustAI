import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'result/result_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text(
          "Scan History",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.trash2, color: Colors.grey),
            onPressed: () async {
              if (user == null) return;

              final ref = FirebaseFirestore.instance
                  .collection("users")
                  .doc(user.uid)
                  .collection("verifications");

              final snap = await ref.get();
              for (final d in snap.docs) {
                await d.reference.delete();
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("History cleared")),
              );
            },
          )
        ],
      ),
      body: user == null
          ? const Center(child: Text("Please login to view history"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(user.uid)
                  .collection("verifications")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Failed to load history"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text("No history yet"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    final input = (data["input"] ?? "").toString();
                    final inputType = (data["inputType"] ?? "text").toString();
                    final verdict = (data["verdict"] ?? "unverified").toString();
                    final confidence = data["confidence"];
                    final rawResult = data["rawResult"] as Map<String, dynamic>?;

                    // 🔥 OCR META (for image scans)
                    final ocrMeta = data["ocr_meta"] as Map<String, dynamic>?;
                    final ocrConfidence = ocrMeta?["confidence"];
                    final imagePath = ocrMeta?["imagePath"];

                    final ts = data["createdAt"] as Timestamp?;
                    final date = ts == null
                        ? "Just now"
                        : "${ts.toDate().day}/${ts.toDate().month}/${ts.toDate().year}";

                    final bool isFake = verdict == "fake";
                    final bool isVerified = verdict == "verified";

                    IconData icon;
                    Color color;

                    if (isFake) {
                      icon = LucideIcons.alertTriangle;
                      color = Colors.red;
                    } else if (isVerified) {
                      icon = LucideIcons.shieldCheck;
                      color = Colors.green;
                    } else {
                      icon = LucideIcons.badgeInfo;
                      color = Colors.orange;
                    }

                    return GestureDetector(
                      onTap: rawResult == null
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ResultScreen(
                                    data: rawResult,
                                    originalText: input,
                                    usedQuery: data["usedQuery"],
                                    resultMode: inputType,
                                  ),
                                ),
                              );
                            },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            // 🔥 IMAGE PREVIEW OR ICON
                            if (inputType == "image" &&
                                imagePath != null &&
                                File(imagePath).existsSync())
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(imagePath),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(icon, color: color, size: 20),
                              ),

                            const SizedBox(width: 15),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    input.isEmpty ? "Verification" : input,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${inputType.toUpperCase()} • $date",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),

                                  // 🔥 OCR CONFIDENCE
                                  if (inputType == "image" &&
                                      ocrConfidence != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        "OCR Confidence: ${ocrConfidence.toStringAsFixed(0)}%",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.blueGrey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            const Icon(
                              LucideIcons.chevronRight,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}