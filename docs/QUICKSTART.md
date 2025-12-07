# Quick Start Guide - Flask LMS Cloud Edition

Get started with Flask LMS in under 10 minutes!

## Prerequisites

✅ **Python 3.9+** installed  
✅ **Node.js 16+** installed  
✅ **Oracle Database** (Free Tier account or local XE)  
✅ **Git** installed

---

## Step 1: Clone Repository

```bash
git clone https://github.com/kagm316-oss/flask-lms-cloud.git
cd flask-lms-cloud
```

---

## Step 2: Set Up Oracle Database

### Option A: Oracle Cloud Free Tier (Recommended)

1. Create account: https://www.oracle.com/cloud/free/
2. Create Autonomous Database
3. Download wallet file
4. Note connection string

### Option B: Local Oracle XE

1. Download from: https://www.oracle.com/database/technologies/xe-downloads.html
2. Install and configure
3. Create user: `lms_user`

---

## Step 3: Initialize Database

```bash
# Connect to Oracle SQL
sqlplus lms_user/password@connection_string

# Run schema
@database/schema.sql

# Run seed data (optional)
@database/seed_data.sql

# Exit
exit
```

---

## Step 4: Configure Backend

```bash
cd backend

# Create virtual environment
python -m venv venv

# Activate (Windows)
venv\Scripts\activate

# Activate (Linux/Mac)
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Copy environment file
copy .env.example .env  # Windows
cp .env.example .env    # Linux/Mac

# Edit .env file with your Oracle credentials
notepad .env  # Windows
nano .env     # Linux/Mac
```

**Required .env settings:**
```env
ORACLE_USER=lms_user
ORACLE_PASSWORD=your_password
ORACLE_DSN=your_connection_string
SECRET_KEY=generate-random-string-here
JWT_SECRET_KEY=generate-another-random-string
```

---

## Step 5: Start Backend Server

```bash
# Still in backend directory
python app.py
```

✅ Backend running at: http://localhost:5000

---

## Step 6: Configure Frontend

**Open a new terminal window:**

```bash
cd flask-lms-cloud/frontend

# Install dependencies
npm install

# Copy environment file
copy .env.example .env  # Windows
cp .env.example .env    # Linux/Mac
```

**The default .env should work:**
```env
REACT_APP_API_URL=http://localhost:5000/api
```

---

## Step 7: Start Frontend Server

```bash
# Still in frontend directory
npm start
```

✅ Frontend opens automatically at: http://localhost:3000

---

## Step 8: Create Admin Account

**In backend terminal, press Ctrl+C to stop server, then:**

```bash
python
```

```python
from app import app, db
from models import User

with app.app_context():
    admin = User(
        username='admin',
        email='admin@example.com',
        first_name='Admin',
        last_name='User',
        role='admin'
    )
    admin.set_password('admin123')  # Change this!
    db.session.add(admin)
    db.session.commit()
    print("Admin user created!")

exit()
```

**Restart backend:**
```bash
python app.py
```

---

## Step 9: Login

1. Open http://localhost:3000
2. Login with:
   - Username: `admin`
   - Password: `admin123`
3. Change password immediately!

---

## What's Next?

### Create Your First Exam
1. Navigate to "Exams" → "Create Exam"
2. Fill in exam details
3. Add questions
4. Publish exam

### Add Students
1. Navigate to "Users" → "Add User"
2. Set role to "Student"
3. Share credentials

### Add Instructors
1. Navigate to "Users" → "Add User"
2. Set role to "Instructor"
3. Share credentials

---

## Docker Quick Start (Alternative)

If you prefer Docker:

```bash
# Configure backend/.env with Oracle credentials
cd flask-lms-cloud
docker-compose up -d

# Initialize database
docker-compose exec backend python init_db.py

# Create admin user
docker-compose exec backend python create_admin.py
```

Access at: http://localhost:3000

---

## Troubleshooting

### Backend won't start

**Error: "cx_Oracle not found"**
```bash
pip install cx-Oracle
```

**Error: "Database connection failed"**
- Check Oracle credentials in `.env`
- Verify database is running
- Test connection with SQL*Plus

### Frontend won't start

**Error: "Port 3000 already in use"**
```bash
# Kill process on port 3000 (Windows)
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Kill process on port 3000 (Linux/Mac)
lsof -ti:3000 | xargs kill -9
```

**Error: "Cannot connect to backend"**
- Ensure backend is running on port 5000
- Check `REACT_APP_API_URL` in frontend `.env`

### Database errors

**Error: "ORA-12154: TNS:could not resolve"**
- Check `ORACLE_DSN` format
- Verify wallet files (if using Cloud)
- Set `TNS_ADMIN` environment variable

**Error: "ORA-01017: invalid username/password"**
- Verify credentials in `.env`
- Check user exists in database

---

## Default Test Accounts

After running seed data:

| Role | Username | Password |
|------|----------|----------|
| Admin | admin | admin123 |
| Instructor | instructor1 | instructor123 |
| Student | student1 | student123 |

**⚠️ Change all passwords in production!**

---

## Project Structure

```
flask-lms-cloud/
├── backend/          # Flask REST API
│   ├── app.py       # Main application
│   ├── models.py    # Database models
│   ├── routes/      # API endpoints
│   └── config.py    # Configuration
├── frontend/        # React frontend
│   ├── src/         # Source code
│   └── public/      # Static files
├── database/        # SQL scripts
│   ├── schema.sql   # Database schema
│   └── seed_data.sql # Sample data
└── docs/           # Documentation
```

---

## Common Commands

### Backend

```bash
# Activate virtual environment
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows

# Install new package
pip install package-name
pip freeze > requirements.txt

# Run tests
pytest

# Database migrations
flask db migrate
flask db upgrade
```

### Frontend

```bash
# Install new package
npm install package-name

# Build for production
npm run build

# Run tests
npm test

# Lint code
npm run lint
```

---

## Getting Help

- 📖 **Documentation**: See `docs/` folder
- 🐛 **Issues**: https://github.com/kagm316-oss/flask-lms-cloud/issues
- 💬 **Discussions**: https://github.com/kagm316-oss/flask-lms-cloud/discussions
- 📧 **Email**: support@example.com

---

## Next Steps

1. ✅ Complete setup (you're here!)
2. 📚 Read full [Documentation](docs/)
3. 🚀 Deploy to [Cloud](docs/DEPLOYMENT.md)
4. 🔐 Configure [Security](docs/SECURITY.md)
5. 📊 Set up [Monitoring](docs/MONITORING.md)

---

**Happy Teaching! 🎓**
