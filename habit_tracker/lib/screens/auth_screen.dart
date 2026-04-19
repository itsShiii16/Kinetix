import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final Color bgColor = const Color(0xFF151515);
  final Color primaryColor = const Color(0xFFD4FF00);
  final Color secondaryColor = const Color(0xFFB4A6FF);
  final Color cardColor = const Color(0xFF2A2A2C);
  final Color mutedTextColor = const Color(0xFF8E8E93);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitAuthForm() async {
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please fill in both email and password.');
      return;
    }

    if (!_isLogin && name.isEmpty) {
      _showError('Please enter your name.');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _showError('Please enter a valid email.');
      return;
    }

    if (password.length < 6) {
      _showError('Password must be at least 6 characters.');
      return;
    }

    if (!_isLogin && password != confirmPassword) {
      _showError('Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // 🔥 CREATE FIRESTORE USER DOCUMENT
        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set({
          'name': name,
          'email': email,
          'notificationsEnabled': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Authentication error');
    } catch (e) {
      _showError('Unexpected error: $e');
    }

    setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF453A),
      ),
    );
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              Text(
                _isLogin ? "Welcome Back" : "Create Account",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              if (!_isLogin)
                _buildTextField(
                  controller: _nameController,
                  hintText: 'Name',
                ),

              _buildTextField(
                controller: _emailController,
                hintText: 'Email',
              ),

              _buildTextField(
                controller: _passwordController,
                hintText: 'Password',
                obscureText: true,
              ),

              if (!_isLogin)
                _buildTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _isLoading ? null : _submitAuthForm,
                child: Text(_isLogin ? "Login" : "Sign Up"),
              ),

              TextButton(
                onPressed: _toggleMode,
                child: Text(
                  _isLogin
                      ? "Create new account"
                      : "Already have an account?",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}