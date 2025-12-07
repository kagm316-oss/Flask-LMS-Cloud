# Quick Test with ngrok - Get Public URL in 30 Seconds

# This script starts your Flask app and exposes it via ngrok
# So your GitHub Pages dashboard can connect immediately

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Flask LMS - Quick Public URL Setup" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check if ngrok is installed
$ngrokPath = Get-Command ngrok -ErrorAction SilentlyContinue

if (-not $ngrokPath) {
    Write-Host "ngrok not found! Installing..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Download ngrok from: https://ngrok.com/download" -ForegroundColor White
    Write-Host "Or install with chocolatey: choco install ngrok" -ForegroundColor White
    Write-Host ""
    
    $install = Read-Host "Do you want to open the download page? (Y/n)"
    if ($install -ne 'n') {
        Start-Process "https://ngrok.com/download"
    }
    
    Write-Host ""
    Write-Host "After installing ngrok, run this script again!" -ForegroundColor Green
    exit
}

Write-Host "✓ ngrok found!" -ForegroundColor Green
Write-Host ""

# Start Flask in background
Write-Host "Starting Flask API..." -ForegroundColor Yellow
$flaskJob = Start-Job -ScriptBlock {
    Set-Location "C:\Users\kagm3\OneDrive\Desktop\flask-lms-cloud\backend"
    & "C:/Users/kagm3/OneDrive/Desktop/Learning management system/.venv/Scripts/python.exe" app_dashboard.py
}

Write-Host "✓ Flask starting in background..." -ForegroundColor Green
Start-Sleep -Seconds 5

# Start ngrok tunnel
Write-Host ""
Write-Host "Creating public URL with ngrok..." -ForegroundColor Yellow
Write-Host ""

Start-Process powershell -ArgumentList "-NoExit", "-Command", "ngrok http 5000"

Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "1. A new window opened with ngrok" -ForegroundColor White
Write-Host "2. Copy the URL that looks like: https://abc123.ngrok.io" -ForegroundColor White
Write-Host ""
Write-Host "3. Go to: https://kagm316-oss.github.io/Flask-LMS-Cloud/" -ForegroundColor Cyan
Write-Host "4. Paste the ngrok URL in 'Backend API URL'" -ForegroundColor White
Write-Host "5. Click 'Connect'" -ForegroundColor White
Write-Host ""
Write-Host "✅ Your dashboard will now work from anywhere!" -ForegroundColor Green
Write-Host ""
Write-Host "Press Ctrl+C to stop when done" -ForegroundColor Yellow
Write-Host ""

# Keep script running
try {
    while ($true) {
        Start-Sleep -Seconds 1
    }
}
finally {
    Write-Host ""
    Write-Host "Stopping Flask..." -ForegroundColor Yellow
    Stop-Job -Job $flaskJob
    Remove-Job -Job $flaskJob
    Write-Host "✓ Stopped" -ForegroundColor Green
}
