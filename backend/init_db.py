# Database Initialization Script for Flask LMS
# Run this after deploying the schema to create initial data

import sys
import os
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent / 'backend'))

from app import app, db
from models import User
from werkzeug.security import generate_password_hash

def init_database():
    """Initialize database with admin user"""
    
    print("=" * 60)
    print("  Flask LMS - Database Initialization")
    print("=" * 60)
    print()
    
    with app.app_context():
        try:
            # Test database connection
            print("Testing database connection...")
            db.session.execute(db.text('SELECT 1 FROM DUAL'))
            print("✓ Database connection successful")
            print()
            
            # Check if admin user already exists
            admin = User.query.filter_by(username='admin').first()
            
            if admin:
                print("⚠ Admin user already exists!")
                print()
                overwrite = input("Do you want to reset the admin password? (y/N): ")
                
                if overwrite.lower() == 'y':
                    new_password = input("Enter new admin password: ")
                    admin.set_password(new_password)
                    db.session.commit()
                    print("✓ Admin password updated successfully!")
                else:
                    print("Skipping admin user creation.")
            else:
                # Create admin user
                print("Creating admin user...")
                print()
                
                username = input("Admin username (default: admin): ") or "admin"
                email = input("Admin email (default: admin@example.com): ") or "admin@example.com"
                password = input("Admin password: ")
                
                if not password:
                    print("✗ Password cannot be empty!")
                    return
                
                first_name = input("First name (default: Admin): ") or "Admin"
                last_name = input("Last name (default: User): ") or "User"
                
                admin = User(
                    username=username,
                    email=email,
                    first_name=first_name,
                    last_name=last_name,
                    role='admin',
                    is_active=True
                )
                admin.set_password(password)
                
                db.session.add(admin)
                db.session.commit()
                
                print()
                print("✓ Admin user created successfully!")
                print()
                print(f"Username: {username}")
                print(f"Email: {email}")
                print(f"Role: admin")
            
            print()
            print("=" * 60)
            print("  Creating Sample Users (Optional)")
            print("=" * 60)
            print()
            
            create_samples = input("Create sample instructor and student? (Y/n): ")
            
            if create_samples.lower() != 'n':
                # Create sample instructor
                instructor = User.query.filter_by(username='instructor').first()
                if not instructor:
                    instructor = User(
                        username='instructor',
                        email='instructor@example.com',
                        first_name='John',
                        last_name='Instructor',
                        role='instructor',
                        is_active=True
                    )
                    instructor.set_password('instructor123')
                    db.session.add(instructor)
                    print("✓ Sample instructor created (username: instructor, password: instructor123)")
                
                # Create sample student
                student = User.query.filter_by(username='student').first()
                if not student:
                    student = User(
                        username='student',
                        email='student@example.com',
                        first_name='Jane',
                        last_name='Student',
                        role='student',
                        is_active=True
                    )
                    student.set_password('student123')
                    db.session.add(student)
                    print("✓ Sample student created (username: student, password: student123)")
                
                db.session.commit()
            
            print()
            print("=" * 60)
            print("  Database Initialization Complete!")
            print("=" * 60)
            print()
            print("You can now start the Flask application:")
            print("  python app.py")
            print()
            
        except Exception as e:
            print(f"✗ Error: {str(e)}")
            db.session.rollback()
            return False
    
    return True

if __name__ == '__main__':
    init_database()
