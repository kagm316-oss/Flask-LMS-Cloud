"""Test Oracle Database Connection"""
import oracledb
import os
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

user = os.getenv('ORACLE_USER')
password = os.getenv('ORACLE_PASSWORD')
dsn = os.getenv('ORACLE_DSN')
wallet_dir = os.getenv('TNS_ADMIN')

print("=" * 60)
print("  Oracle Database Connection Test")
print("=" * 60)
print()
print(f"User: {user}")
print(f"DSN: {dsn}")
print(f"Wallet: {wallet_dir}")
print()

try:
    # Connect to Oracle
    print("Connecting to Oracle Database...")
    connection = oracledb.connect(
        user=user,
        password=password,
        dsn=dsn,
        config_dir=wallet_dir,
        wallet_location=wallet_dir
    )
    
    print("✓ Connected successfully!")
    print()
    
    cursor = connection.cursor()
    
    # Test query
    print("Running test query...")
    cursor.execute("SELECT 'Hello from Oracle!' AS message FROM DUAL")
    result = cursor.fetchone()
    print(f"✓ Query result: {result[0]}")
    print()
    
    # Check Oracle version
    cursor.execute("SELECT BANNER FROM V$VERSION WHERE ROWNUM = 1")
    version = cursor.fetchone()
    print(f"✓ Oracle Version: {version[0]}")
    print()
    
    cursor.close()
    connection.close()
    
    print("=" * 60)
    print("  Connection Test PASSED!")
    print("=" * 60)
    print()
    
except Exception as e:
    print(f"✗ Connection failed: {str(e)}")
    print()
    print("Troubleshooting tips:")
    print("1. Verify your username and password")
    print("2. Check that the wallet files are in:", wallet_dir)
    print("3. Verify the service name in tnsnames.ora")
    print("4. Ensure network access is allowed in Oracle Cloud")
    exit(1)
