import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:music_recommendation_system/Pages/ConnectDeviceScreen.dart';
import 'package:music_recommendation_system/services/user_service.dart';
import 'package:url_launcher/url_launcher.dart'; 

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); 
  
  final UserService _userService = UserService();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final Color _primaryColor = const Color(0xFF4285F4); // Consistent blue color
  final Color _textFieldFillColor = const Color(0xFFF7F8F9); // Light gray fill

  // --- Supabase Registration Logic (Modified for new fields) ---
  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Check if passwords match before calling the service
    if (_passwordController.text != _confirmPasswordController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Passwords do not match')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    // Call registerUser with only the required fields (email, password)
    final result = await _userService.registerUser(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      username: _emailController.text.split('@')[0],
      age: 25,
    );

    setState(() => _isLoading = false);

    if (result?['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result?['message'] ?? 'Registration successful! Please check your email.')),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result?['error'] ?? 'Unknown error'}')),
        );
      }
    }
  }

  // --- Disposal ---
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- UI Builder Functions ---

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = false,
    required ValueChanged<bool> toggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !isVisible,
          keyboardType: isPassword ? TextInputType.visiblePassword : TextInputType.emailAddress,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
            contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
            filled: true,
            fillColor: _textFieldFillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _primaryColor, width: 2),
            ),
            suffixIcon: isPassword 
                ? IconButton(
                    icon: Icon(
                      isVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey[600],
                    ),
                    onPressed: () => toggleVisibility(!isVisible),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Back Button (retained from old code structure)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Logo and Title ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo.png', 
                      height: 40.0,
                      width: 40.0,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.music_note, color: Colors.blueAccent, size: 40),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'MusicMind',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Create Your MusicMind Profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),

                // --- Google Sign Up Button ---
                OutlinedButton.icon(
                  onPressed: () {
                    print('Sign up with Google clicked');
                    // Implement Google Sign-In logic
                  },
                  icon: Image.asset(
                    'assets/google.png', // Replace with a real asset path
                    height: 24.0, 
                    width: 24.0,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, color: Colors.red, size: 24),
                  ),
                  label: const Text(
                    'Sign up with Google',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // --- OR Divider ---
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'OR',
                        style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 20),

                // --- Email Field ---
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hintText: 'your.email@example.com',
                  icon: Icons.email_outlined,
                  isPassword: false,
                  isVisible: false,
                  toggleVisibility: (val) {}, // Not used for email
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Email is required';
                    if (!value!.contains('@')) return 'Enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // --- Password Field ---
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hintText: '8+ characters, 1 number',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  isVisible: _isPasswordVisible,
                  toggleVisibility: (val) => setState(() => _isPasswordVisible = val),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Password is required';
                    if (value!.length < 8) return 'Password must be at least 8 characters';
                    if (!value.contains(RegExp(r'[0-9]'))) return 'Must contain at least 1 number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // --- Confirm Password Field ---
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  isVisible: _isConfirmPasswordVisible,
                  toggleVisibility: (val) => setState(() => _isConfirmPasswordVisible = val),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Confirmation is required';
                    if (value != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // --- Sign Up Button ---
                ElevatedButton(
                  onPressed: _isLoading ? null : _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 20),

                // --- Terms and Policy Text ---
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'By creating an account, you agree to our ',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w600),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              // Open a placeholder URL for Terms
                              final url = Uri.parse('https://example.com/terms');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              }
                            },
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w600),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              // Open a placeholder URL for Privacy
                              final url = Uri.parse('https://example.com/privacy');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              }
                            },
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // --- Already have an account? Sign In ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?", style: TextStyle(color: Colors.grey[700])),
                    TextButton(
                      onPressed: () {
                        // Implement navigation back to the Login Screen
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Sign In',
                        style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w600),
                      ),
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
