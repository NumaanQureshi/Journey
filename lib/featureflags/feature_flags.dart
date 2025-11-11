// FEATURE FLAGS

/// Controls whether the app bypasses the login flow and mocks authentication.
/// 
/// ⚠️ IMPORTANT: Must be set to `false` for production/release builds.
const bool kSkipAuthentication = true; // Set this to false before releasing!

/// The ID of the test user to assume when kSkipAuthentication is true.
/// This ID must match the 'DEBUG_USER_ID=5' set in your Flask backend's .env file.
const int kDebugUserId = 5;

/// The mock token to be used for API calls when kSkipAuthentication is true.
/// This token doesn't need to be valid, as the Flask backend skips validation, 
/// but a non-empty string is often needed for the 'Authorization' header to exist.
const String kDebugAuthToken = 'MOCK_TOKEN_FOR_DEBUG_5'; 

// You can add other debug flags here later, like kSkipDatabaseCalls, etc.