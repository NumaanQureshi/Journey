import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/challenge_provider.dart';
import 'api_service.dart';
import 'auth_service.dart';

class ChallengeService {
  final AuthService _authService = AuthService();

  Future<Map<String, List<Challenge>>> fetchChallenges() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    final response = await http.get(
      Uri.parse(ApiService.challenges()),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch challenges: ${response.body}');
    }

    final jsonResponse = jsonDecode(response.body);
    final List<dynamic> fetchedDataJson = jsonResponse['challenges'];

    final fetchedData =
        fetchedDataJson.map((json) => Challenge.fromJson(json)).toList();

    final newDaily = fetchedData.where((c) => c.type == 'Daily').toList();
    final newWeekly = fetchedData.where((c) => c.type == 'Weekly').toList();
    final fetchedAllTime = fetchedData.where((c) => c.type == 'All-Time');

    // Use a local copy to avoid modifying the global constant list
    final newAllTime =
        allTimeChallenges.map((c) => ChallengeManager._copy(c)).toList();

    for (final fetched in fetchedAllTime) {
      try {
        final localChallenge =
        newAllTime.firstWhere((c) => c.title == fetched.title);
        localChallenge.progress = fetched.progress;
        localChallenge.completed = fetched.completed;
        localChallenge.id = fetched.id;
      } catch (e) {
        // ignore: avoid_print
        print("Challenge mismatch or not found locally: ${fetched.title}");
      }
    }
    ChallengeManager.updateJourneyMaster(newAllTime);

    return {
      'daily': newDaily,
      'weekly': newWeekly,
      'allTime': newAllTime,
    };
  }

  Future<bool> incrementChallenge(Challenge c) async {
    if (c.id == null) return false;

    final token = await _authService.getToken();
    final response = await http.put(
      Uri.parse('${ApiService.challenges()}/${c.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'increment': 1,
      }),
    );

    return response.statusCode == 200;
  }
}

// Challenge Manager
class ChallengeManager {
  static Challenge _copy(Challenge c) {
    return Challenge(
      id: c.id,
      type: c.type,
      title: c.title,
      description: c.description,
      goal: c.goal,
      icon: c.icon,
      color: c.color,
      progress: c.progress,
      completed: c.completed,
    );
  }

  static DateTime getNextDailyReset() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  }

  static DateTime getNextWeeklyReset() {
    final now = DateTime.now();
    final daysUntilSunday = (7 - now.weekday) % 7;
    final nextSunday = now.add(Duration(days: daysUntilSunday));
    return DateTime(
      nextSunday.year,
      nextSunday.month,
      nextSunday.day,
    ); // Sunday midnight
  }

  static void updateJourneyMaster(List<Challenge> allTime) {
    final jm = allTime.firstWhere((x) => x.title == "Journey Master");
    final count = allTime
        .where((x) => x.title != "Journey Master" && x.completed)
        .length;
    jm.progress = count.toDouble();
    jm.completed = jm.progress >= jm.goal;
  }
}
