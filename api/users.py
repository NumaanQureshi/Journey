from flask import Blueprint, jsonify, request
from psycopg2.extras import RealDictCursor
from functools import wraps

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
        return jsonify({"success": True, "users": users})
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
            return jsonify({"success": True, "user": user})
        else:
            return jsonify({"success": False, "error": "User not found"}), 404
    except Exception as e:
        return jsonify({"success": False, "error": str(e)})

# GET current user
@users_bp.route('/me', methods=['GET'])
@token_required
def get_current_user(user_id):
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        sql_query = load_sql_query('select_user_by_id.sql')
        cur.execute(sql_query, (user_id,))
        user = cur.fetchone()
        cur.close()
        conn.close()
        if user:
            return jsonify({"success": True, "user": user})
        else:
            return jsonify({"success": False, "error": "User not found"}), 404
    except Exception as e:
        return jsonify({"success": False, "error": str(e)})

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