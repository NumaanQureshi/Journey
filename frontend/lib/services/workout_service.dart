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
  final String? categoryMajor;
  final String? difficultyLevel;
  final String? mechanic;
  final String? equipment;
  final List<String>? primaryMuscles;
  final List<String>? secondaryMuscles;
  final List<String>? instructions;
  final List<String>? images;

  Exercise({
    required this.id,
    required this.name,
    this.description,
    this.category,
    this.categoryMajor,
    this.difficultyLevel,
    this.mechanic,
    this.equipment,
    this.primaryMuscles,
    this.secondaryMuscles,
    this.instructions,
    this.images,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    // Handle array fields - they may come as arrays or need to be converted
    List<String>? parseStringArray(dynamic value) {
      if (value == null) return null;
      if (value is List) {
        try {
          return List<String>.from(value.map((e) => e.toString()));
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    return Exercise(
      id: WorkoutService._parseInt(json['id']) ?? 0,
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      category: json['category']?.toString(),
      categoryMajor: json['category_major']?.toString(),
      difficultyLevel: (json['difficulty_level'] ?? json['level'])?.toString(),
      mechanic: json['mechanic']?.toString(),
      equipment: json['equipment']?.toString(),
      primaryMuscles: parseStringArray(json['primary_muscles'] ?? json['primaryMuscles']),
      secondaryMuscles: parseStringArray(json['secondary_muscles'] ?? json['secondaryMuscles']),
      instructions: parseStringArray(json['instructions']),
      images: parseStringArray(json['images']),
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

  factory TemplateExercise.fromJson(Map<String, dynamic> json, {int? defaultTemplateId}) {
    // Debug logging
    debugPrint('TemplateExercise.fromJson received: $json');
    
    // Handle null values for required fields
    final id = json['id'];
    final templateId = json['template_id'] ?? json['templateId'] ?? defaultTemplateId;
    final exerciseId = json['exercise_id'] ?? json['exerciseId'];
    
    if (id == null) {
      throw Exception('TemplateExercise.fromJson: id is null');
    }
    if (templateId == null) {
      throw Exception('TemplateExercise.fromJson: templateId is null');
    }
    if (exerciseId == null) {
      throw Exception('TemplateExercise.fromJson: exerciseId is null');
    }
    
    // Create Exercise object if we have exercise details
    Exercise? exercise;
    if (json['exercise'] != null) {
      exercise = Exercise.fromJson(json['exercise']);
    } else if (json['exercise_name'] != null) {
      // Create a minimal Exercise object from exercise_name and exercise_id
      exercise = Exercise(
        id: WorkoutService._parseInt(exerciseId) ?? 0,
        name: json['exercise_name'] as String,
        description: null,
        category: null,
        difficultyLevel: null,
        mechanic: null,
        equipment: null,
        primaryMuscles: null,
        secondaryMuscles: null,
        instructions: null,
        categoryMajor: null,
        images: null,
      );
    }
    
    return TemplateExercise(
      id: WorkoutService._parseInt(id) ?? 0,
      templateId: WorkoutService._parseInt(templateId) ?? 0,
      exerciseId: WorkoutService._parseInt(exerciseId) ?? 0,
      targetSets: WorkoutService._parseInt(json['target_sets'] ?? json['targetSets']),
      targetReps: json['target_reps'] ?? json['targetReps'],
      targetWeightLb: WorkoutService._parseDouble(json['target_weight_lb'] ?? json['targetWeightLb']),
      restSeconds: WorkoutService._parseInt(json['rest_seconds'] ?? json['restSeconds']),
      orderIndex: WorkoutService._parseInt(json['order_index'] ?? json['orderIndex']),
      exercise: exercise,
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
    final templateId = WorkoutService._parseInt(json['id']) ?? 0;
    return WorkoutTemplate(
      id: templateId,
      programId: WorkoutService._parseInt(json['program_id']) ?? 0,
      name: (json['name'] as String?) ?? 'Unnamed Template',
      dayOrder: WorkoutService._parseInt(json['day_order']),
      notes: json['notes'] as String?,
      createdAt: Program._parseDate(json['created_at']),
      exercises: json['exercises'] != null
          ? (json['exercises'] as List).map((e) => TemplateExercise.fromJson(e as Map<String, dynamic>, defaultTemplateId: templateId)).toList()
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
      id: WorkoutService._parseInt(json['id']) ?? 0,
      userId: WorkoutService._parseInt(json['user_id']),
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

  /// Create a copy of this program with some fields replaced
  Program copyWith({
    int? id,
    int? userId,
    String? name,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    List<WorkoutTemplate>? templates,
  }) {
    return Program(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      templates: templates ?? this.templates,
    );
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
      id: WorkoutService._parseInt(json['id']) ?? 0,
      userId: WorkoutService._parseInt(json['user_id']) ?? 0,
      templateId: WorkoutService._parseInt(json['template_id']),
      startTime: Program._parseDate(json['start_time']),
      endTime: Program._parseDate(json['end_time']),
      status: json['status']?.toString(),
      durationMin: WorkoutService._parseInt(json['duration_min']),
      caloriesBurned: WorkoutService._parseInt(json['calories_burned']),
      totalVolumeLb: WorkoutService._parseDouble(json['total_volume_lb']),
      notes: json['notes']?.toString(),
    );
  }
}

class WorkoutService {
  static final _authService = AuthService();

  /// Helper to safely parse integers from various types
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Helper to safely parse doubles from various types
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

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

      final requestBody = <String, dynamic>{
        'name': name,
        'description': description,
      };
      
      if (isActive != null) {
        requestBody['is_active'] = isActive;
      }

      debugPrint('DEBUG: Updating program $programId with body: $requestBody');

      final response = await http.put(
        Uri.parse('${ApiService.workouts()}/programs/$programId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('DEBUG: Update program response status: ${response.statusCode}');
      debugPrint('DEBUG: Update program response body: ${response.body}');

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
        debugPrint('DEBUG: getTemplatesForProgram response: $body');
        if (body['success'] == true && body['templates'] != null) {
          final data = body['templates'] as List;
          final templates = data.map((t) => WorkoutTemplate.fromJson(t)).toList();
          
          // Fetch exercises for each template
          for (int i = 0; i < templates.length; i++) {
            final template = templates[i];
            try {
              final exercisesResponse = await http.get(
                Uri.parse('${ApiService.workouts()}/templates/${template.id}/exercises'),
                headers: {'Authorization': 'Bearer $token'},
              );
              
              if (exercisesResponse.statusCode == 200) {
                final exercisesBody = jsonDecode(exercisesResponse.body) as Map<String, dynamic>;
                if (exercisesBody['success'] == true && exercisesBody['exercises'] != null) {
                  final exercisesData = exercisesBody['exercises'] as List;
                  final exercises = exercisesData.map((e) => TemplateExercise.fromJson(e, defaultTemplateId: template.id)).toList();
                  
                  // Replace template in the list with one that has exercises
                  templates[i] = WorkoutTemplate(
                    id: template.id,
                    programId: template.programId,
                    name: template.name,
                    dayOrder: template.dayOrder,
                    notes: template.notes,
                    createdAt: template.createdAt,
                    exercises: exercises,
                  );
                  debugPrint('DEBUG: Loaded ${exercises.length} exercises for template ${template.name}');
                }
              }
            } catch (e) {
              debugPrint('DEBUG: Error loading exercises for template ${template.id}: $e');
              // Continue anyway - template just won't have exercises
            }
          }
          
          debugPrint('DEBUG: Parsed ${templates.length} templates');
          for (var template in templates) {
            debugPrint('DEBUG: Template ${template.name} has ${template.exercises.length} exercises');
          }
          return templates;
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

  /// Update the day order of a single template
  static Future<WorkoutTemplate> updateTemplateOrder({
    required int templateId,
    required int dayOrder,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No auth token');

      final response = await http.put(
        Uri.parse('${ApiService.workouts()}/templates/$templateId/order'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
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
        throw Exception('Failed to update template order: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Update the day order of multiple templates in bulk
  static Future<List<WorkoutTemplate>> updateTemplatesOrder({
    required List<Map<String, int>> templateOrders,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No auth token');

      final response = await http.put(
        Uri.parse('${ApiService.workouts()}/templates/reorder'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'templates': templateOrders,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['templates'] != null) {
          final templates = (body['templates'] as List)
              .map((t) => WorkoutTemplate.fromJson(t as Map<String, dynamic>))
              .toList();
          return templates;
        }
        throw Exception('Invalid response format');
      } else if (response.statusCode == 403) {
        throw Exception('Unauthorized: You do not own these templates');
      } else {
        throw Exception('Failed to update templates order: ${response.statusCode}');
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

      debugPrint('Adding exercise $exerciseId to template $templateId');
      debugPrint('Target sets: $targetSets, target reps: $targetReps, target weight: $targetWeightLb');

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

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('Parsed response body: $body');
        
        if (body['success'] == true && body['template_exercise'] != null) {
          final templateExerciseData = body['template_exercise'] as Map<String, dynamic>;
          // Create a minimal TemplateExercise object with the data we have
          // The backend only returns {id}, so we construct from known values
          return TemplateExercise(
            id: templateExerciseData['id'] ?? 0,
            templateId: templateId,
            exerciseId: exerciseId,
            targetSets: targetSets,
            targetReps: targetReps,
            targetWeightLb: targetWeightLb,
            restSeconds: restSeconds,
            orderIndex: orderIndex,
            exercise: null, // Will be populated when templates are reloaded
          );
        }
        throw Exception('Invalid response format: $body');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception('Failed to add exercise: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      debugPrint('Error in addExerciseToTemplate: $e');
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

      debugPrint('DEBUG: getWorkoutSessions response status: ${response.statusCode}');
      debugPrint('DEBUG: getWorkoutSessions response body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['sessions'] != null) {
          final data = body['sessions'] as List;
          return data.map((s) => WorkoutSession.fromJson(s)).toList();
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to load sessions: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('DEBUG: Exception in getWorkoutSessions: $e');
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

  /// Phase 3: Create a new workout session
  static Future<WorkoutSession> createWorkoutSession(
    int templateId,
  ) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No auth token');

      debugPrint('DEBUG: Creating session for template $templateId');
      
      final requestBody = jsonEncode({
        'template_id': templateId,
      });
      debugPrint('DEBUG: Request body: $requestBody');
      
      final response = await http.post(
        Uri.parse('${ApiService.workouts()}/sessions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      debugPrint('DEBUG: Create session response status: ${response.statusCode}');
      debugPrint('DEBUG: Create session response body: ${response.body}');

      if (response.statusCode == 201) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['session'] != null) {
          return WorkoutSession.fromJson(body['session']);
        }
        throw Exception('Invalid response format');
      } else if (response.statusCode == 500) {
        throw Exception('Server error creating session: ${response.body}');
      } else {
        throw Exception('Failed to create session: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('ERROR in createWorkoutSession: $e');
      rethrow;
    }
  }

  /// Phase 3: Pre-create empty workout sets for a session based on template
  static Future<List<WorkoutSet>> preCreateWorkoutSets(
    int sessionId,
    int templateId,
  ) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No auth token');

      final response = await http.post(
        Uri.parse('${ApiService.workouts()}/sessions/$sessionId/presets'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'template_id': templateId,
        }),
      );

      if (response.statusCode == 201) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['sets'] != null) {
          final sets = body['sets'] as List;
          return sets.map((e) => WorkoutSet.fromJson(e)).toList();
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to create sets: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Phase 3: Log a workout set
  static Future<WorkoutSet> logWorkoutSet(
    int sessionId,
    int exerciseId,
    int setNumber, {
    required int? repsCompleted,
    required double? weightLb,
    int? rpe,
    bool isWarmup = false,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No auth token');

      final response = await http.post(
        Uri.parse('${ApiService.workouts()}/sessions/$sessionId/sets'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'exercise_id': exerciseId,
          'set_number': setNumber,
          'reps_completed': repsCompleted,
          'weight_lb': weightLb,
          'rpe': rpe,
          'is_warmup': isWarmup,
        }),
      );

      if (response.statusCode == 201) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['set'] != null) {
          return WorkoutSet.fromJson(body['set']);
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to log set: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Phase 3: Finish a workout session and calculate stats
  static Future<WorkoutSession> finishWorkoutSession(
    int sessionId, {
    String? notes,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No auth token');

      final response = await http.put(
        Uri.parse('${ApiService.workouts()}/sessions/$sessionId/complete'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'status': 'completed',
          'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['session'] != null) {
          return WorkoutSession.fromJson(body['session']);
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to finish session: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Phase 3: Get all sets for a session
  static Future<List<WorkoutSet>> getSessionSets(int sessionId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No auth token');

      final response = await http.get(
        Uri.parse('${ApiService.workouts()}/sessions/$sessionId/sets'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['sets'] != null) {
          final sets = body['sets'] as List;
          return sets.map((e) => WorkoutSet.fromJson(e)).toList();
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to fetch sets: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}

/// WorkoutSet - represents a single set of an exercise
class WorkoutSet {
  final int id;
  final int sessionId;
  final int exerciseId;
  final int setNumber;
  final int? repsCompleted;
  final double? weightLb;
  final int? rpe;
  final bool isWarmup;
  final DateTime createdAt;

  WorkoutSet({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.setNumber,
    this.repsCompleted,
    this.weightLb,
    this.rpe,
    this.isWarmup = false,
    required this.createdAt,
  });

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    final createdAtStr = json['created_at'];
    DateTime createdAt;
    try {
      if (createdAtStr is String) {
        createdAt = DateTime.parse(createdAtStr);
      } else {
        createdAt = DateTime.now();
      }
    } catch (_) {
      createdAt = DateTime.now();
    }

    return WorkoutSet(
      id: WorkoutService._parseInt(json['id']) ?? 0,
      sessionId: WorkoutService._parseInt(json['session_id']) ?? 0,
      exerciseId: WorkoutService._parseInt(json['exercise_id']) ?? 0,
      setNumber: WorkoutService._parseInt(json['set_number']) ?? 0,
      repsCompleted: WorkoutService._parseInt(json['reps_completed']),
      weightLb: WorkoutService._parseDouble(json['weight_lb']),
      rpe: WorkoutService._parseInt(json['rpe']),
      isWarmup: (json['is_warmup'] as bool?) ?? false,
      createdAt: createdAt,
    );
  }

Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'exercise_id': exerciseId,
      'set_number': setNumber,
      'reps_completed': repsCompleted,
      'weight_lb': weightLb,
      'rpe': rpe,
      'is_warmup': isWarmup,
    };
  }
}
