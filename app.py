from flask import Flask, jsonify, request, current_app
import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv
import os
from flask_cors import CORS     # CORS import needed to test app locally
import bcrypt
import jwt                      # Encode / Decode
import datetime
from functools import wraps
from helper_functions import calculate_age, generate_reset_token
from sql_loader import load_sql_query
from email_service import send_email


load_dotenv()
app = Flask(__name__) # creates a Flask application

CORS(app, resources={r"/api/*": {"origins": "*"}}) # -- USED ONLY FOR LOCAL TESTING -- 

DATABASE_URL= os.getenv("DATABASE_URL")
JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY")
RESET_PASSWORD_URL = os.getenv("RESET_PASSWORD_URL")
app.config['SKIP_AUTH_DEBUG'] = os.getenv('SKIP_AUTH_DEBUG', 'False').lower() in ('true', '1', 't')
app.config['DEBUG_USER_ID'] = os.getenv('DEBUG_USER_ID', None)

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        
        # FEATURE FLAG -> Allows us to skip auth when testing frontend
        # DEFAULT DEBUG USERID = 5, EMAIL: debug@example.com
        if app.config.get('SKIP_AUTH_DEBUG'):
            debug_user_id = app.config.get('DEBUG_USER_ID')
            if debug_user_id is None:
                # error if no env variable is set
                print("ERROR: AUTH BYPASS ON BUT DEBUG_USER_ID NOT SET")
                return jsonify({'success': False, 'error': 'set DEBUG_USER_ID in .env'}), 500
            print(f"DEBUG MODE: AUTH BYPASSED for User ID: {debug_user_id}")
            try:
                user_id = int(debug_user_id)
                return f(user_id, *args, **kwargs) # returns debug user
            # ensure debug user is int = 5
            except ValueError:
                return jsonify({'success': False, 'error': 'DEBUG_USER_ID must be an integer'}), 500

        token = None
        # Extract token from header
        if 'Authorization' in request.headers:
            token = request.headers['Authorization'].split(" ")[1]  # Expect "Bearer <token>"

        if not token:
            return jsonify({'success': False, 'error': 'Token is missing!'}), 401

        try:
            data = jwt.decode(token, JWT_SECRET_KEY, algorithms=['HS256'])
            user_id = data['user_id']
        except jwt.ExpiredSignatureError:
            return jsonify({'success': False, 'error': 'Token has expired!'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'success': False, 'error': 'Invalid token!'}), 401

        return f(user_id, *args, **kwargs)

    return decorated

def get_db_connection():
    conn = psycopg2.connect(DATABASE_URL)
    return conn

@app.route('/')
def home():
    return jsonify({"message": "Connection made!"})

# Test route to check database connection
@app.route('/api/test-db')
def test_db():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('SELECT version();')
        db_version = cur.fetchone()
        cur.close()
        conn.close()
        return jsonify({"success": True, "database": db_version[0]})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)})
# GET all users
@app.route('/api/users', methods=['GET'])
def get_all_users():
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
@app.route('/api/users/<int:user_id>', methods=['GET'])
def get_user(user_id):
    try:
        conn = get_db_connection()
        cur = conn.cursor()
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

