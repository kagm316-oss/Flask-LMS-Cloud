# Oracle Cloud Connection Setup Script
# This script helps you set up the Oracle Database connection

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Flask LMS - Oracle Cloud Database Setup" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Check if Oracle Instant Client is installed
Write-Host "Checking for Oracle Instant Client..." -ForegroundColor Yellow

$oracleClient = Get-Command sqlplus -ErrorAction SilentlyContinue

if (-not $oracleClient) {
    Write-Host "Oracle Instant Client not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please download and install Oracle Instant Client:" -ForegroundColor Yellow
    Write-Host "1. Go to: https://www.oracle.com/database/technologies/instant-client/downloads.html"
    Write-Host "2. Download 'Basic Package' for Windows"
    Write-Host "3. Extract to C:\oracle\instantclient_21_13"
    Write-Host "4. Add C:\oracle\instantclient_21_13 to your PATH"
    Write-Host ""
    Write-Host "After installing, run this script again." -ForegroundColor Yellow
    exit
} else {
    Write-Host "✓ Oracle Instant Client found" -ForegroundColor Green
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Oracle Autonomous Database Information" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Prompt for database information
Write-Host "Please provide your Oracle Autonomous Database details:" -ForegroundColor Yellow
Write-Host ""

$dbUser = Read-Host "Database Username (e.g., ADMIN)"
$dbPassword = Read-Host "Database Password" -AsSecureString
$dbPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($dbPassword))

Write-Host ""
Write-Host "Service Name Format: dbname_high, dbname_medium, or dbname_low" -ForegroundColor Yellow
$serviceName = Read-Host "Service Name (e.g., mydb_high)"

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Wallet Configuration" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

$walletPath = Read-Host "Enter the path to your wallet folder (e.g., C:\oracle\wallet)"

if (-not (Test-Path $walletPath)) {
    Write-Host "Wallet path not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "To download your wallet:" -ForegroundColor Yellow
    Write-Host "1. Log in to Oracle Cloud Console"
    Write-Host "2. Go to Autonomous Database"
    Write-Host "3. Click your database name"
    Write-Host "4. Click 'DB Connection' button"
    Write-Host "5. Click 'Download Wallet'"
    Write-Host "6. Extract the ZIP file to a folder"
    Write-Host ""
    exit
}

Write-Host "✓ Wallet found at: $walletPath" -ForegroundColor Green

# Set TNS_ADMIN environment variable
$env:TNS_ADMIN = $walletPath
[System.Environment]::SetEnvironmentVariable('TNS_ADMIN', $walletPath, 'User')

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Testing Connection" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Testing connection to Oracle Database..." -ForegroundColor Yellow

$testConnection = @"
SET HEADING OFF
SET FEEDBACK OFF
SELECT 'Connection Successful!' FROM DUAL;
EXIT;
"@

$testConnection | sqlplus -S "$dbUser/$dbPasswordPlain@$serviceName"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Connection successful!" -ForegroundColor Green
} else {
    Write-Host "✗ Connection failed!" -ForegroundColor Red
    Write-Host "Please check your credentials and try again." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Creating .env Configuration" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Generate random secret keys
$secretKey = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | % {[char]$_})
$jwtSecretKey = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | % {[char]$_})

# Create backend .env file
$backendEnv = @"
# Flask Application Settings
SECRET_KEY=$secretKey
JWT_SECRET_KEY=$jwtSecretKey
FLASK_ENV=development

# Oracle Database Configuration
ORACLE_USER=$dbUser
ORACLE_PASSWORD=$dbPasswordPlain
ORACLE_DSN=$serviceName
TNS_ADMIN=$walletPath

# CORS Settings
FRONTEND_URL=http://localhost:3000

# File Upload
UPLOAD_FOLDER=./uploads
MAX_CONTENT_LENGTH=16777216

# Logging
LOG_LEVEL=INFO
"@

$backendEnv | Out-File -FilePath "backend\.env" -Encoding UTF8

Write-Host "✓ Backend .env file created" -ForegroundColor Green

# Create frontend .env file
$frontendEnv = @"
# Backend API URL
REACT_APP_API_URL=http://localhost:5000/api

# App Configuration
REACT_APP_NAME=Flask LMS
REACT_APP_VERSION=1.0.0

# Feature Flags
REACT_APP_ENABLE_ANALYTICS=true
REACT_APP_ENABLE_COMMENTS=true
REACT_APP_ENABLE_NOTIFICATIONS=true
"@

$frontendEnv | Out-File -FilePath "frontend\.env" -Encoding UTF8

Write-Host "✓ Frontend .env file created" -ForegroundColor Green

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Deploying Database Schema" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Would you like to deploy the database schema now? (Y/N)" -ForegroundColor Yellow
$deploySchema = Read-Host

if ($deploySchema -eq "Y" -or $deploySchema -eq "y") {
    Write-Host "Deploying schema to Oracle Database..." -ForegroundColor Yellow
    
    $schemaFile = "database\schema.sql"
    
    if (Test-Path $schemaFile) {
        Get-Content $schemaFile | sqlplus "$dbUser/$dbPasswordPlain@$serviceName"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Schema deployed successfully!" -ForegroundColor Green
        } else {
            Write-Host "✗ Schema deployment encountered errors" -ForegroundColor Red
        }
    } else {
        Write-Host "✗ Schema file not found at: $schemaFile" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Setup Complete!" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Your Flask LMS is now configured to use Oracle Database!" -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Start the backend server:"
Write-Host "   cd backend"
Write-Host "   python -m venv venv"
Write-Host "   venv\Scripts\activate"
Write-Host "   pip install -r requirements.txt"
Write-Host "   python app.py"
Write-Host ""
Write-Host "2. Start the frontend (in a new terminal):"
Write-Host "   cd frontend"
Write-Host "   npm install"
Write-Host "   npm start"
Write-Host ""
Write-Host "3. Access the application:"
Write-Host "   Frontend: http://localhost:3000"
Write-Host "   Backend API: http://localhost:5000"
Write-Host ""
