import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // This should be generated via flutterfire CLI
import 'screens/login_screen.dart';
import 'screens/home/home_screen.dart';
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
      title: 'NewsTrust AI',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
        primarySwatch: Colors.blue,                
        
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87, 
            fontSize: 20, 
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      
      // --- NAVIGATION ROUTES ---
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(firstName: "",),
      },
      
    );
  }
}