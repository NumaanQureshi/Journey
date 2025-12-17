import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';

class AiService {

  final _storage = const FlutterSecureStorage();
  List<Map<String, String>> conversationHistory = [];

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  Future<String> sendMessage(String message) async {
    final token = await getToken();
    
    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    final response = await http.post(
      Uri.parse('${ApiService.ai()}/chat'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'message': message,
        'conversation_history': conversationHistory,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['success'] == true) {
        // Add the exchange to conversation history
        conversationHistory.add({'role': 'user', 'content': message});
        conversationHistory.add({'role': 'assistant', 'content': responseBody['response']});
        return responseBody['response'];
      } else {
        throw Exception('Failed to get AI response: ${responseBody['error']}');
      }
    } else {
      throw Exception('Failed to communicate with the AI service. Status code: ${response.statusCode}');
    }
  }
}
