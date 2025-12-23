from flask import Blueprint, jsonify, request
from psycopg2.extras import RealDictCursor
from functools import wraps
from helper_functions import convert_dict_dates_to_iso8601

# Assuming these are now in your helper_functions or a new utils file
from utils.utilities import token_required, get_db_connection
from utils.sql_loader import load_sql_query

# Define the Blueprint
users_bp = Blueprint('users', __name__)

# GET all users
@users_bp.route('/', methods=['GET'])
@token_required
def get_all_users(user_id=None):
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        sql_query = load_sql_query('select_all_users.sql')        
        cur.execute(sql_query)
        
        users = cur.fetchall()
        cur.close()
        conn.close()
        return jsonify({"success": True, "users": convert_dict_dates_to_iso8601(users)})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)})

# GET single user by ID
@users_bp.route('/<int:user_id>', methods=['GET'])
@token_required
def get_user(user_id):
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        sql_query = load_sql_query('select_user_by_id.sql')
        cur.execute(sql_query, (user_id,))
        user = cur.fetchone()
        cur.close()
        conn.close()
        if user:
            return jsonify({"success": True, "user": convert_dict_dates_to_iso8601(user)})
        else:
            return jsonify({"success": False, "error": "User not found"}), 404
    except Exception as e:
        return jsonify({"success": False, "error": str(e)})

# GET current user with full profile info
@users_bp.route('/me', methods=['GET'])
@token_required
def get_current_user(user_id):
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        sql_query = load_sql_query('select_full_user_profile.sql')
        cur.execute(sql_query, (user_id,))
        profile = cur.fetchone()
        cur.close()
        conn.close()
        if profile:
            return jsonify({"success": True, "profile": convert_dict_dates_to_iso8601(profile)})
        else:
            return jsonify({"success": False, "error": "User not found"}), 404
    except Exception as e:
        return jsonify({"success": False, "error": str(e)})

# UPDATE current user's profile
@users_bp.route('/me', methods=['PUT'])
@token_required
def update_current_user(user_id):
    conn = None
    cur = None
    try:
        data = request.form
        
        conn = get_db_connection()
        cur = conn.cursor()

        # name
        user_name = data.get('name')

        # date of birth
        dob_iso = data.get('dob')
                
        # gender
        gender = data.get('gender')
        
        # exercise focus
        main_focus = data.get('main_focus')

        # intensity
        activity_intensity = data.get('activity_intensity')

        # Height and Weight Conversion (to Imperial)
        unit_system = data.get('unit_system', 'imperial')
        
        # height
        height_raw = data.get('height')
        height_in = None
        if height_raw is not None:
            height_float = float(height_raw)
            if unit_system == 'metric':
                # convert to inches: 1 cm = 0.393701 in
                height_in = round(height_float * 0.393701, 2)
            else: # imperial
                height_in = height_float

        # weight
        weight_raw = data.get('weight')
        weight_lb = None
        if weight_raw is not None:
            weight_float = float(weight_raw)
            if unit_system == 'metric':
                # convert to pounds: 1 kg = 2.20462 lb
                weight_lb = round(weight_float * 2.20462, 2)
            else: # imperial
                weight_lb = weight_float
        
        # goal weight
        goal_weight_raw = data.get('goal_weight')
        goal_weight_lb = None
        if goal_weight_raw is not None:
            goal_weight_float = float(goal_weight_raw)
            if unit_system == 'metric':
                # Convert to pounds: 1 kg = 2.20462 lb
                goal_weight_lb = round(goal_weight_float * 2.20462, 2)
            else: # imperial
                goal_weight_lb = goal_weight_float

        # update profile
        update_profile_sql = load_sql_query('update_profile.sql')
        cur.execute(
            update_profile_sql,
            (
                user_name,
                dob_iso,
                gender,
                height_in,
                weight_lb,
                goal_weight_lb,
                main_focus,
                activity_intensity,
                user_id
            )
        )
        
        # update updated_at timestamp
        cur.execute("UPDATE users SET updated_at = NOW() WHERE id = %s;", (user_id,))

        select_updated_user_sql = load_sql_query('select_updated_user.sql')
        cur.execute(select_updated_user_sql, (user_id,))

        user = cur.fetchone()
        conn.commit()

        if not user:
            return jsonify({
                'success': False,
                'error': 'User not found'
            }), 404

        user_dict = {
            'id': user[0],
            'email': user[1],
            'date_of_birth': user[2],
            'gender': user[3],
            'height_in': user[4],
            'weight_lb': user[5],
            'updated_at': user[6],
            'name': user[7] if len(user) > 7 else None,
            'goal_weight_lb': user[8] if len(user) > 8 else None,
            'main_focus': user[9] if len(user) > 9 else None,
            'activity_intensity': user[10] if len(user) > 10 else None,
        }

        return jsonify({
            'success': True,
            'message': 'Profile updated successfully',
            'user': convert_dict_dates_to_iso8601(user_dict)
        }), 200

    except Exception as e:
        if conn:
            conn.rollback()
        import traceback
        traceback.print_exc() 
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()

# DELETE user
@users_bp.route('/<int:user_id>', methods=['DELETE'])
@token_required
def delete_user(user_id):
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('DELETE FROM users WHERE id = %s;', (user_id,))
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"success": True, "message": "User deleted"})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)})