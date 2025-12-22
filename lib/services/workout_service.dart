import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'auth_service.dart';

class Exercise {
  final int id;
  final String name;
  final String? description;
  final String? category;
  final String? force;
  final String? level;
  final String? mechanic;
  final String? equipment;
  final List<String>? primaryMuscles;
  final List<String>? secondaryMuscles;

  Exercise({
    required this.id,
    required this.name,
    this.description,
    this.category,
    this.force,
    this.level,
    this.mechanic,
    this.equipment,
    this.primaryMuscles,
    this.secondaryMuscles,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      force: json['force'],
      level: json['level'],
      mechanic: json['mechanic'],
      equipment: json['equipment'],
      primaryMuscles: json['primaryMuscles'] != null
          ? List<String>.from(json['primaryMuscles'])
          : json['primary_muscles'] != null
              ? List<String>.from(json['primary_muscles'])
              : null,
      secondaryMuscles: json['secondaryMuscles'] != null
          ? List<String>.from(json['secondaryMuscles'])
          : json['secondary_muscles'] != null
              ? List<String>.from(json['secondary_muscles'])
              : null,
    );
  }
}

class TemplateExercise {
  final int id;
  final int templateId;
  final int exerciseId;
  final int? targetSets;
  final String? targetReps;
  final double? targetWeightLb;
  final int? restSeconds;
  final int? orderIndex;
  final Exercise? exercise;

  TemplateExercise({
    required this.id,
    required this.templateId,
    required this.exerciseId,
    this.targetSets,
    this.targetReps,
    this.targetWeightLb,
    this.restSeconds,
    this.orderIndex,
    this.exercise,
  });

  factory TemplateExercise.fromJson(Map<String, dynamic> json) {
    return TemplateExercise(
      id: json['id'],
      templateId: json['template_id'],
      exerciseId: json['exercise_id'],
      targetSets: json['target_sets'],
      targetReps: json['target_reps'],
      targetWeightLb: json['target_weight_lb'],
      restSeconds: json['rest_seconds'],
      orderIndex: json['order_index'],
      exercise: json['exercise'] != null ? Exercise.fromJson(json['exercise']) : null,
    );
  }
}

class WorkoutTemplate {
  final int id;
  final int programId;
  final String name;
  final int? dayOrder;
  final String? notes;
  final DateTime? createdAt;
  final List<TemplateExercise> exercises;

  WorkoutTemplate({
    required this.id,
    required this.programId,
    required this.name,
    this.dayOrder,
    this.notes,
    this.createdAt,
    this.exercises = const [],
  });

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplate(
      id: (json['id'] as int?) ?? 0,
      programId: (json['program_id'] as int?) ?? 0,
      name: (json['name'] as String?) ?? 'Unnamed Template',
      dayOrder: json['day_order'] as int?,
      notes: json['notes'] as String?,
      createdAt: Program._parseDate(json['created_at']),
      exercises: json['exercises'] != null
          ? (json['exercises'] as List).map((e) => TemplateExercise.fromJson(e)).toList()
          : [],
    );
  }
}

class Program {
  final int id;
  final int? userId;
  final String name;
  final String? description;
  final bool? isActive;
  final DateTime? createdAt;
  final List<WorkoutTemplate> templates;

  Program({
    required this.id,
    this.userId,
    required this.name,
    this.description,
    this.isActive,
    this.createdAt,
    this.templates = const [],
  });

