class ApiService {
  static String getBaseUrl() {
    return 'https://journey-backend-zqz7.onrender.com/api';
  }

  // You can add specific endpoint getters here if you like
  static String auth() => '${getBaseUrl()}/auth';
  static String challenges() => '${getBaseUrl()}/challenges/';
  static String me() => '${getBaseUrl()}/users/me';
  static String ai() => '${getBaseUrl()}/ai';
  static String workouts() => '${getBaseUrl()}/workouts';
}
