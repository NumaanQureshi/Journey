import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';

class ConversationMessage {
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;

  ConversationMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      role: json['role'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class WorkoutPlan {
  final int id;
  final String? goal;
  final Map<String, dynamic> workoutData;
  final bool? wasCompleted;
  final int? feedbackRating;
  final String? feedbackNotes;
  final DateTime generatedAt;

  WorkoutPlan({
    required this.id,
    required this.goal,
    required this.workoutData,
    required this.wasCompleted,
    required this.feedbackRating,
    required this.feedbackNotes,
    required this.generatedAt,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      id: json['id'] as int,
      goal: json['goal'] as String?,
      workoutData: json['workout_data'] as Map<String, dynamic>? ?? {},
      wasCompleted: json['was_completed'] as bool?,
      feedbackRating: json['feedback_rating'] as int?,
      feedbackNotes: json['feedback_notes'] as String?,
      generatedAt: DateTime.parse(json['generated_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }
}

class AiStats {
  final int totalConversations;
  final DateTime? lastConversationAt;
  final int totalPlansGenerated;
  final int plansCompleted;
  final double avgFeedbackRating;

  AiStats({
    required this.totalConversations,
    required this.lastConversationAt,
    required this.totalPlansGenerated,
    required this.plansCompleted,
    required this.avgFeedbackRating,
  });

  factory AiStats.fromJson(Map<String, dynamic> json) {
    return AiStats(
      totalConversations: json['total_conversations'] as int? ?? 0,
      lastConversationAt: json['last_conversation_at'] != null
          ? DateTime.parse(json['last_conversation_at'] as String)
          : null,
      totalPlansGenerated: json['total_plans_generated'] as int? ?? 0,
      plansCompleted: json['plans_completed'] as int? ?? 0,
      avgFeedbackRating: (json['avg_feedback_rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AiService {
  final _storage = const FlutterSecureStorage();
  List<ConversationMessage> conversationHistory = [];
  bool _isInitialized = false;

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  /// Load conversation history from backend
  Future<List<ConversationMessage>> loadConversationHistory() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiService.ai()}/conversation-history'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          final messages = (responseBody['messages'] as List?)
              ?.map((msg) => ConversationMessage.fromJson(msg))
              .toList() ?? [];
          conversationHistory = messages;
          _isInitialized = true;
          return messages;
        } else {
          throw Exception('Failed to load history: ${responseBody['error']}');
        }
      } else if (response.statusCode == 404) {
        // No history yet
        conversationHistory = [];
        _isInitialized = true;
        return [];
      } else {
        throw Exception('Failed to load conversation history. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading conversation history: $e');
      rethrow;
    }
  }

  /// Send a quick response without saving to conversation history
  /// Use this for motivational messages, quick tips, or non-conversational AI requests
  Future<String> getQuickResponse(String prompt) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiService.ai()}/chat'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': prompt,
          'conversation_history': [], // Empty history means don't save
          'save_to_history': false, // Optional flag for backend
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          return responseBody['response'] as String;
        } else {
          throw Exception('Failed to get response: ${responseBody['error']}');
        }
      } else {
        throw Exception('Failed to get quick response. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting quick response: $e');
      rethrow;
    }
  }

  /// Send a message and get response
  Future<String> sendMessage(String message) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    // Prepare conversation history in format expected by backend
    final historyForBackend = conversationHistory
        .map((msg) => {'role': msg.role, 'content': msg.content})
        .toList();

    final response = await http.post(
      Uri.parse('${ApiService.ai()}/chat'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'message': message,
        'conversation_history': historyForBackend,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['success'] == true) {
        final aiResponse = responseBody['response'] as String;
        
        // Note: The screen handles adding messages to conversationHistory
        // This method only handles the API communication
        return aiResponse;
      } else {
        throw Exception('Failed to get AI response: ${responseBody['error']}');
      }
    } else {
      throw Exception('Failed to communicate with the AI service. Status code: ${response.statusCode}');
    }
  }

  /// Clear conversation history locally
  Future<void> clearConversationHistory() async {
    conversationHistory.clear();
  }

  /// Get current conversation history
  List<ConversationMessage> getConversationHistory() {
    return conversationHistory;
  }

  /// Check if conversation history has been loaded
  bool isInitialized() => _isInitialized;

  /// Load all workout plans for the user
  Future<List<WorkoutPlan>> loadWorkoutPlans() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiService.ai()}/workout-plans'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          final plans = (responseBody['plans'] as List?)
              ?.map((plan) => WorkoutPlan.fromJson(plan))
              .toList() ?? [];
          return plans;
        } else {
          throw Exception('Failed to load plans: ${responseBody['error']}');
        }
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load workout plans. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading workout plans: $e');
      rethrow;
    }
  }

  /// Get a specific workout plan with full details
  Future<WorkoutPlan> getWorkoutPlan(int planId) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiService.ai()}/workout-plans/$planId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          return WorkoutPlan.fromJson(responseBody['plan']);
        } else {
          throw Exception('Failed to load plan: ${responseBody['error']}');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Workout plan not found');
      } else {
        throw Exception('Failed to load workout plan. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading workout plan: $e');
      rethrow;
    }
  }

  /// Delete a specific workout plan
  Future<void> deleteWorkoutPlan(int planId) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    try {
      final response = await http.delete(
        Uri.parse('${ApiService.ai()}/workout-plans/$planId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] != true) {
          throw Exception('Failed to delete plan: ${responseBody['error']}');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Workout plan not found');
      } else {
        throw Exception('Failed to delete workout plan. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting workout plan: $e');
      rethrow;
    }
  }

  /// Delete all conversation history from backend
  Future<int> deleteAllConversationsFromBackend() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    try {
      final response = await http.delete(
        Uri.parse('${ApiService.ai()}/conversations'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          conversationHistory.clear();
          return responseBody['deleted_count'] as int? ?? 0;
        } else {
          throw Exception('Failed to delete conversations: ${responseBody['error']}');
        }
      } else {
        throw Exception('Failed to delete conversations. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting conversations: $e');
      rethrow;
    }
  }

  /// Get AI usage statistics
  Future<AiStats> getAiStats() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiService.ai()}/stats'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          return AiStats.fromJson(responseBody['stats']);
        } else {
          throw Exception('Failed to load stats: ${responseBody['error']}');
        }
      } else {
        throw Exception('Failed to load AI stats. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading AI stats: $e');
      rethrow;
    }
  }
}