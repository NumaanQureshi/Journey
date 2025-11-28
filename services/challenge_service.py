import random
import datetime
from utils.sql_loader import load_sql_query

CHALLENGE_TEMPLATES = {
    'Daily': [
        {'title': 'Push-Up Power', 'goal': 30},
        {'title': 'Cardio Blitz', 'goal': 20},
        {'title': 'Try Something New', 'goal': 1},
        {'title': 'Stretch it Out', 'goal': 10},
        {'title': 'Squat Session', 'goal': 20},
        {'title': 'Plank Hold', 'goal': 90},
        {'title': 'Jumping Jack Jolt', 'goal': 50},
        {'title': 'Wall Sit Warrior', 'goal': 60},
        {'title': 'Bicep Curl Boost', 'goal': 20},
        {'title': 'Lunge Challenge', 'goal': 20},
        {'title': 'High Knee Hustle', 'goal': 40},
        {'title': 'Mountain Climber Mayhem', 'goal': 30},
        {'title': 'Sit-Up Surge', 'goal': 25},
        {'title': 'Burpee Blast', 'goal': 15},
        {'title': 'Arm Raise Rampage', 'goal': 30},
    ],
    'Weekly': [
        {'title': 'New PR', 'goal': 1},
        {'title': 'Lower Body Focus', 'goal': 1},
        {'title': '3-Workout Week', 'goal': 3},
        {'title': 'Cardio King/Queen', 'goal': 60},
        {'title': 'Strength Builder', 'goal': 4},
        {'title': 'Total Volume', 'goal': 1000},
        {'title': 'Flexibility Focus', 'goal': 30},
        {'title': 'Endurance Extra', 'goal': 10},
        {'title': 'Core Strength', 'goal': 3},
        {'title': 'Balance Booster', 'goal': 20},
        {'title': 'Upper Body Power', 'goal': 4},
        {'title': 'Speed Challenge', 'goal': 5},
        {'title': 'Stamina Builder', 'goal': 120},
        {'title': 'HIIT Hero', 'goal': 2},
        {'title': 'Mind & Body', 'goal': 2},
    ],
    'All-Time': [
        {'title': 'Centurion', 'goal': 100},
        {'title': 'Heavy Lifter', 'goal': 1000},
        {'title': 'App Explorer', 'goal': 1},
        {'title': 'First Time', 'goal': 1},
        {'title': 'Journey Master', 'goal': 4},
    ]
}
DAILY_CHALLENGE_COUNT = 5
WEEKLY_CHALLENGE_COUNT = 3

def _ensure_current_challenges(user_id, cur):
    """
    Checks if a user has active daily and weekly challenges for the current period.
    If not, it deletes the old ones and generates a new set.
    It also ensures All-Time challenges are created on first-time check.
    """
    now = datetime.datetime.now(datetime.timezone.utc)
    today = now.date()
    

    # 1. Check for existing Daily challenges for today
    check_daily_sql = load_sql_query('check_daily_challenges.sql')
    cur.execute(check_daily_sql, (user_id, today))
    has_daily = cur.fetchone()

    if not has_daily:
        # Delete old Daily challenges
        delete_challenges_sql = load_sql_query('delete_challenges_by_type.sql')
        cur.execute(delete_challenges_sql, (user_id, 'Daily'))
        
        # Create new Daily challenges
        daily_templates = random.sample(CHALLENGE_TEMPLATES['Daily'], DAILY_CHALLENGE_COUNT)
        insert_challenge_sql = load_sql_query('insert_challenge.sql')
        for challenge in daily_templates:
            cur.execute(insert_challenge_sql, (user_id, 'Daily', challenge['title'], challenge['goal'], now, now))

    # 2. Check for existing Weekly challenges for this week
    # The 'week' part of ISO 8601 week date system is used to identify the week.
    current_week = today.isocalendar()[1]
    current_year = today.isocalendar()[0]

    check_weekly_sql = load_sql_query('check_weekly_challenges.sql')
    cur.execute(check_weekly_sql, (user_id, current_week, current_year))
    has_weekly = cur.fetchone()

    if not has_weekly:
        # Delete old Weekly challenges
        delete_challenges_sql = load_sql_query('delete_challenges_by_type.sql')
        cur.execute(delete_challenges_sql, (user_id, 'Weekly'))
        
        # Create new Weekly challenges
        weekly_templates = random.sample(CHALLENGE_TEMPLATES['Weekly'], WEEKLY_CHALLENGE_COUNT)
        insert_challenge_sql = load_sql_query('insert_challenge.sql')
        for challenge in weekly_templates:
            cur.execute(insert_challenge_sql, (user_id, 'Weekly', challenge['title'], challenge['goal'], now, now))

    # 3. Check for All-Time challenges (run once)
    check_all_time_sql = load_sql_query('check_all_time_challenges.sql')
    cur.execute(check_all_time_sql, (user_id,))
    has_all_time = cur.fetchone()

    if not has_all_time:
        # Create All-Time challenges
        insert_challenge_sql = load_sql_query('insert_challenge.sql')
        for challenge in CHALLENGE_TEMPLATES['All-Time']:
            cur.execute(insert_challenge_sql, (user_id, 'All-Time', challenge['title'], challenge['goal'], now, now))
        # Special case: Mark 'First Time' login challenge as complete immediately
        complete_first_time_sql = load_sql_query('complete_first_time_challenge.sql')
        cur.execute(complete_first_time_sql, (now, user_id))
        # After completing 'First Time', update 'Journey Master'
        update_journey_master(user_id, cur)

def update_journey_master(user_id, cur):
    """
    Calculates the number of completed All-Time challenges and updates Journey Master's progress.
    """
    # 1. Count completed, non-'Journey Master' All-Time challenges
    count_sql = load_sql_query('count_completed_all_time_challenges.sql')
    cur.execute(count_sql, (user_id,))
    
    row = cur.fetchone()

    if row:
        # Get the first value from the row dictionary (the actual count)
        completed_count = list(row.values())[0] 
    else:
        completed_count = 0

    # 2. Update Journey Master progress and status
    update_jm_sql = load_sql_query('update_journey_master_progress.sql')
    
    # Now passing an integer (completed_count) instead of a RealDictRow
    cur.execute(update_jm_sql, (completed_count, completed_count, user_id))