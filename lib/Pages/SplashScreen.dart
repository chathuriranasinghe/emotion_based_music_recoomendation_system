import 'package:flutter/material.dart';
import 'package:music_recommendation_system/Pages/WelcomeScreen.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF19233A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(flex: 3),

            Icon(
              Icons.psychology_alt,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 30),


            const Text(
              'Your Mind\'s Soundtrack.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const Spacer(flex: 2),


            const Text(
              'Finding your frequency...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60.0),
              child: LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                backgroundColor: Colors.white12,
                minHeight: 4,
              ),
            ),

            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}