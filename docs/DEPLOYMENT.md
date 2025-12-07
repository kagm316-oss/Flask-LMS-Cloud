# Deployment Guide - Flask LMS Cloud Edition

## Overview

This guide covers deploying Flask LMS to various cloud platforms with Oracle Database integration.

## Table of Contents

1. [Oracle Database Setup](#oracle-database-setup)
2. [Local Development](#local-development)
3. [Docker Deployment](#docker-deployment)
4. [Oracle Cloud Infrastructure (OCI)](#oracle-cloud-infrastructure)
5. [AWS Deployment](#aws-deployment)
6. [Azure Deployment](#azure-deployment)
7. [Google Cloud Platform](#google-cloud-platform)

---

## Oracle Database Setup

### Option 1: Oracle Cloud Always Free Tier

1. **Create Oracle Cloud Account**
   - Visit: https://www.oracle.com/cloud/free/
   - Sign up for Always Free tier
   - Verify email and complete registration

2. **Create Autonomous Database**
   ```
   - Navigate to Autonomous Database
   - Click "Create Autonomous Database"
   - Choose "Transaction Processing" or "Data Warehouse"
   - Select "Always Free" configuration
   - Set admin password
   - Download wallet file
   ```

3. **Configure Connection**
   ```bash
   # Extract wallet files
   unzip Wallet_DBNAME.zip -d /path/to/wallet
   
   # Set environment variables
   export TNS_ADMIN=/path/to/wallet
   ```

4. **Update Connection String**
   ```env
   ORACLE_DSN=(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.region.oraclecloud.com))(connect_data=(service_name=dbname_high.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))
   ```

### Option 2: Oracle Database Express Edition (Local)

1. **Download Oracle XE**
   - Visit: https://www.oracle.com/database/technologies/xe-downloads.html
   - Download for your OS

2. **Install Oracle XE**
   ```bash
   # Linux
   sudo rpm -ivh oracle-xe-*.rpm
   sudo /etc/init.d/oracle-xe configure
   
   # Windows: Run installer
   ```

3. **Configure Connection**
   ```env
   ORACLE_DSN=localhost:1521/XEPDB1
   ORACLE_USER=lms_user
   ORACLE_PASSWORD=your_password
   ```

4. **Create Database User**
   ```sql
   sqlplus sys as sysdba
   
   CREATE USER lms_user IDENTIFIED BY your_password;
   GRANT CONNECT, RESOURCE TO lms_user;
   GRANT CREATE SESSION TO lms_user;
   GRANT CREATE TABLE TO lms_user;
   GRANT CREATE VIEW TO lms_user;
   GRANT CREATE SEQUENCE TO lms_user;
   ALTER USER lms_user QUOTA UNLIMITED ON USERS;
   ```

5. **Run Schema Script**
   ```bash
   cd database
   sqlplus lms_user/your_password@localhost:1521/XEPDB1 @schema.sql
   ```

---

## Local Development

### Prerequisites

- Python 3.9+
- Node.js 16+
- Oracle Database (Cloud or Local)

### Backend Setup

```bash
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your Oracle credentials

# Initialize database
python init_db.py

# Run development server
python app.py
```

Backend will run on: http://localhost:5000

### Frontend Setup

```bash
cd frontend

# Install dependencies
npm install

# Configure environment
cp .env.example .env
# Edit .env if needed

# Run development server
npm start
```

Frontend will run on: http://localhost:3000

---

## Docker Deployment

### Prerequisites

- Docker
- Docker Compose

### Setup

1. **Configure Environment Variables**
   ```bash
   cp backend/.env.example backend/.env
   # Edit backend/.env with your Oracle credentials
   ```

2. **Build and Run**
   ```bash
   docker-compose up -d
   ```

3. **Initialize Database**
   ```bash
   docker-compose exec backend python init_db.py
   ```

4. **Access Application**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:5000

5. **View Logs**
   ```bash
   docker-compose logs -f
   ```

6. **Stop Services**
   ```bash
   docker-compose down
   ```

---

## Oracle Cloud Infrastructure (OCI)

### Architecture

```
Internet → Load Balancer → Container Instances → Autonomous Database
                         → Object Storage (Frontend)
```

### Deployment Steps

#### 1. Create Autonomous Database (Already covered above)

#### 2. Deploy Backend (Container Instances)

```bash
# Build and push image
docker build -t backend:latest ./backend
docker tag backend:latest region.ocir.io/namespace/flask-lms-backend:latest
docker push region.ocir.io/namespace/flask-lms-backend:latest

# Create container instance via OCI Console or CLI
oci container-instances create \
  --display-name flask-lms-backend \
  --image region.ocir.io/namespace/flask-lms-backend:latest \
  --shape CI.Standard.E4.Flex \
  --shape-config '{"memoryInGBs": 4, "ocpus": 1}'
```

#### 3. Deploy Frontend (Object Storage)

```bash
# Build React app
cd frontend
npm run build

# Upload to Object Storage
oci os object bulk-upload \
  -bn flask-lms-frontend \
  --src-dir ./build

# Enable static website hosting
oci os bucket update \
  -bn flask-lms-frontend \
  --public-access-type ObjectRead
```

#### 4. Configure Load Balancer

- Create load balancer
- Add backend container as backend set
- Configure SSL certificate
- Set up health checks

---

## AWS Deployment

### Architecture

```
Route 53 → CloudFront → S3 (Frontend)
                       → ALB → ECS/Fargate (Backend) → Oracle Cloud DB
```

### Deployment Steps

#### 1. Backend (ECS Fargate)

```bash
# Create ECR repository
aws ecr create-repository --repository-name flask-lms-backend

# Build and push
docker build -t flask-lms-backend ./backend
docker tag flask-lms-backend:latest ACCOUNT.dkr.ecr.REGION.amazonaws.com/flask-lms-backend:latest
docker push ACCOUNT.dkr.ecr.REGION.amazonaws.com/flask-lms-backend:latest

# Create ECS cluster
aws ecs create-cluster --cluster-name flask-lms-cluster

# Create task definition (see task-definition.json)
aws ecs register-task-definition --cli-input-json file://task-definition.json

# Create service
aws ecs create-service \
  --cluster flask-lms-cluster \
  --service-name flask-lms-backend \
  --task-definition flask-lms-backend \
  --desired-count 2 \
  --launch-type FARGATE
```

#### 2. Frontend (S3 + CloudFront)

```bash
# Create S3 bucket
aws s3 mb s3://flask-lms-frontend

# Build and upload
cd frontend
npm run build
aws s3 sync ./build s3://flask-lms-frontend

# Configure S3 for static hosting
aws s3 website s3://flask-lms-frontend \
  --index-document index.html \
  --error-document index.html

# Create CloudFront distribution
aws cloudfront create-distribution \
  --origin-domain-name flask-lms-frontend.s3.amazonaws.com
```

#### 3. Configure Secrets Manager

```bash
aws secretsmanager create-secret \
  --name flask-lms/oracle-db \
  --secret-string '{"username":"lms_user","password":"your_password","dsn":"connection_string"}'
```

---

## Azure Deployment

### Architecture

```
Azure Front Door → Static Web Apps (Frontend)
                 → App Service (Backend) → Oracle Cloud DB
```

### Deployment Steps

#### 1. Backend (App Service)

```bash
# Login to Azure
az login

# Create resource group
az group create --name flask-lms-rg --location eastus

# Create App Service plan
az appservice plan create \
  --name flask-lms-plan \
  --resource-group flask-lms-rg \
  --is-linux \
  --sku B1

# Create web app
az webapp create \
  --resource-group flask-lms-rg \
  --plan flask-lms-plan \
  --name flask-lms-backend \
  --runtime "PYTHON:3.11"

# Configure environment variables
az webapp config appsettings set \
  --resource-group flask-lms-rg \
  --name flask-lms-backend \
  --settings ORACLE_USER=lms_user ORACLE_PASSWORD=password

# Deploy code
az webapp up \
  --resource-group flask-lms-rg \
  --name flask-lms-backend \
  --src-path ./backend
```

#### 2. Frontend (Static Web Apps)

```bash
# Create static web app
az staticwebapp create \
  --name flask-lms-frontend \
  --resource-group flask-lms-rg \
  --source https://github.com/username/flask-lms-cloud \
  --location eastus \
  --branch main \
  --app-location "/frontend" \
  --output-location "build"
```

---

## Google Cloud Platform

### Architecture

```
Cloud Load Balancer → Cloud Run (Backend) → Oracle Cloud DB
                    → Firebase Hosting (Frontend)
```

### Deployment Steps

#### 1. Backend (Cloud Run)

```bash
# Set project
gcloud config set project PROJECT_ID

# Build and deploy
gcloud builds submit --tag gcr.io/PROJECT_ID/flask-lms-backend ./backend

gcloud run deploy flask-lms-backend \
  --image gcr.io/PROJECT_ID/flask-lms-backend \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars ORACLE_USER=lms_user,ORACLE_PASSWORD=password
```

#### 2. Frontend (Firebase Hosting)

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize project
cd frontend
firebase init hosting

# Build and deploy
npm run build
firebase deploy --only hosting
```

---

## Environment Variables

### Backend (.env)

```env
SECRET_KEY=your-secret-key
JWT_SECRET_KEY=your-jwt-secret-key
FLASK_ENV=production
ORACLE_USER=lms_user
ORACLE_PASSWORD=your_password
ORACLE_DSN=your_connection_string
FRONTEND_URL=https://your-frontend-url.com
```

### Frontend (.env)

```env
REACT_APP_API_URL=https://your-backend-url.com/api
REACT_APP_NAME=Flask LMS
```

---

## Post-Deployment

### 1. Create Admin User

```bash
# SSH into backend container
python -c "from app import app, db; from models import User; \
with app.app_context(): \
    admin = User(username='admin', email='admin@example.com', \
                 first_name='Admin', last_name='User', role='admin'); \
    admin.set_password('changeme'); \
    db.session.add(admin); \
    db.session.commit()"
```

### 2. Configure SSL/TLS

- Use Let's Encrypt for free SSL
- Configure certificate auto-renewal
- Update CORS and frontend URL

### 3. Set Up Monitoring

- Configure application logs
- Set up error tracking (Sentry)
- Monitor database performance
- Set up uptime monitoring

### 4. Configure Backups

- Schedule database backups
- Back up uploaded files
- Test restore procedures

---

## Troubleshooting

### Database Connection Issues

```bash
# Test Oracle connection
python -c "import cx_Oracle; print(cx_Oracle.clientversion())"

# Check TNS_ADMIN
echo $TNS_ADMIN

# Verify wallet files
ls -la $TNS_ADMIN
```

### Docker Issues

```bash
# Check container logs
docker-compose logs backend

# Exec into container
docker-compose exec backend bash

# Check environment variables
docker-compose exec backend env
```

### Frontend Build Issues

```bash
# Clear cache
npm cache clean --force

# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install

# Build with verbose output
npm run build --verbose
```

---

## Security Checklist

- [ ] Change default SECRET_KEY and JWT_SECRET_KEY
- [ ] Use strong database passwords
- [ ] Enable HTTPS/SSL
- [ ] Configure CORS properly
- [ ] Enable rate limiting
- [ ] Set up WAF (Web Application Firewall)
- [ ] Regular security updates
- [ ] Enable audit logging
- [ ] Implement backup strategy
- [ ] Configure firewall rules

---

## Support

For issues and questions:
- GitHub Issues: https://github.com/kagm316-oss/flask-lms-cloud/issues
- Documentation: See docs/ directory
- Oracle Cloud Support: https://www.oracle.com/cloud/free/faq.html

---

**Last Updated:** December 2025
