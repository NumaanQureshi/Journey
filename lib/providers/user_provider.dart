import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../services/auth_service.dart';

class User {
  final String userId;
  final String username;
  final String? name;
  final String email;

  User({
    required this.userId,
    required this.username,
    this.name,
    required this.email,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'name': name,
      'email': email,
    };
  }

  // Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    debugPrint('User.fromJson received: $json');
    
    // Handle userId - can be int or string
    final userIdRaw = json['id'] ?? json['userId'];
    final userId = userIdRaw is int ? userIdRaw.toString() : (userIdRaw ?? '');
    
    final username = json['username'] ?? '';
    final name = json['name'];
    final email = json['email'] ?? '';
    
    debugPrint('Parsed User - id: $userId, username: $username, name: $name, email: $email');
    
    return User(
      userId: userId,
      username: username,
      name: name,
      email: email,
    );
  }

  // Create a copy with optional modifications
  User copyWith({
    String? userId,
    String? username,
    String? name,
    String? email,
  }) {
    return User(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
}

class UserProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _authService = AuthService();
  
  User? _user;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get username => _user?.username;
  String? get displayName => _user?.name ?? _user?.username;
  String? get userId => _user?.userId;

  /// Initialize user data on app startup
  /// Tries to load from cache first, then fetches from backend
  Future<void> initializeUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Try to load from local storage first
      await _loadUserFromStorage();
      
      // Then fetch fresh data from backend
      await refreshUserData();
    } catch (e) {
      _error = 'Failed to initialize user: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user data from login response
  /// Called after successful login/signup with the response data
  void updateUserFromLoginResponse(Map<String, dynamic> userData) {
    try {
      debugPrint('updateUserFromLoginResponse - received: $userData');
      
      // Create user from response data
      // Note: Backend login response has username in wrong field, we'll use email as fallback
      final userIdRaw = userData['id'] ?? userData['userId'];
      final userId = userIdRaw is int ? userIdRaw.toString() : (userIdRaw ?? '');
      
      // The backend returns wrong data in username field, so use email or empty
      final username = userData['username'] ?? '';
      final email = userData['email'] ?? '';
      
      // If username looks like a date, it's the wrong field - use email instead
      if (username.contains('GMT') || username.contains('-') || username.isEmpty) {
        _user = User(
          userId: userId,
          username: email.split('@').first, // Use email prefix as fallback
          name: null,
          email: email,
        );
      } else {
        _user = User(
          userId: userId,
          username: username,
          name: userData['name'],
          email: email,
        );
      }
      
      _error = null;
      debugPrint('User updated from login - displayName: ${_user?.name ?? _user?.username}');
      
      // Store the user data
      _saveUserToStorage(_user!);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user from login response: $e');
    }
  }

  /// Fetch user data from backend
  Future<void> refreshUserData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _authService.getToken();
      if (token == null) {
        _error = 'No authentication token available';
        debugPrint(_error);
        return;
      }

      // Get user ID from the JWT token
      final userId = await _authService.getUserIdFromToken();
      if (userId == null) {
        _error = 'Could not extract user ID from token';
        debugPrint(_error);
        return;
      }

      debugPrint('Attempting to fetch user with ID: $userId');
      debugPrint('API base URL: ${ApiService.getBaseUrl()}');

      final response = await http.get(
        Uri.parse('${ApiService.getBaseUrl()}/users/$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Request timeout while fetching user data');
        },
      );

      debugPrint('refreshUserData - Status: ${response.statusCode}');
      debugPrint('refreshUserData - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        debugPrint('Decoded response: $responseBody');
        
        // Handle the response structure - it might be wrapped in a "user" key
        final userData = responseBody is Map<String, dynamic> && responseBody.containsKey('user')
          ? responseBody['user']
          : responseBody;
        
        debugPrint('Parsed userData: $userData');
        _user = User.fromJson(userData);
        _error = null;
        debugPrint('User successfully loaded - displayName: ${_user?.name ?? _user?.username}');
        
        // Save to local storage
        await _saveUserToStorage(_user!);
      } else {
        _error = 'Failed to fetch user data: ${response.statusCode}';
        debugPrint(_error);
        debugPrint('Response headers: ${response.headers}');
        // Try to parse error details if available
        try {
          if (response.body.isNotEmpty && response.body.startsWith('{')) {
            final errorBody = jsonDecode(response.body);
            debugPrint('Error details: $errorBody');
          }
        } catch (e) {
          debugPrint('Could not parse error response: $e');
        }
      }
    } on TimeoutException catch (e) {
      _error = 'Request timeout: $e';
      debugPrint(_error);
    } catch (e) {
      _error = 'Error refreshing user data: $e';
      debugPrint(_error);
      debugPrint('Stack trace: ${StackTrace.current}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load user data from secure storage
  Future<void> _loadUserFromStorage() async {
    try {
      final userJson = await _storage.read(key: 'user_data');
      if (userJson != null) {
        final decodedJson = jsonDecode(userJson);
        _user = User.fromJson(decodedJson);
      }
    } catch (e) {
      debugPrint('Error loading user from storage: $e');
    }
  }

  /// Save user data to secure storage
  Future<void> _saveUserToStorage(User user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _storage.write(key: 'user_data', value: userJson);
    } catch (e) {
      debugPrint('Error saving user to storage: $e');
    }
  }

  /// Update user data manually (useful when other parts of app update user info)
  void updateUser(User user) {
    _user = user;
    _saveUserToStorage(user);
    notifyListeners();
  }

  /// Clear user data (e.g., on logout)
  Future<void> clearUser() async {
    _user = null;
    _error = null;
    await _storage.delete(key: 'user_data');
    notifyListeners();
  }

  /// Fetch user data from backend by user ID
  /// Useful if you have the user ID separately
  Future<void> fetchUserById(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _authService.getToken();
      if (token == null) {
        _error = 'No authentication token available';
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiService.getBaseUrl()}/users/$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        _user = User.fromJson(responseBody);
        _error = null;
        
        // Save to local storage
        await _saveUserToStorage(_user!);
      } else {
        _error = 'Failed to fetch user data: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error fetching user: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
