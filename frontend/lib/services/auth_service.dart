import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  // --- Get User ID from JWT Token ---
  Future<String?> getUserIdFromToken() async {
    try {
      final token = await getToken();
      if (token == null) return null;
      
      // JWT format: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) {
        debugPrint('Invalid token format: expected 3 parts, got ${parts.length}');
        return null;
      }
      
      // Decode the payload (add padding if necessary)
      String payload = parts[1];
      
      // Add padding if necessary for base64 decoding
      switch (payload.length % 4) {
        case 1:
          payload += '===';
          break;
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }
      
      try {
        final decoded = utf8.decode(base64Url.decode(payload));
        final json = jsonDecode(decoded) as Map<String, dynamic>;
        
        debugPrint('JWT payload decoded: $json');
        
        final userId = json['user_id'];
        debugPrint('Extracted user_id: $userId');
        
        return userId?.toString();
      } catch (e) {
        debugPrint('Error decoding JWT payload: $e');
        return null;
      }
    } catch (e) {
      debugPrint('Error in getUserIdFromToken: $e');
      return null;
    }
  }

  // --- Persistent Auth Token ---
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // --- Sign Up ---
  Future<bool> signUp(String email, String password, String username) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.auth()}/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
          'username': username,
        }),
      );

      debugPrint('SignUp Response Status: ${response.statusCode}');
      debugPrint('SignUp Response Body: ${response.body}');

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
      debugPrint('SignUp failed with status ${response.statusCode}');
      return false;
    } catch (e) {
      debugPrint('SignUp exception: $e');
      return false;
    }
  }

  // --- Log In ---
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.auth()}/login'),
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
            // Return user data from the response
            return responseBody['user'] as Map<String, dynamic>?;
          }
        }
        return null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // --- Request Password Reset Link ---
  Future<bool> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.auth()}/forgot-password'), // endpoint for forgot_password
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
        Uri.parse('${ApiService.auth()}/reset-password'), // endpoint for reset_password
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

  /// Checks if a valid token exists and is still valid by making a test request
  Future<bool> isTokenValid() async {
    try {
      final token = await getToken();
      if (token == null) {
        debugPrint('No token found in storage');
        return false;
      }

      // Make a simple request to verify the token is still valid
      final response = await http.get(
        Uri.parse(ApiService.me()),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        debugPrint('Token is valid');
        return true;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Token is invalid or expired
        debugPrint('Token is invalid (${response.statusCode})');
        await _storage.delete(key: 'auth_token');
        return false;
      } else {
        // Other error - assume token might still be valid
        debugPrint('Token validation returned status ${response.statusCode}');
        return true;
      }
    } catch (e) {
      debugPrint('Error validating token: $e');
      return false;
    }
  }

}
