from flask import Flask, jsonify
from dotenv import load_dotenv
import os
from flask_cors import CORS     # CORS import needed to test app locally
from api.auth import auth_bp
from api.challenges import challenge_bp
from api.users import users_bp
from api.ai import ai_bp
from api.workouts import workouts_bp

def create_app():
    load_dotenv()
    app = Flask(__name__)
    
    # Configure CORS for production
    allowed_origins = os.getenv('ALLOWED_ORIGINS', 'http://localhost:3000').split(',')
    CORS(app, resources={r"/api/*": {"origins": allowed_origins}})

    app.config['DATABASE_URL'] = os.getenv("DATABASE_URL")
    app.config['JWT_SECRET_KEY'] = os.getenv("JWT_SECRET_KEY")
    app.config['RESET_PASSWORD_URL'] = os.getenv("RESET_PASSWORD_URL")
    app.config['ENV'] = os.getenv('FLASK_ENV', 'production')
    app.config['DEBUG'] = os.getenv('FLASK_DEBUG', 'False').lower() in ('true', '1', 't')

    # blueprint registry
    app.register_blueprint(auth_bp, url_prefix='/api/auth')
    app.register_blueprint(challenge_bp, url_prefix='/api/challenges')
    app.register_blueprint(users_bp, url_prefix='/api/users')
    app.register_blueprint(ai_bp, url_prefix='/api/ai')
    app.register_blueprint(workouts_bp, url_prefix='/api/workouts')

    # test routes
    @app.route('/')
    def home():
        return jsonify({"message": "Connection made!"})
        
    return app

app = create_app()

if __name__ == '__main__':
    # Use environment variable to control debug mode - should be False in production
    debug_mode = os.getenv('FLASK_DEBUG', 'False').lower() in ('true', '1', 't')
    app.run(debug=debug_mode, host='0.0.0.0', port=int(os.getenv('PORT', 5000)))