# Journey

An AI-assisted fitness tracking app specializing in safety, correction, and commitment.

Created by **Sahel Reja**, **Numaan Qureshi**, and **Tawhidul Islam**.

## Features

- 💻 **AI Fitness Assistance** - Get personalized workout plans and real-time guidance powered by AI
- 💪🏽 **Form Correction & Optimization** - Receive feedback on exercise form and technique for safer, more effective workouts
- 🏃🏽‍♀️ **Weekly Challenges** - Participate in community-driven challenges to stay motivated and track progress
- 📊 **Workout Tracking** - Log exercises, sets, and reps with detailed analytics and progress visualization

## Tech Stack

### Frontend
- **Framework:** Flutter (Cross-platform mobile app)
- **Language:** Dart

### Backend
- **Framework:** Flask (Python)
- **Language:** Python
- **Database:** Supabase (PostgreSQL)
- **AI Integration:** GPT API for fitness guidance and form correction

## Architecture

The application follows a client-server architecture:

- **Frontend** (Flutter) - Handles UI, user interactions, and communicates with the backend API
- **Backend** (Flask) - Manages all intensive operations including:
  - AI-powered workout planning and form analysis
  - User authentication and account management
  - Challenge management and leaderboards
  - Workout session tracking and analytics
- **Database** (Supabase) - Stores user data, workout history, challenge progress, and AI conversation logs

## Project Structure

```
├── frontend/             # Flutter mobile application
│   ├── lib/              # Dart source code
│   ├── assets/           # Images and fonts
│   └── pubspec.yaml      # Flutter dependencies
└── backend/              # Flask API server
    ├── api/              # API endpoints
    ├── services/         # Business logic layer
    ├── sql_queries/      # Database queries
    ├── utils/            # Helper functions
    └── requirements.txt  # Python dependencies
```

## Getting Started

### Prerequisites
- **Flutter SDK** (for frontend)
- **Python 3.x** (for backend)
- **Supabase account** (for database)

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Configure environment variables (copy `.env.example` to `.env`):
   ```bash
   cp .env.example .env
   ```

4. Run the Flask server:
   ```bash
   python app.py
   ```

### Frontend Setup

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Development

Both frontend and backend are configured for development and deployment via the `render.yaml` configuration.

### Database Schema
See `full_schema.sql` in both directories for the complete database structure.

