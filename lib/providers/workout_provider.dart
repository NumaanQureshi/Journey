import 'package:flutter/material.dart';
import '../services/workout_service.dart';

class WorkoutProvider extends ChangeNotifier {
  List<Program> programs = [];
  List<Exercise> exercises = [];
  Program? activeProgram;
  bool isLoading = false;
  String? error;

  /// Load all programs for the user
  Future<void> loadPrograms() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      programs = await WorkoutService.getPrograms();
      // Set first program as active if available
      if (programs.isNotEmpty && activeProgram == null) {
        activeProgram = programs.first;
      }
    } catch (e) {
      error = e.toString();
      debugPrint('Error loading programs: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Load all available exercises
  Future<void> loadExercises() async {
    try {
      exercises = await WorkoutService.getExercises();
      notifyListeners();
    } catch (e) {
      error = e.toString();
      debugPrint('Error loading exercises: $e');
    }
  }

  /// Create a new program
  Future<Program?> createProgram({
    required String name,
    String? description,
    bool isActive = false,
  }) async {
    try {
      final program = await WorkoutService.createProgram(
        name: name,
        description: description,
        isActive: isActive,
      );
      programs.add(program);
      if (isActive) {
        activeProgram = program;
      }
      notifyListeners();
      return program;
    } catch (e) {
      error = e.toString();
      debugPrint('Error creating program: $e');
      return null;
    }
  }

  /// Set the active program
  void setActiveProgram(Program program) {
    activeProgram = program;
    notifyListeners();
  }

  /// Create a new template for the active program
  Future<WorkoutTemplate?> createTemplate({
    required String name,
    int? dayOrder,
    String? notes,
  }) async {
    if (activeProgram == null) {
      error = 'No active program selected';
      return null;
    }

    try {
      final template = await WorkoutService.createTemplate(
        programId: activeProgram!.id,
        name: name,
        dayOrder: dayOrder,
        notes: notes,
      );
      // Update the active program with new template
      await loadPrograms();
      return template;
    } catch (e) {
      error = e.toString();
      debugPrint('Error creating template: $e');
      return null;
    }
  }

  /// Add an exercise to a template
  Future<TemplateExercise?> addExerciseToTemplate({
    required int templateId,
    required int exerciseId,
    int targetSets = 3,
    String? targetReps,
    double? targetWeightLb,
    int restSeconds = 60,
  }) async {
    try {
      final templateExercise = await WorkoutService.addExerciseToTemplate(
        templateId: templateId,
        exerciseId: exerciseId,
        targetSets: targetSets,
        targetReps: targetReps,
        targetWeightLb: targetWeightLb,
        restSeconds: restSeconds,
      );
      // Reload programs to get updated data
      await loadPrograms();
      return templateExercise;
    } catch (e) {
      error = e.toString();
      debugPrint('Error adding exercise: $e');
      return null;
    }
  }

  /// Start a workout from a template
  Future<WorkoutSession?> startWorkout(int templateId) async {
    try {
      final session = await WorkoutService.startWorkout(templateId);
      notifyListeners();
      return session;
    } catch (e) {
      error = e.toString();
      debugPrint('Error starting workout: $e');
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    error = null;
    notifyListeners();
  }
}