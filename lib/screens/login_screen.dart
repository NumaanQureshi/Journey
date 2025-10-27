import 'package:flutter/material.dart';
import 'login.dart';
import 'sign_up.dart';

class LoginScreen extends StatelessWidget
{
  const LoginScreen({super.key});

  Route _createFadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  @override
    Widget build(BuildContext context) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: <Widget>[
            // Using Sized box for image since AppBar is not fit for putting logo.
            SizedBox.expand(
              child: Image.asset(
                'assets/images/login_bg.png', 
                fit: BoxFit.cover,
                ),
            ),

            // Journey Logo
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 70),
                  const Text(
                    'Journey',
                    style: TextStyle(
                      fontFamily: 'OCR Extended A',
                      fontSize: 64,
                      color: Color(0xFFFBBF18),
                    ),
                  ),
                ],
              ),
            ),

            // Log in Button
            Positioned(
              bottom: 200,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 200,
                  height: 60, 
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFBF6A02),
                      foregroundColor: Colors.white,
                    ),
                    // Log In Function
                    onPressed: () {
                      Navigator.push(context, _createFadeRoute(const Login()));
                    },
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        fontSize: 18,
                      )
                    ),
                  ),
                ),
              ),
            ),

            // Sign Up Button
            Positioned(
              bottom: 125,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox( // Button Size
                  width: 200,
                  height: 60, 
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF667DB5),
                      foregroundColor: Colors.white,
                    ),
                    // Sign Up Function
                    onPressed: () {
                      Navigator.push(context, _createFadeRoute(const SignUp()));
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 18,
                      )
                    ),
                  ),
                ),
              ),
            ),
          ], 
        ),
      );
    }
}