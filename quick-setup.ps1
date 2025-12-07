# Flask LMS Quick Setup - No SQL*Plus Required
# Uses Python and cx_Oracle for everything

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  Flask LMS - Quick Oracle Setup (Python-based)" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script sets up your Oracle connection using only Python." -ForegroundColor White
Write-Host "No Oracle Instant Client or SQL*Plus required!" -ForegroundColor Green
Write-Host ""

# Step 1: Collect information
Write-Host "Step 1: Oracle Connection Details" -ForegroundColor Yellow
Write-Host "---------------------------------" -ForegroundColor Yellow
Write-Host ""

$dbUser = Read-Host "Oracle Username (usually ADMIN)"
$dbPassword = Read-Host "Oracle Password" -AsSecureString
$dbPasswordText = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($dbPassword)
)

Write-Host ""
Write-Host "Service Name examples: mydb_high, mydb_medium, mydb_low" -ForegroundColor Gray
$serviceName = Read-Host "Service Name"

Write-Host ""
Write-Host "Step 2: Wallet Location" -ForegroundColor Yellow
Write-Host "-----------------------" -ForegroundColor Yellow
Write-Host ""
Write-Host "Where is your wallet ZIP file?" -ForegroundColor White
Write-Host "Download from: Oracle Cloud Console > Database > DB Connection > Download Wallet" -ForegroundColor Gray
Write-Host ""

$walletZip = Read-Host "Full path to wallet ZIP file"

if (-not (Test-Path $walletZip)) {
    Write-Host ""
    Write-Host "✗ File not found: $walletZip" -ForegroundColor Red
    exit 1
}

# Step 3: Extract wallet
Write-Host ""
Write-Host "Step 3: Extracting Wallet" -ForegroundColor Yellow
Write-Host "-------------------------" -ForegroundColor Yellow
Write-Host ""

$walletDir = Join-Path $PSScriptRoot "backend\wallet"
if (-not (Test-Path $walletDir)) {
    New-Item -ItemType Directory -Path $walletDir -Force | Out-Null
}

try {
    Expand-Archive -Path $walletZip -DestinationPath $walletDir -Force
    Write-Host "✓ Wallet extracted to: $walletDir" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to extract wallet: $_" -ForegroundColor Red
    exit 1
}

# Step 4: Create .env file
Write-Host ""
Write-Host "Step 4: Creating Configuration" -ForegroundColor Yellow
Write-Host "-------------------------------" -ForegroundColor Yellow
Write-Host ""

$secretKey = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | ForEach-Object {[char]$_})
$jwtSecret = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | ForEach-Object {[char]$_})

$envContent = @"
# Flask Settings
SECRET_KEY=$secretKey
JWT_SECRET_KEY=$jwtSecret
FLASK_ENV=development

# Oracle Database
ORACLE_USER=$dbUser
ORACLE_PASSWORD=$dbPasswordText
ORACLE_DSN=$serviceName
TNS_ADMIN=$walletDir

# CORS
FRONTEND_URL=http://localhost:3000

# Upload
UPLOAD_FOLDER=./uploads
MAX_CONTENT_LENGTH=16777216
"@

$envPath = Join-Path $PSScriptRoot "backend\.env"
Set-Content -Path $envPath -Value $envContent -Encoding UTF8

Write-Host "✓ Configuration file created" -ForegroundColor Green

# Step 5: Install dependencies
Write-Host ""
Write-Host "Step 5: Installing Python Dependencies" -ForegroundColor Yellow
Write-Host "---------------------------------------" -ForegroundColor Yellow
Write-Host ""

Push-Location (Join-Path $PSScriptRoot "backend")

Write-Host "Installing packages..." -ForegroundColor White
python -m pip install --quiet --upgrade pip
python -m pip install --quiet cx_Oracle python-dotenv

Write-Host "✓ Dependencies installed" -ForegroundColor Green

# Step 6: Test connection and deploy schema
Write-Host ""
Write-Host "Step 6: Testing Connection & Deploying Schema" -ForegroundColor Yellow
Write-Host "----------------------------------------------" -ForegroundColor Yellow
Write-Host ""

$setupScript = @"
import cx_Oracle
import os
from pathlib import Path

# Load environment
from dotenv import load_dotenv
load_dotenv()

