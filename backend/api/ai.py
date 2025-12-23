from flask import Blueprint, jsonify, request
from psycopg2.extras import RealDictCursor
from helper_functions import convert_dict_dates_to_iso8601
from utils.utilities import token_required, get_db_connection
from utils.sql_loader import load_sql_query
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


@ai_bp.route('/conversation-history', methods=['GET'])
@token_required
def get_conversation_history(user_id):
    """Fetch all conversation history for the user, ordered chronologically."""
    conn = None
    cur = None
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)

        sql_query = load_sql_query('select_ai_user_conversations.sql')
        cur.execute(sql_query, (user_id,))
        conversations = cur.fetchall()
        
        # Convert to message format expected by frontend
        messages = []
        for conv in conversations:
            messages.append({
                'role': 'user',
                'content': conv['message'],
                'timestamp': conv['created_at'].isoformat() if conv['created_at'] else None
            })
            messages.append({
                'role': 'assistant',
                'content': conv['response'],
                'timestamp': conv['created_at'].isoformat() if conv['created_at'] else None
            })
        
        return jsonify({
            "success": True,
            "messages": messages
        }), 200

    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({"success": False, "error": str(e)}), 500

    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()


@ai_bp.route('/workout-plans', methods=['GET'])
@token_required
def get_workout_plans(user_id):
    """Fetch all AI-generated workout plans for the user."""
    conn = None
    cur = None
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)

        sql_query = load_sql_query('select_ai_user_workout_plans.sql')
        cur.execute(sql_query, (user_id,))
        plans = cur.fetchall()

        return jsonify({
            "success": True,
            "plans": convert_dict_dates_to_iso8601(plans)
        }), 200

    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({"success": False, "error": str(e)}), 500

    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()


@ai_bp.route('/workout-plans/<int:plan_id>', methods=['GET'])
@token_required
def get_workout_plan(user_id, plan_id):
    """Fetch a specific AI-generated workout plan with full details."""
    conn = None
    cur = None
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)

        sql_query = load_sql_query('select_ai_workout_plan_by_id.sql')
        cur.execute(sql_query, (plan_id, user_id))
        plan = cur.fetchone()

        if not plan:
            return jsonify({"success": False, "error": "Workout plan not found"}), 404

        return jsonify({
            "success": True,
            "plan": convert_dict_dates_to_iso8601(dict(plan))
        }), 200

    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({"success": False, "error": str(e)}), 500

    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()


@ai_bp.route('/conversations', methods=['DELETE'])
@token_required
def delete_all_conversations(user_id):
    """Delete all conversation history for the user."""
    conn = None
    cur = None
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)

        # First count conversations to delete
        count_query = load_sql_query('count_ai_user_conversations.sql')
        cur.execute(count_query, (user_id,))
        count_result = cur.fetchone()
        deleted_count = count_result.get('count', 0) if count_result else 0

        # Delete all conversations
        delete_query = load_sql_query('delete_ai_user_conversations.sql')
        cur.execute(delete_query, (user_id,))
        conn.commit()

        return jsonify({
            "success": True,
            "message": f"Deleted {deleted_count} conversations",
            "deleted_count": deleted_count
        }), 200

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


@ai_bp.route('/workout-plans/<int:plan_id>', methods=['DELETE'])
@token_required
def delete_workout_plan(user_id, plan_id):
    """Delete a specific AI-generated workout plan."""
    conn = None
    cur = None
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)

        # Verify ownership before deletion
        verify_query = load_sql_query('verify_ai_workout_plan_ownership.sql')
        cur.execute(verify_query, (plan_id, user_id))
        
        if not cur.fetchone():
            return jsonify({"success": False, "error": "Workout plan not found"}), 404

        # Delete the plan
        delete_query = load_sql_query('delete_ai_workout_plan_by_id.sql')
        cur.execute(delete_query, (plan_id, user_id))
        conn.commit()

        return jsonify({
            "success": True,
            "message": "Workout plan deleted successfully"
        }), 200

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


@ai_bp.route('/stats', methods=['GET'])
@token_required
def get_ai_stats(user_id):
    """Get AI interaction statistics for the user."""
    conn = None
    cur = None
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)

        # Get conversation stats
        conv_query = load_sql_query('select_ai_conversation_stats.sql')
        cur.execute(conv_query, (user_id,))
        conv_stats = cur.fetchone()

        # Get workout plan stats
        plan_query = load_sql_query('select_ai_workout_plan_stats.sql')
        cur.execute(plan_query, (user_id,))
        plan_stats = cur.fetchone()

        stats = {
            "total_conversations": conv_stats.get('total_conversations', 0) if conv_stats else 0,
            "last_conversation_at": conv_stats.get('last_conversation_at') if conv_stats else None,
            "total_plans_generated": plan_stats.get('total_plans_generated', 0) if plan_stats else 0,
            "plans_completed": plan_stats.get('plans_completed', 0) if plan_stats else 0,
            "avg_feedback_rating": float(plan_stats.get('avg_feedback_rating', 0) or 0) if plan_stats else 0
        }

        return jsonify({
            "success": True,
            "stats": convert_dict_dates_to_iso8601(stats)
        }), 200

    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({"success": False, "error": str(e)}), 500

    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()

