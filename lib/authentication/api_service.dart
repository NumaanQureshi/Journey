import 'package:flutter/foundation.dart';

class ApiService {
  static String getBaseUrl() {


    if (kIsWeb) {
      // Web
      return 'http://127.0.0.1:5000/api';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // Android
      return 'http://10.0.2.2:5000/api';
    } else if (defaultTargetPlatform == TargetPlatform.iOS){
      // iOS
      return 'http://localhost:5000/api';
    } else {
      // --- Hosted URL for Updating Challenges ---
      return 'https://journey-backend-zqz7.onrender.com/api';
    }

  }

  // You can add specific endpoint getters here if you like
  static String auth() => '${getBaseUrl()}/auth';
  static String challenges() => '${getBaseUrl()}/challenges/';
  static String me() => '${auth()}/me';
}