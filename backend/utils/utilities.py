from flask import jsonify, request, current_app
import psycopg2
import jwt                      # Encode / Decode
from functools import wraps
import os

DATABASE_URL = os.getenv("DATABASE_URL")

def get_db_connection():
    conn = psycopg2.connect(DATABASE_URL)
    return conn

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        
        # FEATURE FLAG -> Allows us to skip auth when testing frontend
        # DEFAULT DEBUG USERID = 4, EMAIL: debug@example.com
        if current_app.config.get('SKIP_AUTH_DEBUG'):
            debug_user_id = current_app.config.get('DEBUG_USER_ID')
            if debug_user_id is None:
                # error if no env variable is set
                print("ERROR: AUTH BYPASS ON BUT DEBUG_USER_ID NOT SET")
                return jsonify({'success': False, 'error': 'set DEBUG_USER_ID in .env'}), 500
            print(f"DEBUG MODE: AUTH BYPASSED for User ID: {debug_user_id}")
            try:
                user_id = int(debug_user_id)
                # Only inject user_id if not already in kwargs (from URL parameter)
                if 'user_id' not in kwargs:
                    kwargs['user_id'] = user_id
                return f(*args, **kwargs) # returns debug user
            # ensure debug user is int = 4
            except ValueError:
                return jsonify({'success': False, 'error': 'DEBUG_USER_ID must be an integer'}), 500

        token = None
        # Extract token from header
        if 'Authorization' in request.headers:
            token = request.headers['Authorization'].split(" ")[1]  # Expect "Bearer <token>"

        if not token:
            return jsonify({'success': False, 'error': 'Token is missing!'}), 401

        try:
            secret_key = current_app.config.get('JWT_SECRET_KEY') 
            if not secret_key:
                raise jwt.InvalidTokenError
                
            data = jwt.decode(token, secret_key, algorithms=['HS256'])
            user_id = data['user_id']
        except jwt.ExpiredSignatureError:
            return jsonify({'success': False, 'error': 'Token has expired!'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'success': False, 'error': 'Invalid token!'}), 401

        # Only inject user_id if not already in kwargs (from URL parameter)
        if 'user_id' not in kwargs:
            kwargs['user_id'] = user_id
        return f(*args, **kwargs)

    return decorated

def get_db_connection():
    conn = psycopg2.connect(DATABASE_URL)
    return conn