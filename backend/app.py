# Flask Backend - REST API

from flask import Flask, jsonify, request
from flask_cors import CORS
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import timedelta
import os
from dotenv import load_dotenv

# Import models and database
from models import db, User, Exam, Question, Submission
from config import Config

# Load environment variables
load_dotenv()

# Initialize Flask app
app = Flask(__name__)
app.config.from_object(Config)

# Initialize extensions
CORS(app, resources={r"/api/*": {"origins": app.config['FRONTEND_URL']}})
jwt = JWTManager(app)
db.init_app(app)

# Import routes
from routes import auth_bp, exams_bp, students_bp, analytics_bp

# Register blueprints
app.register_blueprint(auth_bp, url_prefix='/api/auth')
app.register_blueprint(exams_bp, url_prefix='/api/exams')
app.register_blueprint(students_bp, url_prefix='/api/students')
app.register_blueprint(analytics_bp, url_prefix='/api/analytics')


@app.route('/')
def index():
    """API root endpoint"""
    return jsonify({
        'message': 'Flask LMS REST API',
        'version': '1.0.0',
        'status': 'online',
        'endpoints': {
            'auth': '/api/auth',
            'exams': '/api/exams',
            'students': '/api/students',
            'analytics': '/api/analytics',
            'docs': '/api/docs'
        }
    })


@app.route('/api/health')
def health_check():
    """Health check endpoint for monitoring"""
    try:
        # Test database connection
        db.session.execute('SELECT 1 FROM DUAL')
        db_status = 'healthy'
    except Exception as e:
        db_status = f'unhealthy: {str(e)}'
    
    return jsonify({
        'status': 'healthy',
        'database': db_status,
        'version': '1.0.0'
    })


@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    return jsonify({'error': 'Not found'}), 404


@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors"""
    db.session.rollback()
    return jsonify({'error': 'Internal server error'}), 500


@jwt.expired_token_loader
def expired_token_callback(jwt_header, jwt_payload):
    """Handle expired tokens"""
    return jsonify({
        'error': 'Token has expired',
        'message': 'Please login again'
    }), 401


@jwt.invalid_token_loader
def invalid_token_callback(error):
    """Handle invalid tokens"""
    return jsonify({
        'error': 'Invalid token',
        'message': 'Token verification failed'
    }), 401


@jwt.unauthorized_loader
def missing_token_callback(error):
    """Handle missing tokens"""
    return jsonify({
        'error': 'Authorization required',
        'message': 'Access token is missing'
    }), 401


if __name__ == '__main__':
    # Create tables if they don't exist
    with app.app_context():
        db.create_all()
    
    # Run development server
    app.run(
        host='0.0.0.0',
        port=5000,
        debug=app.config['DEBUG']
    )
