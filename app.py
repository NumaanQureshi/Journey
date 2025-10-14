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

DATABASE_URL = os.getenv('DATABASE_URL')

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
@app.route('/api/users', methods=['POST'])
def create_user():
    try:
        data = request.get_json()
        conn = get_db_connection()
        cur = conn.cursor()
        password = data['password']
        password_hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
        cur.execute(
            'INSERT INTO users (username, email, password_hash, age, gender, height_in, weight_lb) VALUES (%s, %s, %s, %s, %s, %s, %s) RETURNING id;',
            (data['username'], data['email'], password_hash, data.get('age'), data.get('gender'), data.get('height_in'), data.get('weight_lb'))
        )
        user_id = cur.fetchone()['id']
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"success": True, "message": "User created", "user_id": user_id}), 201
    except Exception as e:
        return jsonify({"success": False, "error": str(e)})

# UPDATE user
@app.route('/api/users/<int:user_id>', methods=['PUT'])
def update_user(user_id):
    try:
        data = request.get_json()
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            'UPDATE users SET age = %s, gender = %s, height_in = %s, weight_lb = %s WHERE id = %s;',
            (data.get('age'), data.get('gender'), data.get('height_in'), data.get('weight_lb'), user_id)
        )
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"success": True, "message": "User updated"})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)})

# @app.route('/api/users/<int:user_id>/password', methods=['PUT'])
# def update_password(user_id):
    try:

#@app.route('/api/auth/login', methods=['POST'])
#def login():
    try:
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

