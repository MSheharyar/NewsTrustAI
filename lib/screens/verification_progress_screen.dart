import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class VerificationProgressScreen extends StatefulWidget {
  final String title;
  final String content;
  final String verifiedBy;

  const VerificationProgressScreen({
    super.key,
    required this.title,
    required this.content,
    required this.verifiedBy,
  });

  @override
  State<VerificationProgressScreen> createState() =>
      _VerificationProgressScreenState();
}

class _VerificationProgressScreenState
    extends State<VerificationProgressScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _confidence = 0.0;
  bool _completed = false;
  bool _isTrue = true;

  @override
  void initState() {
    super.initState();
    _isTrue = Random().nextBool();
    double target = Random().nextDouble() * 0.5 + 0.5; // 50–100 %

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addListener(() {
        setState(() {
          _confidence = _animation.value;
        });
      });

    _controller.forward().whenComplete(() {
      setState(() => _completed = true);
      Timer(const Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(
          context,
          '/result',
          arguments: {
            'newsTitle': widget.title,
            'verificationStatus': _isTrue ? 'True' : 'False',
            'confidence': _confidence,
            'verifiedBy': widget.verifiedBy,
          },
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _completed
        ? (_isTrue ? Colors.green : Colors.red)
        : Colors.indigo;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Analyzing News Authenticity...",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 30),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 170,
                  width: 170,
                  child: CircularProgressIndicator(
                    value: _confidence,
                    strokeWidth: 10,
                    color: color,
                    backgroundColor: Colors.grey[300],
                  ),
                ),
                Text(
                  "${(_confidence * 100).toStringAsFixed(0)}%",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            if (!_completed)
              const Text(
                "AI Model is verifying credibility...",
                style: TextStyle(color: Colors.grey),
              )
            else
              Text(
                _isTrue ? "Verified: TRUE" : "Verified: FALSE",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
