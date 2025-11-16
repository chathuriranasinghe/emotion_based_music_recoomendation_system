import 'package:flutter/material.dart';
import 'package:music_recommendation_system/Pages/ConnectDeviceScreen.dart';
import 'package:music_recommendation_system/services/user_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _ageController = TextEditingController();
  final UserService _userService = UserService();
  bool _isLoading = false;

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _userService.registerUser(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      username: _usernameController.text.trim(),
      age: int.parse(_ageController.text),
    );

    setState(() => _isLoading = false);

    if (result?['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ConnectDeviceScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result?['error'] ?? 'Unknown error'}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
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
                  'Profile Setup',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Create Your Profile',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Email is required';
                    if (!value!.contains('@')) return 'Enter valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Password is required';
                    if (value!.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Username is required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ageController,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Age is required';
                    final age = int.tryParse(value!);
                    if (age == null || age < 1 || age > 120) return 'Enter valid age';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Create Profile',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              const SizedBox(height: 16),
              const Text(
                'Or connect with',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontFamily: 'Roboto',
                  letterSpacing: 0.3,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B5998),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(109.8, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Facebook'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00ACEE),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(100, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Twitter'),
                  ),
                ],
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}