  /// Helper method to safely parse dates from various formats
  static DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    
    try {
      final dateString = dateValue.toString().trim();
      if (dateString.isEmpty) return null;
      
      // Try ISO 8601 format first
      try {
        return DateTime.parse(dateString);
      } catch (_) {
        // If that fails, try other common formats
        // Handle HTTP date format: "Thu, 18 Dec 2025 18:56:16 GMT"
        if (dateString.contains(',')) {
          // Parse HTTP date format manually
          final parts = dateString.split(' ');
          if (parts.length >= 4) {
            final months = {
              'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
              'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
            };
            try {
              final day = int.parse(parts[1]);
              final month = months[parts[2]] ?? 1;
              final year = int.parse(parts[3]);
              final timeParts = parts[4].split(':');
              final hour = int.parse(timeParts[0]);
              final minute = int.parse(timeParts[1]);
              final second = int.parse(timeParts[2]);
              return DateTime.utc(year, month, day, hour, minute, second);
            } catch (_) {
              return null;
            }
          }
        }
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int?,
      name: (json['name'] as String?) ?? 'Unnamed Program',
      description: json['description'] as String?,
      isActive: json['is_active'] as bool?,
      createdAt: _parseDate(json['created_at']),
      templates: json['templates'] != null
          ? (json['templates'] as List).map((t) => WorkoutTemplate.fromJson(t)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'is_active': isActive,
    };
  }
}

class WorkoutSession {
  final int id;
  final int userId;
  final int? templateId;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? status;
  final int? durationMin;
  final int? caloriesBurned;
  final double? totalVolumeLb;
  final String? notes;

  WorkoutSession({
    required this.id,
    required this.userId,
    this.templateId,
    this.startTime,
    this.endTime,
    this.status,
    this.durationMin,
    this.caloriesBurned,
    this.totalVolumeLb,
    this.notes,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'],
      userId: json['user_id'],
      templateId: json['template_id'],
      startTime: Program._parseDate(json['start_time']),
      endTime: Program._parseDate(json['end_time']),
      status: json['status'],
      durationMin: json['duration_min'],
      caloriesBurned: json['calories_burned'],
      totalVolumeLb: json['total_volume_lb'],
      notes: json['notes'],
    );
  }
}

class WorkoutService {
  static final _authService = AuthService();

  // ==================== PROGRAMS ====================

  /// Fetch all programs for the current user
  static Future<List<Program>> getPrograms() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No auth token');

