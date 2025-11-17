import 'package:flutter/material.dart';
import 'package:music_recommendation_system/Pages/ProfileScreen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:music_recommendation_system/services/music_service.dart';
import 'EmotionsScreen.dart';
import 'ManualEEGInputScreen.dart';
import 'MusicPlayerScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final MusicService _musicService = MusicService();
  String? _currentlyPlaying;
  bool _isPlaying = false;

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

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final currentEmotion = args?['currentEmotion'];
    final recommendedPlaylists = args?['recommendedPlaylists'] as List<dynamic>? ?? [];
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            color: Colors.grey[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(
                          'assets/profile.jpg'),
                      radius: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Home',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Current Emotion',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentEmotion?.toUpperCase() ?? 'Joyful',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentEmotion != null 
                                  ? 'Your EEG data indicates a state of ${currentEmotion.toLowerCase()}.'
                                  : 'Your EEG data indicates a state of happiness and contentment.',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/joyful_emoji.jpg',
                          height: 40,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Recommended for You',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                if (recommendedPlaylists.isEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/uplifting_beats.jpg',
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Uplifting Beats',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const Text(
                              'Songs to keep your spirits high',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/chill_vibes.jpg',
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Chill Vibes',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const Text(
                              'Relaxing tunes for a calm mind',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: recommendedPlaylists.take(5).map<Widget>((playlist) {
                      if (playlist == null) return const SizedBox.shrink();
                      
                      final track = playlist;
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
                              _musicService.addToRecentlyPlayed(track);
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
                    }).toList(),
                  ),
                const SizedBox(height: 24),
                const Text(
                  'Recently Played',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
_musicService.recentlyPlayed.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'No recently played tracks',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : Column(
                        children: _musicService.recentlyPlayed.take(5).map((track) {
                          final album = track['album'] as Map?;
                          final images = album?['images'] as List?;
                          final imageUrl = images?.isNotEmpty == true ? images![0]['url'] : null;
                          final trackName = track['name']?.toString() ?? 'Unknown Track';
                          final artistName = track['artists']?[0]?['name']?.toString() ?? 'Unknown Artist';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: imageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
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
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ],
            ),
          ),
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
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmotionsScreen(),
                  settings: RouteSettings(
                    arguments: {
                      'currentEmotion': currentEmotion,
                      'recommendedPlaylists': recommendedPlaylists,
                    },
                  ),
                ),
              );
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
