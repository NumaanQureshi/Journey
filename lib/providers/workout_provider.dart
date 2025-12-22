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

  /// Load all available exercises with pagination
  Future<void> loadExercises() async {
    isLoading = true;
    error = null;
    notifyListeners();
    
    try {
      exercises = [];
      int offset = 0;
      const int batchSize = 500; 
      bool hasMore = true;

      while (hasMore) {
        debugPrint('DEBUG: Fetching batch at offset $offset');
        final batch = await WorkoutService.getExercises(
          limit: batchSize,
          offset: offset,
        );

        debugPrint('DEBUG: Got batch with ${batch.length} exercises');
        
        if (batch.isEmpty) {
          hasMore = false;
        } else {
          exercises.addAll(batch);
          offset += batchSize;
          // If we got fewer items than the batch size, we've reached the end
          if (batch.length < batchSize) {
            hasMore = false;
          }
          if (hasMore) {
            await Future.delayed(const Duration(milliseconds: 100));
          }
        }
      }

      debugPrint('Loaded ${exercises.length} exercises total');
      notifyListeners();
    } catch (e) {
      error = e.toString();
      debugPrint('Error loading exercises: $e');
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
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

  /// Set a program as active by ID (deactivates other programs)
  Future<bool> setActiveProgramById(int programId) async {
    try {
      // Find the program to activate
      final programToActivate = programs.firstWhere(
        (p) => p.id == programId,
        orElse: () => throw Exception('Program not found'),
      );

      // Deactivate all programs and activate the selected one
      for (int i = 0; i < programs.length; i++) {
        if (programs[i].id == programId) {
          // Activate this program
          final updatedProgram = await WorkoutService.updateProgram(
            programId: programId,
            name: programToActivate.name,
            description: programToActivate.description,
            isActive: true,
          );
          programs[i] = updatedProgram;
          activeProgram = updatedProgram;
        } else if (programs[i].isActive == true) {
          // Deactivate other programs
          final updatedProgram = await WorkoutService.updateProgram(
            programId: programs[i].id,
            name: programs[i].name,
            description: programs[i].description,
            isActive: false,
          );
          programs[i] = updatedProgram;
        }
      }
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      debugPrint('Error setting active program: $e');
      return false;
    }
  }

  /// Load templates for the active program
  Future<void> loadTemplatesForActiveProgram() async {
    if (activeProgram == null) {
      error = 'No active program selected';
      return;
    }

    try {
      final templates = await WorkoutService.getTemplatesForProgram(activeProgram!.id);
      // Update the active program with loaded templates
      activeProgram = Program(
        id: activeProgram!.id,
        userId: activeProgram!.userId,
        name: activeProgram!.name,
        description: activeProgram!.description,
        isActive: activeProgram!.isActive,
        createdAt: activeProgram!.createdAt,
        templates: templates,
      );
      notifyListeners();
    } catch (e) {
      error = e.toString();
      debugPrint('Error loading templates: $e');
    }
  }

  /// Delete a program
  Future<bool> deleteProgram(int programId) async {
    try {
      await WorkoutService.deleteProgram(programId: programId);
      programs.removeWhere((p) => p.id == programId);
      if (activeProgram?.id == programId) {
        activeProgram = null;
      }
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      debugPrint('Error deleting program: $e');
      return false;
    }
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
      // Load templates for the active program to refresh the UI
      await loadTemplatesForActiveProgram();
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
      await loadTemplatesForActiveProgram();
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
