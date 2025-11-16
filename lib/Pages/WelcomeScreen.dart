import 'package:flutter/material.dart';
import 'package:music_recommendation_system/Pages/ProfileSetupScreen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.grey[50],
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'MusicMind',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Image.asset(
                    'assets/logo.png',
                    height: 100,
                  ),
                  const SizedBox(height: 100),
                  const Text(
                    'Music that understands you',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Discover music tailored to your emotions using EEG data. Experience a new way to connect with music.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 150),
                  
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}