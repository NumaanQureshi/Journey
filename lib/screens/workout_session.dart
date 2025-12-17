import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum WeightType { weight, plates }
enum WeightUnit { lbs, kgs }

class WorkoutSession extends StatefulWidget {
  const WorkoutSession({super.key});

  @override
  State<WorkoutSession> createState() => _WorkoutSessionState();
}

class _WorkoutSessionState extends State<WorkoutSession> {
  final Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;
  String _elapsedTime = '00:00:00';

  // State for the smaller, controllable workout timer
  final Stopwatch _exerciseStopwatch = Stopwatch();
  Timer? _exerciseTimer;
  String _exerciseElapsedTime = '00:00:00';
  bool _isExerciseTimerRunning = false;

  final TextEditingController _repController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  WeightType _selectedWeightType = WeightType.weight;
  WeightUnit _selectedWeightUnit = WeightUnit.lbs;

  @override
  void initState() {
    super.initState();
    _startStopwatch();
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    _exerciseTimer?.cancel();
    _exerciseStopwatch.stop();
    _repController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _startStopwatch() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_stopwatch.isRunning) {
        setState(() {
          _elapsedTime = _formatTime(_stopwatch.elapsed);
        });
      }
    });
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  void _toggleExerciseTimer() {
    setState(() {
      if (_isExerciseTimerRunning) {
        _exerciseStopwatch.stop();
        _exerciseTimer?.cancel();
      } else {
        _exerciseStopwatch.start();
        _exerciseTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
          if (_exerciseStopwatch.isRunning) {
            setState(() {
              _exerciseElapsedTime = _formatTime(_exerciseStopwatch.elapsed);
            });
          }
        });
      }
      _isExerciseTimerRunning = !_isExerciseTimerRunning;
    });
  }

  void _resetExerciseTimer() {
    setState(() {
      _exerciseStopwatch.stop();
      _exerciseStopwatch.reset();
      _exerciseTimer?.cancel();
      _exerciseElapsedTime = '00:00:00';
      _isExerciseTimerRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Column(
          children: [
            // Top Action Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48), // Placeholder for alignment
                  IconButton(
                    onPressed: () => _showEndSessionDialog(context),
                    icon: const Icon(
                      CupertinoIcons.stop_circle_fill,
                      color: Colors.redAccent,
                      size: 28,
                    ),
                    tooltip: 'End Session',
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: Column(
                    children: [
                      // Session Timer Section
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade900.withValues(alpha: 0.3),
                              Colors.blue.shade700.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              'Total Session Time',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _elapsedTime,
                              style: GoogleFonts.robotoMono(
                                fontSize: 56,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Current Exercise Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: const Column(
                          children: [
                            Text(
                              'Current Exercise',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.8,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Barbell Bench Press',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Weight/Plates Selector
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Row(
                          children: [
                            _buildSegmentButton(
                              'Weight',
                              _selectedWeightType == WeightType.weight,
                              () {
                                setState(() {
                                  _selectedWeightType = WeightType.weight;
                                });
                              },
                            ),
                            _buildSegmentButton(
                              'Plates',
                              _selectedWeightType == WeightType.plates,
                              () {
                                setState(() {
                                  _selectedWeightType = WeightType.plates;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Weight Input Section
                      if (_selectedWeightType == WeightType.weight)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  controller: _weightController,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '135',
                                    hintStyle: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.2),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.blue.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildUnitButton(
                                      'lbs',
                                      _selectedWeightUnit == WeightUnit.lbs,
                                      () {
                                        setState(() {
                                          _selectedWeightUnit = WeightUnit.lbs;
                                        });
                                      },
                                    ),
                                    _buildUnitButton(
                                      'kgs',
                                      _selectedWeightUnit == WeightUnit.kgs,
                                      () {
                                        setState(() {
                                          _selectedWeightUnit = WeightUnit.kgs;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: const Text(
                            'Plate calculator coming soon!',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      const SizedBox(height: 28),

                      // Exercise Timer & Rep Counter
                      Row(
                        children: [
                          Expanded(
                            child: _buildExerciseCard(
                              title: 'Set Timer',
                              child: Column(
                                children: [
                                  Text(
                                    _exerciseElapsedTime,
                                    style: GoogleFonts.robotoMono(
                                      fontSize: 32,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FilledButton.tonal(
                                        onPressed: _toggleExerciseTimer,
                                        style: FilledButton.styleFrom(
                                          backgroundColor: _isExerciseTimerRunning
                                              ? Colors.orange.withValues(alpha: 0.2)
                                              : Colors.blue.withValues(alpha: 0.1),
                                          foregroundColor: _isExerciseTimerRunning
                                              ? Colors.orange
                                              : Colors.blue,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                        ),
                                        child: Text(
                                          _isExerciseTimerRunning
                                              ? 'Stop'
                                              : 'Start',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: _resetExerciseTimer,
                                        icon: const Icon(
                                          Icons.refresh_rounded,
                                          color: Colors.white54,
                                          size: 20,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 36,
                                          minHeight: 36,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildExerciseCard(
                              title: 'Reps',
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 70,
                                    child: TextField(
                                      controller: _repController,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(
                                        fontSize: 36,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '0',
                                        hintStyle: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          fontSize: 36,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(
                                          vertical: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade500.withValues(alpha: 0.8),
                        Colors.blue.shade700.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Next exercise functionality not implemented yet.',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'Next Exercise',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentButton(
    String label,
    bool isSelected,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blue.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? Colors.blue.withValues(alpha: 0.4)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.white60,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnitButton(
    String label,
    bool isSelected,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: isSelected
              ? BorderRadius.circular(9)
              : BorderRadius.zero,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.white60,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  void _showEndSessionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          title: const Text(
            'End Session',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to end this workout session?\nTotal time: $_elapsedTime',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Go Back',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back
              },
              child: const Text(
                'End Session',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
