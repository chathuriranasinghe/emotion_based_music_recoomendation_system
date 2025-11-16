import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'HomeScreen.dart';
import 'EmotionsScreen.dart';
import 'ProfileScreen.dart';

// You would use this screen in your main.dart file like this:
// home: const ManualEEGInputScreen(),

class ManualEEGInputScreen extends StatefulWidget {
  const ManualEEGInputScreen({super.key});

  @override
  State<ManualEEGInputScreen> createState() => _ManualEEGInputScreenState();
}

class _ManualEEGInputScreenState extends State<ManualEEGInputScreen> {
  // Controller for the input text field
  final TextEditingController _eegController = TextEditingController();
  // State to hold the predicted emotion
  String _predictedEmotion = "";
  String _errorMessage = "";
  bool _isLoading = false;
  List<dynamic> _playlists = [];
  bool _showPlaylists = false;

  static const String _apiUrl =
      "https://emotion-api-978585089245.us-central1.run.app";
  static const String _spotifyClientId = "5471f3d6b8214f8e9411516b3038e476";
  static const String _spotifyClientSecret = "d32f8353924c4168b7efd099f391aaee";

  // Function to predict emotion using backend API
  Future<void> _predictEmotion() async {
    if (_eegController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "Please enter EEG data";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      // Parse input text to EEG matrix
      List<List<double>> eegMatrix = [];
      List<String> lines = _eegController.text.trim().split('\n');

      for (String line in lines) {
        if (line.trim().isNotEmpty) {
          try {
            List<double> channel =
                line.split(',').map((s) => double.parse(s.trim())).toList();
            eegMatrix.add(channel);
          } catch (e) {
            throw Exception("Invalid number format in line: $line");
          }
        }
      }

      if (eegMatrix.isEmpty) {
        throw Exception("No valid EEG data found");
      }

      print('EEG Matrix: $eegMatrix'); // Debug print

      // Make API request
      final response = await http.post(
        Uri.parse('$_apiUrl/predict-raw'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'eeg_matrix': eegMatrix}),
      );

      print('API Response Status: ${response.statusCode}'); // Debug print
      print('API Response Body: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final emotion = data['emotion'] ?? 'Unknown';
        print('Predicted Emotion: $emotion'); // Debug print

        // Get Spotify tracks based on emotion
        final tracks = await _getSpotifyPlaylists(emotion);
        print('Spotify Tracks Count: ${tracks.length}'); // Debug print

        setState(() {
          _predictedEmotion = emotion;
          _playlists = tracks;
          _showPlaylists = true;
          _isLoading = false;
        });

        // Navigate to home page with emotion and tracks data
        if (mounted) {
          print('Attempting navigation to HomeScreen'); // Debug print
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const EmotionsScreen(),
                settings: RouteSettings(
                  arguments: {
                    'currentEmotion': emotion,
                    'recommendedPlaylists': tracks,
                  },
                ),
              ),
            );
            print('Navigation completed'); // Debug print
          });
        }
      } else {
        String errorMsg = 'API Error: ${response.statusCode}';
        try {
          final error = json.decode(response.body);
          errorMsg = error['detail'] ?? errorMsg;
        } catch (e) {
          errorMsg = 'Server returned: ${response.body}';
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('Prediction Error: $e'); // Debug print
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // Get Spotify access token
  Future<String> _getSpotifyToken() async {
    String credentials =
        base64Encode(utf8.encode('$_spotifyClientId:$_spotifyClientSecret'));

    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {'Authorization': 'Basic $credentials'},
      body: {'grant_type': 'client_credentials'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['access_token'];
    }
    throw Exception('Failed to get Spotify token');
  }

  // Get tracks from Spotify based on emotion
  Future<List<dynamic>> _getSpotifyPlaylists(String emotion) async {
    try {
      final token = await _getSpotifyToken();

      final response = await http.get(
        Uri.parse(
            'https://api.spotify.com/v1/search?q=$emotion&type=track&limit=10'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['tracks']['items'] ?? [];
      }
    } catch (e) {
      print('Error fetching tracks: $e');
    }
    return [];
  }

  // Show Spotify URL
  void _showSpotifyUrl(BuildContext context, String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Spotify URL: $url'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Function to clear input and reset state
  void _clearInput() {
    setState(() {
      _eegController.clear();
      _predictedEmotion = "";
      _errorMessage = "";
      _isLoading = false;
      _playlists = [];
      _showPlaylists = false;
    });
  }

  @override
  void dispose() {
    _eegController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. App Bar
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
                settings: RouteSettings(
                  arguments: {
                    'currentEmotion': _predictedEmotion.isNotEmpty ? _predictedEmotion : null,
                    'recommendedPlaylists': _playlists,
                  },
                ),
              ),
            );
          },
        ),
        title: const Text(
          'Manual EEG Data Input',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20),
      ),

      // 2. Body Content
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Instructions
            const Text(
              'Manual EEG Data Input Instructions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Enter your EEG values for each channel.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Separate each number with a comma ,',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Each line represents one channel.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Example (2 channels):',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Text(
                '0.12,0.25,0.30,0.18,0.40\n0.15,0.28,0.35,0.20,0.42',
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'monospace',
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tips:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '• Use only numbers.\n• Keep the same number of values per channel.\n• Press Predict Emotion to see results.\n• Press Clear Input to start over.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Errors:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'If the format is wrong, the system will show a message in red.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),

            // Error Message Display
            if (_errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ),

            // EEG Value Input Field
            TextField(
              controller: _eegController,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: 'Enter your EEG values here, one channel per line...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.grey[100],
                filled: true,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons (Predict Emotion and Clear Input)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // Predict Emotion Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _predictEmotion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Predict Emotion',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                // Clear Input Button
                OutlinedButton(
                  onPressed: _clearInput,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black54,
                    side: const BorderSide(color: Colors.grey),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Clear input',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        showUnselectedLabels: true,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Emotions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note_outlined),
            activeIcon: Icon(Icons.music_note),
            label: 'Music',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                  settings: RouteSettings(
                    arguments: {
                      'currentEmotion': _predictedEmotion.isNotEmpty ? _predictedEmotion : null,
                      'recommendedPlaylists': _playlists,
                    },
                  ),
                ),
              );
              break;
            case 1:
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const EmotionsScreen()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
              break;
          }
        },
      ),
    );
  }
}
