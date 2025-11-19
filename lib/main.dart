import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const Journey(),
    ),
  );
}

class Journey extends StatelessWidget {
  const Journey({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Journey',
          themeMode: themeProvider.themeMode,
          // Define your light theme
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            // You can customize other properties like fonts, etc.
          ),
          // Define your dark theme
          darkTheme: ThemeData(brightness: Brightness.dark),
          home: const LoginScreen(),
        );
      },
    );
  }
}