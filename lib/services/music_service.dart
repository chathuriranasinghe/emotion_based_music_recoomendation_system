class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  final List<Map<String, dynamic>> _recentlyPlayed = [];

  List<Map<String, dynamic>> get recentlyPlayed => List.unmodifiable(_recentlyPlayed);

  void addToRecentlyPlayed(Map<String, dynamic> track) {
    _recentlyPlayed.removeWhere((item) => item['id'] == track['id']);
    _recentlyPlayed.insert(0, track);
    if (_recentlyPlayed.length > 10) {
      _recentlyPlayed.removeLast();
    }
  }
}