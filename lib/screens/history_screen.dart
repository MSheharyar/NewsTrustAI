import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Example data — replace with dynamic data later
    final List<Map<String, dynamic>> verifiedNews = [
      {
        "title": "Government passes AI regulation bill",
        "status": "True",
        "confidence": 0.92,
        "verifiedBy": "AI Model"
      },
      {
        "title": "New COVID variant found in Pakistan",
        "status": "False",
        "confidence": 0.87,
        "verifiedBy": "AI + Manual Review"
      },
      {
        "title": "Facebook to ban all fake news accounts",
        "status": "Partially True",
        "confidence": 0.65,
        "verifiedBy": "AI Model"
      },
    ];

    Color getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case "true":
          return Colors.green;
        case "false":
          return Colors.red;
        case "partially true":
          return Colors.orange;
        default:
          return Colors.grey;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Verification History"),
        backgroundColor: Colors.indigo,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: verifiedNews.length,
        itemBuilder: (context, index) {
          final news = verifiedNews[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: Icon(
                Icons.article,
                color: getStatusColor(news["status"]),
                size: 40,
              ),
              title: Text(
                news["title"],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    "Status: ${news["status"]}",
                    style: TextStyle(
                      color: getStatusColor(news["status"]),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "Confidence: ${(news["confidence"] * 100).toStringAsFixed(1)}%",
                  ),
                  Text("Verified by: ${news["verifiedBy"]}"),
                ],
              ),
              onTap: () {
                // Navigate to result details screen (reuse VerificationResultScreen)
                Navigator.pushNamed(
                  context,
                  '/result',
                  arguments: {
                    'newsTitle': news['title'],
                    'verificationStatus': news['status'],
                    'confidence': news['confidence'],
                    'verifiedBy': news['verifiedBy'],
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
