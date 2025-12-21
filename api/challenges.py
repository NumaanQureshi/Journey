from flask import Blueprint, jsonify, request
from psycopg2.extras import RealDictCursor
from helper_functions import convert_dict_dates_to_iso8601

# Assuming these are now in your helper_functions or a new utils file
# (Adjust import paths based on your actual file locations)
from utils.utilities import token_required, get_db_connection
from utils.sql_loader import load_sql_query

# Assuming you moved the generation and update logic to services/challenge_service.py
from services.challenge_service import _ensure_current_challenges, update_journey_master

challenge_bp = Blueprint('challenges', __name__)

# QUERY user challenges
@challenge_bp.route('/', methods=['GET'])
@token_required
def get_user_challenges(user_id):
    """
    Retrieves all active daily, weekly, and all-time challenges for the user.
    """
    conn = None
    cur = None
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)

        _ensure_current_challenges(user_id, cur)
        conn.commit()

        get_challenges = load_sql_query('select_user_challenges.sql')
        cur.execute(get_challenges, (user_id,))
        
        challenges = cur.fetchall()

        challenges_data = []
        for row in challenges:
            challenge_dict = dict(row)
            
            # convert to float for json compatibility
            if 'goal' in challenge_dict:
                challenge_dict['goal'] = float(challenge_dict['goal'])
            if 'current_progress' in challenge_dict:
                challenge_dict['current_progress'] = float(challenge_dict['current_progress'])
            
            challenges_data.append(challenge_dict)

        return jsonify({
            'success': True,
            'challenges': convert_dict_dates_to_iso8601(challenges)
        }), 200

    except Exception as e:
        if conn:
            conn.rollback()
        import traceback
        traceback.print_exc()
        return jsonify({'success': False, 'error': f'Failed to fetch challenges: {str(e)}'}), 500

    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()

@challenge_bp.route('/<int:challenge_instance_id>', methods=['PUT'])
@token_required
def update_challenge_progress(user_id, challenge_instance_id):
    """
    Updates the progress of a specific challenge instance.
    """
    conn = None
    cur = None
    try:
        data = request.get_json()
        # The client sends an increment value, not the new total progress.
        increment = data.get('increment', 1) # Default to incrementing by 1
        if not isinstance(increment, (int, float)) or increment <= 0:
            return jsonify({'success': False, 'error': 'Invalid increment value'}), 400
 
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
 
        # 1. Get current challenge state
        select_challenge_sql = load_sql_query('select_challenge_for_update.sql')
        cur.execute(select_challenge_sql, (challenge_instance_id, user_id))
        challenge = cur.fetchone()
 
        if not challenge:
            return jsonify({'success': False, 'error': 'Challenge not found or does not belong to user'}), 404
 
        if challenge['is_completed']:
            # Return a success response but indicate no change was made.
            return jsonify({'success': True, 'message': 'Challenge is already completed'}), 200
 
        # 2. Calculate new progress and completion status
        new_progress = challenge['current_progress'] + increment
        is_completed = new_progress >= challenge['goal']
        if is_completed:
            new_progress = challenge['goal'] # Clamp progress to goal
 
        # 3. Update the challenge in the database
        update_challenge_sql = load_sql_query('update_challenge_progress.sql')
        cur.execute(update_challenge_sql, (new_progress, is_completed, challenge_instance_id, user_id))
 
        conn.commit()
 
        # 4. If an All-Time challenge was just completed, update Journey Master
        if is_completed:
            select_challenge_type_sql = load_sql_query('select_challenge_type.sql')
            cur.execute(select_challenge_type_sql, (challenge_instance_id,))
            challenge_type = cur.fetchone()['challenge_type']
            if challenge_type == 'All-Time':
                update_journey_master(user_id, cur)
                conn.commit()
 
        return jsonify({
            'success': True,
            'message': 'Challenge progress updated successfully'
        }), 200

    except Exception as e:
        if conn:
            conn.rollback()
        import traceback
        traceback.print_exc()
        return jsonify({'success': False, 'error': f'Failed to update challenge: {str(e)}'}), 500

    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()