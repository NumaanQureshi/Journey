# Journey - Frontend

Flutter mobile application for the Journey fitness tracking platform.

Created by **Numaan Qureshi**, **Sahel Reja**, and **Tawhidul Islam**.

## Features

- 📱 **Cross-Platform Mobile UI** - Native performance on Android (iOS soon)
- 💪🏽 **Workout Logging Interface** - Easy-to-use forms for tracking exercises, sets, and reps
- 🏃🏽‍♀️ **Challenge Participation** - Browse and complete weekly challenges with real-time progress
- 📊 **Progress Analytics** - View detailed workout history and statistics
- 💬 **AI Chat Interface** - Real-time communication with AI fitness assistant

## Tech Stack

- **Framework:** Flutter
- **Language:** Dart
- **Backend Communication:** HTTP REST API (Flask)

## Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Dart SDK (included with Flutter)

### Setup

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Configure API endpoint in your app (update backend URL as needed)

3. Run the app:
   ```bash
   flutter run
   ```

### Build

**Android:**
```bash
flutter build apk
```

**iOS:**
```bash
flutter build ios
```

## Project Structure

```
lib/
├── main.dart           # App entry point
├── screens/            # UI screens
├── providers/          # State management
├── services/           # API communication
└── featureflags/       # Feature flag configuration
```

