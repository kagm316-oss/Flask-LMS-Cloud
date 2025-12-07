# Oracle Cloud Compute - Complete Deployment Guide

## Prerequisites

- Oracle Cloud Account (Free Tier)
- SSH client (PuTTY, OpenSSH, or PowerShell)
- Wallet files from Oracle Autonomous Database

---

## Step 1: Create Compute Instance

### 1.1 Create Instance in Oracle Cloud Console

1. **Login to Oracle Cloud:**
   - Go to: https://cloud.oracle.com
   - Sign in with your credentials

2. **Navigate to Compute:**
   - Click ☰ Menu → Compute → Instances

3. **Create Instance:**
   - Click **"Create Instance"**
   
   **Configuration:**
   - **Name:** `flask-lms-server`
   - **Compartment:** (root) - keep default
   - **Placement:** Keep default
   - **Image:** Ubuntu 22.04 (Oracle Linux also works)
   - **Shape:** VM.Standard.E2.1.Micro (Always Free)
     - 1 OCPU
     - 1 GB RAM
   - **Networking:**
     - Use default VCN
     - Assign public IP: ✅ Yes
   - **SSH Keys:**
     - Generate new key pair (download both private and public keys)
     - Save the private key securely

4. **Click "Create"**
   - Wait 2-3 minutes for provisioning
   - Note the **Public IP Address** (e.g., 152.70.xxx.xxx)

### 1.2 Configure Firewall Rules

1. **Navigate to VCN:**
   - Instance Details → Primary VNIC → Subnet → Default Security List

2. **Add Ingress Rule:**
   - Click "Add Ingress Rules"
   - **Source CIDR:** `0.0.0.0/0`
   - **IP Protocol:** TCP
   - **Destination Port:** `5000`
   - **Description:** Flask API
   - Click "Add Ingress Rules"

3. **Add HTTP/HTTPS (Optional):**
   - Repeat for ports 80 and 443 if using nginx

---

## Step 2: Connect to Instance via SSH

### Windows (PowerShell):

```powershell
# Set correct permissions on private key
icacls flask-lms-server.key /inheritance:r
icacls flask-lms-server.key /grant:r "$($env:USERNAME):(R)"

# Connect via SSH
ssh -i flask-lms-server.key ubuntu@YOUR_PUBLIC_IP
```

### Windows (PuTTY):

1. Convert `.key` to `.ppk` using PuTTYgen
2. Open PuTTY
3. Host: `ubuntu@YOUR_PUBLIC_IP`
4. Connection → SSH → Auth → Browse to `.ppk` file
5. Click "Open"

### Linux/Mac:

```bash
chmod 400 flask-lms-server.key
ssh -i flask-lms-server.key ubuntu@YOUR_PUBLIC_IP
```

---

## Step 3: Setup Flask on Instance

### 3.1 Run Setup Script

Once connected via SSH:

```bash
# Download setup script
wget https://raw.githubusercontent.com/kagm316-oss/Flask-LMS-Cloud/main/oracle-cloud-setup.sh

# Make executable
chmod +x oracle-cloud-setup.sh

# Run setup
./oracle-cloud-setup.sh
```

This will:
- ✅ Update system packages
- ✅ Install Python 3, pip, nginx
- ✅ Install Oracle Instant Client
- ✅ Clone Flask LMS repository
- ✅ Install Python dependencies

### 3.2 Upload Wallet Files

**From your local machine (new PowerShell window):**

```powershell
# Navigate to wallet location
cd "C:\Users\kagm3\Downloads"

# Upload wallet ZIP
scp -i flask-lms-server.key Wallet_flaskLMS.zip ubuntu@YOUR_PUBLIC_IP:~/

# Or upload individual files
scp -i flask-lms-server.key -r "C:\Users\kagm3\OneDrive\Desktop\flask-lms-cloud\backend\wallet" ubuntu@YOUR_PUBLIC_IP:~/Flask-LMS-Cloud/backend/
```

**Back on the server:**

```bash
# Extract wallet if uploaded as ZIP
cd ~/Flask-LMS-Cloud/backend/wallet
unzip ~/Wallet_flaskLMS.zip

# Set permissions
chmod 600 *
```

### 3.3 Configure Flask

```bash
# Download configure script
cd ~/Flask-LMS-Cloud
wget https://raw.githubusercontent.com/kagm316-oss/Flask-LMS-Cloud/main/configure-flask.sh
chmod +x configure-flask.sh

# Run configuration
./configure-flask.sh
```

Enter when prompted:
- Oracle Username: `ADMIN`
- Oracle Password: `PA$$word060306`
- Service Name: `flasklms_high`
- Wallet Password: `PA$$word060306`

---

## Step 4: Start Flask Service

