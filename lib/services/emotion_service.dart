import 'package:shared_preferences/shared_preferences.dart';

class EmotionService {
  static const String _emotionKey = 'current_emotion';
  static const String _playlistsKey = 'recommended_playlists';

  static Future<void> saveEmotion(String emotion) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emotionKey, emotion);
  }

  static Future<String?> getCurrentEmotion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emotionKey);
  }

  static Future<void> clearEmotion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emotionKey);
  }
}