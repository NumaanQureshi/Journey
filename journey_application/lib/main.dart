import 'package:flutter/material.dart';
import 'package:journey_application/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Journey());
}

class Journey extends StatelessWidget {
  const Journey({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // theme: ThemeData(

      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
      // ),
      home: const LoginScreen(),
    );
  }
}