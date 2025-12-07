#!/bin/bash
# Flask LMS - Oracle Cloud Compute Instance Setup Script
# Run this script on your Oracle Cloud Ubuntu instance

set -e

echo "=========================================="
echo "  Flask LMS - Oracle Cloud Setup"
echo "=========================================="
echo ""

# Update system
echo "→ Updating system packages..."
sudo apt update
sudo apt upgrade -y

# Install Python and required packages
echo ""
echo "→ Installing Python and dependencies..."
sudo apt install -y python3 python3-pip python3-venv git nginx

# Install Oracle Instant Client
echo ""
echo "→ Installing Oracle Instant Client..."
cd /opt
sudo wget https://download.oracle.com/otn_software/linux/instantclient/2115000/instantclient-basic-linux.x64-21.15.0.0.0dbru.zip
sudo apt install -y unzip libaio1
sudo unzip instantclient-basic-linux.x64-21.15.0.0.0dbru.zip
sudo sh -c "echo /opt/instantclient_21_15 > /etc/ld.so.conf.d/oracle-instantclient.conf"
sudo ldconfig

# Clone repository
echo ""
echo "→ Cloning Flask LMS repository..."
cd ~
git clone https://github.com/kagm316-oss/Flask-LMS-Cloud.git
cd Flask-LMS-Cloud

# Install Python dependencies
echo ""
echo "→ Installing Python packages..."
cd backend
pip3 install --user -r requirements.txt

# Create wallet directory
echo ""
echo "→ Setting up wallet directory..."
mkdir -p wallet

echo ""
echo "=========================================="
echo "  Initial Setup Complete!"
echo "=========================================="
echo ""
echo "Next Steps:"
echo "1. Upload wallet files to ~/Flask-LMS-Cloud/backend/wallet/"
echo "2. Run: ./configure-flask.sh"
echo ""
