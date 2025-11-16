import 'package:flutter/material.dart';
import 'package:music_recommendation_system/Pages/HomeScreen.dart';

class ConnectedSuccessfullyScreen extends StatelessWidget {
  const ConnectedSuccessfullyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.grey[50],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Device Connected',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Connection Successful!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your EEG device is now successfully connected. Get ready to explore music tailored to your emotions.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/eeg_connection.jpg',
                      height: 450,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Start Emotion Tracking',
                    style: TextStyle(fontSize: 16),
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