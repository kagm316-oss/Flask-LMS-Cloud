# Oracle Cloud Deployment Helper Script
# Run this on your LOCAL Windows machine

Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "  Oracle Cloud - Flask Deployment Helper" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This script will guide you through deploying Flask to Oracle Cloud." -ForegroundColor White
Write-Host ""

# Step 1: Check if user has Oracle Cloud instance
Write-Host "Step 1: Oracle Cloud Instance" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Yellow
Write-Host ""
Write-Host "Have you created an Oracle Cloud Compute instance? (Y/n)" -ForegroundColor White
$hasInstance = Read-Host

if ($hasInstance -eq 'n' -or $hasInstance -eq 'N') {
    Write-Host ""
    Write-Host "Please create an instance first:" -ForegroundColor Yellow
    Write-Host "1. Go to: https://cloud.oracle.com" -ForegroundColor White
    Write-Host "2. Navigate to: Compute → Instances" -ForegroundColor White
    Write-Host "3. Click 'Create Instance'" -ForegroundColor White
    Write-Host "4. Choose: Ubuntu 22.04, VM.Standard.E2.1.Micro (Always Free)" -ForegroundColor White
    Write-Host "5. Download SSH key pair" -ForegroundColor White
    Write-Host ""
    Write-Host "Full guide: See ORACLE_CLOUD_DEPLOY.md" -ForegroundColor Cyan
    Write-Host ""
    
    $openGuide = Read-Host "Open deployment guide? (Y/n)"
    if ($openGuide -ne 'n') {
        Start-Process "ORACLE_CLOUD_DEPLOY.md"
    }
    
    exit
}

# Step 2: Get instance details
Write-Host ""
Write-Host "Step 2: Instance Connection Details" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Yellow
Write-Host ""

$publicIP = Read-Host "Enter your instance's Public IP address"
$keyPath = Read-Host "Enter path to your SSH private key (.key file)"

if (-not (Test-Path $keyPath)) {
    Write-Host ""
    Write-Host "✗ Key file not found: $keyPath" -ForegroundColor Red
    exit 1
}

# Step 3: Test SSH connection
Write-Host ""
Write-Host "Step 3: Testing SSH Connection" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Yellow
Write-Host ""

Write-Host "Testing connection to ubuntu@$publicIP..." -ForegroundColor White

# Fix key permissions
icacls $keyPath /inheritance:r | Out-Null
icacls $keyPath /grant:r "$($env:USERNAME):(R)" | Out-Null

# Test connection
$testCmd = "echo 'Connection successful!'"
$result = ssh -i $keyPath -o StrictHostKeyChecking=no ubuntu@$publicIP $testCmd 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ SSH connection successful!" -ForegroundColor Green
} else {
    Write-Host "✗ Cannot connect to instance" -ForegroundColor Red
    Write-Host "Make sure:" -ForegroundColor Yellow
    Write-Host "  1. Public IP is correct" -ForegroundColor White
    Write-Host "  2. Instance is running (not stopped)" -ForegroundColor White
    Write-Host "  3. Security list allows SSH (port 22)" -ForegroundColor White
    exit 1
}

# Step 4: Upload setup scripts
Write-Host ""
Write-Host "Step 4: Uploading Setup Scripts" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Yellow
Write-Host ""

scp -i $keyPath oracle-cloud-setup.sh ubuntu@${publicIP}:~/ 2>&1 | Out-Null
scp -i $keyPath configure-flask.sh ubuntu@${publicIP}:~/ 2>&1 | Out-Null
scp -i $keyPath start-flask.sh ubuntu@${publicIP}:~/ 2>&1 | Out-Null

Write-Host "✓ Scripts uploaded!" -ForegroundColor Green

# Step 5: Upload wallet
Write-Host ""
Write-Host "Step 5: Upload Wallet Files" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Yellow
Write-Host ""

