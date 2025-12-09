import 'dart:async';
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
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
              'Session Timer',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 8),

            // Stopwatch Display
            Text(
              _elapsedTime,
              style: GoogleFonts.robotoMono(
                fontSize: 64,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            // Current Workout Title Card
            Card(
              color: const Color(0xFF2C2C2C),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                width: double.infinity,
                child: const Text( // TODO: Make this dynamic
                  'Current Workout: Barbell Bench Press',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Weight/Plates Toggle
            ToggleButtons(
              isSelected: [
                _selectedWeightType == WeightType.weight,
                _selectedWeightType == WeightType.plates
              ],
              onPressed: (index) {
                setState(() {
                  _selectedWeightType =
                      index == 0 ? WeightType.weight : WeightType.plates;
                });
              },
              color: Colors.white,
              selectedColor: Colors.white,
              fillColor: Colors.blue.withValues(alpha: 0.5),
              borderColor: Colors.blue,
              selectedBorderColor: Colors.blue,
              borderRadius: BorderRadius.circular(8),
              children: const [
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text('Weight')),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text('Plates')),
              ],
            ),
            const SizedBox(height: 20),

            // Conditional UI for Weight or Plates
            if (_selectedWeightType == WeightType.weight)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _weightController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 24, color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: '135',
                          hintStyle: TextStyle(color: Colors.white24),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white24)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ToggleButtons(
                      isSelected: [
                        _selectedWeightUnit == WeightUnit.lbs,
                        _selectedWeightUnit == WeightUnit.kgs
                      ],
                      onPressed: (index) {
                        setState(() {
                          _selectedWeightUnit =
                              index == 0 ? WeightUnit.lbs : WeightUnit.kgs;
                        });
                      },
                      color: Colors.white,
                      selectedColor: Colors.black,
                      fillColor: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      constraints: const BoxConstraints(minHeight: 36, minWidth: 50),
                      children: const [Text('lbs'), Text('kgs')],
                    ),
                  ],
                ),
              )
            else
              const Text('Plate calculator coming soon!', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),

            // Combined Timer and Rep Counter Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Smaller Workout Timer
                Column(
                  children: [
                    Text(
                      _exerciseElapsedTime,
                      style: GoogleFonts.robotoMono(
                        fontSize: 36,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _toggleExerciseTimer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isExerciseTimerRunning
                                ? Colors.orangeAccent
                                : const Color(0xFF2C2C2C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: Text(
                            _isExerciseTimerRunning ? 'Stop Timer' : 'Start Timer',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _resetExerciseTimer,
                          icon: const Icon(Icons.refresh, color: Colors.white70),
                        ),
                      ],
                    )
                  ],
                ),

                // Rep Counter
                Column(
                  children: [
                    const Text(
                      'Reps',
                      style: TextStyle(color: Colors.white70, fontSize: 24),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _repController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 42,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(color: Colors.white24),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),

            // Action Buttons 
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Next exercise functionality not implemented yet.')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Next Exercise'),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'End Session',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],  
        ),
      )),
    );
  }
}