import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  String get _baseUrl {
    if (kIsWeb) {
      // chrome
      return 'http://127.0.0.1:5000/api/auth';
    } 
    else if (defaultTargetPlatform == TargetPlatform.android) {
      // android
      return 'http://10.0.2.2:5000/api/auth';
    }
    // iOS + all other platforms
    return 'http://localhost:5000/api/auth';
  }
  final _storage = const FlutterSecureStorage();

  Future<bool> signUp(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody is Map<String, dynamic> && responseBody.containsKey('token')) {
          final token = responseBody['token'] as String?;
          if (token != null) {
            await _storage.write(key: 'auth_token', value: token);
            return true;
          }
        }
        return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
