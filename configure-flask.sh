#!/bin/bash
# Configure Flask LMS with Oracle credentials

echo "=========================================="
echo "  Flask LMS Configuration"
echo "=========================================="
echo ""

# Get user input
read -p "Oracle Username (ADMIN): " ORACLE_USER
ORACLE_USER=${ORACLE_USER:-ADMIN}

read -sp "Oracle Password: " ORACLE_PASSWORD
echo ""

read -p "Oracle Service Name (flasklms_high): " ORACLE_DSN
ORACLE_DSN=${ORACLE_DSN:-flasklms_high}

read -sp "Wallet Password: " WALLET_PASSWORD
echo ""
echo ""

# Generate secret keys
SECRET_KEY=$(python3 -c 'import secrets; print(secrets.token_hex(32))')
JWT_KEY=$(python3 -c 'import secrets; print(secrets.token_hex(32))')

# Get wallet path
WALLET_PATH="$HOME/Flask-LMS-Cloud/backend/wallet"

# Create .env file
cat > ~/Flask-LMS-Cloud/backend/.env << EOF
# Flask Configuration
SECRET_KEY=$SECRET_KEY
JWT_SECRET_KEY=$JWT_KEY
FLASK_ENV=production

# Oracle Database
ORACLE_USER=$ORACLE_USER
ORACLE_PASSWORD=$ORACLE_PASSWORD
ORACLE_DSN=$ORACLE_DSN
ORACLE_WALLET_PASSWORD=$WALLET_PASSWORD
TNS_ADMIN=$WALLET_PATH

# CORS
FRONTEND_URL=https://kagm316-oss.github.io

# Server
HOST=0.0.0.0
PORT=5000
EOF

echo "✓ Configuration saved!"
echo ""
echo "Next: Run ./start-flask.sh"
