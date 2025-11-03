from flask import Flask, jsonify, request
import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv
import os
import bcrypt
import jwt                                                                  # Encode / Decode
import datetime
from functools import wraps


load_dotenv()
app = Flask(__name__) # creates a Flask application

DATABASE_URL= os.getenv("DATABASE_URL")
JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY")
def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
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
def get_users():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('SELECT id, username, email, age, gender, height_in, weight_lb, created_at FROM users;')
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
        cur.execute('SELECT id, username, email, age, gender, height_in, weight_lb, created_at FROM users WHERE id = %s;', (user_id,))
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
        if not user_login_info.get('username'):
            return jsonify({'success': False, 'error': 'Username is required'}), 400
        if not user_login_info.get('email'):
            return jsonify({'success': False, 'error': 'Email is required'}), 400
        if not user_login_info.get('password'):
            return jsonify({'success': False, 'error': 'Password is required'}), 400
        password = user_login_info['password']
        if len(password) < 8: #For security purposes, we want a secure password that's at least 8 characters long
            return jsonify({
                'success': False,
                'error': 'Password must be at least 8 characters long'
            }), 400
        password_hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute( """
            INSERT INTO users (username, email, password_hash, age, gender, height_in, weight_lb) VALUES (%s, %s, %s, %s, %s, %s, %s) RETURNING id, username, email, age, gender, height_in, weight_lb, created_at""",
            (user_login_info['username'],user_login_info['email'],password_hash,user_login_info.get('age'),user_login_info.get('gender'),user_login_info.get('height_in'),user_login_info.get('weight_lb')))
        user = cur.fetchone()
        user_id = int(user[0])
        cur.execute( 'INSERT INTO leaderboard (user_id) VALUES (%s);',
        (user_id,)) #all other aspects of the leaderboard are defaulted to 0
        conn.commit()
        token = jwt.encode(
            {
            'user_id': user_id,
            'exp': datetime.datetime.utcnow() + datetime.timedelta(days=7)
            },
            JWT_SECRET_KEY,
            algorithm='HS256'
        )
        return jsonify({
            'success': True,
            'message': 'Registration successful',
            'user': {
                'id': user[0],
                'username': user[1],
                'email': user[2],
                'age': user[3],
                'gender': user[4],
                'height_in': user[5],
                'weight_lb': user[6],
                'created_at': str(user[7])
            },
            'token': token
        }), 201
    except psycopg2.errors.UniqueViolation as e:
        if conn:
            conn.rollback()
        error_msg = str(e)
        if 'username' in error_msg:
            return jsonify({
                'success': False,
                'error': 'Username already exists'
            }), 400
        elif 'email' in error_msg:
            return jsonify({
                'success': False,
                'error': 'Email already exists'
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
        data = request.get_json()
        conn = get_db_connection()
        cur = conn.cursor()

        cur.execute(
            '''UPDATE users 
               SET age = COALESCE(%s, age),
                   gender = COALESCE(%s, gender),
                   height_in = COALESCE(%s, height_in),
                   weight_lb = COALESCE(%s, weight_lb),
                   updated_at = NOW()
               WHERE id = %s
               RETURNING id, username, email, age, gender, height_in, weight_lb, updated_at;''',
            (
                data.get('age'),
                data.get('gender'),
                data.get('height_in'),
                data.get('weight_lb'),
                user_id
            )
        )

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
                'username': user[1],
                'email': user[2],
                'age': user[3],
                'gender': user[4],
                'height_in': user[5],
                'weight_lb': user[6],
                'updated_at': str(user[7])
            }
        }), 200

    except Exception as e:
        if conn:
            conn.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()


@app.route('/api/auth/me/password', methods=['PUT'])
@token_required
def update_password(user_id):
    conn = None
    cur = None

    try:
        data = request.get_json()
        old_password = data.get('old_password')
        new_password = data.get('new_password')

        if not old_password:
            return jsonify({
                'success': False,
                'error': 'Current password is required'
            }), 400
        if not new_password:
            return jsonify({
                'success': False,
                'error': 'New password is required'
            }), 400
        if len(new_password) < 6:
            return jsonify({
                'success': False,
                'error': 'New password must be at least 6 characters long'
            }), 400
        if old_password == new_password:
            return jsonify({
                'success': False,
                'error': 'New password must be different from current password'
            }), 400

        conn = get_db_connection()
        cur = conn.cursor()

        cur.execute(
            'SELECT password_hash FROM users WHERE id = %s;',
            (user_id,)
        )
        user = cur.fetchone()

        if not user:
            return jsonify({
                'success': False,
                'error': 'User not found'
            }), 404

        if not bcrypt.checkpw(old_password.encode('utf-8'), user[0].encode('utf-8')):
            return jsonify({
                'success': False,
                'error': 'Current password is incorrect'
            }), 401

        new_password_hash = bcrypt.hashpw(
            new_password.encode('utf-8'),
            bcrypt.gensalt()
        ).decode('utf-8')

        cur.execute(
            '''UPDATE users 
               SET password_hash = %s, updated_at = NOW() 
               WHERE id = %s;''',
            (new_password_hash, user_id)
        )
        conn.commit()

        return jsonify({
            'success': True,
            'message': 'Password updated successfully'
        }), 200

    except Exception as e:
        if conn:
            conn.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()

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
        # Get user from database
        cur.execute(
            '''SELECT id, username, email, password_hash, age, gender, 
                      height_in, weight_lb, created_at 
               FROM users 
               WHERE email = %s;''',
            (email,)
        )
        user = cur.fetchone()
        user_id = user[0]
        password_hash = user[3]
        if not user:
            return jsonify({
                'success': False,
                'error': 'Invalid email or password'
            }), 401
        # Verify password with bcrypt
        if not bcrypt.checkpw(password.encode('utf-8'), password_hash.encode('utf-8')):
            return jsonify({
                'success': False,
                'error': 'Invalid email or password'
            }), 401
        # Create JWT token (expires in 7 days)
        token = jwt.encode(
            {
                'user_id': user_id,
                'exp': datetime.datetime.utcnow() + datetime.timedelta(days=7)
            },
            JWT_SECRET_KEY,
            algorithm='HS256'
        )
        # Remove password_hash from response
        user_data = {
            'id': user[0],
            'username': user[1],
            'email': user[2],
            'age': user[4],
            'gender': user[5],
            'height_in': user[6],
            'weight_lb': user[7],
            'created_at': str(user[8])
        }

        return jsonify({
            'success': True,
            'message': 'Login successful',
            'user': user_data,
            'token': token
        }), 200

    except Exception as e:
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

