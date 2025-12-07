-- Simple Flask LMS Schema for Oracle

-- Drop tables if they exist
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE submissions CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE questions CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE exams CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE enrollments CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE courses CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE users CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

-- Drop sequences if they exist
BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE users_seq';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE courses_seq';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE enrollments_seq';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE exams_seq';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE questions_seq';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE submissions_seq';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

-- Create tables
CREATE TABLE users (
    id NUMBER PRIMARY KEY,
    username VARCHAR2(80) UNIQUE NOT NULL,
    email VARCHAR2(120) UNIQUE NOT NULL,
    password_hash VARCHAR2(255) NOT NULL,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    role VARCHAR2(20) NOT NULL CHECK (role IN ('admin', 'instructor', 'student')),
    is_active NUMBER(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
/

CREATE TABLE courses (
    id NUMBER PRIMARY KEY,
    title VARCHAR2(200) NOT NULL,
    description CLOB,
    instructor_id NUMBER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_course_instructor FOREIGN KEY (instructor_id) REFERENCES users(id)
)
/

CREATE TABLE enrollments (
    id NUMBER PRIMARY KEY,
    student_id NUMBER NOT NULL,
    course_id NUMBER NOT NULL,
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_enrollment_student FOREIGN KEY (student_id) REFERENCES users(id),
    CONSTRAINT fk_enrollment_course FOREIGN KEY (course_id) REFERENCES courses(id),
    CONSTRAINT uk_enrollment UNIQUE (student_id, course_id)
)
/

CREATE TABLE exams (
    id NUMBER PRIMARY KEY,
    course_id NUMBER NOT NULL,
    title VARCHAR2(200) NOT NULL,
    description CLOB,
    duration_minutes NUMBER,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_exam_course FOREIGN KEY (course_id) REFERENCES courses(id)
)
/

CREATE TABLE questions (
    id NUMBER PRIMARY KEY,
    exam_id NUMBER NOT NULL,
    question_text CLOB NOT NULL,
    question_type VARCHAR2(20) NOT NULL CHECK (question_type IN ('multiple_choice', 'true_false', 'short_answer', 'essay')),
    options CLOB,
    correct_answer CLOB,
    points NUMBER DEFAULT 1,
    CONSTRAINT fk_question_exam FOREIGN KEY (exam_id) REFERENCES exams(id)
)
/

CREATE TABLE submissions (
    id NUMBER PRIMARY KEY,
    exam_id NUMBER NOT NULL,
    student_id NUMBER NOT NULL,
    answers CLOB,
    score NUMBER,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    graded_at TIMESTAMP,
    CONSTRAINT fk_submission_exam FOREIGN KEY (exam_id) REFERENCES exams(id),
    CONSTRAINT fk_submission_student FOREIGN KEY (student_id) REFERENCES users(id),
    CONSTRAINT uk_submission UNIQUE (exam_id, student_id)
)
/

-- Create sequences
CREATE SEQUENCE users_seq START WITH 1 INCREMENT BY 1
/

CREATE SEQUENCE courses_seq START WITH 1 INCREMENT BY 1
/

CREATE SEQUENCE enrollments_seq START WITH 1 INCREMENT BY 1
/

CREATE SEQUENCE exams_seq START WITH 1 INCREMENT BY 1
/

CREATE SEQUENCE questions_seq START WITH 1 INCREMENT BY 1
/

CREATE SEQUENCE submissions_seq START WITH 1 INCREMENT BY 1
/

-- Create triggers for auto-increment
CREATE OR REPLACE TRIGGER users_bi
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    IF :new.id IS NULL THEN
        SELECT users_seq.NEXTVAL INTO :new.id FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER courses_bi
BEFORE INSERT ON courses
FOR EACH ROW
BEGIN
    IF :new.id IS NULL THEN
        SELECT courses_seq.NEXTVAL INTO :new.id FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER enrollments_bi
BEFORE INSERT ON enrollments
FOR EACH ROW
BEGIN
    IF :new.id IS NULL THEN
        SELECT enrollments_seq.NEXTVAL INTO :new.id FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER exams_bi
BEFORE INSERT ON exams
FOR EACH ROW
BEGIN
    IF :new.id IS NULL THEN
        SELECT exams_seq.NEXTVAL INTO :new.id FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER questions_bi
BEFORE INSERT ON questions
FOR EACH ROW
BEGIN
    IF :new.id IS NULL THEN
        SELECT questions_seq.NEXTVAL INTO :new.id FROM dual;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER submissions_bi
BEFORE INSERT ON submissions
FOR EACH ROW
BEGIN
    IF :new.id IS NULL THEN
        SELECT submissions_seq.NEXTVAL INTO :new.id FROM dual;
    END IF;
END;
/

-- Create indexes
CREATE INDEX idx_courses_instructor ON courses(instructor_id)
/

CREATE INDEX idx_enrollments_student ON enrollments(student_id)
/

CREATE INDEX idx_enrollments_course ON enrollments(course_id)
/

CREATE INDEX idx_exams_course ON exams(course_id)
/

CREATE INDEX idx_questions_exam ON questions(exam_id)
/

CREATE INDEX idx_submissions_exam ON submissions(exam_id)
/

CREATE INDEX idx_submissions_student ON submissions(student_id)
/

CREATE INDEX idx_users_email ON users(email)
/
