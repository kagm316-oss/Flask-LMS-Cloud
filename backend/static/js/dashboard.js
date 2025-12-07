// Dashboard JavaScript

// API Base URL
const API_BASE = 'http://localhost:5000/api';

// Initialize dashboard
document.addEventListener('DOMContentLoaded', () => {
    checkConnection();
    loadStats();
    loadUsers();
    loadCourses();
    
    // Refresh data every 30 seconds
    setInterval(() => {
        loadStats();
        if (document.getElementById('usersTab').classList.contains('active')) {
            loadUsers();
        } else {
            loadCourses();
        }
    }, 30000);
});

// Check database connection
async function checkConnection() {
    try {
        const response = await fetch('http://localhost:5000/health');
        const data = await response.json();
        
        const statusDot = document.querySelector('.status-dot');
        const statusText = document.querySelector('.status-text');
        
        if (data.status === 'healthy') {
            statusDot.classList.add('connected');
            statusText.textContent = 'Connected to Oracle Database';
        } else {
            statusDot.classList.add('disconnected');
            statusText.textContent = 'Database disconnected';
        }
    } catch (error) {
        const statusDot = document.querySelector('.status-dot');
        const statusText = document.querySelector('.status-text');
        statusDot.classList.add('disconnected');
        statusText.textContent = 'Connection error';
    }
}

// Load dashboard statistics
async function loadStats() {
    try {
        const response = await fetch(`${API_BASE}/stats`);
        const data = await response.json();
        
        if (data.success) {
            document.getElementById('userCount').textContent = data.stats.users;
            document.getElementById('courseCount').textContent = data.stats.courses;
            document.getElementById('examCount').textContent = data.stats.exams;
            document.getElementById('enrollmentCount').textContent = data.stats.enrollments;
        }
    } catch (error) {
        console.error('Error loading stats:', error);
    }
}

// Switch tabs
function switchTab(tabName) {
    // Update tab buttons
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    event.target.classList.add('active');
    
    // Update tab content
    document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
    
    if (tabName === 'users') {
        document.getElementById('usersTab').classList.add('active');
        loadUsers();
    } else if (tabName === 'courses') {
        document.getElementById('coursesTab').classList.add('active');
        loadCourses();
    }
}

// ============================================================================
// Users Management
// ============================================================================

async function loadUsers() {
    try {
        const response = await fetch(`${API_BASE}/users`);
        const data = await response.json();
        
        const tbody = document.getElementById('usersTableBody');
        
        if (data.success && data.users.length > 0) {
            tbody.innerHTML = data.users.map(user => `
                <tr>
                    <td>${user.id}</td>
                    <td><strong>${user.username}</strong></td>
                    <td>${user.email}</td>
                    <td>${user.first_name} ${user.last_name}</td>
                    <td><span class="badge badge-${user.role}">${user.role}</span></td>
                    <td><span class="badge badge-${user.is_active ? 'active' : 'inactive'}">
                        ${user.is_active ? 'Active' : 'Inactive'}
                    </span></td>
                    <td>${formatDate(user.created_at)}</td>
                    <td>
                        <button class="btn btn-danger" onclick="deleteUser(${user.id})">Delete</button>
                    </td>
                </tr>
            `).join('');
        } else {
            tbody.innerHTML = '<tr><td colspan="8" class="loading">No users found</td></tr>';
        }
    } catch (error) {
        console.error('Error loading users:', error);
        showToast('Error loading users', 'error');
    }
}

function showUserForm() {
    document.getElementById('userForm').style.display = 'block';
}

function hideUserForm() {
    document.getElementById('userForm').style.display = 'none';
    document.getElementById('userForm').querySelector('form').reset();
}

async function createUser(event) {
    event.preventDefault();
    
    const userData = {
        username: document.getElementById('username').value,
        email: document.getElementById('email').value,
        first_name: document.getElementById('firstName').value,
        last_name: document.getElementById('lastName').value,
        role: document.getElementById('role').value
    };
    
    try {
        const response = await fetch(`${API_BASE}/users`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(userData)
        });
        
        const data = await response.json();
        
        if (data.success) {
            showToast('User created successfully!', 'success');
            hideUserForm();
            loadUsers();
            loadStats();
        } else {
            showToast('Error: ' + data.error, 'error');
        }
    } catch (error) {
        showToast('Error creating user', 'error');
    }
}

