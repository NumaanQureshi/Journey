# Journey - Backend

Flask API server powering the Journey fitness tracking platform.

Created by **Sahel Reja**, **Numaan Qureshi**, and **Tawhidul Islam**.

## Features

- 🤖 **AI-Powered Workouts** - Generate personalized workout plans using GPT API
- 💪 **Form Correction** - Analyze and provide feedback on exercise form
- 🏆 **Challenge Management** - Create, track, and manage user challenges and leaderboards
- 👤 **User Management** - Handle authentication and user profiles
- 📝 **Workout Tracking** - Store and retrieve comprehensive workout session data
- 💬 **AI Conversations** - Maintain conversation history with the AI fitness assistant

## Tech Stack

- **Framework:** Flask (Python)
- **Language:** Python 3.x
- **Database:** Supabase (PostgreSQL)
- **AI Integration:** Google GPT API

## API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration

### Users
- `GET /api/users/<user_id>` - Get user profile
- `PUT /api/users/<user_id>` - Update user profile

### Workouts
- `GET /api/workouts/<user_id>` - Get user workouts
- `POST /api/workouts` - Create workout session
- `PUT /api/workouts/<workout_id>` - Update workout

### AI
- `POST /api/ai/workout-plan` - Generate AI workout plan
- `POST /api/ai/chat` - Send message to AI assistant
- `GET /api/ai/conversations/<user_id>` - Get conversation history

### Challenges
- `GET /api/challenges/<user_id>` - Get user challenges
- `POST /api/challenges/<user_id>/complete` - Complete a challenge

## Getting Started

### Prerequisites
- Python 3.x
- pip (Python package manager)
- Supabase account and connection string

### Setup

1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Configure environment variables:
   ```bash
   cp .env.example .env
   ```
   Fill in your Supabase credentials and API keys

3. Run the Flask server:
   ```bash
   python app.py
   ```

The API will be available at `http://localhost:5000`

## Project Structure

```
├── api/                # API endpoint definitions
├── services/           # Business logic layer
├── sql_queries/        # Database queries organized by feature
├── utils/              # Helper functions and utilities
├── finetune/           # AI model fine-tuning (optional)
├── app.py              # Flask app initialization
└── requirements.txt    # Python dependencies
```

## Database

All data is stored in Supabase (PostgreSQL). See `full_schema.sql` for the complete database schema.

