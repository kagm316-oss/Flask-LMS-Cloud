"""Flask LMS Dashboard Application"""
from flask import Flask, render_template, request, jsonify
from flask_cors import CORS
import oracledb
from datetime import datetime
from werkzeug.security import generate_password_hash

app = Flask(__name__)
app.config['SECRET_KEY'] = '9UCOBi2bhfvoWlgtLr5NuAdG7Mj6KY0s'

# Enable CORS for GitHub Pages
CORS(app, resources={
    r"/api/*": {
        "origins": [
            "https://kagm316-oss.github.io",
            "http://localhost:3000",
            "http://localhost:5000",
            "http://127.0.0.1:5000"
        ]
    }
})

# Oracle connection settings
DB_CONFIG = {
    'user': 'ADMIN',
    'password': 'PA$$word060306',
    'dsn': 'flasklms_high',
    'config_dir': r'C:\Users\kagm3\OneDrive\Desktop\flask-lms-cloud\backend\wallet',
    'wallet_location': r'C:\Users\kagm3\OneDrive\Desktop\flask-lms-cloud\backend\wallet',
    'wallet_password': 'PA$$word060306'
}

def get_db_connection():
    """Get Oracle database connection"""
    return oracledb.connect(**DB_CONFIG)

@app.route('/')
def index():
    """Main dashboard page"""
    return render_template('dashboard.html')

@app.route('/api/health')
def health():
    """Health check endpoint"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT 1 FROM DUAL")
        cursor.close()
        conn.close()
        return jsonify({'status': 'healthy', 'database': 'connected'})
    except Exception as e:
        return jsonify({'status': 'unhealthy', 'error': str(e)}), 500

@app.route('/api/users', methods=['GET'])
def get_users():
    """Get all users"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT id, username, email, first_name, last_name, role, 
                   TO_CHAR(created_at, 'YYYY-MM-DD HH24:MI:SS') as created_at
            FROM users
            ORDER BY id DESC
        """)
        columns = [col[0].lower() for col in cursor.description]
        users = [dict(zip(columns, row)) for row in cursor.fetchall()]
        cursor.close()
        conn.close()
        return jsonify({'users': users, 'count': len(users)})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/users', methods=['POST'])
def create_user():
    """Create a new user"""
    try:
        data = request.json
        
        # Validate required fields
        required = ['username', 'email', 'password', 'role']
        if not all(field in data for field in required):
            return jsonify({'error': 'Missing required fields'}), 400
        
        # Hash password
        password_hash = generate_password_hash(data['password'])
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Use a simpler insert without RETURNING clause
        cursor.execute("""
            INSERT INTO users (username, email, password_hash, first_name, last_name, role, is_active)
            VALUES (:1, :2, :3, :4, :5, :6, 1)
        """, [
            data['username'],
            data['email'],
            password_hash,
            data.get('first_name', ''),
            data.get('last_name', ''),
            data['role']
        ])
        
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({'message': 'User created successfully'}), 201
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/courses', methods=['GET'])
def get_courses():
    """Get all courses"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT c.id, c.title, c.description, c.instructor_id,
                   u.username as instructor_name,
                   TO_CHAR(c.created_at, 'YYYY-MM-DD HH24:MI:SS') as created_at
            FROM courses c
            LEFT JOIN users u ON c.instructor_id = u.id
            ORDER BY c.id DESC
        """)
        columns = [col[0].lower() for col in cursor.description]
        courses = [dict(zip(columns, row)) for row in cursor.fetchall()]
        cursor.close()
        conn.close()
        return jsonify({'courses': courses, 'count': len(courses)})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/courses', methods=['POST'])
def create_course():
    """Create a new course"""
    try:
        data = request.json
        
        required = ['title', 'instructor_id']
        if not all(field in data for field in required):
            return jsonify({'error': 'Missing required fields'}), 400
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        cursor.execute("""
            INSERT INTO courses (title, description, instructor_id)
            VALUES (:1, :2, :3)
        """, [
            data['title'],
            data.get('description', ''),
            data['instructor_id']
        ])
        
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({'message': 'Course created successfully'}), 201
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/stats')
def get_stats():
    """Get dashboard statistics"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        stats = {}
        
        # Count users by role
        cursor.execute("SELECT role, COUNT(*) FROM users GROUP BY role")
        stats['users_by_role'] = {row[0]: row[1] for row in cursor.fetchall()}
        
        # Total counts
        cursor.execute("SELECT COUNT(*) FROM courses")
        stats['total_courses'] = cursor.fetchone()[0]
        
        cursor.execute("SELECT COUNT(*) FROM exams")
        stats['total_exams'] = cursor.fetchone()[0]
        
        cursor.execute("SELECT COUNT(*) FROM enrollments")
        stats['total_enrollments'] = cursor.fetchone()[0]
        
        cursor.close()
        conn.close()
        
        return jsonify(stats)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    print("\n" + "=" * 60)
    print("  Flask LMS Dashboard")
    print("=" * 60)
    print(f"\n  Dashboard URL: http://localhost:5000")
    print(f"  API Docs:      http://localhost:5000/api/health")
    print(f"\n  Press CTRL+C to stop the server")
    print("=" * 60 + "\n")
    
    app.run(debug=True, host='0.0.0.0', port=5000)