# CREATE new user
@app.route('/api/auth/register', methods=['POST'])
def register():
    conn = None
    cur = None
    try:
        user_login_info = request.get_json()
        if not user_login_info.get('email'):
            return jsonify({'success': False, 'error': 'Email is required'}), 400
        if not user_login_info.get('password'):
            return jsonify({'success': False, 'error': 'Password is required'}), 400
        password = user_login_info['password']
        if not user_login_info.get('username'):
            return jsonify({'success': False, 'error': 'Username is required'}), 400
        if len(password) < 8: #For security purposes, we want a secure password that's at least 8 characters long
            return jsonify({
                'success': False,
                'error': 'Password must be at least 8 characters long'
            }), 400
        password_hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
        conn = get_db_connection()
        cur = conn.cursor()
        insert_user_sql = load_sql_query('insert_user_core.sql')
        cur.execute(insert_user_sql,
            (
                user_login_info['email'].lower(),
                password_hash,
                user_login_info['username']
            )
        )
        user_id = cur.fetchone()[0]
        insert_profile_sql = load_sql_query('insert_profile.sql')
        cur.execute(
            insert_profile_sql,
            (
                user_id,
                user_login_info.get('age'),
                user_login_info.get('gender'),
                user_login_info.get('height_in'),
                user_login_info.get('weight_lb')
            )
        )
        insert_leaderboard_sql = load_sql_query('insert_leaderboard.sql')
        cur.execute(
            insert_leaderboard_sql, 
            (user_id,)
             # all other aspects of the leaderboard are defaulted to 0
        )
        conn.commit()
        
        token = jwt.encode(
            {
            'user_id': user_id,
            'exp': datetime.datetime.now(datetime.UTC) + datetime.timedelta(days=7)
            },
            JWT_SECRET_KEY,
            algorithm='HS256'
        )
        return jsonify({
            'success': True,
            'message': 'Registration successful',
            'user': {
                'id': user_id,
                'email': user_login_info['email'],
                'username': user_login_info['username'],
                'age': user_login_info.get('age'),
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


@app.route('/api/auth/me', methods=['PUT'])
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

        # age
        dob_iso = data.get('dob') # <-- Client sends 'dob'
        
        calculated_age = None
        if dob_iso:
            try:
                dob_date = datetime.datetime.fromisoformat(dob_iso.replace('Z', '+00:00'))
                birth_year = dob_date.year
                birth_month = dob_date.month
                birth_day = dob_date.day
                calculated_age = calculate_age(birth_year, birth_month, birth_day)
            except Exception as e:
                current_app.logger.error(f"DOB parsing failed: {e}")
                
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
                height_in = height_float * 0.393701
            else: # imperial
                height_in = height_float

        # weight
        weight_raw = data.get('weight')
        weight_lb = None
        if weight_raw is not None:
            weight_float = float(weight_raw)
            if unit_system == 'metric':
                # convert to pounds: 1 kg = 2.20462 lb
                weight_lb = weight_float * 2.20462
            else: # imperial
                weight_lb = weight_float
        
        # goal weight
        goal_weight_raw = data.get('goal_weight')
        goal_weight_lb = None
        if goal_weight_raw is not None:
            goal_weight_float = float(goal_weight_raw)
            if unit_system == 'metric':
                # Convert to pounds: 1 kg = 2.20462 lb
                goal_weight_lb = goal_weight_float * 2.20462
            else: # imperial
                goal_weight_lb = goal_weight_float

        # update profile
        update_profile_sql = load_sql_query('update_profile.sql')
        cur.execute(
            update_profile_sql,
            (
                user_name,
                calculated_age,
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
                'age': user[2],
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


# @app.route('/api/auth/me/password', methods=['PUT'])
# @token_required
# def update_password(user_id):
#     conn = None
#     cur = None

#     try:
#         data = request.get_json()
#         old_password = data.get('old_password')
#         new_password = data.get('new_password')

#         if not old_password:
#             return jsonify({
#                 'success': False,
#                 'error': 'Current password is required'
#             }), 400
#         if not new_password:
#             return jsonify({
#                 'success': False,
#                 'error': 'New password is required'
#             }), 400
#         if len(new_password) < 6:
#             return jsonify({
#                 'success': False,
#                 'error': 'New password must be at least 6 characters long'
#             }), 400
#         if old_password == new_password:
#             return jsonify({
#                 'success': False,
#                 'error': 'New password must be different from current password'
#             }), 400

#         conn = get_db_connection()
#         cur = conn.cursor()

#         cur.execute(
#             'SELECT password_hash FROM users WHERE id = %s;',
#             (user_id,)
#         )
#         user = cur.fetchone()

#         if not user:
#             return jsonify({
#                 'success': False,
#                 'error': 'User not found'
#             }), 404

#         if not bcrypt.checkpw(old_password.encode('utf-8'), user[0].encode('utf-8')):
#             return jsonify({
#                 'success': False,
#                 'error': 'Current password is incorrect'
#             }), 401

#         new_password_hash = bcrypt.hashpw(
#             new_password.encode('utf-8'),
#             bcrypt.gensalt()
#         ).decode('utf-8')

#         cur.execute(
#             '''UPDATE users 
#                SET password_hash = %s, updated_at = NOW() 
#                WHERE id = %s;''',
#             (new_password_hash, user_id)
#         )
#         conn.commit()

#         return jsonify({
#             'success': True,
#             'message': 'Password updated successfully'
#         }), 200

#     except Exception as e:
#         if conn:
#             conn.rollback()
#         return jsonify({
#             'success': False,
#             'error': str(e)
#         }), 500

#     finally:
#         if cur:
#             cur.close()
#         if conn:
#             conn.close()

@app.route('/api/auth/forgot-password', methods=['POST'])
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
        reset_link = f"{RESET_PASSWORD_URL}?token={reset_token}"
        
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

@app.route('/api/auth/reset-password', methods=['POST'])
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

        # 1. Decode and validate the JWT token
        try:
            payload = jwt.decode(token, JWT_SECRET_KEY, algorithms=['HS256'])
            if payload.get('token_type') != 'password_reset':
                raise jwt.InvalidTokenError
            user_id = payload['user_id']
        except jwt.ExpiredSignatureError:
            return jsonify({'success': False, 'error': 'Reset link has expired'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'success': False, 'error': 'Invalid reset token'}), 401

        # 2. Hash the new password
        new_password_hash = bcrypt.hashpw(
            new_password.encode('utf-8'),
            bcrypt.gensalt()
        ).decode('utf-8')

        conn = get_db_connection()
        cur = conn.cursor()

        # 3. Update the user's password
        cur.execute(
            '''
            UPDATE users 
            SET password_hash = %s, updated_at = NOW() 
            WHERE id = %s;
            ''',
            (new_password_hash, user_id)
        )
        
        # Check if a row was updated
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

@app.route('/api/auth/login', methods=['POST'])
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
            JWT_SECRET_KEY,
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

# DELETE user
@app.route('/api/users/<int:user_id>', methods=['DELETE'])
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

if __name__ == '__main__':
    app.run(debug=True)
