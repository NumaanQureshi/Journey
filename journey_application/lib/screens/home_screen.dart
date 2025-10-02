import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Journey',
          style: TextStyle(
            fontFamily: 'OCR Extended A',
            fontSize: 40,
            color: Color(0xFFFBBF18),
          ),
        ),
        backgroundColor: Colors.black,
        // leading: IconButton(
        //   // onPressed: _openMenu
        //   icon: Icons.
        // ),
      ),
    );
  }
}