user = os.getenv('ORACLE_USER')
password = os.getenv('ORACLE_PASSWORD')
dsn = os.getenv('ORACLE_DSN')
wallet_dir = os.getenv('TNS_ADMIN')

print('Connecting to Oracle Database...')
print(f'User: {user}')
print(f'DSN: {dsn}')
print(f'Wallet: {wallet_dir}')
print()

try:
    # Connect
    connection = cx_Oracle.connect(
        user=user,
        password=password,
        dsn=dsn,
        encoding='UTF-8'
    )
    
    print('✓ Connected successfully!')
    print()
    
    cursor = connection.cursor()
    
    # Test query
    cursor.execute('SELECT 1 FROM DUAL')
    result = cursor.fetchone()
    print(f'✓ Test query successful: {result[0]}')
    print()
    
    # Deploy schema
    print('Deploying database schema...')
    schema_file = Path(__file__).parent.parent / 'database' / 'schema.sql'
    
    if schema_file.exists():
        with open(schema_file, 'r') as f:
            schema_sql = f.read()
        
        # Split into statements
        statements = [s.strip() for s in schema_sql.split(';') if s.strip()]
        
        success = 0
        skipped = 0
        errors = 0
        
        for i, stmt in enumerate(statements, 1):
            if stmt:
                try:
                    cursor.execute(stmt)
                    success += 1
                    print(f'  [{i}/{len(statements)}] ✓', end='\r')
                except cx_Oracle.DatabaseError as e:
                    error_obj, = e.args
                    if error_obj.code == 955:  # ORA-00955: name already used
                        skipped += 1
                    else:
                        errors += 1
                        print(f'\n  [{i}] ✗ {error_obj.message}')
        
        print()
        connection.commit()
        print(f'✓ Schema deployed: {success} created, {skipped} skipped, {errors} errors')
        print()
        
        # Verify tables
        print('Verifying tables...')
        cursor.execute("""
            SELECT table_name 
            FROM user_tables 
            WHERE table_name IN ('USERS', 'COURSES', 'ENROLLMENTS', 'EXAMS', 'QUESTIONS', 'SUBMISSIONS')
            ORDER BY table_name
        """)
        
        tables = cursor.fetchall()
        if tables:
            print('✓ Tables verified:')
            for table in tables:
                print(f'  - {table[0]}')
        
    else:
        print('✗ Schema file not found')
    
    cursor.close()
    connection.close()
    
    print()
    print('=' * 60)
    print('Setup Complete!')
    print('=' * 60)
    
except Exception as e:
    print(f'✗ Error: {str(e)}')
    exit(1)
"@

$tempScript = Join-Path $PSScriptRoot "temp_setup.py"
Set-Content -Path $tempScript -Value $setupScript -Encoding UTF8

python $tempScript

Remove-Item $tempScript -ErrorAction SilentlyContinue

Pop-Location

# Step 7: Create admin user
Write-Host ""
Write-Host "Step 7: Create Admin User" -ForegroundColor Yellow
Write-Host "-------------------------" -ForegroundColor Yellow
Write-Host ""

$createAdmin = Read-Host "Create admin user now? (Y/n)"

if ($createAdmin -ne 'n') {
    Push-Location (Join-Path $PSScriptRoot "backend")
    
    if (Test-Path "init_db.py") {
        python init_db.py
    } else {
        Write-Host "⚠ init_db.py not found - you can create users later" -ForegroundColor Yellow
    }
    
    Pop-Location
}

# Step 8: Summary
Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your Flask LMS is now connected to Oracle Cloud!" -ForegroundColor White
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Start the backend:" -ForegroundColor White
Write-Host "   cd backend" -ForegroundColor Gray
Write-Host "   pip install -r requirements.txt" -ForegroundColor Gray
Write-Host "   python app.py" -ForegroundColor Gray
Write-Host ""
Write-Host "2. In another terminal, start the frontend:" -ForegroundColor White
Write-Host "   cd frontend" -ForegroundColor Gray
Write-Host "   npm install" -ForegroundColor Gray
Write-Host "   npm start" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Access your app:" -ForegroundColor White
Write-Host "   Frontend: http://localhost:3000" -ForegroundColor Gray
Write-Host "   Backend:  http://localhost:5000" -ForegroundColor Gray
Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""
