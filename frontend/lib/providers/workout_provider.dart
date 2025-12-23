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
      
      // Load templates for each program
      for (int i = 0; i < programs.length; i++) {
        try {
          final templates = await WorkoutService.getTemplatesForProgram(programs[i].id);
          programs[i] = Program(
            id: programs[i].id,
            userId: programs[i].userId,
            name: programs[i].name,
            description: programs[i].description,
            isActive: programs[i].isActive,
            createdAt: programs[i].createdAt,
            templates: templates,
          );
          debugPrint('DEBUG: Loaded ${templates.length} templates for program "${programs[i].name}"');
        } catch (e) {
          debugPrint('DEBUG: Error loading templates for program ${programs[i].id}: $e');
          // Continue with empty templates list
        }
      }
      
      // Find the currently active program from backend
      if (programs.isNotEmpty) {
        final activeProgramFromBackend = programs.firstWhere(
          (p) => p.isActive == true,
          orElse: () => programs.first,
        );
        activeProgram = activeProgramFromBackend;
        debugPrint('DEBUG: Set active program to "${activeProgram?.name}" (id: ${activeProgram?.id}, templates: ${activeProgram?.templates.length})');
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
    // Skip if already loaded
    if (exercises.isNotEmpty) {
      debugPrint('DEBUG: Exercises already loaded (${exercises.length} total), skipping reload');
      return;
    }

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

      debugPrint('DEBUG: Setting program $programId as active');

      // Deactivate all other active programs first
      for (int i = 0; i < programs.length; i++) {
        if (programs[i].isActive == true && programs[i].id != programId) {
          debugPrint('DEBUG: Deactivating program ${programs[i].id}');
          try {
            await WorkoutService.updateProgram(
              programId: programs[i].id,
              name: programs[i].name,
              description: programs[i].description,
              isActive: false,
            );
            programs[i] = programs[i].copyWith(isActive: false);
            debugPrint('DEBUG: Successfully deactivated program ${programs[i].id}');
          } catch (e) {
            debugPrint('DEBUG: Warning - Error deactivating program ${programs[i].id}: $e');
            // Continue anyway, the main activation is more important
          }
        }
      }

      // Then activate the selected program
      debugPrint('DEBUG: Activating program $programId');
      final updatedProgram = await WorkoutService.updateProgram(
        programId: programId,
        name: programToActivate.name,
        description: programToActivate.description,
        isActive: true,
      );

      // Reload templates for the updated program
      try {
        final templates = await WorkoutService.getTemplatesForProgram(programId);
        debugPrint('DEBUG: Reloaded ${templates.length} templates for active program');
        final programWithTemplates = Program(
          id: updatedProgram.id,
          userId: updatedProgram.userId,
          name: updatedProgram.name,
          description: updatedProgram.description,
          isActive: updatedProgram.isActive,
          createdAt: updatedProgram.createdAt,
          templates: templates,
        );
        activeProgram = programWithTemplates;
      } catch (e) {
        debugPrint('DEBUG: Error reloading templates: $e, using program without templates');
        activeProgram = updatedProgram;
      }

      // Update locally
      final index = programs.indexWhere((p) => p.id == programId);
      if (index != -1) {
        programs[index] = activeProgram!;
      }
      
      debugPrint('DEBUG: Successfully set program $programId as active');
      error = null;
      notifyListeners();
      return true;
    } catch (e) {
      error = 'Failed to set program as active: $e';
      debugPrint('ERROR: $error');
      notifyListeners();
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

  /// Update a single template's day order
  Future<bool> updateTemplateOrder({
    required int templateId,
    required int dayOrder,
  }) async {
    if (activeProgram == null) {
      error = 'No active program selected';
      return false;
    }

    try {
      final updatedTemplate = await WorkoutService.updateTemplateOrder(
        templateId: templateId,
        dayOrder: dayOrder,
      );
      
      // Update the template in the active program
      final templateIndex = activeProgram!.templates.indexWhere((t) => t.id == templateId);
      if (templateIndex != -1) {
        final updatedTemplates = List<WorkoutTemplate>.from(activeProgram!.templates);
        updatedTemplates[templateIndex] = updatedTemplate;
        activeProgram = Program(
          id: activeProgram!.id,
          userId: activeProgram!.userId,
          name: activeProgram!.name,
          description: activeProgram!.description,
          isActive: activeProgram!.isActive,
          createdAt: activeProgram!.createdAt,
          templates: updatedTemplates,
        );
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      debugPrint('Error updating template order: $e');
      return false;
    }
  }

  /// Update multiple templates' day order in bulk
  Future<bool> updateTemplatesOrder({
    required List<WorkoutTemplate> orderedTemplates,
  }) async {
    if (activeProgram == null) {
      error = 'No active program selected';
      return false;
    }

    try {
      debugPrint('DEBUG: Updating order for ${orderedTemplates.length} templates');
      
      // Update each template with its new day_order
      final updatedTemplates = <WorkoutTemplate>[];
      for (int i = 0; i < orderedTemplates.length; i++) {
        final template = orderedTemplates[i];
        final newDayOrder = i + 1;
        
        debugPrint('DEBUG: Updating template ${template.id} to day_order $newDayOrder');
        
        try {
          final updatedTemplate = await WorkoutService.updateTemplate(
            templateId: template.id,
            name: template.name,
            notes: template.notes,
            dayOrder: newDayOrder,
          );
          updatedTemplates.add(updatedTemplate);
          debugPrint('DEBUG: Successfully updated template ${template.id}');
        } catch (e) {
          debugPrint('ERROR: Failed to update template ${template.id}: $e');
          throw Exception('Failed to update template ${template.name}: $e');
        }
      }
      
      // Update the active program with the new order
      activeProgram = Program(
        id: activeProgram!.id,
        userId: activeProgram!.userId,
        name: activeProgram!.name,
        description: activeProgram!.description,
        isActive: activeProgram!.isActive,
        createdAt: activeProgram!.createdAt,
        templates: updatedTemplates,
      );
      
      debugPrint('DEBUG: Successfully updated all template orders');
      error = null;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      debugPrint('Error updating templates order: $e');
      return false;
    }
  }

  /// Get the next template to follow based on completion history
  /// If no templates have been completed, returns the first template (day_order 1)
  /// Otherwise returns the next template after the last completed one
  Future<WorkoutTemplate?> getNextTemplate() async {
    if (activeProgram == null || activeProgram!.templates.isEmpty) {
      return null;
    }

    try {
      // Get all sessions for the user to find the last completed one
      final sessions = await WorkoutService.getWorkoutSessions();
      
      // Find the most recent completed session
      WorkoutSession? lastCompletedSession;
      for (final session in sessions) {
        if (session.status == 'completed') {
          if (lastCompletedSession == null ||
              session.endTime!.isAfter(lastCompletedSession.endTime!)) {
            lastCompletedSession = session;
          }
        }
      }

      // If no completed sessions, return the first template
      if (lastCompletedSession == null) {
        return activeProgram!.templates.isEmpty
            ? null
            : activeProgram!.templates.first;
      }

      // Find the template that was just completed
      final completedTemplateId = lastCompletedSession.templateId;
      WorkoutTemplate? completedTemplate;
      try {
        completedTemplate = activeProgram!.templates
            .firstWhere((t) => t.id == completedTemplateId);
      } catch (e) {
        completedTemplate = null;
      }

      if (completedTemplate == null) {
        // Template was deleted, return first template
        return activeProgram!.templates.isEmpty
            ? null
            : activeProgram!.templates.first;
      }

      // Get the next template based on day_order
      final sortedTemplates = List<WorkoutTemplate>.from(activeProgram!.templates);
      sortedTemplates.sort((a, b) => (a.dayOrder ?? 0).compareTo(b.dayOrder ?? 0));

      final currentIndex = sortedTemplates.indexWhere((t) => t.id == completedTemplate!.id);
      
      if (currentIndex == -1 || currentIndex == sortedTemplates.length - 1) {
        // Completed template is last or not found, cycle back to first
        return sortedTemplates.isNotEmpty ? sortedTemplates.first : null;
      }

      // Return the next template in sequence
      return sortedTemplates[currentIndex + 1];
    } catch (e) {
      debugPrint('Error getting next template: $e');
      // Fallback to first template
      return activeProgram!.templates.isEmpty
          ? null
          : activeProgram!.templates.first;
    }
  }

  /// Clear error message
  void clearError() {
    error = null;
    notifyListeners();
  }
}
