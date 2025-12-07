# Routes package initialization

from flask import Blueprint

# Import blueprints
from .auth import auth_bp
from .exams import exams_bp
from .students import students_bp
from .analytics import analytics_bp

__all__ = ['auth_bp', 'exams_bp', 'students_bp', 'analytics_bp']
