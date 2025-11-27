import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart'; // comment out for publication builds

class AuthService {
  // --- Hosted Backend URL specifically for Auth Functions ---
  String get _baseUrl {
    return 'https://journey-backend-zqz7.onrender.com/api/auth';
  }

  // // --- Local Backend URL specifically for Auth Functions ---
  // String get _baseUrl {
  //   if (kIsWeb) {
  //     // chrome
  //     return 'http://127.0.0.1:5000/api/auth';
  //   } 
  //   else if (defaultTargetPlatform == TargetPlatform.android) {
  //     // android
  //     return 'http://10.0.2.2:5000/api/auth';
  //   }
  //   // iOS + all other platforms
  //   return 'http://localhost:5000/api/auth';
  // }
  final _storage = const FlutterSecureStorage();

  // --- Persistent Auth Token ---
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // --- Sign Up ---
  Future<bool> signUp(String email, String password, String username) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
          'username': username,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody is Map<String, dynamic> && responseBody.containsKey('token')) {
          final token = responseBody['token'] as String?;
          if (token != null) {
            await _storage.write(key: 'auth_token', value: token);
            return true;
          }
        }
        // token missing should return false
        return false; 
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // --- Log In ---
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

  // --- Request Password Reset Link ---
  Future<bool> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/forgot-password'), // endpoint for forgot_password
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // --- Password Reset ---
  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/reset-password'), // endpoint for reset_password
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'token': token,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        await _storage.delete(key: 'auth_token'); 
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

}