async function deleteUser(userId) {
    if (!confirm('Are you sure you want to delete this user?')) {
        return;
    }
    
    try {
        const response = await fetch(`${API_BASE}/users/${userId}`, {
            method: 'DELETE'
        });
        
        const data = await response.json();
        
        if (data.success) {
            showToast('User deleted successfully!', 'success');
            loadUsers();
            loadStats();
        } else {
            showToast('Error: ' + data.error, 'error');
        }
    } catch (error) {
        showToast('Error deleting user', 'error');
    }
}

// ============================================================================
// Courses Management
// ============================================================================

async function loadCourses() {
    try {
        const response = await fetch(`${API_BASE}/courses`);
        const data = await response.json();
        
        const tbody = document.getElementById('coursesTableBody');
        
        if (data.success && data.courses.length > 0) {
            tbody.innerHTML = data.courses.map(course => `
                <tr>
                    <td>${course.id}</td>
                    <td><strong>${course.title}</strong></td>
                    <td>${course.description || 'No description'}</td>
                    <td>${course.instructor_name || 'Unassigned'}</td>
                    <td>${formatDate(course.created_at)}</td>
                    <td>
                        <button class="btn btn-danger" onclick="deleteCourse(${course.id})">Delete</button>
                    </td>
                </tr>
            `).join('');
        } else {
            tbody.innerHTML = '<tr><td colspan="6" class="loading">No courses found</td></tr>';
        }
    } catch (error) {
        console.error('Error loading courses:', error);
        showToast('Error loading courses', 'error');
    }
}

async function showCourseForm() {
    document.getElementById('courseForm').style.display = 'block';
    
    // Load instructors for dropdown
    try {
        const response = await fetch(`${API_BASE}/users`);
        const data = await response.json();
        
        if (data.success) {
            const instructors = data.users.filter(u => u.role === 'instructor' || u.role === 'admin');
            const select = document.getElementById('courseInstructor');
            
            select.innerHTML = '<option value="">Select Instructor</option>' +
                instructors.map(i => `
                    <option value="${i.id}">${i.first_name} ${i.last_name} (${i.username})</option>
                `).join('');
        }
    } catch (error) {
        console.error('Error loading instructors:', error);
    }
}

function hideCourseForm() {
    document.getElementById('courseForm').style.display = 'none';
    document.getElementById('courseForm').querySelector('form').reset();
}

async function createCourse(event) {
    event.preventDefault();
    
    const courseData = {
        title: document.getElementById('courseTitle').value,
        description: document.getElementById('courseDescription').value,
        instructor_id: parseInt(document.getElementById('courseInstructor').value)
    };
    
    try {
        const response = await fetch(`${API_BASE}/courses`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(courseData)
        });
        
        const data = await response.json();
        
        if (data.success) {
            showToast('Course created successfully!', 'success');
            hideCourseForm();
            loadCourses();
            loadStats();
        } else {
            showToast('Error: ' + data.error, 'error');
        }
    } catch (error) {
        showToast('Error creating course', 'error');
    }
}

async function deleteCourse(courseId) {
    if (!confirm('Are you sure you want to delete this course?')) {
        return;
    }
    
    try {
        const response = await fetch(`${API_BASE}/courses/${courseId}`, {
            method: 'DELETE'
        });
        
        const data = await response.json();
        
        if (data.success) {
            showToast('Course deleted successfully!', 'success');
            loadCourses();
            loadStats();
        } else {
            showToast('Error: ' + data.error, 'error');
        }
    } catch (error) {
        showToast('Error deleting course', 'error');
    }
}

// ============================================================================
// Utilities
// ============================================================================

function formatDate(dateString) {
    if (!dateString) return 'N/A';
    const date = new Date(dateString);
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
}

function showToast(message, type = 'info') {
    const toast = document.getElementById('toast');
    toast.textContent = message;
    toast.className = `toast ${type} show`;
    
    setTimeout(() => {
        toast.classList.remove('show');
    }, 3000);
}
