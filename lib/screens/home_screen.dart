import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'profile_screen.dart';
import 'side_menu.dart';
import 'journeyai_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum DayStatus {missed, rest, logged}

class DayLog {
  final int dayIndex; // sunday = 0, saturday = 6
  DayStatus status;
  DayLog({required this.dayIndex, this.status = DayStatus.missed});
}

class HomeContent extends StatelessWidget
{
  final List<DayLog> dayLogs;  
  final void Function(int dayIndex, DayStatus newStatus) updateStatus;

  const HomeContent({super.key, required this.dayLogs, required this.updateStatus});
  
  Color _getColorForStatus(DayStatus status) {
  switch (status) {
    case DayStatus.logged:
      return const Color(0xFF6CDC00); 
    case DayStatus.rest:
      return const Color(0xFF7ED5EA); 
    default:
      return const Color(0xFFD4D4D4); 
  }
}

  Widget buildDayIcon(DayLog log) {
  final key = ValueKey(log.dayIndex);
  final color = _getColorForStatus(log.status);
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4.0),
    child: Container(
      key: key, 
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    ),
  );
}

  // void _updateDayIcon(ValueKey key){
    
  // }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Journey',
              style: TextStyle(
                fontFamily: 'OCR Extended A',
                fontSize: 40,
                color: Color(0xFFFBBF18),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ...dayLogs.map((log) => buildDayIcon(log)).toList(),
              ],
            ),
            SizedBox(height: 500)
          ],
        ),
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<DayLog> _dayLogs = List.generate(7, (index) => DayLog(dayIndex: index));

  // navigation bar destinations
  static final List<Widget> _navBarDestinations = <Widget>[
    NavigationDestination(
      icon: const Icon(
        Icons.home_outlined,
        color: Colors.white,
        size: 30,
      ),
      selectedIcon: const Icon(
        Icons.home,
        color: Colors.white,
        size: 30,
      ), 
      label: 'Home'),
    NavigationDestination(
      icon: SvgPicture.asset(
        'assets/images/updated_journey_logo.svg',
        width: 24,
        height: 24,
      ),
      label: 'Journey AI'),
  ];

  void _updateDayStatus(int dayIndex, DayStatus newStatus) {
    setState(() {
      _dayLogs[dayIndex].status = newStatus;
    });
  }

  void _onDestinationSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      HomeContent(dayLogs: _dayLogs, updateStatus: _updateDayStatus),
      const JourneyAiScreen(),
    ];

    return Scaffold(
      drawer: const SideMenu(currentScreen: 'Home'),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A1A),
        leading: Builder(
          builder: (context) => IconButton(
            color: Colors.blue,
            icon: const Icon(Icons.menu),
            tooltip: 'Menu',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
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
      backgroundColor: const Color(0xFF1A1A1A),
      extendBodyBehindAppBar: true,
      body: screens.elementAt(_selectedIndex),
      bottomNavigationBar: NavigationBar(
        destinations: _navBarDestinations,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        backgroundColor: Color(0xFF2C2C2C),
        indicatorColor: Colors.black,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((Set<WidgetState> states) {
          // selected labels
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              color: Colors.white,
            );
          }
          // unselected labels
          return const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          );
        }),
      ),
    );
  }
}