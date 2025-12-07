# Flask LMS - Live Cloud Dashboard

🎓 **Interactive Learning Management System Dashboard**

This is the frontend interface for Flask LMS, connected to Oracle Autonomous Database.

## 🌐 Live Demo

**Dashboard URL**: https://kagm316-oss.github.io/Flask-LMS-Cloud/

## ⚙️ Setup

### Option 1: Use Local Backend (Recommended for Testing)

1. **Start the Flask backend locally:**
   ```bash
   cd backend
   python app_dashboard.py
   ```

2. **Open the dashboard:**
   - Visit: https://kagm316-oss.github.io/Flask-LMS-Cloud/
   - Enter API URL: `http://localhost:5000`
   - Click "Connect"

### Option 2: Deploy Backend to Cloud

Deploy the Flask backend to:
- **Oracle Cloud** (recommended - same cloud as database)
- **Heroku**
- **AWS Lambda**
- **Azure App Service**

Then enter your deployed API URL in the dashboard.

## 🚀 Features

- ✅ Real-time statistics (users, courses, exams, enrollments)
- ✅ Create and manage users (Student, Instructor, Admin)
- ✅ Create and manage courses
- ✅ Live database connection status
- ✅ Auto-refresh every 30 seconds
- ✅ Persistent API URL configuration

## 🗄️ Database

Connected to **Oracle Autonomous Database** (Always Free Tier)

Tables:
- `USERS` - User accounts with roles
- `COURSES` - Course information
- `EXAMS` - Exam definitions
- `QUESTIONS` - Exam questions
- `ENROLLMENTS` - Student-course relationships
- `SUBMISSIONS` - Student exam submissions

## 🔧 Backend API

The Flask backend provides these endpoints:

- `GET /api/health` - Health check
- `GET /api/users` - List all users
- `POST /api/users` - Create new user
- `GET /api/courses` - List all courses
- `POST /api/courses` - Create new course
- `GET /api/stats` - Dashboard statistics

## 📝 CORS Configuration

For the frontend to connect to your backend, ensure Flask has CORS enabled:

```python
from flask_cors import CORS
app = Flask(__name__)
CORS(app, origins=['https://kagm316-oss.github.io'])
```

## 🔒 Security Note

This is a demonstration application. For production use:
- Add authentication/authorization
- Use HTTPS for API
- Implement rate limiting
- Add input validation
- Use environment variables for sensitive data

## 📖 Documentation

Full documentation available in the repository:
- [Quick Start Guide](docs/QUICKSTART.md)
- [Deployment Guide](docs/DEPLOYMENT.md)
- [API Documentation](docs/API.md)

## 👤 Author

**kagm316-oss**

## 📄 License

MIT License - See LICENSE file for details
