# GitHub Pages Setup Instructions

## 🌐 Enable GitHub Pages

Your dashboard files are now pushed to GitHub! Follow these steps to enable GitHub Pages:

### Step 1: Go to Repository Settings

1. Visit: https://github.com/kagm316-oss/Flask-LMS-Cloud
2. Click on **"Settings"** tab (⚙️ gear icon at top right)

### Step 2: Enable GitHub Pages

1. In the left sidebar, click **"Pages"**
2. Under **"Source"**, select:
   - Branch: **main**
   - Folder: **/ (root)**
3. Click **"Save"**

### Step 3: Wait for Deployment (2-3 minutes)

GitHub will build and deploy your site. You'll see:
```
✅ Your site is live at https://kagm316-oss.github.io/Flask-LMS-Cloud/
```

### Step 4: Test the Dashboard

1. Open: https://kagm316-oss.github.io/Flask-LMS-Cloud/
2. The dashboard will load (but won't connect to backend yet)

---

## 🚀 Connect Backend to Frontend

### Option A: Use Local Backend (Easiest for Testing)

1. **Start Flask backend locally:**
   ```powershell
   cd backend
   python app_dashboard.py
   ```

2. **Configure frontend:**
   - Open: https://kagm316-oss.github.io/Flask-LMS-Cloud/
   - In the "Backend API URL" field, enter: `http://localhost:5000`
   - Click "Connect"
   - ✅ Dashboard should now show live data!

**Note:** Browser security may block this. If so, use Option B.

### Option B: Deploy Backend to Oracle Cloud

Deploy your Flask backend to Oracle Cloud Infrastructure (where your database is):

1. **Create Compute Instance:**
   ```bash
   # Oracle Cloud Console → Compute → Instances → Create Instance
   # Choose: Always Free Tier Ubuntu
   ```

2. **Deploy Flask app:**
   ```bash
   # SSH into instance
   git clone https://github.com/kagm316-oss/Flask-LMS-Cloud.git
   cd Flask-LMS-Cloud/backend
   pip install -r requirements.txt
   python app_dashboard.py --host 0.0.0.0 --port 80
   ```

3. **Update frontend:**
   - Enter your server's IP: `http://YOUR-IP-ADDRESS`

### Option C: Use Tunneling (Quick Test)

Use ngrok to expose your local Flask app:

```powershell
# Download ngrok: https://ngrok.com/download
ngrok http 5000
```

This gives you a public URL like: `https://abc123.ngrok.io`

Enter that URL in the dashboard's "Backend API URL" field.

---

## 📋 Verify Everything Works

1. ✅ GitHub Pages is live: https://kagm316-oss.github.io/Flask-LMS-Cloud/
2. ✅ Flask backend is running (locally or cloud)
3. ✅ Dashboard shows "✓ Connected to Oracle"
4. ✅ Can see statistics and data tables
5. ✅ Can create users and courses

---

## 🔧 Troubleshooting

### "Cannot Connect" Error

**Problem:** CORS blocking cross-origin requests

**Solution:** The backend already has CORS enabled for GitHub Pages. Make sure:
- Flask app is running
- You entered the correct URL
- No firewall blocking the connection

### Backend Not Responding

**Check Flask is running:**
```powershell
curl http://localhost:5000/api/health
```

Should return: `{"status": "healthy", "database": "connected"}`

### Database Connection Failed

**Check Oracle credentials:**
- Username: ADMIN
- Password: PA$$word060306
- Service: flasklms_high
- Wallet: Extracted and path is correct

---

## 🎉 Success!

Once everything is connected:

- **Frontend:** https://kagm316-oss.github.io/Flask-LMS-Cloud/
- **Backend:** Your Flask API (local or cloud)
- **Database:** Oracle Autonomous Database (Always Free)

You now have a **fully functional cloud-based LMS!** 🚀

---

## 📝 Next Steps

1. **Add Authentication:** Implement login system
2. **Deploy Backend:** Move Flask to production server
3. **Add Features:** Exams, grades, analytics
4. **Secure API:** Add API keys and rate limiting
5. **Custom Domain:** Point your domain to GitHub Pages

Need help? Check the docs or repository issues!
