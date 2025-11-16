import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'HomeScreen.dart';
import 'EmotionsScreen.dart';
import 'ManualEEGInputScreen.dart';
import 'ProfileScreen.dart';

class MusicPlayerScreen extends StatefulWidget {
  final Map<String, dynamic>? trackData;
  final String? currentEmotion;
  final List<dynamic>? recommendedPlaylists;
  
  const MusicPlayerScreen({
    super.key,
    this.trackData,
    this.currentEmotion,
    this.recommendedPlaylists,
  });

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  double _currentSliderValue = 0.0;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = const Duration(seconds: 30);
  int _currentTrackIndex = 0;

  List<dynamic> get _tracks => widget.recommendedPlaylists ?? [];
  Map<String, dynamic>? get _currentTrack => _tracks.isNotEmpty ? _tracks[_currentTrackIndex] : widget.trackData;
  
  String get _songTitle => _currentTrack?['name']?.toString() ?? 'Unknown Track';
  String get _artistName => _currentTrack?['artists']?[0]?['name']?.toString() ?? 'Unknown Artist';
  String? get _previewUrl => _currentTrack?['preview_url'] as String?;
  String? get _imageUrl {
    final album = _currentTrack?['album'] as Map?;
    final images = album?['images'] as List?;
    return images?.isNotEmpty == true ? images![0]['url'] : null;
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    if (widget.trackData != null && _tracks.isNotEmpty) {
      _currentTrackIndex = _tracks.indexWhere((track) => track['id'] == widget.trackData!['id']);
      if (_currentTrackIndex == -1) _currentTrackIndex = 0;
    }
    if (_previewUrl != null) {
      _playTrack();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playTrack() async {
    if (_previewUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No preview available for this track')),
      );
      return;
    }
    
    try {
      await _audioPlayer.play(UrlSource(_previewUrl!));
      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing track: $e')),
      );
    }
  }

  void _togglePlayPause() async {
    if (_previewUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No preview available for this track')),
      );
      return;
    }
    
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        await _audioPlayer.play(UrlSource(_previewUrl!));
        setState(() {
          _isPlaying = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing track: $e')),
      );
    }
  }

  void _skipPrevious() {
    if (_tracks.isEmpty) return;
    
    setState(() {
      _currentTrackIndex = (_currentTrackIndex - 1 + _tracks.length) % _tracks.length;
      _isPlaying = false;
    });
    
    _audioPlayer.stop();
    if (_previewUrl != null) {
      _playTrack();
    }
  }

  void _rewind() {
    print('Rewinding 10 seconds');
  }

  void _fastForward() {
    print('Fast-forwarding 10 seconds');
  }

  void _skipNext() {
    if (_tracks.isEmpty) return;
    
    setState(() {
      _currentTrackIndex = (_currentTrackIndex + 1) % _tracks.length;
      _isPlaying = false;
    });
    
    _audioPlayer.stop();
    if (_previewUrl != null) {
      _playTrack();
    }
  }

  // Helper to format duration for display
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- App Bar ---
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          onPressed: () {
            // Handle closing the player / navigating back
            Navigator.pop(context); 
          },
        ),
        title: const Text(
          'Player', // Title based on the screenshot, though it's partially cut off
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false, // Align title to the left
        backgroundColor: Colors.white, // Match the background
        elevation: 0, // No shadow
      ),

      // --- Body Content ---
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: <Widget>[
            // Flexible space to push content down slightly
            const Spacer(flex: 2),

            // Album Art
            Container(
              width: MediaQuery.of(context).size.width * 0.75,
              height: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _imageUrl != null
                    ? Image.network(
                        _imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.music_note,
                              size: 100,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.music_note,
                          size: 100,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),

            const Spacer(flex: 1),

            // Song Title and Artist
            Text(
              _songTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _artistName,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (_previewUrl == null)
              Text(
                'No preview available',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red[600],
                ),
                textAlign: TextAlign.center,
              ),

            const Spacer(flex: 1),

            // Progress Slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4.0,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.0),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 15.0),
                activeTrackColor: Colors.blue,
                inactiveTrackColor: Colors.blue.withOpacity(0.3),
                thumbColor: Colors.blue,
                overlayColor: Colors.blue.withOpacity(0.2),
              ),
              child: Slider(
                value: _currentSliderValue,
                min: 0.0,
                max: 1.0,
                onChanged: (double value) {
                  setState(() {
                    _currentSliderValue = value;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(_currentPosition),
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  Text(
                    _formatDuration(_totalDuration),
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Playback Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  iconSize: 36.0,
                  color: Colors.blue[400],
                  onPressed: _skipPrevious,
                ),
                IconButton(
                  icon: const Icon(Icons.fast_rewind),
                  iconSize: 36.0,
                  color: Colors.blue[400],
                  onPressed: _rewind,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    iconSize: 48.0,
                    onPressed: _togglePlayPause,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.fast_forward),
                  iconSize: 36.0,
                  color: Colors.blue[400],
                  onPressed: _fastForward,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  iconSize: 36.0,
                  color: Colors.blue[400],
                  onPressed: _skipNext,
                ),
              ],
            ),

            const Spacer(flex: 3), // Push bottom nav to the bottom
          ],
        ),
      ),

      // --- Bottom Navigation Bar ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // 'Music' is the active tab (index 2)
        type: BottomNavigationBarType.fixed, // Ensures all labels are visible
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
            icon: Icon(Icons.sentiment_satisfied_alt_outlined), // Changed to reflect "Emotions"
            activeIcon: Icon(Icons.sentiment_satisfied_alt),
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
                      'currentEmotion': widget.currentEmotion,
                      'recommendedPlaylists': widget.recommendedPlaylists,
                    },
                  ),
                ),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmotionsScreen(),
                  settings: RouteSettings(
                    arguments: {
                      'currentEmotion': widget.currentEmotion,
                      'recommendedPlaylists': widget.recommendedPlaylists,
                    },
                  ),
                ),
              );
              break;
            case 2:
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                  settings: RouteSettings(
                    arguments: {
                      'currentEmotion': widget.currentEmotion,
                      'recommendedPlaylists': widget.recommendedPlaylists,
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