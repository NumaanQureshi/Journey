import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'auth_service.dart';

class Exercise {
  final int id;
  final String name;
  final String? description;
  final String? category;

  Exercise({
    required this.id,
    required this.name,
    this.description,
    this.category,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
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
      id: json['id'],
      programId: json['program_id'],
      name: json['name'],
      dayOrder: json['day_order'],
      notes: json['notes'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      exercises: json['exercises'] != null
          ? (json['exercises'] as List).map((e) => TemplateExercise.fromJson(e)).toList()
          : [],
    );
  }
}

class Program {
  final int id;
  final int userId;
  final String name;
  final String? description;
  final bool? isActive;
  final DateTime? createdAt;
  final List<WorkoutTemplate> templates;

  Program({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.isActive,
    this.createdAt,
    this.templates = const [],
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      description: json['description'],
      isActive: json['is_active'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
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
      startTime: json['start_time'] != null ? DateTime.parse(json['start_time']) : null,
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
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
  static String _endpoint() => '${ApiService.getBaseUrl()}/workouts';

  // ==================== PROGRAMS ====================

  /// Fetch all programs for the current user
  static Future<List<Program>> getPrograms() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No auth token');

      final response = await http.get(
        Uri.parse('${_endpoint()}/programs'),
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
        Uri.parse('${_endpoint()}/programs'),
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
        if (body['success'] == true && body['program'] != null) {
          return Program.fromJson(body['program']);
        }
        throw Exception('Invalid response format');
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
        Uri.parse('${_endpoint()}/programs/$programId'),
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
        return Program.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update program: ${response.statusCode}');
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
        Uri.parse('${_endpoint()}/programs/$programId/templates'),
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
        Uri.parse('${_endpoint()}/programs/$programId/templates'),
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
        if (body['success'] == true && body['template'] != null) {
          return WorkoutTemplate.fromJson(body['template']);
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to create template: ${response.statusCode}');
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
        Uri.parse('${_endpoint()}/templates/$templateId/exercises'),
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
        Uri.parse('${_endpoint()}/sets/$templateExerciseId'),
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
        Uri.parse('${_endpoint()}/sessions'),
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
        Uri.parse('${_endpoint()}/sessions'),
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

  /// Get available exercises
  static Future<List<Exercise>> getExercises() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No auth token');

      final response = await http.get(
        Uri.parse('${_endpoint()}/exercises'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['exercises'] != null) {
          final data = body['exercises'] as List;
          return data.map((e) => Exercise.fromJson(e)).toList();
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to load exercises: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
