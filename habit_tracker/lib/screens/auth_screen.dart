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

  final Color bgColor = const Color(0xFF151515);
  final Color primaryColor = const Color(0xFFD4FF00);
  final Color secondaryColor = const Color(0xFFB4A6FF);
  final Color cardColor = const Color(0xFF2A2A2C);
  final Color mutedColor = const Color(0xFF3A3A3C);
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
      _showError('Please fill in email and password.');
      return;
    }

    if (!_isLogin && name.isEmpty) {
      _showError('Please enter your name.');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _showError('Please enter a valid email address.');
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

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

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

      // Do not navigate manually here.
      // main.dart is already listening to authStateChanges()
      // and will automatically switch to MainScreen.
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'weak-password':
          message = 'Password must be at least 6 characters.';
          break;
        case 'user-not-found':
        case 'invalid-credential':
        case 'wrong-password':
          message = 'Incorrect email or password.';
          break;
        case 'network-request-failed':
          message = 'Please check your internet connection.';
          break;
        default:
          message = e.message ?? 'Authentication failed.';
      }

      _showError(message);
    } catch (e) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFFF453A),
          content: Text(
            msg,
            style: GoogleFonts.nunitoSans(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _toggleMode() {
    if (_isLoading) return;

    setState(() {
      _isLogin = !_isLogin;
      _nameController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              Container(
                width: 240,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: secondaryColor.withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: -10,
                    ),
                  ],
                ),
                child: Image.network(
                  'https://ggrhecslgdflloszjkwl.supabase.co/storage/v1/object/public/user-assets/KW8OrAZwCO9/components/W6uccXGKDqb.png',
                ),
              ),
              const SizedBox(height: 40),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                  ),
                  children: [
                    const TextSpan(text: 'Level Up Your\n'),
                    TextSpan(
                      text: 'Daily Life',
                      style: TextStyle(
                        color: primaryColor,
                        shadows: [
                          Shadow(
                            color: primaryColor.withOpacity(0.5),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Track habits, complete chores, and maintain your streak.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: mutedTextColor,
                ),
              ),
              const SizedBox(height: 48),

              if (!_isLogin) ...[
                _buildInputLabel('NAME'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _nameController,
                  hintText: 'Your name',
                ),
                const SizedBox(height: 20),
              ],

              _buildInputLabel('EMAIL'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _emailController,
                hintText: 'hello@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              _buildInputLabel('PASSWORD'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _passwordController,
                hintText: '••••••••',
                obscureText: true,
              ),

              if (!_isLogin) ...[
                const SizedBox(height: 20),
                _buildInputLabel('CONFIRM PASSWORD'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _confirmPasswordController,
                  hintText: '••••••••',
                  obscureText: true,
                ),
              ],

              const SizedBox(height: 32),

              GestureDetector(
                onTap: _isLoading ? null : _submitAuthForm,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        offset: const Offset(0, 10),
                        blurRadius: 20,
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: bgColor,
                              strokeWidth: 3,
                            ),
                          )
                        : Text(
                            _isLogin ? 'Log In' : 'Sign Up',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: bgColor,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin
                        ? "Don't have an account? "
                        : "Already have an account? ",
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: mutedTextColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: _toggleMode,
                    child: Text(
                      _isLogin ? "Sign Up" : "Log In",
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Text(
          text,
          style: GoogleFonts.nunitoSans(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: mutedTextColor,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.nunitoSans(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: mutedTextColor.withOpacity(0.5)),
        filled: true,
        fillColor: cardColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: primaryColor.withOpacity(0.5),
            width: 2,
          ),
        ),
      ),
    );
  }
}