```bash
# Download start script
wget https://raw.githubusercontent.com/kagm316-oss/Flask-LMS-Cloud/main/start-flask.sh
chmod +x start-flask.sh

# Start Flask
./start-flask.sh
```

This creates a systemd service that:
- ✅ Starts automatically on boot
- ✅ Restarts on failure
- ✅ Runs with gunicorn (production server)

### Verify It's Running

```bash
# Check service status
sudo systemctl status flask-lms

# Test API locally
curl http://localhost:5000/api/health

# Test from internet
curl http://YOUR_PUBLIC_IP:5000/api/health
```

Should return:
```json
{"status":"healthy","database":"connected"}
```

---

## Step 5: Configure Ubuntu Firewall

```bash
# Allow Flask port
sudo ufw allow 5000/tcp

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status
```

---

## Step 6: Update GitHub Pages Dashboard

### 6.1 Get Your API URL

Your API is now at: `http://YOUR_PUBLIC_IP:5000`

Example: `http://152.70.123.45:5000`

### 6.2 Update Frontend

**Option A: Manual Update (Users enter URL)**

1. Visit: https://kagm316-oss.github.io/Flask-LMS-Cloud/
2. In "Backend API URL" field, enter: `http://YOUR_PUBLIC_IP:5000`
3. Click "Connect"
4. ✅ Dashboard now connected!

**Option B: Hardcode URL (Auto-connect)**

Edit `index.html` on your local machine:

```javascript
// Change this line:
let API_BASE_URL = localStorage.getItem('api_url') || 'http://localhost:5000';

// To:
let API_BASE_URL = localStorage.getItem('api_url') || 'http://YOUR_PUBLIC_IP:5000';
```

Then commit and push:

```powershell
cd "C:\Users\kagm3\OneDrive\Desktop\flask-lms-cloud"
git add index.html
git commit -m "Update API URL to Oracle Cloud instance"
git push origin main
```

---

## Step 7: Optional - Setup HTTPS with Domain

### 7.1 Point Domain to Instance

If you have a domain (e.g., `api.yourdomain.com`):

1. Add A record: `api.yourdomain.com` → `YOUR_PUBLIC_IP`

### 7.2 Install Certbot (Let's Encrypt)

```bash
# Install nginx and certbot
sudo apt install -y nginx certbot python3-certbot-nginx

# Configure nginx
sudo tee /etc/nginx/sites-available/flask-lms > /dev/null << 'EOF'
server {
    listen 80;
    server_name api.yourdomain.com;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

# Enable site
sudo ln -s /etc/nginx/sites-available/flask-lms /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Get SSL certificate
sudo certbot --nginx -d api.yourdomain.com
```

Now access via: `https://api.yourdomain.com`

---

## Management Commands

```bash
# Check service status
sudo systemctl status flask-lms

# View logs
sudo journalctl -u flask-lms -f

# Restart service
sudo systemctl restart flask-lms

# Stop service
sudo systemctl stop flask-lms

# Start service
sudo systemctl start flask-lms

# Update code
cd ~/Flask-LMS-Cloud
git pull origin main
sudo systemctl restart flask-lms
```

---

## Troubleshooting

### Service won't start:

```bash
# Check logs
sudo journalctl -u flask-lms --no-pager | tail -50

# Check Python errors
cd ~/Flask-LMS-Cloud/backend
python3 app_dashboard.py
```

### Database connection fails:

```bash
# Test Oracle connection
cd ~/Flask-LMS-Cloud/backend
python3 -c "
import oracledb
conn = oracledb.connect(
    user='ADMIN',
    password='PA\$\$word060306',
    dsn='flasklms_high',
    config_dir='wallet',
    wallet_location='wallet',
    wallet_password='PA\$\$word060306'
)
print('Connected!')
"
```

### Port 5000 not accessible:

```bash
# Check if service is listening
sudo netstat -tlnp | grep 5000

# Check firewall
sudo ufw status

# Check Oracle Cloud Security List (in web console)
```

---

## Cost

**Always Free Resources:**
- ✅ 1x VM.Standard.E2.1.Micro instance
- ✅ 1 OCPU + 1 GB RAM
- ✅ 50 GB storage
- ✅ Unlimited outbound data transfer (first 10 TB/month)
- ✅ No charges for stopped instances

Your Flask LMS API will run **24/7 for FREE**! 🎉

---

## Summary

After completing these steps:

- ✅ Flask API running on Oracle Cloud (same as database)
- ✅ Accessible at `http://YOUR_PUBLIC_IP:5000`
- ✅ Auto-starts on boot
- ✅ GitHub Pages dashboard connected
- ✅ Completely free (Always Free Tier)

Your LMS is now **fully deployed in the cloud**! 🚀
