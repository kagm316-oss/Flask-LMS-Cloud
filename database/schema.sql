-- Oracle Database Schema for Flask LMS
-- Compatible with Oracle Database Free Tier (Always Free)

-- Drop existing tables (for clean install)
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE submissions CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE comments CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE user_exams CASCADE CONSTRAINTS';
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
   EXECUTE IMMEDIATE 'DROP TABLE users CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE users_seq';
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
   EXECUTE IMMEDIATE 'DROP SEQUENCE user_exams_seq';
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

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE comments_seq';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

-- Create sequences for primary keys
CREATE SEQUENCE users_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE exams_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE questions_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE user_exams_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE submissions_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE comments_seq START WITH 1 INCREMENT BY 1;

-- Users Table
CREATE TABLE users (
    id NUMBER(10) PRIMARY KEY,
    username VARCHAR2(50) UNIQUE NOT NULL,
    email VARCHAR2(120) UNIQUE NOT NULL,
    password_hash VARCHAR2(255) NOT NULL,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    role VARCHAR2(20) DEFAULT 'student' NOT NULL,
    is_active NUMBER(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for users table
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- Trigger for users auto-increment
CREATE OR REPLACE TRIGGER users_bir 
BEFORE INSERT ON users 
FOR EACH ROW
BEGIN
  IF :NEW.id IS NULL THEN
    SELECT users_seq.NEXTVAL INTO :NEW.id FROM DUAL;
  END IF;
END;
/

-- Trigger for users updated_at
CREATE OR REPLACE TRIGGER users_bur
BEFORE UPDATE ON users
FOR EACH ROW
BEGIN
  :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

-- Exams Table
CREATE TABLE exams (
    id NUMBER(10) PRIMARY KEY,
    title VARCHAR2(200) NOT NULL,
    description CLOB,
    subject VARCHAR2(100),
    instructor_id NUMBER(10) NOT NULL,
    time_limit NUMBER(10),
    total_points NUMBER(10) DEFAULT 0,
    passing_score NUMBER(10) DEFAULT 70,
    instructions CLOB,
    status VARCHAR2(20) DEFAULT 'draft',
    randomize_questions NUMBER(1) DEFAULT 0,
    randomize_options NUMBER(1) DEFAULT 0,
    show_results NUMBER(1) DEFAULT 1,
    allow_review NUMBER(1) DEFAULT 1,
    availability_start TIMESTAMP,
    availability_end TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_exams_instructor FOREIGN KEY (instructor_id) REFERENCES users(id)
);

-- Create indexes for exams table
CREATE INDEX idx_exams_instructor ON exams(instructor_id);
CREATE INDEX idx_exams_status ON exams(status);

-- Trigger for exams auto-increment
CREATE OR REPLACE TRIGGER exams_bir 
BEFORE INSERT ON exams 
FOR EACH ROW
BEGIN
  IF :NEW.id IS NULL THEN
    SELECT exams_seq.NEXTVAL INTO :NEW.id FROM DUAL;
  END IF;
END;
/

-- Trigger for exams updated_at
CREATE OR REPLACE TRIGGER exams_bur
BEFORE UPDATE ON exams
FOR EACH ROW
BEGIN
  :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

-- Questions Table
CREATE TABLE questions (
    id NUMBER(10) PRIMARY KEY,
    exam_id NUMBER(10) NOT NULL,
    question_text CLOB NOT NULL,
    question_type VARCHAR2(50) NOT NULL,
    options CLOB,
    correct_answer CLOB,
    points NUMBER(10) DEFAULT 1,
    order_num NUMBER(10) DEFAULT 0,
    explanation CLOB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_questions_exam FOREIGN KEY (exam_id) REFERENCES exams(id) ON DELETE CASCADE
);

-- Create indexes for questions table
CREATE INDEX idx_questions_exam ON questions(exam_id);
CREATE INDEX idx_questions_order ON questions(exam_id, order_num);

-- Trigger for questions auto-increment
CREATE OR REPLACE TRIGGER questions_bir 
BEFORE INSERT ON questions 
FOR EACH ROW
BEGIN
  IF :NEW.id IS NULL THEN
    SELECT questions_seq.NEXTVAL INTO :NEW.id FROM DUAL;
  END IF;
END;
/

-- User Exams Table (Exam Attempts)
CREATE TABLE user_exams (
    id NUMBER(10) PRIMARY KEY,
    user_id NUMBER(10) NOT NULL,
    exam_id NUMBER(10) NOT NULL,
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP,
    submit_time TIMESTAMP,
    score NUMBER(10,2) DEFAULT 0,
    max_score NUMBER(10) DEFAULT 0,
    status VARCHAR2(20) DEFAULT 'in_progress',
    time_taken NUMBER(10),
    ip_address VARCHAR2(45),
    CONSTRAINT fk_user_exams_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_user_exams_exam FOREIGN KEY (exam_id) REFERENCES exams(id) ON DELETE CASCADE
);

-- Create indexes for user_exams table
CREATE INDEX idx_user_exams_user ON user_exams(user_id);
CREATE INDEX idx_user_exams_exam ON user_exams(exam_id);
CREATE INDEX idx_user_exams_status ON user_exams(status);

-- Trigger for user_exams auto-increment
CREATE OR REPLACE TRIGGER user_exams_bir 
BEFORE INSERT ON user_exams 
FOR EACH ROW
BEGIN
  IF :NEW.id IS NULL THEN
    SELECT user_exams_seq.NEXTVAL INTO :NEW.id FROM DUAL;
  END IF;
END;
/

-- Submissions Table (Individual Answers)
CREATE TABLE submissions (
    id NUMBER(10) PRIMARY KEY,
    user_exam_id NUMBER(10) NOT NULL,
    question_id NUMBER(10) NOT NULL,
    answer CLOB,
    score NUMBER(10,2) DEFAULT 0,
    max_score NUMBER(10) DEFAULT 0,
    is_correct NUMBER(1) DEFAULT 0,
    auto_graded NUMBER(1) DEFAULT 0,
    feedback CLOB,
    graded_by NUMBER(10),
    graded_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_submissions_user_exam FOREIGN KEY (user_exam_id) REFERENCES user_exams(id) ON DELETE CASCADE,
    CONSTRAINT fk_submissions_question FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    CONSTRAINT fk_submissions_grader FOREIGN KEY (graded_by) REFERENCES users(id)
);

-- Create indexes for submissions table
CREATE INDEX idx_submissions_user_exam ON submissions(user_exam_id);
CREATE INDEX idx_submissions_question ON submissions(question_id);

-- Trigger for submissions auto-increment
CREATE OR REPLACE TRIGGER submissions_bir 
BEFORE INSERT ON submissions 
FOR EACH ROW
BEGIN
  IF :NEW.id IS NULL THEN
    SELECT submissions_seq.NEXTVAL INTO :NEW.id FROM DUAL;
  END IF;
END;
/

-- Comments Table
CREATE TABLE comments (
    id NUMBER(10) PRIMARY KEY,
    exam_id NUMBER(10) NOT NULL,
    user_id NUMBER(10) NOT NULL,
    comment_text CLOB NOT NULL,
    screenshot_path VARCHAR2(255),
    is_resolved NUMBER(1) DEFAULT 0,
    parent_id NUMBER(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_comments_exam FOREIGN KEY (exam_id) REFERENCES exams(id) ON DELETE CASCADE,
    CONSTRAINT fk_comments_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_comments_parent FOREIGN KEY (parent_id) REFERENCES comments(id)
);

-- Create indexes for comments table
CREATE INDEX idx_comments_exam ON comments(exam_id);
CREATE INDEX idx_comments_user ON comments(user_id);
CREATE INDEX idx_comments_parent ON comments(parent_id);

-- Trigger for comments auto-increment
CREATE OR REPLACE TRIGGER comments_bir 
BEFORE INSERT ON comments 
FOR EACH ROW
BEGIN
  IF :NEW.id IS NULL THEN
    SELECT comments_seq.NEXTVAL INTO :NEW.id FROM DUAL;
  END IF;
END;
/

-- Trigger for comments updated_at
CREATE OR REPLACE TRIGGER comments_bur
BEFORE UPDATE ON comments
FOR EACH ROW
BEGIN
  :NEW.updated_at := CURRENT_TIMESTAMP;
END;
/

-- Grant permissions (adjust as needed for your user)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON users TO lms_user;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON exams TO lms_user;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON questions TO lms_user;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON user_exams TO lms_user;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON submissions TO lms_user;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON comments TO lms_user;

-- Commit changes
COMMIT;

-- Display success message
SELECT 'Database schema created successfully!' AS status FROM DUAL;
