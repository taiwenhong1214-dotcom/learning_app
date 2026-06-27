import 'package:flutter/material.dart';
import 'services/firebase_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;
  bool _isLogin = true; // Toggle between Login and Sign Up
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitEmailAuth() async {
    final username = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both username and password.')),
      );
      return;
    }

    if (!_isLogin && password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters long.')),
      );
      return;
    }

    if (!_isLogin && username.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username must be at least 3 characters long.')),
      );
      return;
    }

    // Firebase requires an email format, so we create a hidden dummy email using their username
    final fakeEmail = '$username@learnbmapp.local';

    setState(() => _isLoading = true);

    final user = _isLogin 
        ? await FirebaseService.signInWithEmail(fakeEmail, password)
        : await FirebaseService.signUpWithEmail(fakeEmail, password);

    if (mounted) {
      setState(() => _isLoading = false);
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isLogin 
                ? 'Login failed. Incorrect username or password.' 
                : 'Sign up failed. Username might already be taken.'),
          ),
        );
      }
    }
  }

  void _signInWithGoogle() async {
    setState(() => _isLoading = true);
    final user = await FirebaseService.signInWithGoogle();
    if (mounted) {
      setState(() => _isLoading = false);
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to sign in with Google.')),
        );
      }
    }
  }

  void _signInAsGuest() async {
    setState(() => _isLoading = true);
    final user = await FirebaseService.signInAnonymously();
    if (mounted) {
      setState(() => _isLoading = false);
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to sign in as guest.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D1117), Color(0xFF161B22)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo/Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5C6BC0), Color(0xFF3949AB)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5C6BC0).withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.language_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Learn BM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your personal Bahasa Malaysia AI Tutor',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF8B949E),
                    ),
                  ),
                  const SizedBox(height: 30),

                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(color: Color(0xFFFFD54F)),
                    )
                  else ...[
                    // Email/Password Form
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Username',
                        hintStyle: const TextStyle(color: Color(0xFF8B949E)),
                        prefixIcon: const Icon(Icons.person_rounded, color: Color(0xFF8B949E)),
                        filled: true,
                        fillColor: const Color(0xFF1C2333),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: const TextStyle(color: Color(0xFF8B949E)),
                        prefixIcon: const Icon(Icons.lock_rounded, color: Color(0xFF8B949E)),
                        filled: true,
                        fillColor: const Color(0xFF1C2333),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitEmailAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5C6BC0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        _isLogin ? 'Log In' : 'Sign Up',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(
                        _isLogin 
                            ? "Don't have an account? Sign Up" 
                            : "Already have an account? Log In",
                        style: const TextStyle(color: Color(0xFFFFD54F)),
                      ),
                    ),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(child: Divider(color: Color(0xFF30363D))),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('OR', style: TextStyle(color: Color(0xFF8B949E))),
                          ),
                          Expanded(child: Divider(color: Color(0xFF30363D))),
                        ],
                      ),
                    ),

                    ElevatedButton(
                      onPressed: _signInWithGoogle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.g_mobiledata_rounded, size: 32, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Continue with Google',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _signInAsGuest,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF30363D), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Continue as Guest',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
