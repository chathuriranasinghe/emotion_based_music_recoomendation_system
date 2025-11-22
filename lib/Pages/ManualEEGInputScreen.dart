import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'HomeScreen.dart';
import 'EmotionsScreen.dart';
import 'ProfileScreen.dart';
import '../services/emotion_service.dart';

class ManualEEGInputScreen extends StatefulWidget {
  const ManualEEGInputScreen({super.key});

  @override
  State<ManualEEGInputScreen> createState() => _ManualEEGInputScreenState();
}

class _ManualEEGInputScreenState extends State<ManualEEGInputScreen> {
  final TextEditingController _eegController = TextEditingController();
  String _predictedEmotion = "";
  String _errorMessage = "";
  bool _isLoading = false;
  List<dynamic> _playlists = [];
  bool _showPlaylists = false;

  static const String _apiUrl =
      "https://emotion-api-978585089245.us-central1.run.app";
  static const String _spotifyClientId = "5471f3d6b8214f8e9411516b3038e476";
  static const String _spotifyClientSecret = "d32f8353924c4168b7efd099f391aaee";


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

      print('EEG Matrix: $eegMatrix');


      final response = await http.post(
        Uri.parse('$_apiUrl/predict-raw'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'eeg_matrix': eegMatrix}),
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final emotion = data['emotion'] ?? 'Unknown';
        print('Predicted Emotion: $emotion');

        final tracks = await _getSpotifyPlaylists(emotion);
        print('Spotify Tracks Count: ${tracks.length}');

        await EmotionService.saveEmotion(emotion);
        
        setState(() {
          _predictedEmotion = emotion;
          _playlists = tracks;
          _showPlaylists = true;
          _isLoading = false;
        });

        if (mounted) {
          print('Attempting navigation to EmotionsScreen');
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
            print('Navigation completed');
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
      print('Prediction Error: $e');
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }


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


  Future<List<dynamic>> _getSpotifyPlaylists(String emotion) async {
    try {
      final token = await _getSpotifyToken();
      final searchQuery = _getEmotionBasedQuery(emotion);

      final response = await http.get(
        Uri.parse(
            'https://api.spotify.com/v1/search?q=$searchQuery&type=track&limit=50'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tracks = data['tracks']['items'] ?? [];
        return await _filterTracksByEmotion(tracks, emotion, token);
      }
    } catch (e) {
      print('Error fetching tracks: $e');
    }
    return [];
  }

  Future<List<dynamic>> _filterTracksByEmotion(List<dynamic> tracks, String emotion, String token) async {
    return tracks.take(15).toList();
  }

  Future<Map<String, dynamic>?> _getAudioFeatures(String trackId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/audio-features/$trackId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error getting audio features: $e');
    }
    return null;
  }

  bool _matchesEmotionCriteria(Map<String, dynamic> audioFeatures, String emotion) {
    final valence = (audioFeatures['valence'] ?? 0.0).toDouble();
    final energy = (audioFeatures['energy'] ?? 0.0).toDouble();
    final danceability = (audioFeatures['danceability'] ?? 0.0).toDouble();
    
    print('Audio features - Valence: $valence, Energy: $energy, Danceability: $danceability');
    
    switch (emotion.toLowerCase()) {
      case 'sad':
      case 'sadness':
        final matches = valence > 0.5 && energy > 0.4;
        print('SAD criteria (valence > 0.5, energy > 0.4): $matches');
        return matches;
      case 'happy':
      case 'joy':
      case 'joyful':
        final matches = valence > 0.4 && danceability > 0.3;
        print('HAPPY criteria (valence > 0.4, danceability > 0.3): $matches');
        return matches;
      default:
        return true;
    }
  }

  String _getEmotionBasedQuery(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'sad':
      case 'sadness':
        return 'happy mood feel good positive vibes';
      case 'happy':
      case 'joy':
      case 'joyful':
        return 'party hits top hits dance pop';
      case 'angry':
      case 'anger':
        return 'calm peaceful relaxing meditation';
      case 'stressed':
      case 'anxiety':
        return 'relaxing peaceful meditation calm';
      case 'excited':
        return 'high energy dance party';
      case 'calm':
      case 'relaxed':
        return 'peaceful ambient chill';
      case 'lonely':
        return 'comfort warm acoustic';
      case 'confident':
        return 'empowering motivational';
      default:
        return 'feel good positive';
    }
  }


  void _showSpotifyUrl(BuildContext context, String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Spotify URL: $url'),
        duration: const Duration(seconds: 3),
      ),
    );
  }


  void _clearInput() {
    setState(() {
      _eegController.clear();
      _errorMessage = "";
      _isLoading = false;
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


      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            const Text(
              'Manual EEG Data Input Instructions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Enter your EEG values for each channel.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Separate each number with a comma ,',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Each line represents one channel.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Example (2 channels):',
              style: TextStyle(
                fontSize: 16,
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
                  fontSize: 15,
                  fontFamily: 'monospace',
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tips:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '• Use only numbers.\n• Keep the same number of values per channel.\n• Press Predict Emotion to see results.\n• Press Clear Input to start over.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Errors:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'If the format is wrong, the system will show a message in red.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),

            if (_predictedEmotion.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.psychology, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Current Emotion: $_predictedEmotion',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

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
                    fontSize: 16,
                  ),
                ),
              ),


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


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[

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
            if (_showPlaylists && _playlists.isNotEmpty)...[
              const SizedBox(height: 20),
              Text(
                'Recommended for $_predictedEmotion:',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _playlists.length,
                itemBuilder: (context, index) {
                  final track = _playlists[index];
                  return Card(
                    child: ListTile(
                      leading: track['album']['images'].isNotEmpty
                          ? Image.network(
                              track['album']['images'][0]['url'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.music_note),
                      title: Text(track['name']),
                      subtitle: Text(track['artists'][0]['name']),
                      onTap: () => _showSpotifyUrl(context, track['external_urls']['spotify']),
                    ),
                  );
                },
              ),
            ],
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
