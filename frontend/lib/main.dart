import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'providers/user_provider.dart';
import 'providers/workout_provider.dart';

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
  @override
  void initState() {
    super.initState();
    // Initialize user data on app startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().initializeUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const LoginScreen();
  }
}