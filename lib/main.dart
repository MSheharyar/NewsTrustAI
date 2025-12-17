import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // This should be generated via flutterfire CLI

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/verification_result_screen.dart';
import 'screens/history_screen.dart';
import 'screens/verification_progress_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure binding before async calls
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const NewsVerifierApp());
}

class NewsVerifierApp extends StatelessWidget {
  const NewsVerifierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NewsTrustAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(firstName: "",),
        '/result': (context) => const VerificationResultScreen(
              newsTitle: '',
              verificationStatus: '',
              confidence: 0.0,
              verifiedBy: '',
            ),
        '/history': (context) => const HistoryScreen(),
        '/progress': (context) => const VerificationProgressScreen(
              title: '',
              content: '',
              verifiedBy: '',
            ),
      },
    );
  }
}