      final response = await http.get(
        Uri.parse('${ApiService.workouts()}/programs'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['programs'] != null) {
          final data = body['programs'] as List;
          return data.map((p) => Program.fromJson(p)).toList();
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to load programs: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new program
  static Future<Program> createProgram({
    required String name,
    String? description,
    bool isActive = false,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No auth token');

      final response = await http.post(
        Uri.parse('${ApiService.workouts()}/programs'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
          'is_active': isActive,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        Map<String, dynamic>? programData;
        
        // Try to extract program data from nested structure
        if (body['success'] == true && body['program'] != null) {
          programData = body['program'] as Map<String, dynamic>;
        } else if (body.containsKey('id')) {
          // Response might be the program directly
          programData = body;
        }
        
        if (programData != null) {
          // Ensure name and description are preserved from request
          programData['name'] = programData['name'] ?? name;
          programData['description'] = programData['description'] ?? description;
          return Program.fromJson(programData);
        }
        throw Exception('Invalid response format: no program data');
      } else {
        throw Exception('Failed to create program: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Update a program
  static Future<Program> updateProgram({
    required int programId,
    required String name,
    String? description,
    bool? isActive,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No auth token');

      final response = await http.put(
        Uri.parse('${ApiService.workouts()}/programs/$programId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
          'is_active': isActive,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Backend returns: {"success": true, "program": {...}}
        if (body['success'] == true && body['program'] != null) {
          final programData = body['program'] as Map<String, dynamic>;
          // Ensure all required fields are present
          programData['id'] = programData['id'] ?? programId;
          programData['name'] = programData['name'] ?? name;
          programData['description'] = programData['description'] ?? description;
          return Program.fromJson(programData);
        } else {
          throw Exception('Invalid response format: missing program data');
        }
      } else {
        throw Exception('Failed to update program: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a program
  static Future<void> deleteProgram({required int programId}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No auth token');

      final response = await http.delete(
        Uri.parse('${ApiService.workouts()}/programs/$programId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] != true) {
          throw Exception(body['error'] ?? 'Failed to delete program');
        }
      } else if (response.statusCode == 403) {
        throw Exception('Unauthorized: You do not own this program');
      } else {
        throw Exception('Failed to delete program: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ==================== WORKOUT TEMPLATES ====================

  /// Fetch all templates for a program
  static Future<List<WorkoutTemplate>> getTemplatesForProgram(int programId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No auth token');

      final response = await http.get(
        Uri.parse('${ApiService.workouts()}/programs/$programId/templates'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['templates'] != null) {
          final data = body['templates'] as List;
          return data.map((t) => WorkoutTemplate.fromJson(t)).toList();
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to load templates: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new workout template
  static Future<WorkoutTemplate> createTemplate({
    required int programId,
    required String name,
    int? dayOrder,
    String? notes,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No auth token');

      final response = await http.post(
        Uri.parse('${ApiService.workouts()}/programs/$programId/templates'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'day_order': dayOrder,
          'notes': notes,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        Map<String, dynamic>? templateData;
        
        // Try to extract template data from nested structure
        if (body['success'] == true && body['template'] != null) {
          templateData = body['template'] as Map<String, dynamic>;
        } else if (body.containsKey('id')) {
          // Response might be the template directly
          templateData = body;
        }
        
        if (templateData != null) {
          // Ensure required fields are preserved from request
          templateData['program_id'] = templateData['program_id'] ?? programId;
          templateData['name'] = templateData['name'] ?? name;
          return WorkoutTemplate.fromJson(templateData);
        }
        throw Exception('Invalid response format: no template data');
      } else {
        throw Exception('Failed to create template: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing workout template
  static Future<WorkoutTemplate> updateTemplate({
    required int templateId,
    required String name,
    String? notes,
    int? dayOrder,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No auth token');

      final response = await http.put(
        Uri.parse('${ApiService.workouts()}/templates/$templateId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'notes': notes,
          'day_order': dayOrder,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['template'] != null) {
          return WorkoutTemplate.fromJson(body['template']);
        }
        throw Exception('Invalid response format');
      } else if (response.statusCode == 403) {
        throw Exception('Unauthorized: You do not own this template');
      } else {
        throw Exception('Failed to update template: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a workout template
  static Future<void> deleteTemplate({required int templateId}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No auth token');

      final response = await http.delete(
        Uri.parse('${ApiService.workouts()}/templates/$templateId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] != true) {
          throw Exception(body['error'] ?? 'Failed to delete template');
        }
      } else if (response.statusCode == 403) {
        throw Exception('Unauthorized: You do not own this template');
      } else {
        throw Exception('Failed to delete template: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ==================== TEMPLATE EXERCISES ====================

  /// Add an exercise to a template
  static Future<TemplateExercise> addExerciseToTemplate({
    required int templateId,
    required int exerciseId,
    int targetSets = 3,
    String? targetReps,
    double? targetWeightLb,
    int restSeconds = 60,
    int orderIndex = 0,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No auth token');

      final response = await http.post(
        Uri.parse('${ApiService.workouts()}/templates/$templateId/exercises'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'exercise_id': exerciseId,
          'target_sets': targetSets,
          'target_reps': targetReps,
          'target_weight_lb': targetWeightLb,
          'rest_seconds': restSeconds,
          'order_index': orderIndex,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['template_exercise'] != null) {
          return TemplateExercise.fromJson(body['template_exercise']);
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to add exercise: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Remove an exercise from a template
  static Future<void> removeExerciseFromTemplate({
    required int templateId,
    required int templateExerciseId,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No auth token');

      final response = await http.delete(
        Uri.parse('${ApiService.workouts()}/templates/$templateId/exercises/$templateExerciseId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] != true) {
          throw Exception(body['error'] ?? 'Failed to remove exercise');
        }
      } else if (response.statusCode == 403) {
        throw Exception('Unauthorized: You do not own this template');
      } else if (response.statusCode == 404) {
        throw Exception('Template exercise not found');
      } else {
        throw Exception('Failed to remove exercise: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Update a template exercise
  static Future<TemplateExercise> updateTemplateExercise({
    required int templateExerciseId,
    int? targetSets,
    String? targetReps,
    double? targetWeightLb,
    int? restSeconds,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No auth token');

      final response = await http.put(
        Uri.parse('${ApiService.workouts()}/sets/$templateExerciseId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'target_sets': targetSets,
          'target_reps': targetReps,
          'target_weight_lb': targetWeightLb,
          'rest_seconds': restSeconds,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['set'] != null) {
          return TemplateExercise.fromJson(body['set']);
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to update exercise: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ==================== WORKOUT SESSIONS ====================

  /// Start a new workout session from a template
  static Future<WorkoutSession> startWorkout(int templateId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No auth token');

      final response = await http.post(
        Uri.parse('${ApiService.workouts()}/sessions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'template_id': templateId,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['session'] != null) {
          return WorkoutSession.fromJson(body['session']);
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to start workout: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get all workout sessions for the user
  static Future<List<WorkoutSession>> getWorkoutSessions() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No auth token');

      final response = await http.get(
        Uri.parse('${ApiService.workouts()}/sessions'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['sessions'] != null) {
          final data = body['sessions'] as List;
          return data.map((s) => WorkoutSession.fromJson(s)).toList();
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to load sessions: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ==================== EXERCISE LIBRARY ====================

  /// Get all available exercises with optional pagination
  static Future<List<Exercise>> getExercises({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No auth token');

      final uri = Uri.parse('${ApiService.workouts()}/exercises').replace(
        queryParameters: {
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );

      debugPrint('DEBUG: Fetching exercises from $uri');
      
      // Retry logic for transient failures
      int retries = 5;
      Exception? lastException;
      
      while (retries > 0) {
        try {
          // Create a fresh client for each request to avoid connection reuse issues
          final response = await http.get(
            uri,
            headers: {'Authorization': 'Bearer $token'},
          ).timeout(
            const Duration(seconds: 60),
            onTimeout: () => throw Exception('Request timeout while loading exercises'),
          );

          debugPrint('DEBUG: Response status: ${response.statusCode}');
          debugPrint('DEBUG: Response body length: ${response.body.length}');

          if (response.statusCode == 200) {
            final body = jsonDecode(response.body) as Map<String, dynamic>;
            if (body['success'] == true && body['exercises'] != null) {
              final data = body['exercises'] as List;
              debugPrint('DEBUG: Parsed ${data.length} exercises from response');
              return data.map((e) => Exercise.fromJson(e)).toList();
            }
            throw Exception('Invalid response format');
          } else {
            throw Exception('Failed to load exercises: ${response.statusCode}');
          }
        } on Exception catch (e) {
          lastException = e;
          retries--;
          if (retries > 0) {
            debugPrint('DEBUG: Request failed, retrying... ($retries retries left)');
            // Increase delay significantly - server may need time to clean up connections
            await Future.delayed(const Duration(milliseconds: 1000));
          }
        }
      }
      
      throw lastException ?? Exception('Failed to load exercises after retries');
    } catch (e) {
      debugPrint('DEBUG: getExercises error: $e');
      rethrow;
    }
  }

  /// Get a specific exercise by ID
  static Future<Exercise> getExercise(int exerciseId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No auth token');

      final response = await http.get(
        Uri.parse('${ApiService.workouts()}/exercises/$exerciseId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['exercise'] != null) {
          return Exercise.fromJson(body['exercise']);
        }
        throw Exception('Invalid response format');
      } else if (response.statusCode == 404) {
        throw Exception('Exercise not found');
      } else {
        throw Exception('Failed to load exercise: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
