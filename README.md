# Flask LMS Cloud Edition

A modern, cloud-ready Learning Management System with REST API backend and responsive frontend, designed for deployment on cloud platforms with Oracle Database integration.

## 🌟 Features

- **Modern REST API**: Flask-based backend with JWT authentication
- **Responsive Frontend**: React-based SPA for seamless user experience
- **Oracle Database**: Integrated with Oracle Free Tier (Always Free)
- **Role-Based Access**: Admin, Instructor, and Student roles
- **Cloud-Ready**: Containerized with Docker for easy deployment
- **Scalable Architecture**: Microservices-ready design

## 🏗️ Architecture

```
┌─────────────────┐
│  React Frontend │  (Port 3000)
│   (Public Web)  │
└────────┬────────┘
         │ HTTPS/REST API
         ▼
┌─────────────────┐
│  Flask Backend  │  (Port 5000)
│   (REST API)    │
└────────┬────────┘
         │ cx_Oracle
         ▼
┌─────────────────┐
│ Oracle Database │  (Always Free)
│  (Cloud/Local)  │
└─────────────────┘
```

## 📋 Prerequisites

- **Python**: 3.9 or higher
- **Node.js**: 16.x or higher
- **Oracle Database**: Free Tier account or local Oracle XE
- **Docker**: (Optional) For containerized deployment

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/kagm316-oss/flask-lms-cloud.git
cd flask-lms-cloud
```

### 2. Backend Setup

```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt

# Configure Oracle connection
cp .env.example .env
# Edit .env with your Oracle credentials

# Initialize database
python init_db.py

# Run backend server
python app.py
```

### 3. Frontend Setup

```bash
cd frontend
npm install

# Configure API endpoint
cp .env.example .env
# Edit .env with backend API URL

# Run development server
npm start
```

### 4. Access the Application

- **Frontend**: http://localhost:3000
- **API**: http://localhost:5000/api
- **API Docs**: http://localhost:5000/api/docs

## 🔧 Configuration

### Oracle Database Connection

Create a `.env` file in the `backend` directory:

```env
# Oracle Database Configuration
ORACLE_USER=your_username
ORACLE_PASSWORD=your_password
ORACLE_DSN=your_host:1521/your_service_name

# For Oracle Cloud Always Free
# ORACLE_DSN=adb.us-ashburn-1.oraclecloud.com:1522/service_name_high.adb.oraclecloud.com

# Application Settings
SECRET_KEY=your-secret-key-change-in-production
JWT_SECRET_KEY=your-jwt-secret-key
FLASK_ENV=development

# CORS Settings
FRONTEND_URL=http://localhost:3000
```

## 📦 Deployment

### Docker Deployment

```bash
# Build and run with Docker Compose
docker-compose up -d

# Stop services
docker-compose down
```

### Cloud Deployment Options

1. **Oracle Cloud Infrastructure (OCI)**
   - Deploy backend on Container Instances
   - Host frontend on Object Storage (static site)
   - Use Oracle Autonomous Database

2. **AWS**
   - Backend: Elastic Beanstalk or ECS
   - Frontend: S3 + CloudFront
   - Database: Oracle RDS or Oracle Cloud

3. **Azure**
   - Backend: App Service
   - Frontend: Static Web Apps
   - Database: Oracle Cloud integration

4. **Google Cloud Platform**
   - Backend: Cloud Run
   - Frontend: Firebase Hosting
   - Database: Oracle Cloud

## 🗂️ Project Structure

```
flask-lms-cloud/
├── backend/                 # Flask REST API
│   ├── app.py              # Main application entry
│   ├── models.py           # Database models (SQLAlchemy)
│   ├── routes/             # API route handlers
│   │   ├── auth.py         # Authentication endpoints
│   │   ├── exams.py        # Exam management
│   │   ├── students.py     # Student operations
│   │   └── analytics.py    # Analytics and reporting
│   ├── config.py           # Configuration management
│   ├── requirements.txt    # Python dependencies
│   └── Dockerfile          # Backend container
│
├── frontend/               # React frontend
│   ├── public/            # Static assets
│   ├── src/
│   │   ├── components/    # Reusable components
│   │   ├── pages/         # Page components
│   │   ├── services/      # API service layer
│   │   ├── context/       # React context (auth, etc.)
│   │   ├── utils/         # Utility functions
│   │   └── App.js         # Main app component
│   ├── package.json       # Node dependencies
│   └── Dockerfile         # Frontend container
│
├── database/              # Database scripts
│   ├── schema.sql         # Oracle schema definition
│   ├── seed_data.sql      # Sample data
│   └── migrations/        # Database migrations
│
├── docs/                  # Documentation
│   ├── API.md            # API documentation
│   ├── DEPLOYMENT.md     # Deployment guide
│   └── USER_GUIDE.md     # User manual
│
├── docker-compose.yml     # Multi-container orchestration
├── .gitignore            # Git ignore rules
└── README.md             # This file
```

## 🔐 Security Features

- JWT-based authentication
- Password hashing with bcrypt
- CSRF protection
- Rate limiting on API endpoints
- SQL injection prevention (parameterized queries)
- XSS protection
- CORS configuration
- Environment-based secrets management

## 🧪 Testing

### Backend Tests
```bash
cd backend
pytest tests/
```

### Frontend Tests
```bash
cd frontend
npm test
```

## 📊 API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout
- `GET /api/auth/me` - Get current user

### Exams
- `GET /api/exams` - List all exams
- `POST /api/exams` - Create new exam
- `GET /api/exams/:id` - Get exam details
- `PUT /api/exams/:id` - Update exam
- `DELETE /api/exams/:id` - Delete exam

### Students
- `GET /api/students` - List all students
- `GET /api/students/:id` - Get student details
- `GET /api/students/:id/performance` - Student analytics

### Submissions
- `POST /api/exams/:id/submit` - Submit exam
- `GET /api/submissions/:id` - Get submission details
- `PUT /api/submissions/:id/grade` - Grade submission

See [API.md](docs/API.md) for complete API documentation.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: [docs/](docs/)
- **Issues**: [GitHub Issues](https://github.com/kagm316-oss/flask-lms-cloud/issues)
- **Discussions**: [GitHub Discussions](https://github.com/kagm316-oss/flask-lms-cloud/discussions)

## 🙏 Acknowledgments

- Flask framework and community
- React ecosystem
- Oracle Cloud Free Tier
- All contributors

---

**Built with ❤️ for modern education**
