from flask import Blueprint, jsonify, request, current_app
import psycopg2
import bcrypt
import jwt                      # Encode / Decode
import datetime
from helper_functions import convert_dict_dates_to_iso8601
from utils.utilities import get_db_connection, token_required
from utils.helper_functions import calculate_age, generate_reset_token
from utils.sql_loader import load_sql_query
from services.challenge_service import _ensure_current_challenges
from services.email_service import send_email

auth_bp = Blueprint('auth', __name__)


# CREATE new user
@auth_bp.route('/register', methods=['POST'])
def register():
    conn = None
    cur = None
    try:
        user_login_info = request.get_json()
        if not user_login_info.get('email'):
            return jsonify({'success': False, 'error': 'Email is required'}), 400
        if not user_login_info.get('password'):
            return jsonify({'success': False, 'error': 'Password is required'}), 400
        if not user_login_info.get('username'):
            return jsonify({'success': False, 'error': 'Username is required'}), 400
        password = user_login_info['password']
        if len(password) < 8: #For security purposes, we want a secure password that's at least 8 characters long
            return jsonify({
                'success': False,
                'error': 'Password must be at least 8 characters long'
            }), 400
        password_hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
        conn = get_db_connection()
        cur = conn.cursor()
        insert_user_sql = load_sql_query('insert_user_core.sql')
        print(f"DEBUG: SQL Query: {insert_user_sql}")
        cur.execute(insert_user_sql,
            (
                user_login_info['email'].lower(),
                password_hash,
                user_login_info['username']
            )
        )
        result = cur.fetchone()
        print(f"DEBUG: fetchone() result: {result}")
        if result is None:
            print("DEBUG: ERROR - fetchone() returned None!")
            raise Exception("Failed to retrieve user_id from insert")
        user_id = result[0]
        print(f"DEBUG: Successfully retrieved user_id: {user_id}")
        
        insert_profile_sql = load_sql_query('insert_profile.sql')
        print(f"DEBUG: About to insert profile...")
        cur.execute(
            insert_profile_sql,
            (
                user_id,
                user_login_info.get('date_of_birth'),
                user_login_info.get('gender'),
                user_login_info.get('height_in'),
                user_login_info.get('weight_lb')
            )
        )
        print(f"DEBUG: Profile inserted successfully")
        
        insert_leaderboard_sql = load_sql_query('insert_leaderboard.sql')
        print(f"DEBUG: About to insert leaderboard...")
        cur.execute(
            insert_leaderboard_sql, 
            (user_id,)
             # all other aspects of the leaderboard are defaulted to 0
        )
        print(f"DEBUG: Leaderboard inserted successfully")
        
        print(f"DEBUG: About to ensure current challenges...")
        # initialize user challenges
        try:
            _ensure_current_challenges(user_id, cur)
            print(f"DEBUG: Current challenges ensured successfully")
        except Exception as e:
            print(f"DEBUG: Error ensuring current challenges: {e}")
            raise

        conn.commit()
        
        token = jwt.encode(
            {
            'user_id': user_id,
            'exp': datetime.datetime.now(datetime.UTC) + datetime.timedelta(days=7)
            },
            current_app.config['JWT_SECRET_KEY'],
            algorithm='HS256'
        )
        return jsonify({
            'success': True,
            'message': 'Registration successful',
            'user': {
                'id': user_id,
                'email': user_login_info['email'],
                'username': user_login_info['username'],
                'date_of_birth': user_login_info.get('date_of_birth'),
                'gender': user_login_info.get('gender'),
                'height_in': user_login_info.get('height_in'),
                'weight_lb': user_login_info.get('weight_lb'),
            },
            'token': token
        }), 201
    except psycopg2.errors.UniqueViolation as e:
        if conn:
            conn.rollback()
        error_msg = str(e)
        if 'email' in error_msg:
            return jsonify({
                'success': False,
                'error': 'Email already exists'
            }), 400
        if 'username' in error_msg:
            return jsonify({
                'success': False,
                'error': 'Username already exists'
            }), 400
        return jsonify({
            'success': False,
            'error': 'User already exists'
        }), 400

    except Exception as e:
        if conn:
            conn.rollback()
        return jsonify({
            'success': False,
            'error': f'Registration failed: {str(e)}'
        }), 500

    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()


@auth_bp.route('/login', methods=['POST'])
def login():
    conn = None
    cur = None

    try:
        data = request.get_json()
        email = data.get('email')
        password = data.get('password')

        if not email or not password:
            return jsonify({
                'success': False,
                'error': 'Email and password are required'
            }), 400
        conn = get_db_connection()
        cur = conn.cursor()
        # get user from database
        sql_query = load_sql_query('select_user_for_login.sql')
        cur.execute(
            sql_query, 
            (email,)
        )
        user = cur.fetchone()
        # check if exists
        if not user:
            return jsonify({
                'success': False, 
                'error': 'Invalid email or password'
                }), 401
        user_id = user[0]
        password_hash = user[2]
        if not user:
            return jsonify({
                'success': False,
                'error': 'Invalid email or password'
            }), 401
        # verify password with bcrypt
        if not bcrypt.checkpw(
            password.encode('utf-8'), 
            password_hash if isinstance(password_hash, bytes) else password_hash.encode('utf-8')
        ):
            return jsonify({
                'success': False,
                'error': 'Invalid email or password'
            }), 401
        # create JWT token (expires in 7 days)
        token = jwt.encode(
            {
                'user_id': user_id,
                'exp': datetime.datetime.now(datetime.UTC) + datetime.timedelta(days=7)
            },
            current_app.config['JWT_SECRET_KEY'],
            algorithm='HS256'
        )
        # Remove password_hash from response
        user_data = {
            'id': user[0],
            'email': user[1],
            'username': user[3],
        }

        return jsonify({
            'success': True,
            'message': 'Login successful',
            'user': user_data,
            'token': token
        }), 200

    except Exception as e:
        print("--- DEBUGGING LOGIN ERROR ---")
        import traceback
        traceback.print_exc()
        print("-----------------------------")
        return jsonify({
            'success': False,
            'error': f'Login failed: {str(e)}'
        }), 500

    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()


