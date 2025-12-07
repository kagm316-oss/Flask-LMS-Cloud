# Database Models for Flask LMS (Oracle Database)

from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash

db = SQLAlchemy()


class User(db.Model):
    """User model for authentication and authorization"""
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False, index=True)
    email = db.Column(db.String(120), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(255), nullable=False)
    first_name = db.Column(db.String(50))
    last_name = db.Column(db.String(50))
    role = db.Column(db.String(20), nullable=False, default='student')  # admin, instructor, student
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    exams = db.relationship('Exam', backref='instructor', lazy='dynamic', foreign_keys='Exam.instructor_id')
    submissions = db.relationship('UserExam', backref='student', lazy='dynamic')
    comments = db.relationship('Comment', backref='author', lazy='dynamic')
    
    def set_password(self, password):
        """Hash and set password"""
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        """Verify password"""
        return check_password_hash(self.password_hash, password)
    
    def to_dict(self, include_email=False):
        """Convert to dictionary for API responses"""
        data = {
            'id': self.id,
            'username': self.username,
            'first_name': self.first_name,
            'last_name': self.last_name,
            'role': self.role,
            'is_active': self.is_active,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }
        if include_email:
            data['email'] = self.email
        return data
    
    def __repr__(self):
        return f'<User {self.username}>'


class Exam(db.Model):
    """Exam model for test management"""
    __tablename__ = 'exams'
    
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text)
    subject = db.Column(db.String(100))
    instructor_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    time_limit = db.Column(db.Integer)  # minutes
    total_points = db.Column(db.Integer, default=0)
    passing_score = db.Column(db.Integer, default=70)
    instructions = db.Column(db.Text)
    status = db.Column(db.String(20), default='draft')  # draft, active, closed, archived
    randomize_questions = db.Column(db.Boolean, default=False)
    randomize_options = db.Column(db.Boolean, default=False)
    show_results = db.Column(db.Boolean, default=True)
    allow_review = db.Column(db.Boolean, default=True)
    availability_start = db.Column(db.DateTime)
    availability_end = db.Column(db.DateTime)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    questions = db.relationship('Question', backref='exam', lazy='dynamic', cascade='all, delete-orphan')
    user_exams = db.relationship('UserExam', backref='exam', lazy='dynamic', cascade='all, delete-orphan')
    comments = db.relationship('Comment', backref='exam', lazy='dynamic', cascade='all, delete-orphan')
    
    def to_dict(self, include_questions=False):
        """Convert to dictionary for API responses"""
        data = {
            'id': self.id,
            'title': self.title,
            'description': self.description,
            'subject': self.subject,
            'instructor_id': self.instructor_id,
            'instructor_name': f"{self.instructor.first_name} {self.instructor.last_name}" if self.instructor else None,
            'time_limit': self.time_limit,
            'total_points': self.total_points,
            'passing_score': self.passing_score,
            'status': self.status,
            'randomize_questions': self.randomize_questions,
            'randomize_options': self.randomize_options,
            'show_results': self.show_results,
            'allow_review': self.allow_review,
            'availability_start': self.availability_start.isoformat() if self.availability_start else None,
            'availability_end': self.availability_end.isoformat() if self.availability_end else None,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'question_count': self.questions.count()
        }
        
        if include_questions:
            data['questions'] = [q.to_dict() for q in self.questions.order_by(Question.order_num)]
        
        return data
    
    def __repr__(self):
        return f'<Exam {self.title}>'


class Question(db.Model):
    """Question model for exam questions"""
    __tablename__ = 'questions'
    
    id = db.Column(db.Integer, primary_key=True)
    exam_id = db.Column(db.Integer, db.ForeignKey('exams.id'), nullable=False)
    question_text = db.Column(db.Text, nullable=False)
    question_type = db.Column(db.String(50), nullable=False)  # multiple_choice, true_false, short_answer, essay
    options = db.Column(db.Text)  # JSON string for multiple choice options
    correct_answer = db.Column(db.Text)
    points = db.Column(db.Integer, default=1)
    order_num = db.Column(db.Integer, default=0)
    explanation = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    submissions = db.relationship('Submission', backref='question', lazy='dynamic', cascade='all, delete-orphan')
    
    def to_dict(self, include_answer=False):
        """Convert to dictionary for API responses"""
        import json
        
        data = {
            'id': self.id,
            'exam_id': self.exam_id,
            'question_text': self.question_text,
            'question_type': self.question_type,
            'points': self.points,
            'order_num': self.order_num
        }
        
        # Parse options if multiple choice
        if self.options:
            try:
                data['options'] = json.loads(self.options)
            except:
                data['options'] = self.options.split(',') if ',' in self.options else []
        
        # Include correct answer only for instructors/grading
        if include_answer:
            data['correct_answer'] = self.correct_answer
            data['explanation'] = self.explanation
        
        return data
    
    def __repr__(self):
        return f'<Question {self.id}>'


