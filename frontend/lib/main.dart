import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'providers/user_provider.dart';
import 'providers/workout_provider.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Journey());
}

class Journey extends StatelessWidget {
  const Journey({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => WorkoutProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        home: const _AppInitializer(),
      ),
    );
  }
}

/// Initializes user data before showing the home screen
class _AppInitializer extends StatefulWidget {
  const _AppInitializer();

  @override
  State<_AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<_AppInitializer> {
  late Future<Widget> _futureInitialization;

  @override
  void initState() {
    super.initState();
    _futureInitialization = _initializeApp();
  }

  /// Check if user is already logged in and load their data
  Future<Widget> _initializeApp() async {
    try {
      final authService = AuthService();
      
      // Check if a valid token exists
      final isTokenValid = await authService.isTokenValid();
      
      if (isTokenValid) {
        // Token is valid - initialize user data and start loading exercises
        if (mounted) {
          await context.read<UserProvider>().initializeUser();
          // Start loading exercises in the background (no await - let it load while navigating)
          context.read<WorkoutProvider>().loadExercises();
        }
        return const HomeScreen();
      } else {
        // No valid token - show login screen
        return const LoginScreen();
      }
    } catch (e) {
      debugPrint('Error during app initialization: $e');
      // On error, show login screen
      return const LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _futureInitialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading screen while checking authentication
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          // On error, show login screen
          return const LoginScreen();
        } else if (snapshot.hasData) {
          return snapshot.data!;
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}