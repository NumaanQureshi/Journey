import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'side_menu.dart';
import 'dart:core'; 
// import 'dart:async';

class Workout extends StatelessWidget {
  const Workout({super.key});

  // void _notImplemented(BuildContext context) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Not Implemented')),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideMenu(currentScreen: 'Workout'),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.blue),
        title: Text(
          'Workout',
          style: GoogleFonts.lexend(
            color: const Color(0xFFFBBF18),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/workout_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 20,
            bottom: 10,
            child: Center(
              child: Column(
                children: [
                  Text('Test 1'),
                  Text('Test 2'),
                  Text('Test 3'),
                ],
              )
            ) 
          )
        ],
      ),
    );
  }
}
//   Widget _buildCircularIconButton(BuildContext context, {required IconData icon, required String tooltip, required VoidCallback onPressed, required Color color}) {
//     return Container(
//       decoration: BoxDecoration(
//         color: color,
//         shape: BoxShape.circle,
//       ),
//       child: IconButton(
//         icon: Icon(icon),
//         iconSize: 48,
//         color: Colors.white,
//         onPressed: onPressed,
//         tooltip: tooltip,
//       ),
//     );
//   }
// }