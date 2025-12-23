import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'profile_screen.dart';
import 'side_menu.dart';
import 'workout_screen.dart';
import 'journeyai_screen.dart';
import '../providers/challenge_provider.dart';
import 'challenges_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum DayStatus { missed, rest, logged }

class DayLog {
  final int dayIndex; // sunday = 0, saturday = 6
  DayStatus status;
  DayLog({required this.dayIndex, this.status = DayStatus.missed});
}

class HomeContent extends StatefulWidget {
  final List<DayLog> dayLogs;
  final List<Challenge>? dailyChallenges;
  final void Function(int dayIndex, DayStatus newStatus) updateStatus;

  const HomeContent({
    super.key,
    required this.dayLogs,
    required this.updateStatus,
    this.dailyChallenges,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _isChallengesExpanded = false;

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

  String getDayOfTheWeek(int dayIndex){
    switch (dayIndex){
      case (1):
        return 'M';
      case (2):
        return 'T';
      case (3):
        return 'W';
      case (4):
        return 'T';
      case (5):
        return 'F';
      default:
        return 'S';
    }
  }

  Widget buildDayIcon(DayLog log) {
    final key = ValueKey(log.dayIndex); // Accessing widget properties
    final dayOfTheWeek = getDayOfTheWeek(log.dayIndex);
    final color = _getColorForStatus(log.status);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          Container(
            key: key,
            width: 16, // Adjusted for 7 days
            height: 16,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(height: 5),
          Text(dayOfTheWeek, style: TextStyle(color: Colors.white)),
        ],
      )
    );
  }

  Widget _buildHorizontalChallengeCard(Challenge challenge) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Challenges()),
      ),
      child: Card(
        color: challenge.color.withValues(alpha: 0.8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                challenge.description,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: challenge.progressPercentage,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        challenge.completed ? Colors.greenAccent : Colors.white,
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "${challenge.progress.toInt()}/${challenge.goal.toInt()}",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyChallengesSection(BuildContext context) {
    return Card(
      color: const Color(0xFF2C2C2C),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isChallengesExpanded = !_isChallengesExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's Challenges",
                    style: TextStyle(
                      color: Color(0xFFFBBF18),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    _isChallengesExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: const Color(0xFFFBBF18),
                  ),
                ],
              ),
            ),
            if (_isChallengesExpanded) ...[
              const SizedBox(height: 16),
              if (widget.dailyChallenges == null ||
                  widget.dailyChallenges!.isEmpty)
                const Text(
                  'No daily challenges available.',
                  style: TextStyle(color: Colors.white70),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: widget.dailyChallenges!
                      .map((c) => _buildHorizontalChallengeCard(c))
                      .toList(),
                ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            const Text(
              'Journey',
              style: TextStyle(
                fontFamily: 'OCR Extended A',
                fontSize: 40,
                color: Color(0xFFFBBF18),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                border: BoxBorder.all(color: const Color.fromARGB(255, 131, 131, 131)),
                borderRadius: BorderRadius.circular(12), // Add rounded corners
                color: const Color.fromARGB(255, 16, 16, 16)
              ),
              padding: const EdgeInsets.only(top: 16, bottom: 26, left: 0, right: 0),
              width: 460,
              child: Column(
                children: [
                   Text(
                    'Your Week',
                    style: GoogleFonts.inconsolata(fontSize: 22, color: Color(0xFFFBBF18)),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ...widget.dayLogs.map((log) => buildDayIcon(log)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Workout(),
                      ), // Placeholder
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: Color(0xFF1A1A1A),
                    shadowColor: Colors.redAccent,
                    surfaceTintColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                  ),
                  child: Text(
                    'Start a Workout',
                    style: GoogleFonts.mavenPro(fontSize: 18, color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => const Challenges(),
                    //   ), // Placeholder
                    // );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: Color(0xFF1A1A1A),
                    shadowColor: Colors.lightGreenAccent,
                    surfaceTintColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                  ),
                  child: Text(
                    'See Your Journey',
                    style: GoogleFonts.mavenPro(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
            _buildDailyChallengesSection(context),
          ],
        ),
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final AuthService _authService = AuthService();
  List<Challenge> _dailyChallenges = [];

  final List<DayLog> _dayLogs = List.generate(
    7,
    (index) => DayLog(dayIndex: index),
  );

  @override
  void initState() {
    super.initState();
    _fetchDailyChallenges();
  }

  Future<void> _fetchDailyChallenges() async {
    final token = await _authService.getToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse(ApiService.challenges()),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 && mounted) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> fetchedDataJson = jsonResponse['challenges'];
        final allChallenges = fetchedDataJson
            .map((json) => Challenge.fromJson(json))
            .toList();
        setState(() {
          _dailyChallenges = allChallenges
              .where((c) => c.type == 'Daily')
              .toList();
        });
      }
    } catch (e) {
      // Handle error silently for home screen
    }
  }

  // navigation bar destinations
  static final List<Widget> _navBarDestinations = <Widget>[
    NavigationDestination(
      icon: const Icon(Icons.home_outlined, color: Colors.white, size: 30),
      selectedIcon: const Icon(Icons.home, color: Colors.white, size: 30),
      label: 'Home',
    ),
    NavigationDestination(
      icon: SvgPicture.asset(
        'assets/images/updated_journey_logo.svg',
        width: 24,
        height: 24,
      ),
      label: 'Journey AI',
    ),
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
      HomeContent(
        dayLogs: _dayLogs,
        updateStatus: _updateDayStatus,
        dailyChallenges: _dailyChallenges,
      ),
      const JourneyAi(),
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
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
          Set<WidgetState> states,
        ) {
          // selected labels
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(fontSize: 12, color: Colors.white);
          }
          // unselected labels
          return const TextStyle(fontSize: 12, color: Colors.grey);
        }),
      ),
    );
  }
}
