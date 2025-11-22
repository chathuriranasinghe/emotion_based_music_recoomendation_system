import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:music_recommendation_system/Pages/EmotionsScreen.dart';
import 'package:music_recommendation_system/Pages/HomeScreen.dart';
import 'package:music_recommendation_system/Pages/ManualEEGInputScreen.dart';
import 'package:music_recommendation_system/services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }
  
  Future<void> _loadUserProfile() async {
    try {
      final user = _userService.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client
            .from('users')
            .select()
            .eq('id', user.id)
            .single();
        
        setState(() {
          _userProfile = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading profile: $e');
    }
  }
  
  Future<void> _handleLogout() async {
    await _userService.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final currentEmotion = args?['currentEmotion'];
    final recommendedPlaylists = args?['recommendedPlaylists'] as List<dynamic>? ?? [];
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
        title: Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        child: _userProfile == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            _userProfile?['username'] ?? _userService.currentUser?.email?.split('@')[0] ?? 'User',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            _userService.currentUser?.email ?? 'No email',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (_userProfile?['age'] != null)
                            Text(
                              'Age: ${_userProfile!['age']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
              SizedBox(height: 32),
              Text(
                'Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              ListTile(
                title: Text('Edit Profile'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                },
              ),
              ListTile(
                title: Text('Change Password'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                },
              ),
              SizedBox(height: 16),
              Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              ListTile(
                title: Text('Notifications'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                },
              ),
              SizedBox(height: 16),
              Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              ListTile(
                title: Text('Language'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                },
              ),
              ListTile(
                title: Text('Theme'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                },
              ),
              SizedBox(height: 16),
              Text(
                'History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              ListTile(
                title: Text('Listening History'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                ),
                leading: const Icon(Icons.logout, color: Colors.red),
                onTap: _handleLogout,
              ),
            ],
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
        currentIndex: 3,
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
              break;
          }
        },
      ),
    );
  }
}