import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../services/auth_service.dart';

class Profile {
  final String? name;
  final DateTime? dateOfBirth;
  final String? gender;
  final double? heightIn;
  final double? weightLb;
  final String? mainFocus;
  final String? fitnessLevel;
  final String? injuries;
  final String? availableEquipment;
  final int? preferredWorkoutDays;

  Profile({
    this.name,
    this.dateOfBirth,
    this.gender,
    this.heightIn,
    this.weightLb,
    this.mainFocus,
    this.fitnessLevel,
    this.injuries,
    this.availableEquipment,
    this.preferredWorkoutDays,
  });

  /// Calculate age from date of birth
  int? get age {
    if (dateOfBirth == null) return null;
    final today = DateTime.now();
    int calculatedAge = today.year - dateOfBirth!.year;
    if (today.month < dateOfBirth!.month ||
        (today.month == dateOfBirth!.month && today.day < dateOfBirth!.day)) {
      calculatedAge--;
    }
    return calculatedAge;
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    DateTime? parseDateOfBirth;
    if (json['date_of_birth'] != null) {
      try {
        parseDateOfBirth = _parseDate(json['date_of_birth']);
      } catch (e) {
        debugPrint('Error parsing date_of_birth: $e');
      }
    }
    
    return Profile(
      name: json['name'],
      dateOfBirth: parseDateOfBirth,
      gender: json['gender'],
      heightIn: (json['height_in'] is num) ? (json['height_in'] as num).toDouble() : null,
      weightLb: (json['weight_lb'] is num) ? (json['weight_lb'] as num).toDouble() : null,
      mainFocus: json['main_focus'],
      fitnessLevel: json['fitness_level'],
      injuries: json['injuries'],
      availableEquipment: json['available_equipment'],
      preferredWorkoutDays: json['preferred_workout_days'],
    );
  }

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
        // Handle HTTP date format: "Thu, 06 Apr 2000 00:00:00 GMT"
        if (dateString.contains(',')) {
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
            } catch (e) {
              return null;
            }
          }
        }
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date_of_birth': dateOfBirth != null ? dateOfBirth!.toIso8601String().split('T')[0] : null,
      'gender': gender,
      'height_in': heightIn,
      'weight_lb': weightLb,
      'main_focus': mainFocus,
      'fitness_level': fitnessLevel,
      'injuries': injuries,
      'available_equipment': availableEquipment,
      'preferred_workout_days': preferredWorkoutDays,
    };
  }

  Profile copyWith({
    String? name,
    DateTime? dateOfBirth,
    String? gender,
    double? heightIn,
    double? weightLb,
    String? mainFocus,
    String? fitnessLevel,
    String? injuries,
    String? availableEquipment,
    int? preferredWorkoutDays,
  }) {
    return Profile(
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      heightIn: heightIn ?? this.heightIn,
      weightLb: weightLb ?? this.weightLb,
      mainFocus: mainFocus ?? this.mainFocus,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      injuries: injuries ?? this.injuries,
      availableEquipment: availableEquipment ?? this.availableEquipment,
      preferredWorkoutDays: preferredWorkoutDays ?? this.preferredWorkoutDays,
    );
  }
}

class User {
  final String userId;
  final String username;
  final String email;
  final Profile? profile;

  User({
    required this.userId,
    required this.username,
    required this.email,
    this.profile,
  });

  // Convenience getter for name from profile
  String? get name => profile?.name;

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'profile': profile?.toJson(),
    };
  }

  // Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    debugPrint('User.fromJson received: $json');
    
    final userIdRaw = json['id'] ?? json['userId'];
    final userId = userIdRaw is int ? userIdRaw.toString() : (userIdRaw ?? '');
    
    final username = json['username'] ?? '';
    final email = json['email'] ?? '';
    
    Profile? profile;
    
    // Try to parse profile from nested 'profile' key first
    if (json['profile'] != null) {
      profile = Profile.fromJson(json['profile']);
    } else {
      // If not nested, check if profile fields exist at top level
      // (backend returns them at top level from /profile/me endpoint)
      if (json.containsKey('name') || json.containsKey('gender') || json.containsKey('height_in')) {
        profile = Profile.fromJson(json);
      }
    }
    
    debugPrint('Parsed User - id: $userId, username: $username, email: $email, has profile: ${profile != null}');
    
    return User(
      userId: userId,
      username: username,
      email: email,
      profile: profile,
    );
  }

  // Create a copy with optional modifications
  User copyWith({
    String? userId,
    String? username,
    String? email,
    Profile? profile,
  }) {
    return User(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      profile: profile ?? this.profile,
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
  String? get displayName => _user?.profile?.name ?? _user?.username;
  String? get userId => _user?.userId;
  Profile? get profile => _user?.profile;

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
  void updateUserFromLoginResponse(Map<String, dynamic> userData) {
    try {
      debugPrint('updateUserFromLoginResponse - received: $userData');
      
      final userIdRaw = userData['id'] ?? userData['userId'];
      final userId = userIdRaw is int ? userIdRaw.toString() : (userIdRaw ?? '');
      
      final username = userData['username'] ?? '';
      final email = userData['email'] ?? '';
      
      // If username looks like a date, it's the wrong field - use email instead
      if (username.contains('GMT') || username.contains('-') || username.isEmpty) {
        _user = User(
          userId: userId,
          username: email.split('@').first,
          email: email,
        );
      } else {
        _user = User(
          userId: userId,
          username: username,
          email: email,
        );
      }
      
      _error = null;
      debugPrint('User updated from login - displayName: ${_user?.profile?.name ?? _user?.username}');
      
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

      debugPrint('Attempting to fetch user profile from ${ApiService.me()}');
      debugPrint('API base URL: ${ApiService.getBaseUrl()}');

      final response = await http.get(
        Uri.parse(ApiService.me()),
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
        
        // Backend wraps profile data in a "profile" key, so unwrap it
        final profileData = responseBody is Map<String, dynamic> && responseBody.containsKey('profile')
            ? responseBody['profile']
            : responseBody;
        
        debugPrint('Profile data to parse: $profileData');
        
        // Parse the response which should contain user and profile data
        _user = User.fromJson(profileData);
        _error = null;
        debugPrint('User successfully loaded - displayName: ${_user?.profile?.name ?? _user?.username}');
        
        // Save to local storage
        await _saveUserToStorage(_user!);
      } else {
        _error = 'Failed to fetch user data: ${response.statusCode}';
        debugPrint(_error);
        debugPrint('Response headers: ${response.headers}');
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

  /// Update user data manually
  void updateUser(User user) {
    _user = user;
    _saveUserToStorage(user);
    notifyListeners();
  }

  /// Clear user data
  Future<void> clearUser() async {
    _user = null;
    _error = null;
    await _storage.delete(key: 'user_data');
    notifyListeners();
  }

  /// Fetch user data from backend by user ID
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
