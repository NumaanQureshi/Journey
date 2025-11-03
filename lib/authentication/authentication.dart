import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class AuthService {
    // local - use IPv4
    // android - 10.0.2.2
    // ios - localhost
  final String _baseUrl = 'http://192.168.1.154:5000';
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
        debugPrint('Sign up failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error during sign up: $e');
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
        String token = jsonDecode(response.body)['access_token'];
        await _storage.write(key: 'auth_token', value: token);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error during login: $e');
      return false;
    }
  }
}
