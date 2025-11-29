import 'package:flutter/material.dart';
import 'package:journey_application/screens/login.dart';
import 'personalization_screen.dart';
import '../authentication/authentication.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _page1FormKey = GlobalKey<FormState>();
  final _page2FormKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _currentPage = 0;
  bool _isPage1Valid = false;
  final AuthService _authService = AuthService();

  Route _createSlideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _usernameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Validate both forms before submitting
    final isPage2Valid = _page2FormKey.currentState?.validate() ?? false;

    if (_isPage1Valid && isPage2Valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Creating account...')),
      );

      final success = await _authService.signUp(
        _emailController.text,
        _passwordController.text,
        _usernameController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Please log in.')),
        );
        Navigator.pushReplacement(
          context,
          _createSlideRoute(const PersonalizationScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign up failed. Please try again.')),
        );
      }
    }
  }

  void _nextPage() {
    if (_currentPage == 0) {
      final isPage1Valid = _page1FormKey.currentState?.validate() ?? false;
      if (isPage1Valid) {
        setState(() => _isPage1Valid = true);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    } else if (_currentPage == 1) {
      if (_page2FormKey.currentState?.validate() ?? false) {
        _submit();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background image matches login screen style if available
          SizedBox.expand(
            child: Image.asset(
              'assets/images/blur_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (page) => setState(() => _currentPage = page),
            children: [
              _buildPage1(),
              _buildPage2(),
            ],
          ),
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667DB5),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    _currentPage == 0 ? 'Next' : 'Create Account',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    _createSlideRoute(const Login()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBF6A02),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Already have an Account?', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(GlobalKey<FormState> formKey, List<Widget> children) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
        child: Card(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage1() {
    return _buildPage(_page1FormKey, [
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.90),
          labelText: 'Email',
          prefixIcon: const Icon(Icons.email),
          floatingLabelStyle: const TextStyle(color: Colors.black54),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Enter your email';
          if (!value.contains('@') || !value.contains('.')) return 'Enter a valid email';
          return null;
        },
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.90),
          labelText: 'Password',
          prefixIcon: const Icon(Icons.lock),
          floatingLabelStyle: const TextStyle(color: Colors.black54),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Enter a password';
          if (value.length < 8) return 'Password must be at least 8 characters';
          return null;
        },
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _confirmController,
        obscureText: _obscureConfirmPassword,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.90),
          labelText: 'Confirm Password',
          prefixIcon: const Icon(Icons.lock_outline),
          floatingLabelStyle: const TextStyle(color: Colors.black54),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          suffixIcon: IconButton(
            icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Confirm your password';
          if (value != _passwordController.text) return 'Passwords do not match';
          return null;
        },
      ),
    ]);
  }

  Widget _buildPage2() {
    return _buildPage(_page2FormKey, [
      TextFormField(
        controller: _usernameController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.90),
          labelText: 'Username',
          prefixIcon: const Icon(Icons.person),
          floatingLabelStyle: const TextStyle(color: Colors.black54),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter a username';
          }
          if (value.length < 3) {
            return 'Username must be at least 3 characters';
          }
          // Alphanumeric check
          if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
            return 'Username can only contain letters and numbers';
          }
          return null;
        },
      ),
    ]);
  }
}