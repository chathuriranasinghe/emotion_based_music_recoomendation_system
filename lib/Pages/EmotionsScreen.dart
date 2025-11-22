import 'package:flutter/material.dart';
import 'package:music_recommendation_system/Pages/HomeScreen.dart';
import 'package:music_recommendation_system/Pages/ProfileScreen.dart';
import 'package:music_recommendation_system/Pages/RecommendationsScreen.dart';
import 'package:music_recommendation_system/Pages/ManualEEGInputScreen.dart';
import 'package:music_recommendation_system/services/emotion_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'MusicPlayerScreen.dart';

class EmotionsScreen extends StatefulWidget {
  const EmotionsScreen({super.key});

  @override
  State<EmotionsScreen> createState() => _EmotionsScreenState();
}

class _EmotionsScreenState extends State<EmotionsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlaying;
  bool _isPlaying = false;
  String? _persistedEmotion;

  @override
  void initState() {
    super.initState();
    _loadPersistedEmotion();
  }

  Future<void> _loadPersistedEmotion() async {
    final emotion = await EmotionService.getCurrentEmotion();
    setState(() {
      _persistedEmotion = emotion;
    });
  }

  Future<void> _playTrack(String? previewUrl, String trackName) async {
    if (previewUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No preview available for this track')),
      );
      return;
    }

    try {
      if (_isPlaying && _currentlyPlaying == previewUrl) {
        await _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        await _audioPlayer.play(UrlSource(previewUrl));
        setState(() {
          _currentlyPlaying = previewUrl;
          _isPlaying = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing track: $e')),
      );
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _getEmotionGuidance(String? emotion) {
    if (emotion == null) return 'Connect your EEG device to detect your emotional state and get personalized music recommendations.';
    
    switch (emotion.toLowerCase()) {
      case 'sad':
      case 'sadness':
        return 'We detected sadness. Here\'s uplifting music to help boost your mood and bring positivity to your day.';
      case 'happy':
      case 'joy':
      case 'joyful':
        return 'You\'re feeling happy! Here are energetic tracks to amplify your joy and keep the good vibes flowing.';
      case 'angry':
      case 'anger':
        return 'We sense anger. These calming tracks can help you relax and find inner peace.';
      case 'stressed':
      case 'anxiety':
        return 'Feeling stressed? These peaceful melodies are designed to help you unwind and reduce anxiety.';
      case 'excited':
        return 'Your excitement is contagious! Here\'s high-energy music to match your enthusiasm.';
      case 'calm':
      case 'relaxed':
        return 'You\'re in a calm state. Enjoy these peaceful tracks to maintain your tranquility.';
      case 'lonely':
        return 'Feeling lonely? These comforting songs can provide warmth and connection.';
      case 'confident':
        return 'Your confidence is shining! Here are empowering tracks to fuel your strength.';
      default:
        return 'We\'ve detected your ${emotion.toLowerCase()} state and curated music to enhance your emotional well-being.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final currentEmotion = args?['currentEmotion'] ?? _persistedEmotion;
    final recommendedPlaylists = args?['recommendedPlaylists'] as List<dynamic>? ?? [];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
                settings: RouteSettings(
                  arguments: {
                    'currentEmotion': currentEmotion,
                    'recommendedPlaylists': recommendedPlaylists,
                  },
                ),
              ),
            );
          },
        ),
        title: Text('Emotions'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Current Emotional State',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Based on your EEG data, we\'ve detected that you\'re feeling',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            Text(
              currentEmotion?.toUpperCase() ?? 'Relaxed',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getEmotionGuidance(currentEmotion),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            if (recommendedPlaylists.isEmpty)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage('assets/relaxed.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recommended Tracks',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: recommendedPlaylists.length,
                        itemBuilder: (context, index) {
                          final track = recommendedPlaylists[index];
                          if (track == null) return const SizedBox.shrink();
                          
                          final album = track['album'] as Map?;
                          final images = album?['images'] as List?;
                          final imageUrl = images?.isNotEmpty == true 
                              ? images![0]['url'] 
                              : null;
                          final previewUrl = track['preview_url'] as String?;
                          final trackName = track['name']?.toString() ?? 'Unknown Track';
                          final artistName = track['artists']?[0]?['name']?.toString() ?? 'Unknown Artist';
                          final isCurrentTrack = _currentlyPlaying == previewUrl;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: imageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(
                                        imageUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 50,
                                            height: 50,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.music_note),
                                          );
                                        },
                                      ),
                                    )
                                  : Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.music_note),
                                    ),
                              title: Text(
                                trackName,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                artistName,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MusicPlayerScreen(
                                        trackData: track,
                                        currentEmotion: currentEmotion,
                                        recommendedPlaylists: recommendedPlaylists,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            if (recommendedPlaylists.isEmpty)
              const SizedBox(height: 120),
            if (recommendedPlaylists.isEmpty)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ManualEEGInputScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    child: Text(
                      'Predict My Emotion',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Emotions'),
          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: 'Music'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                  settings: RouteSettings(
                    arguments: {
                      'currentEmotion': currentEmotion,
                      'recommendedPlaylists': recommendedPlaylists,
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
                MaterialPageRoute(builder: (context) => const ManualEEGInputScreen()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                  settings: RouteSettings(
                    arguments: {
                      'currentEmotion': currentEmotion,
                      'recommendedPlaylists': recommendedPlaylists,
                    },
                  ),
                ),
              );
              break;
          }
        },
      ),
    );
  }
}