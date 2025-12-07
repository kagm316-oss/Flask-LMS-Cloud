# Deploy Flask Backend to Free Cloud Platforms

Since GitHub Pages cannot run Python, deploy your Flask API to one of these **FREE** platforms:

---

## Option 1: Render.com (Recommended - Easiest) ⭐

### Steps:

1. **Go to Render.com:**
   - Visit: https://render.com
   - Sign up with your GitHub account

2. **Create New Web Service:**
   - Click "New +" → "Web Service"
   - Select "Build and deploy from a Git repository"
   - Connect your GitHub account
   - Select repository: `Flask-LMS-Cloud`

3. **Configure Service:**
   - **Name:** `flask-lms-api`
   - **Region:** Oregon (Free)
   - **Branch:** `main`
   - **Root Directory:** `backend`
   - **Runtime:** Python 3
   - **Build Command:** `pip install -r requirements.txt`
   - **Start Command:** `gunicorn app_dashboard:app`
   - **Plan:** Free

4. **Add Environment Variables:**
   Click "Advanced" → "Add Environment Variable":
   ```
   ORACLE_USER=ADMIN
   ORACLE_PASSWORD=PA$$word060306
   ORACLE_DSN=flasklms_high
   ORACLE_WALLET_PASSWORD=PA$$word060306
   SECRET_KEY=9UCOBi2bhfvoWlgtLr5NuAdG7Mj6KY0s
   JWT_SECRET_KEY=m75eV9sgMRN1K8ZbdHG6PfTLzCJw2q3W
   FLASK_ENV=production
   ```

5. **Upload Wallet Files:**
   You'll need to add wallet files manually or use Render Disks

6. **Deploy:**
   - Click "Create Web Service"
   - Wait 5-10 minutes for deployment
   - Your API URL: `https://flask-lms-api.onrender.com`

7. **Update GitHub Pages:**
   - Visit: https://kagm316-oss.github.io/Flask-LMS-Cloud/
   - Enter API URL: `https://flask-lms-api.onrender.com`
   - Click "Connect"
   - ✅ Done!

**Note:** Free tier sleeps after 15 min of inactivity. First request takes ~30 seconds to wake up.

---

## Option 2: Railway.app

### Steps:

1. Visit: https://railway.app
2. Sign in with GitHub
3. "New Project" → "Deploy from GitHub repo"
4. Select `Flask-LMS-Cloud`
5. Add environment variables (same as above)
6. Deploy
7. Get your URL: `https://your-app.railway.app`

---

## Option 3: PythonAnywhere (24/7 Free Tier)

### Steps:

1. Visit: https://www.pythonanywhere.com
2. Sign up for free account
3. Upload your code
4. Configure WSGI app
5. Free subdomain: `yourusername.pythonanywhere.com`

---

## Option 4: Oracle Cloud (Best - Same as Database)

Since your database is on Oracle Cloud, deploy Flask there too:

### Steps:

1. **Create Compute Instance:**
   - Oracle Cloud Console → Compute → Instances
   - Create Instance → Always Free: VM.Standard.E2.1.Micro
   - OS: Ubuntu 22.04

2. **SSH and Setup:**
   ```bash
   ssh ubuntu@YOUR-IP
   
   # Install Python
   sudo apt update
   sudo apt install python3-pip python3-venv nginx -y
   
   # Clone repo
   git clone https://github.com/kagm316-oss/Flask-LMS-Cloud.git
   cd Flask-LMS-Cloud/backend
   
   # Install dependencies
   pip3 install -r requirements.txt
   
   # Copy wallet files
   # Upload wallet via SCP or SFTP to backend/wallet/
   
   # Run with gunicorn
   gunicorn app_dashboard:app --bind 0.0.0.0:5000
   ```

3. **Configure Firewall:**
   ```bash
   sudo ufw allow 5000
   ```

4. **Setup as Service (Optional):**
   Create `/etc/systemd/system/flask-lms.service`:
   ```ini
   [Unit]
   Description=Flask LMS API
   After=network.target
   
   [Service]
   User=ubuntu
   WorkingDirectory=/home/ubuntu/Flask-LMS-Cloud/backend
   ExecStart=/usr/bin/gunicorn app_dashboard:app --bind 0.0.0.0:5000
   Restart=always
   
   [Install]
   WantedBy=multi-user.target
   ```
   
   ```bash
   sudo systemctl enable flask-lms
   sudo systemctl start flask-lms
   ```

5. **Get Public IP:**
   - Your API: `http://YOUR-ORACLE-IP:5000`

---

## Option 5: Heroku (Deprecated Free Tier)

Heroku removed free tier, but if you have credits:

```bash
heroku create flask-lms-api
git push heroku main
heroku config:set ORACLE_USER=ADMIN
# ... add other vars
```

---

## After Deploying Backend

### Update Frontend to Use Deployed API:

1. Visit: https://kagm316-oss.github.io/Flask-LMS-Cloud/
2. Enter your API URL (from deployment above)
3. Click "Connect"
4. ✅ Dashboard now works from anywhere!

### Or Hardcode the API URL:

Edit `index.html` and change:
```javascript
let API_BASE_URL = 'https://your-deployed-api.com';
```

Then commit and push to GitHub.

---

## Quick Test (Local - For Now)

If you want to test immediately:

1. **Keep Flask running locally:**
   ```powershell
   cd backend
   python app_dashboard.py
   ```

2. **Use ngrok (temporary public URL):**
   ```powershell
   # Download: https://ngrok.com/download
   ngrok http 5000
   ```
   
   This gives you: `https://abc123.ngrok.io`

3. **Use that URL in dashboard:**
   - Visit: https://kagm316-oss.github.io/Flask-LMS-Cloud/
   - Enter: `https://abc123.ngrok.io`
   - Click "Connect"

**Note:** ngrok URL expires when you close it.

---

## Recommended Solution

For a permanent, free solution:

1. **Deploy to Render.com** (easiest, 5 minutes)
2. Or **Oracle Cloud Compute** (best - same cloud as DB)
3. Update GitHub Pages with the deployed URL

This way your dashboard at `https://kagm316-oss.github.io/Flask-LMS-Cloud/` will work from anywhere!

---

## Need Help?

I can help you deploy to any of these platforms. Just let me know which one you prefer!
