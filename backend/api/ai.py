from flask import Blueprint, jsonify, request
from psycopg2.extras import RealDictCursor
from backend.helper_functions import convert_dict_dates_to_iso8601
from utils.utilities import token_required, get_db_connection
from utils.helper_functions import calculate_age
from services.ai_service import (
    fitness_ai_agent,
    get_user_profile,
    get_user_workout_history,
    get_user_strength_progress,
    save_ai_workout_plan,
    get_recent_soreness_data,
    save_ai_conversation,
    update_workout_plan_feedback
)

ai_bp = Blueprint('ai', __name__)


@ai_bp.route('/personalized-workout', methods=['POST'])
@token_required
def generate_personalized_workout(user_id):
    conn = None
    cur = None
    try:
        data = request.get_json()

        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)

        # Fetch complete user context
        profile = get_user_profile(user_id, cur)
        workout_history = get_user_workout_history(user_id, cur, limit=10)
        strength_progress = get_user_strength_progress(user_id, cur)
        recent_soreness = get_recent_soreness_data(user_id, cur)

        # Calculate age from date_of_birth
        age = None
        if profile.get('date_of_birth'):
            try:
                dob = profile.get('date_of_birth')
                age = calculate_age(dob.year, dob.month, dob.day)
            except Exception:
                age = None

        # Build user data
        user_data = {
            'user_id': user_id,
            'name': profile.get('name'),
            'fitness_level': profile.get('fitness_level', 'intermediate'),
            'age': age,
            'weight': profile.get('weight_lb'),
            'height': profile.get('height_in'),
            'goals': [profile.get('main_focus')] if profile.get('main_focus') else [],
            'injuries': profile.get('injuries'),
            'available_equipment': profile.get('available_equipment', []),
            'workout_days': profile.get('preferred_workout_days', 3),
            'workout_history': workout_history,
            'strength_progress': strength_progress,
            'fatigue_level': data.get('fatigue_level', 5),
            'soreness': data.get('soreness', recent_soreness),
            'energy_level': data.get('energy_level', 'moderate')
        }

        workout_request = {
            'goal': data.get('goal', profile.get('main_focus', 'general fitness')),
            'focus_areas': data.get('focus_areas', ['full body']),
            'duration_minutes': data.get('duration_minutes', 45),
            'energy_level': data.get('energy_level', 'moderate')
        }

        result = fitness_ai_agent.generate_personalized_workout(user_data, workout_request)

        if result['success']:
            plan_id = save_ai_workout_plan(
                user_id,
                workout_request['goal'],
                result['workout'],
                cur
            )
            conn.commit()
            result['plan_id'] = plan_id

        return jsonify(convert_dict_dates_to_iso8601(result)), 200 if result['success'] else 500

    except Exception as e:
        if conn:
            conn.rollback()
        import traceback
        traceback.print_exc()
        return jsonify({"success": False, "error": str(e)}), 500

    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()


@ai_bp.route('/chat', methods=['POST'])
@token_required
def chat_with_trainer(user_id):
    conn = None
    cur = None
    try:
        data = request.get_json()

        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)

        profile = get_user_profile(user_id, cur)
        workout_history = get_user_workout_history(user_id, cur, limit=5)
        strength_progress = get_user_strength_progress(user_id, cur)

        user_data = {
            **profile,
            'workout_history': workout_history,
            'strength_progress': strength_progress
        }

        result = fitness_ai_agent.chat_with_trainer(
            user_data=user_data,
            message=data.get('message'),
            conversation_history=data.get('conversation_history', [])
        )

        # Save conversation
        if result['success']:
            save_ai_conversation(user_id, data.get('message'), result['response'], cur)
            conn.commit()

        return jsonify(convert_dict_dates_to_iso8601(result)), 200 if result['success'] else 500

    except Exception as e:
        if conn:
            conn.rollback()
        import traceback
        traceback.print_exc()
        return jsonify({"success": False, "error": str(e)}), 500

    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()


