from flask import Flask, jsonify
from dotenv import load_dotenv
import os
from flask_cors import CORS     # CORS import needed to test app locally
from api.auth import auth_bp
from api.challenges import challenge_bp
from api.users import users_bp

def create_app():
    load_dotenv()
    app = Flask(__name__)
    CORS(app, resources={r"/api/*": {"origins": "*"}}) 

    app.config['DATABASE_URL'] = os.getenv("DATABASE_URL")
    app.config['JWT_SECRET_KEY'] = os.getenv("JWT_SECRET_KEY")
    app.config['RESET_PASSWORD_URL'] = os.getenv("RESET_PASSWORD_URL")
    
    # debugging feature flags
    app.config['SKIP_AUTH_DEBUG'] = os.getenv('SKIP_AUTH_DEBUG', 'False').lower() in ('true', '1', 't')
    app.config['DEBUG_USER_ID'] = os.getenv('DEBUG_USER_ID', None)

    # blueprint registry
    app.register_blueprint(auth_bp, url_prefix='/api/auth')
    app.register_blueprint(challenge_bp, url_prefix='/api/challenges')
    app.register_blueprint(users_bp, url_prefix='/api/users') # Note the /users prefix

    # test routes
    @app.route('/')
    def home():
        return jsonify({"message": "Connection made!"})
        
    return app

app = create_app()

if __name__ == '__main__':
    app.run(debug=True)