@auth_bp.route('/forgot-password', methods=['POST'])
def forgot_password():
    conn = None
    cur = None
    try:
        data = request.get_json()
        email = data.get('email')

        if not email:
            return jsonify({'success': False, 'error': 'Email is required'}), 400

        conn = get_db_connection()
        cur = conn.cursor()

        # find user's email
        sql_query = load_sql_query('select_user_by_email.sql')
        cur.execute(sql_query, (email,))
        user = cur.fetchone()

        if not user:
            # obfuscation message
            return jsonify({
                'success': True,
                'message': 'If an account is associated with this email, a reset link has been sent.'
            }), 200

        user_id = user[0]
        reset_token = generate_reset_token(user_id)

        # 2. Construct the reset link (using the new env var)
        reset_link = f"{current_app.config['RESET_PASSWORD_URL']}?token={reset_token}"
        
        # 3. Define the email content
        subject = "Password Reset Request"
        body = f"You requested a password reset. Click the link to reset your password (expires in 1 hour): {reset_link}"

        # 4. Send the email
        success = send_email(email, subject, body)

        if not success:
             # Log the error but still tell the user to check their email
             print(f"Error sending email to {email}")

        return jsonify({
            'success': True,
            'message': 'If an account is associated with this email, a reset link has been sent.'
        }), 200

    except Exception as e:
        if conn: conn.rollback()
        import traceback
        traceback.print_exc()
        return jsonify({'success': False, 'error': f'Request failed: {str(e)}'}), 500
    finally:
        if cur: cur.close()
        if conn: conn.close()


@auth_bp.route('/reset-password', methods=['POST'])
def reset_password():
    conn = None
    cur = None
    try:
        data = request.get_json()
        token = data.get('token')
        new_password = data.get('new_password')

        if not token:
            return jsonify({'success': False, 'error': 'Reset token is missing'}), 400
        if not new_password or len(new_password) < 8:
            return jsonify({'success': False, 'error': 'New password must be at least 8 characters long'}), 400

        # validate jwt
        try:
            payload = jwt.decode(token, current_app.config['JWT_SECRET_KEY'], algorithms=['HS256'])
            if payload.get('token_type') != 'password_reset':
                raise jwt.InvalidTokenError
            user_id = payload['user_id']
        except jwt.ExpiredSignatureError:
            return jsonify({'success': False, 'error': 'Reset link has expired'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'success': False, 'error': 'Invalid reset token'}), 401

        # hash new pass
        new_password_hash = bcrypt.hashpw(
            new_password.encode('utf-8'),
            bcrypt.gensalt()
        ).decode('utf-8')

        conn = get_db_connection()
        cur = conn.cursor()

        # update user password
        cur.execute(
            '''
            UPDATE users 
            SET password_hash = %s, updated_at = NOW() 
            WHERE id = %s;
            ''',
            (new_password_hash, user_id)
        )
        
        # check if updated
        if cur.rowcount == 0:
            return jsonify({'success': False, 'error': 'User not found or password already reset'}), 404

        conn.commit()

        return jsonify({
            'success': True,
            'message': 'Password reset successfully. You can now log in with your new password.'
        }), 200

    except Exception as e:
        if conn: conn.rollback()
        import traceback
        traceback.print_exc()
        return jsonify({'success': False, 'error': f'Password reset failed: {str(e)}'}), 500
    finally:
        if cur: cur.close()
        if conn: conn.close()


@auth_bp.route('/me', methods=['PUT'])
@token_required
def update_user(user_id):
    conn = None
    cur = None
    try:
        data = request.form # <--- CHANGE 1: Use request.form for text data
        
        # profile picture
        # profile_picture_file = request.files.get('profile_picture') # <-- Access file
        
        # TODO: logic to save profile pic to db
        
        conn = get_db_connection()
        cur = conn.cursor()

        # name
        user_name = data.get('name')

        # date of birth
        dob_iso = data.get('dob') # <-- Client sends 'dob'
                
        # gender
        gender = data.get('gender')
        
        # exercise focus
        main_focus = data.get('main_focus')

        # intensity
        activity_intensity = data.get('activity_intensity')

        # 1d. Height and Weight Conversion (to Imperial)
        unit_system = data.get('unit_system', 'imperial') # Default to imperial for existing fields
        
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
                # TODO: add profile pic
            )
        )
        
        # set update_at
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

        return jsonify({
            'success': True,
            'message': 'Profile updated successfully',
            'user': {
                'id': user[0],
                'email': user[1],
                'date_of_birth': user[2],
                'gender': user[3],
                'height_in': user[4],
                'weight_lb': user[5],
                'updated_at': str(user[6]),
                'name': user[7] if len(user) > 7 else None,
                'goal_weight_lb': user[8] if len(user) > 8 else None,
                'main_focus': user[9] if len(user) > 9 else None,
                'activity_intensity': user[10] if len(user) > 10 else None,
            }
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