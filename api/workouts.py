from flask import Blueprint, jsonify, request
from psycopg2.extras import RealDictCursor
from utils.utilities import token_required, get_db_connection
from utils.sql_loader import load_sql_query
from helper_functions import convert_dict_dates_to_iso8601
import datetime

workouts_bp = Blueprint('workouts', __name__)

# ===================== Exercise Library =====================

# GET all exercises
@workouts_bp.route('/exercises', methods=['GET'])
def get_all_exercises():
    """Get all exercises with optional pagination."""
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        limit = request.args.get('limit', 500, type=int)
        offset = request.args.get('offset', 0, type=int)
        
        # Limit to reasonable pagination
        limit = min(limit, 500)
        
        sql_query = load_sql_query('select_all_exercises.sql')
        cur.execute(sql_query, (limit, offset))
        
        exercises = cur.fetchall()
        cur.close()
        conn.close()
        
        return jsonify({"success": True, "exercises": convert_dict_dates_to_iso8601(exercises)}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


# GET exercise by ID
@workouts_bp.route('/exercises/<int:exercise_id>', methods=['GET'])
def get_exercise(exercise_id):
    """Get a specific exercise with full details."""
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        sql_query = load_sql_query('select_exercise_by_id.sql')
        cur.execute(sql_query, (exercise_id,))
        
        exercise = cur.fetchone()
        cur.close()
        conn.close()
        
        if not exercise:
            return jsonify({"success": False, "error": "Exercise not found"}), 404
        
        return jsonify({"success": True, "exercise": convert_dict_dates_to_iso8601(exercise)}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


# ===================== User Planning and Customization =====================

# GET user's programs
@workouts_bp.route('/programs', methods=['GET'])
@token_required
def get_programs(user_id):
    """Get all programs for the authenticated user."""
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        sql_query = load_sql_query('select_programs_by_user.sql')
        cur.execute(sql_query, (user_id,))
        
        programs = cur.fetchall()
        cur.close()
        conn.close()
        
        return jsonify({"success": True, "programs": convert_dict_dates_to_iso8601(programs)}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


# CREATE a new program
@workouts_bp.route('/programs', methods=['POST'])
@token_required
def create_program(user_id):
    """Create a new workout program."""
    try:
        data = request.get_json()
        name = data.get('name')
        description = data.get('description', '')
        
        if not name:
            return jsonify({"success": False, "error": "Program name is required"}), 400
        
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        sql_query = load_sql_query('insert_program.sql')
        cur.execute(sql_query, (user_id, name, description, False))
        
        program = cur.fetchone()
        conn.commit()
        cur.close()
        conn.close()
        
        return jsonify({"success": True, "program": convert_dict_dates_to_iso8601(program)}), 201
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


# UPDATE a program
@workouts_bp.route('/programs/<int:program_id>', methods=['PUT'])
@token_required
def update_program(user_id, program_id):
    """Update an existing workout program."""
    try:
        data = request.get_json()
        name = data.get('name')
        description = data.get('description')
        is_active = data.get('is_active')
        
        if not name:
            return jsonify({"success": False, "error": "Program name is required"}), 400
        
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        # Verify user owns this program
        sql_verify = load_sql_query('select_program_by_id.sql')
        cur.execute(sql_verify, (program_id,))
        program = cur.fetchone()
        if not program or program['user_id'] != user_id:
            return jsonify({"success": False, "error": "Unauthorized"}), 403
        
        # Use existing values if not provided
        name = name if name is not None else program['name']
        description = description if description is not None else program['description']
        is_active = is_active if is_active is not None else program['is_active']
        
        sql_query = load_sql_query('update_program.sql')
        cur.execute(sql_query, (name, description, is_active, program_id))
        
        updated_program = cur.fetchone()
        conn.commit()
        cur.close()
        conn.close()
        
        return jsonify({"success": True, "program": convert_dict_dates_to_iso8601(updated_program)}), 200
    except Exception as e:
        if conn:
            conn.rollback()
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()


# DELETE a program
@workouts_bp.route('/programs/<int:program_id>', methods=['DELETE'])
@token_required
def delete_program(user_id, program_id):
    """Delete a workout program."""
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        # Verify user owns this program
        sql_verify = load_sql_query('select_program_by_id.sql')
        cur.execute(sql_verify, (program_id,))
        program = cur.fetchone()
        if not program or program['user_id'] != user_id:
            return jsonify({"success": False, "error": "Unauthorized"}), 403
        
        sql_query = load_sql_query('delete_program.sql')
        cur.execute(sql_query, (program_id,))
        
        deleted_program = cur.fetchone()
        conn.commit()
        cur.close()
        conn.close()
        
        return jsonify({"success": True, "message": "Program deleted successfully", "program_id": deleted_program['id']}), 200
    except Exception as e:
        if conn:
            conn.rollback()
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()


# GET workout templates for a program
@workouts_bp.route('/programs/<int:program_id>/templates', methods=['GET'])
@token_required
def get_templates(user_id, program_id):
    """Get all workout templates for a program."""
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        # Verify user owns this program
        sql_verify = load_sql_query('select_program_by_id.sql')
        cur.execute(sql_verify, (program_id,))
        program = cur.fetchone()
        if not program or program['user_id'] != user_id:
            return jsonify({"success": False, "error": "Unauthorized"}), 403
        
        sql_query = load_sql_query('select_workout_templates_by_program.sql')
        cur.execute(sql_query, (program_id,))
        
        templates = cur.fetchall()
        cur.close()
        conn.close()
        
        return jsonify({"success": True, "templates": convert_dict_dates_to_iso8601(templates)}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


# CREATE a new workout template
@workouts_bp.route('/programs/<int:program_id>/templates', methods=['POST'])
@token_required
def create_template(user_id, program_id):
    """Create a new workout template for a program."""
    try:
        data = request.get_json()
        name = data.get('name')
        day_order = data.get('day_order', 1)
        notes = data.get('notes', '')
        
        if not name:
            return jsonify({"success": False, "error": "Template name is required"}), 400
        
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        # Verify user owns this program
        sql_verify = load_sql_query('select_program_by_id.sql')
        cur.execute(sql_verify, (program_id,))
        program = cur.fetchone()
        if not program or program['user_id'] != user_id:
            return jsonify({"success": False, "error": "Unauthorized"}), 403
        
        sql_query = load_sql_query('insert_workout_template.sql')
        cur.execute(sql_query, (program_id, name, day_order, notes))
        
        template = cur.fetchone()
        conn.commit()
        cur.close()
        conn.close()
        
        return jsonify({"success": True, "template": convert_dict_dates_to_iso8601(template)}), 201
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


# UPDATE a workout template
@workouts_bp.route('/templates/<int:template_id>', methods=['PUT'])
@token_required
def update_template(user_id, template_id):
    """Update a workout template's name, notes, or day_order."""
    try:
        data = request.get_json()
        name = data.get('name')
        notes = data.get('notes')
        day_order = data.get('day_order')
        
        if not name:
            return jsonify({"success": False, "error": "Template name is required"}), 400
        
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        # Verify user owns this template via program ownership check
        sql_verify = load_sql_query('verify_template_owner_by_id.sql')
        cur.execute(sql_verify, (template_id,))
        result = cur.fetchone()
        if not result or result['user_id'] != user_id:
            return jsonify({"success": False, "error": "Unauthorized"}), 403
        
        # Get current template to use existing values if not provided
        sql_get = load_sql_query('select_template_by_id.sql')
        cur.execute(sql_get, (template_id,))
        template = cur.fetchone()
        
        name = name if name is not None else template['name']
        notes = notes if notes is not None else template['notes']
        day_order = day_order if day_order is not None else template['day_order']
        
        sql_query = load_sql_query('update_workout_template.sql')
        cur.execute(sql_query, (name, notes, day_order, template_id))
        
        updated_template = cur.fetchone()
        conn.commit()
        cur.close()
        conn.close()
        
        return jsonify({"success": True, "template": convert_dict_dates_to_iso8601(updated_template)}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


# DELETE a workout template
@workouts_bp.route('/templates/<int:template_id>', methods=['DELETE'])
@token_required
def delete_template(user_id, template_id):
    """Delete a workout template."""
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        # Verify user owns this template via program ownership check
        sql_verify = load_sql_query('verify_template_owner_by_id.sql')
        cur.execute(sql_verify, (template_id,))
        result = cur.fetchone()
        if not result or result['user_id'] != user_id:
            return jsonify({"success": False, "error": "Unauthorized"}), 403
        
        # Delete the template (cascading delete will remove template_exercises)
        sql_query = load_sql_query('delete_workout_template.sql')
        cur.execute(sql_query, (template_id,))
        
        deleted = cur.fetchone()
        conn.commit()
        cur.close()
        conn.close()
        
        return jsonify({"success": True, "message": "Template deleted successfully", "deleted_id": deleted['id']}), 200
    except Exception as e:
        if conn:
            conn.rollback()
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()


# GET exercises in a template
@workouts_bp.route('/templates/<int:template_id>/exercises', methods=['GET'])
@token_required
def get_template_exercises(user_id, template_id):
    """Get all exercises in a workout template."""
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        # Verify user owns this template via program ownership check
        sql_verify = load_sql_query('verify_template_owner_by_id.sql')
        cur.execute(sql_verify, (template_id,))
        result = cur.fetchone()
        if not result or result['user_id'] != user_id:
            return jsonify({"success": False, "error": "Unauthorized"}), 403
        
        sql_query = load_sql_query('select_template_exercises.sql')
        cur.execute(sql_query, (template_id,))
        
        exercises = cur.fetchall()
        cur.close()
        conn.close()
        
        return jsonify({"success": True, "exercises": convert_dict_dates_to_iso8601(exercises)}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


# ADD exercise to template
@workouts_bp.route('/templates/<int:template_id>/exercises', methods=['POST'])
@token_required
def add_template_exercise(user_id, template_id):
    """Add an exercise to a workout template."""
    try:
        data = request.get_json()
        exercise_id = data.get('exercise_id')
        target_sets = data.get('target_sets', 3)
        target_reps = data.get('target_reps', '8-12')
        target_weight_lb = data.get('target_weight_lb')
        rest_seconds = data.get('rest_seconds', 60)
        order_index = data.get('order_index', 0)
        
        if not exercise_id:
            return jsonify({"success": False, "error": "exercise_id is required"}), 400
        
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        # Verify user owns this template
        sql_verify = load_sql_query('verify_template_owner_by_id.sql')
        cur.execute(sql_verify, (template_id,))
        result = cur.fetchone()
        if not result or result['user_id'] != user_id:
            return jsonify({"success": False, "error": "Unauthorized"}), 403
        
        sql_query = load_sql_query('insert_template_exercise.sql')
        cur.execute(sql_query, (template_id, exercise_id, target_sets, target_reps, target_weight_lb, rest_seconds, order_index))
        
        template_exercise = cur.fetchone()
        conn.commit()
        cur.close()
        conn.close()
        
        return jsonify({"success": True, "template_exercise": convert_dict_dates_to_iso8601(template_exercise)}), 201
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


# REMOVE exercise from template
@workouts_bp.route('/templates/<int:template_id>/exercises/<int:template_exercise_id>', methods=['DELETE'])
@token_required
def remove_template_exercise(user_id, template_id, template_exercise_id):
    """Remove an exercise from a workout template."""
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        # Verify user owns this template
        sql_verify = load_sql_query('verify_template_owner_by_id.sql')
        cur.execute(sql_verify, (template_id,))
        result = cur.fetchone()
        if not result or result['user_id'] != user_id:
            return jsonify({"success": False, "error": "Unauthorized"}), 403
        
        # Verify the template exercise belongs to this template
        cur.execute("""
            SELECT id FROM template_exercises 
            WHERE id = %s AND template_id = %s
        """, (template_exercise_id, template_id))
        
        if not cur.fetchone():
            return jsonify({"success": False, "error": "Template exercise not found"}), 404
        
        # Delete the template exercise
        sql_query = load_sql_query('delete_template_exercise.sql')
        cur.execute(sql_query, (template_exercise_id,))
        
        deleted = cur.fetchone()
        conn.commit()
        cur.close()
        conn.close()
        
        return jsonify({"success": True, "message": "Exercise removed from template", "deleted_id": deleted['id']}), 200
    except Exception as e:
        if conn:
            conn.rollback()
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()


# ===================== User Workout and Sessions =====================

# CREATE a new workout session
@workouts_bp.route('/sessions', methods=['POST'])
@token_required
def create_session(user_id):
    """Start a new workout session from a template."""
    try:
        data = request.get_json()
        template_id = data.get('template_id')
        
        if not template_id:
            return jsonify({"success": False, "error": "template_id is required"}), 400
        
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        # Verify template exists and user has access
        sql_verify = load_sql_query('verify_template_owner_by_id.sql')
        cur.execute(sql_verify, (template_id,))
        result = cur.fetchone()
        if not result or result['user_id'] != user_id:
            return jsonify({"success": False, "error": "Unauthorized"}), 403
        
        # Create the session
        sql_query = load_sql_query('insert_workout_session.sql')
        cur.execute(sql_query, (user_id, template_id, ''))
        session = cur.fetchone()
        session_id = session[0]
        
        # Pre-fill sets from template
        sql_get_exercises = load_sql_query('select_template_exercises.sql')
        cur.execute(sql_get_exercises, (template_id,))
        
        template_exercises = cur.fetchall()
        
        for te in template_exercises:
            for set_num in range(1, te['target_sets'] + 1):
                cur.execute("""
                    INSERT INTO workout_sets (session_id, exercise_id, set_number)
                    VALUES (%s, %s, %s)
                """, (session_id, te['exercise_id'], set_num))
        
        conn.commit()
        
        return jsonify({"success": True, "session": {"id": session_id}}), 201
    except Exception as e:
        if conn:
            conn.rollback()
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()


# GET current session details
@workouts_bp.route('/sessions/<int:session_id>', methods=['GET'])
@token_required
def get_session(user_id, session_id):
    """Get details of a specific workout session."""
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        # Get session and verify ownership
        sql_query = load_sql_query('select_workout_session.sql')
        cur.execute(sql_query, (session_id, user_id))
        session = cur.fetchone()
        if not session:
            return jsonify({"success": False, "error": "Session not found"}), 404
        
        # Get all sets for this session
        sql_sets = load_sql_query('select_workout_sets.sql')
        cur.execute(sql_sets, (session_id,))
        sets = cur.fetchall()
        cur.close()
        conn.close()
        
        return jsonify({"success": True, "session": convert_dict_dates_to_iso8601(dict(session)), "sets": convert_dict_dates_to_iso8601(sets)}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


# GET user's recent sessions
@workouts_bp.route('/sessions', methods=['GET'])
@token_required
def get_sessions(user_id):
    """Get all workout sessions for the user."""
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        limit = request.args.get('limit', 20, type=int)
        
        sql_query = load_sql_query('select_user_sessions.sql')
        cur.execute(sql_query, (user_id, limit))
        
        sessions = cur.fetchall()
        cur.close()
        conn.close()
        
        return jsonify({"success": True, "sessions": convert_dict_dates_to_iso8601(sessions)}), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


# ===================== Session Logging =====================

# LOG a set
@workouts_bp.route('/sessions/<int:session_id>/sets', methods=['POST'])
@token_required
def log_set(user_id, session_id):
    """Log a new set during a workout."""
    try:
        data = request.get_json()
        exercise_id = data.get('exercise_id')
        set_number = data.get('set_number')
        reps_completed = data.get('reps_completed')
        weight_lb = data.get('weight_lb')
        rpe = data.get('rpe')
        is_warmup = data.get('is_warmup', False)
        
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Verify user owns this session
        sql_verify = load_sql_query('select_session_owner.sql')
        cur.execute(sql_verify, (session_id,))
        session = cur.fetchone()
        if not session or session[0] != user_id:
            return jsonify({"success": False, "error": "Unauthorized"}), 403
        
        # Insert the set
        sql_query = load_sql_query('insert_workout_set.sql')
        cur.execute(sql_query, (session_id, exercise_id, set_number, reps_completed, weight_lb, rpe, is_warmup))
        
        new_set = cur.fetchone()
        conn.commit()
        cur.close()
        conn.close()
        
        return jsonify({"success": True, "set": {"id": new_set[0]}}), 201
    except Exception as e:
        if conn:
            conn.rollback()
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()


# UPDATE a set
@workouts_bp.route('/sets/<int:set_id>', methods=['PUT'])
@token_required
def update_set(user_id, set_id):
    """Update a logged set."""
    try:
        data = request.get_json()
        reps_completed = data.get('reps_completed')
        weight_lb = data.get('weight_lb')
        rpe = data.get('rpe')
        
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Verify user owns this set (through session)
        sql_verify = load_sql_query('verify_set_owner.sql')
        cur.execute(sql_verify, (set_id, user_id))
        
        if not cur.fetchone():
            return jsonify({"success": False, "error": "Unauthorized"}), 403
        
        # Update the set
        sql_query = load_sql_query('update_workout_set.sql')
        cur.execute(sql_query, (reps_completed, weight_lb, rpe, set_id))
        
        updated_set = cur.fetchone()
        conn.commit()
        cur.close()
        conn.close()
        
        return jsonify({"success": True, "set": convert_dict_dates_to_iso8601(dict(updated_set))}), 200
    except Exception as e:
        if conn:
            conn.rollback()
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()


# ===================== Completion and Analysis =====================

# COMPLETE a workout session
@workouts_bp.route('/sessions/<int:session_id>/complete', methods=['PUT'])
@token_required
def complete_session(user_id, session_id):
    """Complete a workout session and calculate stats."""
    try:
        data = request.get_json()
        notes = data.get('notes', '')
        
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        # Verify user owns this session
        sql_verify = load_sql_query('select_session_owner.sql')
        cur.execute(sql_verify, (session_id,))
        session = cur.fetchone()
        if not session or session['user_id'] != user_id:
            return jsonify({"success": False, "error": "Unauthorized"}), 403
        
        # Calculate total volume and duration
        sql_stats = load_sql_query('select_session_stats.sql')
        cur.execute(sql_stats, (session_id,))
        stats = cur.fetchone()
        total_volume = float(stats['total_volume_lb']) if stats['total_volume_lb'] else 0
        
        # Get start time and calculate duration
        sql_get_time = load_sql_query('select_session_start_time.sql')
        cur.execute(sql_get_time, (session_id,))
        session_data = cur.fetchone()
        start_time = session_data['start_time']
        end_time = datetime.datetime.now(datetime.timezone.utc)
        duration_min = int((end_time - start_time).total_seconds() / 60)
        
        # Estimate calories (rough formula: 5 calories per 1000 lbs volume + 3 per minute)
        calories_burned = int((total_volume / 1000 * 5) + (duration_min * 3))
        
        # Update session
        sql_update = load_sql_query('update_workout_session_complete.sql')
        cur.execute(sql_update, (end_time, duration_min, total_volume, calories_burned, notes, session_id))
        
        completed_session = cur.fetchone()
        conn.commit()
        cur.close()
        conn.close()
        
        return jsonify({
            "success": True, 
            "session": convert_dict_dates_to_iso8601(dict(completed_session)),
            "stats": {
                "total_volume_lb": total_volume,
                "calories_burned": calories_burned,
                "duration_min": duration_min
            }
        }), 200
    except Exception as e:
        if conn:
            conn.rollback()
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()
