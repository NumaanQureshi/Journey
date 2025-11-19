import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'side_menu.dart';
import 'journeyai_screen.dart';
// import '../widgets/video_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class HomeContent extends StatelessWidget
{
  const HomeContent({super.key});
  @override
  Widget build(BuildContext context) {

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Journey',
              style: TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;

  static const List<Widget> _screens = <Widget>[
    HomeContent(),
    JourneyAiScreen(),
  ];

  // navigation bar destinations
  static const List<Widget> _navBarDestinations = <Widget>[
    NavigationDestination(
      icon: Icon(Icons.home), 
      label: 'Home'),
    NavigationDestination(
      icon: ImageIcon(AssetImage("assets/images/journey_logo.png")), 
      label: 'Journey AI'),
  ];

  void _onDestinationSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideMenu(currentScreen: 'Home'),
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
        leading: Builder(
          builder: (context) => IconButton(
            color: Colors.blue,
            icon: const Icon(Icons.menu),
            tooltip: 'Menu',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
              color: Colors.amber,
              height: 4.0,
          )
        ),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outline),
            color: Colors.blue,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Profile()),
              );
            },
          ),
        ],
      ),
      // backgroundColor: const Color.fromARGB(255, 37, 37, 37),
      extendBodyBehindAppBar: true,
      body: _screens.elementAt(_selectedIndex),
      bottomNavigationBar: NavigationBar(
        destinations: _navBarDestinations,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}