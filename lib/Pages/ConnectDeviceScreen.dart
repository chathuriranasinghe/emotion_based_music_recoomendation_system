import 'package:flutter/material.dart';
import 'package:music_recommendation_system/Pages/ConnectedSuccessfullyScreen.dart';
import 'package:music_recommendation_system/Pages/ManualEEGInputScreen.dart';

class ConnectDeviceScreen extends StatelessWidget {
  const ConnectDeviceScreen({super.key});

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
                  'Connect Your Device',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Let's get started",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Follow these steps to connect your EEG device and start receiving personalized music recommendations.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Image.asset(
                    'assets/eeg_device.jpg', 
                    height: 200, 
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Steps',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '1. Prepare Your Device',
                  style: TextStyle(fontSize: 16),
                ),
                const Text(
                  '   • Ensure your EEG device is charged and within range.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                const Text(
                  '2. Enable Bluetooth',
                  style: TextStyle(fontSize: 16),
                ),
                const Text(
                  '   • Open your device\'s settings and enable Bluetooth.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                const Text(
                  '3. Connect',
                  style: TextStyle(fontSize: 16),
                ),
                const Text(
                  '   • Tap the button below to initiate the connection.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ConnectedSuccessfullyScreen()),
                      );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Connect',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ManualEEGInputScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Add Data Manually',
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