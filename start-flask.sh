#!/bin/bash
# Start Flask LMS as a systemd service

echo "=========================================="
echo "  Starting Flask LMS Service"
echo "=========================================="
echo ""

# Create systemd service file
echo "→ Creating systemd service..."
sudo tee /etc/systemd/system/flask-lms.service > /dev/null << EOF
[Unit]
Description=Flask LMS API Server
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/Flask-LMS-Cloud/backend
Environment="PATH=$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"
ExecStart=$HOME/.local/bin/gunicorn --bind 0.0.0.0:5000 --workers 2 --timeout 120 app_dashboard:app
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start service
echo "→ Starting service..."
sudo systemctl daemon-reload
sudo systemctl enable flask-lms
sudo systemctl start flask-lms

# Check status
sleep 2
sudo systemctl status flask-lms --no-pager

echo ""
echo "=========================================="
echo "  Flask LMS is Running!"
echo "=========================================="
echo ""
echo "✓ Service: flask-lms"
echo "✓ Port: 5000"
echo ""
echo "Useful commands:"
echo "  sudo systemctl status flask-lms   # Check status"
echo "  sudo systemctl restart flask-lms  # Restart"
echo "  sudo systemctl logs flask-lms     # View logs"
echo ""
