// FEATURE FLAGS

/// Controls whether the app bypasses the login flow and mocks authentication.
/// 
/// ENSURE THIS IS SET TO FALSE IN PRODUCTION
const bool kSkipAuthentication = false; // Set this to false before releasing!

/// DEBUG_ID = 14
/// Must match the 'DEBUG_USER_ID=5' set in backend .env file.
const int kDebugUserId = 4;

const String kDebugAuthToken = 'MOCK_TOKEN_FOR_DEBUG_4'; 

// OTHER FLAGS