$walletPath = "C:\Users\kagm3\Downloads\Wallet_flaskLMS.zip"
if (Test-Path $walletPath) {
    Write-Host "Found wallet at: $walletPath" -ForegroundColor White
    scp -i $keyPath $walletPath ubuntu@${publicIP}:~/
    Write-Host "✓ Wallet uploaded!" -ForegroundColor Green
} else {
    Write-Host "⚠ Wallet not found at default location" -ForegroundColor Yellow
    Write-Host "You'll need to upload manually:" -ForegroundColor White
    Write-Host "  scp -i $keyPath C:\path\to\wallet.zip ubuntu@${publicIP}:~/" -ForegroundColor Gray
}

# Step 6: Run setup
Write-Host ""
Write-Host "Step 6: Running Setup on Instance" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Yellow
Write-Host ""

Write-Host "This will install all dependencies. Continue? (Y/n)" -ForegroundColor White
$continue = Read-Host

if ($continue -ne 'n') {
    Write-Host ""
    Write-Host "→ Setting up instance (this takes 5-10 minutes)..." -ForegroundColor White
    Write-Host ""
    
    ssh -i $keyPath ubuntu@$publicIP "bash ~/oracle-cloud-setup.sh"
    
    Write-Host ""
    Write-Host "✓ Setup complete!" -ForegroundColor Green
}

# Step 7: Extract wallet
Write-Host ""
Write-Host "Step 7: Extracting Wallet" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Yellow
Write-Host ""

ssh -i $keyPath ubuntu@$publicIP @"
cd ~/Flask-LMS-Cloud/backend/wallet
if [ -f ~/Wallet_flaskLMS.zip ]; then
    unzip -o ~/Wallet_flaskLMS.zip
    chmod 600 *
    echo 'Wallet extracted!'
fi
"@

# Step 8: Configure Flask
Write-Host ""
Write-Host "Step 8: Configure Flask Application" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Yellow
Write-Host ""

Write-Host "Opening SSH session to configure Flask..." -ForegroundColor White
Write-Host "Commands to run:" -ForegroundColor Cyan
Write-Host "  cd ~/Flask-LMS-Cloud" -ForegroundColor Gray
Write-Host "  bash configure-flask.sh" -ForegroundColor Gray
Write-Host "  bash start-flask.sh" -ForegroundColor Gray
Write-Host ""
Write-Host "Press any key to open SSH connection..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

ssh -i $keyPath ubuntu@$publicIP

# Final instructions
Write-Host ""
Write-Host "======================================================" -ForegroundColor Green
Write-Host "  Deployment Complete!" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your Flask API should now be running at:" -ForegroundColor White
Write-Host "  http://${publicIP}:5000" -ForegroundColor Cyan
Write-Host ""
Write-Host "Test it:" -ForegroundColor Yellow
Write-Host "  curl http://${publicIP}:5000/api/health" -ForegroundColor Gray
Write-Host ""
Write-Host "Update GitHub Pages dashboard:" -ForegroundColor Yellow
Write-Host "  1. Visit: https://kagm316-oss.github.io/Flask-LMS-Cloud/" -ForegroundColor White
Write-Host "  2. Enter API URL: http://${publicIP}:5000" -ForegroundColor White
Write-Host "  3. Click 'Connect'" -ForegroundColor White
Write-Host ""
Write-Host "Management commands (via SSH):" -ForegroundColor Yellow
Write-Host "  sudo systemctl status flask-lms    # Check status" -ForegroundColor Gray
Write-Host "  sudo systemctl restart flask-lms   # Restart" -ForegroundColor Gray
Write-Host "  sudo journalctl -u flask-lms -f    # View logs" -ForegroundColor Gray
Write-Host ""
Write-Host "SSH command:" -ForegroundColor Yellow
Write-Host "  ssh -i $keyPath ubuntu@$publicIP" -ForegroundColor Gray
Write-Host ""
