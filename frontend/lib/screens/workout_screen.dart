import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'side_menu.dart';
import 'workout_plans.dart';
import 'dart:core';
import 'dart:math' as math;
import 'workout_logs.dart';
import 'workout_session.dart';
import '../services/ai_service.dart';
import '../providers/workout_provider.dart';
import '../services/workout_service.dart';

class _RingProgressPainter extends CustomPainter {
  final double progress;

  _RingProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Draw the progress arc from -90 degrees (top) for a full 360 degree sweep
    final sweepAngle = progress * 2 * math.pi;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start at top
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class Workout extends StatefulWidget {
  const Workout({super.key});

  @override
  State<Workout> createState() => _WorkoutState();
}

class WorkoutContent extends StatefulWidget {
  const WorkoutContent({super.key});

  @override
  State<WorkoutContent> createState() => _WorkoutContentState();
}

class _WorkoutContentState extends State<WorkoutContent>
    with TickerProviderStateMixin {
  late AnimationController _ringController;
  late Animation<double> _ringAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isHolding = false;
  
  final AiService _aiService = AiService();
  String _motivationalMessage = 'Ready to crush it? 💪';
  WorkoutTemplate? _nextTemplate;
  bool _isLoadingTemplate = true;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _ringAnimation = Tween<double>(begin: 0, end: 1).animate(_ringController);
    
    // Fade animation for the message
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    
    // Fetch motivational message and next template asynchronously
    _fetchMotivationalMessage();
    _loadNextTemplate();
  }

  Future<void> _loadNextTemplate() async {
    try {
      final provider = context.read<WorkoutProvider>();
      final nextTemplate = await provider.getNextTemplate();
      
      if (mounted) {
        setState(() {
          _nextTemplate = nextTemplate;
          _isLoadingTemplate = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTemplate = false;
        });
        debugPrint('Error loading next template: $e');
      }
    }
  }

  Future<void> _fetchMotivationalMessage() async {
    try {
      final message = await _aiService.sendMessage(
        'Give me a single sentence motivational quote to encourage someone to have a great workout today. '
        'Just the quote, no additional text or punctuation.',
      );
      
      if (mounted) {
        setState(() {
          _motivationalMessage = message;
        });
        // Trigger fade-in animation
        _fadeController.forward();
      }
    } catch (e) {
      if (mounted) {
        // Keep default message and fade it in anyway
        _fadeController.forward();
      }
    }
  }

  @override
  void dispose() {
    _ringController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onPointerDown() {
    if (!_isHolding && _nextTemplate != null) {
      _isHolding = true;
      _ringController.forward();
    }
  }

  void _onPointerUp() {
    if (_isHolding) {
      _isHolding = false;
      
      // Check if the animation completed (user held for full 2 seconds)
      if (_ringAnimation.value >= 1.0 && _nextTemplate != null) {
        // Navigate to workout session with the next template
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutSessionScreen(templateId: _nextTemplate!.id),
          ),
        );
      }
      
      _ringController.reverse();
    }
  }

  void _startWorkoutManually() {
    if (_nextTemplate != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutSessionScreen(templateId: _nextTemplate!.id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            // AI Suggestion Card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Card(
                color: const Color(0xFF2C2C2C),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/images/updated_journey_logo.svg',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Text(
                                _motivationalMessage,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Active Program and Template Info
            if (provider.activeProgram != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: const Color(0xFF2C2C2C),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.fitness_center, color: Colors.orangeAccent),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Active Program',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    provider.activeProgram!.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Today's Workout",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_isLoadingTemplate)
                                const SizedBox(
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.orangeAccent,
                                    strokeWidth: 2,
                                  ),
                                )
                              else if (_nextTemplate != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _nextTemplate!.name,
                                      style: const TextStyle(
                                        color: Colors.orangeAccent,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_nextTemplate!.exercises.length} exercises',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                const Text(
                                  'No templates available',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Start Session Button
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: AnimatedBuilder(
                    animation: _ringAnimation,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Animated progress ring
                          if (_ringAnimation.value > 0)
                            CustomPaint(
                              size: const Size(200, 200),
                              painter: _RingProgressPainter(
                                progress: _ringAnimation.value,
                              ),
                            ),
                          // Button with fixed size
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: Listener(
                              onPointerDown: (_) => _onPointerDown(),
                              onPointerUp: (_) => _onPointerUp(),
                              onPointerCancel: (_) => _onPointerUp(),
                              child: ElevatedButton(
                                onPressed: _isLoadingTemplate || _nextTemplate == null
                                    ? null
                                    : _startWorkoutManually,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 24, 24, 24),
                                  shadowColor: Colors.red,
                                  surfaceTintColor: const Color.fromARGB(255, 37, 12, 10),
                                  elevation: 15,
                                  shape: const CircleBorder(),
                                  side: const BorderSide(color: Colors.orange, width: 2),
                                  disabledBackgroundColor: const Color.fromARGB(255, 24, 24, 24),
                                ),
                                child: Text(
                                  _isLoadingTemplate ? 'Loading...' : 'Start Session',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.mavenPro(
                                    color: _nextTemplate == null ? Colors.white30 : Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WorkoutState extends State<Workout> {
  int _selectedIndex = 1;

  int _streakLevel = 0; // 0: none, 1: small, 2: medium, 3: high
  final List<Color> _streakColors = [
    Colors.grey.shade700,
    Colors.orangeAccent,
    Colors.orange,
    Colors.red,
  ];

  static const List<Widget> _workoutNavBarDestinations = <Widget>[
    NavigationDestination(
      icon: Icon(Icons.bookmark_border, color: Colors.amber),
      selectedIcon: Icon(Icons.bookmark, color: Colors.amber),
      label: 'Plans',
    ),
    NavigationDestination(
      icon: Icon(Icons.fitness_center, color: Colors.red, size: 36),
      label: '',
    ),
    NavigationDestination(
      selectedIcon: Icon(Icons.calendar_month, color: Colors.blue),
      icon: Icon(Icons.calendar_today, color: Colors.blue),
      label: 'Logs',
    ),
  ];


  void _onDestinationSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      const WorkoutPlans(),
      const WorkoutContent(),
      const WorkoutLogs(),
    ];
    return Scaffold(
      drawer: const SideMenu(currentScreen: 'Workout'),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        iconTheme: const IconThemeData(color: Colors.blue),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              tooltip: 'Workout Streak',
              icon: Icon(
                Icons.local_fire_department,
                color: _streakColors[_streakLevel],
                size: 28,
              ),
              onPressed: () {
                setState(() {
                  _streakLevel = (_streakLevel + 1) % _streakColors.length;
                });
              },
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1A1A1A),
      body: screens.elementAt(_selectedIndex),
      bottomNavigationBar: NavigationBar(
        destinations: _workoutNavBarDestinations,
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