class UserExam(db.Model):
    """User-Exam relationship for tracking exam attempts"""
    __tablename__ = 'user_exams'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    exam_id = db.Column(db.Integer, db.ForeignKey('exams.id'), nullable=False)
    start_time = db.Column(db.DateTime, default=datetime.utcnow)
    end_time = db.Column(db.DateTime)
    submit_time = db.Column(db.DateTime)
    score = db.Column(db.Float, default=0)
    max_score = db.Column(db.Integer, default=0)
    status = db.Column(db.String(20), default='in_progress')  # in_progress, submitted, graded, reviewed
    time_taken = db.Column(db.Integer)  # seconds
    ip_address = db.Column(db.String(45))
    
    # Relationships
    submissions = db.relationship('Submission', backref='user_exam', lazy='dynamic', cascade='all, delete-orphan')
    
    def to_dict(self):
        """Convert to dictionary for API responses"""
        percentage = (self.score / self.max_score * 100) if self.max_score > 0 else 0
        
        return {
            'id': self.id,
            'user_id': self.user_id,
            'exam_id': self.exam_id,
            'exam_title': self.exam.title if self.exam else None,
            'student_name': f"{self.student.first_name} {self.student.last_name}" if self.student else None,
            'start_time': self.start_time.isoformat() if self.start_time else None,
            'end_time': self.end_time.isoformat() if self.end_time else None,
            'submit_time': self.submit_time.isoformat() if self.submit_time else None,
            'score': self.score,
            'max_score': self.max_score,
            'percentage': round(percentage, 2),
            'status': self.status,
            'time_taken': self.time_taken,
            'passed': percentage >= (self.exam.passing_score if self.exam else 70)
        }
    
    def __repr__(self):
        return f'<UserExam {self.id}>'


class Submission(db.Model):
    """Submission model for individual question answers"""
    __tablename__ = 'submissions'
    
    id = db.Column(db.Integer, primary_key=True)
    user_exam_id = db.Column(db.Integer, db.ForeignKey('user_exams.id'), nullable=False)
    question_id = db.Column(db.Integer, db.ForeignKey('questions.id'), nullable=False)
    answer = db.Column(db.Text)
    score = db.Column(db.Float, default=0)
    max_score = db.Column(db.Integer, default=0)
    is_correct = db.Column(db.Boolean, default=False)
    auto_graded = db.Column(db.Boolean, default=False)
    feedback = db.Column(db.Text)
    graded_by = db.Column(db.Integer, db.ForeignKey('users.id'))
    graded_at = db.Column(db.DateTime)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self, include_correct_answer=False):
        """Convert to dictionary for API responses"""
        data = {
            'id': self.id,
            'user_exam_id': self.user_exam_id,
            'question_id': self.question_id,
            'answer': self.answer,
            'score': self.score,
            'max_score': self.max_score,
            'is_correct': self.is_correct,
            'auto_graded': self.auto_graded,
            'feedback': self.feedback,
            'graded_at': self.graded_at.isoformat() if self.graded_at else None
        }
        
        if include_correct_answer and self.question:
            data['correct_answer'] = self.question.correct_answer
            data['explanation'] = self.question.explanation
        
        return data
    
    def __repr__(self):
        return f'<Submission {self.id}>'


class Comment(db.Model):
    """Comment model for exam feedback and questions"""
    __tablename__ = 'comments'
    
    id = db.Column(db.Integer, primary_key=True)
    exam_id = db.Column(db.Integer, db.ForeignKey('exams.id'), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    comment_text = db.Column(db.Text, nullable=False)
    screenshot_path = db.Column(db.String(255))
    is_resolved = db.Column(db.Boolean, default=False)
    parent_id = db.Column(db.Integer, db.ForeignKey('comments.id'))  # For replies
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Self-referential relationship for replies
    replies = db.relationship('Comment', backref=db.backref('parent', remote_side=[id]), lazy='dynamic')
    
    def to_dict(self):
        """Convert to dictionary for API responses"""
        return {
            'id': self.id,
            'exam_id': self.exam_id,
            'user_id': self.user_id,
            'author_name': f"{self.author.first_name} {self.author.last_name}" if self.author else None,
            'author_role': self.author.role if self.author else None,
            'comment_text': self.comment_text,
            'screenshot_path': self.screenshot_path,
            'is_resolved': self.is_resolved,
            'parent_id': self.parent_id,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
            'reply_count': self.replies.count()
        }
    
    def __repr__(self):
        return f'<Comment {self.id}>'
