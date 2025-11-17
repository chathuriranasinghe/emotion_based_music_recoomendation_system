import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> registerUser({
    required String email,
    required String password,
    required String username,
    required int age,
  }) async {
    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: null,
      );

      if (response.user != null) {
        return {
          'success': true, 
          'user': response.user,
          'message': 'Please check your email to confirm your account before logging in.'
        };
      }
      return {'success': false, 'error': 'Registration failed'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null && response.session != null) {
        return {'success': true, 'user': response.user};
      }
      return {'success': false, 'error': 'Invalid credentials'};
    } catch (e) {
      if (e.toString().contains('email_not_confirmed')) {
        return {'success': false, 'error': 'Please confirm your email before logging in. Check your inbox.'};
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;
  
  bool get isLoggedIn => _supabase.auth.currentUser != null;
}