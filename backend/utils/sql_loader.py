# Loads SQL files from '/sql_queries with organized folder structure

import os

SQL_DIR = 'sql_queries'

# Mapping of SQL filenames to their subdirectories
SQL_FOLDERS = {
    # Users
    'insert_user_core.sql': 'users',
    'select_user_by_id.sql': 'users',
    'select_user_by_email.sql': 'users',
    'select_user_for_login.sql': 'users',
    'select_updated_user.sql': 'users',
    'select_all_users.sql': 'users',
    'delete_user_by_id.sql': 'users',
    'update_user_password.sql': 'users',
    'update_user_timestamp.sql': 'users',
    'insert_profile.sql': 'users',
    'select_full_user_profile.sql': 'users',
    'update_profile.sql': 'users',
    'select_recent_soreness.sql': 'users',
    
    # Programs
    'select_programs_by_user.sql': 'programs',
    'select_program_by_id.sql': 'programs',
    'insert_program.sql': 'programs',
    'update_program.sql': 'programs',
    'delete_program.sql': 'programs',
    
    # Templates
    'select_workout_templates_by_program.sql': 'templates',
    'select_template_by_id.sql': 'templates',
    'insert_workout_template.sql': 'templates',
    'update_workout_template.sql': 'templates',
    'delete_workout_template.sql': 'templates',
    'select_template_exercises.sql': 'templates',
    'insert_template_exercise.sql': 'templates',
    'delete_template_exercise.sql': 'templates',
    'verify_template_owner_by_id.sql': 'templates',
    
    # Sessions
    'select_user_sessions.sql': 'sessions',
    'select_session_owner.sql': 'sessions',
    'select_session_start_time.sql': 'sessions',
    'select_session_stats.sql': 'sessions',
    'select_workout_session.sql': 'sessions',
    'insert_workout_session.sql': 'sessions',
    'update_workout_session_complete.sql': 'sessions',
    'select_workout_history.sql': 'sessions',
    
    # Sets
    'select_workout_sets.sql': 'sets',
    'insert_workout_set.sql': 'sets',
    'update_workout_set.sql': 'sets',
    'verify_set_owner.sql': 'sets',
    
    # Exercises
    'select_all_exercises.sql': 'exercises',
    'select_exercise_by_id.sql': 'exercises',
    
    # Challenges
    'check_all_time_challenges.sql': 'challenges',
    'check_daily_challenges.sql': 'challenges',
    'check_weekly_challenges.sql': 'challenges',
    'complete_first_time_challenge.sql': 'challenges',
    'count_completed_all_time_challenges.sql': 'challenges',
    'delete_challenges_by_type.sql': 'challenges',
    'insert_base_challenge.sql': 'challenges',
    'insert_challenge.sql': 'challenges',
    'select_challenge_by_id_and_user.sql': 'challenges',
    'select_challenge_type_by_id.sql': 'challenges',
    'select_user_challenges.sql': 'challenges',
    'update_challenge_progress.sql': 'challenges',
    'update_journey_master_progress.sql': 'challenges',
    
    # Leaderboard
    'insert_leaderboard.sql': 'leaderboard',
    
    # AI
    'insert_ai_conversation.sql': 'ai',
    'insert_ai_workout_plan.sql': 'ai',
    'select_ai_user_workout_history.sql': 'ai',
    'select_user_strength_progress_ai.sql': 'ai',
    'update_ai_workout_plan_feedback.sql': 'ai',
}

def load_sql_query(filename):
    """Loads a SQL query from a file in the SQL_DIR with organized folder structure."""
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    folder = SQL_FOLDERS.get(filename, '')
    
    if folder:
        filepath = os.path.join(base_dir, SQL_DIR, folder, filename)
    else:
        # Fallback to root directory if not in mapping
        filepath = os.path.join(base_dir, SQL_DIR, filename)
    
    try:
        with open(filepath, 'r') as f:
            return f.read().strip()
    except FileNotFoundError:
        print(f"Error: SQL file not found at {filepath}")
        return None
