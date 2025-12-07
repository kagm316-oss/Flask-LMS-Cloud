# GitHub Repository Setup Guide

Follow these steps to push your Flask LMS Cloud Edition to GitHub.

## Step 1: Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `flask-lms-cloud`
3. Description: "Modern cloud-ready Learning Management System with REST API and React frontend"
4. Choose: **Public** or **Private**
5. ❌ Do NOT initialize with README (we have one)
6. Click "Create repository"

## Step 2: Initialize Local Git Repository

Open PowerShell in the project directory:

```powershell
cd "c:\Users\kagm3\OneDrive\Desktop\flask-lms-cloud"

# Initialize Git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Flask LMS Cloud Edition with Oracle Database support"
```

## Step 3: Connect to GitHub

Replace `YOUR-USERNAME` with your actual GitHub username:

```powershell
# Add remote repository
git remote add origin https://github.com/YOUR-USERNAME/flask-lms-cloud.git

# Verify remote
git remote -v
```

## Step 4: Push to GitHub

```powershell
# Push to main branch
git branch -M main
git push -u origin main
```

## Step 5: Set Up GitHub Repository Settings

### Enable Features

1. Go to your repository on GitHub
2. Click "Settings"
3. Enable these features:
   - ✅ Issues
   - ✅ Projects
   - ✅ Discussions
   - ✅ Wiki

### Add Repository Topics

In the "About" section, add these topics:
- `learning-management-system`
- `lms`
- `flask`
- `react`
- `oracle-database`
- `rest-api`
- `education`
- `cloud-ready`
- `docker`

### Configure Branch Protection (Optional)

1. Settings → Branches → Add rule
2. Branch name pattern: `main`
3. Enable:
   - ✅ Require pull request reviews
   - ✅ Require status checks to pass
   - ✅ Include administrators

## Step 6: Add Secrets for CI/CD (If deploying)

Settings → Secrets and variables → Actions → New repository secret

Add these secrets if using automated deployment:

```
ORACLE_USER=your_oracle_username
ORACLE_PASSWORD=your_oracle_password
ORACLE_DSN=your_oracle_connection_string
SECRET_KEY=your_flask_secret_key
JWT_SECRET_KEY=your_jwt_secret_key
```

## Step 7: Create Additional Branches (Optional)

```powershell
# Create development branch
git checkout -b develop
git push -u origin develop

# Create staging branch
git checkout -b staging
git push -u origin staging

# Return to main
git checkout main
```

## Step 8: Add Collaborators (If team project)

1. Settings → Collaborators
2. Click "Add people"
3. Enter GitHub usernames
4. Set permissions

## Recommended GitHub Repository Structure

```
main branch        → Production-ready code
├── develop        → Development/integration branch
├── staging        → Staging/testing branch
└── feature/*      → Feature branches
```

## Git Workflow for Team

### Creating a Feature

```powershell
# Update develop branch
git checkout develop
git pull origin develop

# Create feature branch
git checkout -b feature/exam-analytics

# Make changes and commit
git add .
git commit -m "Add exam analytics dashboard"

# Push to GitHub
git push -u origin feature/exam-analytics
```

### Creating Pull Request

1. Go to GitHub repository
2. Click "Pull requests" → "New pull request"
3. Base: `develop` ← Compare: `feature/exam-analytics`
4. Add description and reviewers
5. Click "Create pull request"

### Merging to Main (Release)

```powershell
# Update develop
git checkout develop
git pull origin develop

# Merge to main
git checkout main
git pull origin main
git merge develop

# Tag release
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin main --tags
```

## Common Git Commands

```powershell
# Check status
git status

# View changes
git diff

# View commit history
git log --oneline --graph

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Discard local changes
git checkout -- filename

# Update from remote
git pull

# View branches
git branch -a

# Delete local branch
git branch -d feature/branch-name

# Delete remote branch
git push origin --delete feature/branch-name
```

## Updating Repository After Changes

```powershell
# Stage all changes
git add .

# Commit with message
git commit -m "Description of changes"

# Push to GitHub
git push
```

## Clone Repository on Another Computer

```powershell
# Clone via HTTPS
git clone https://github.com/YOUR-USERNAME/flask-lms-cloud.git

# Or clone via SSH (if configured)
git clone git@github.com:YOUR-USERNAME/flask-lms-cloud.git

cd flask-lms-cloud

# Follow QUICKSTART.md to set up
```

## Troubleshooting

### Authentication Error

If you get authentication errors:

1. **Use Personal Access Token (PAT)**:
   - GitHub → Settings → Developer settings → Personal access tokens
   - Generate new token (classic)
   - Select scopes: `repo`, `workflow`
   - Copy token
   - Use as password when prompted

2. **Configure Git credentials**:
   ```powershell
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

### Push Rejected

If push is rejected:

```powershell
# Pull latest changes first
git pull --rebase origin main

# Then push
git push
```

### Large Files

If you have large files (>100MB):

```powershell
# Install Git LFS
git lfs install

# Track large files
git lfs track "*.zip"
git lfs track "*.pdf"

# Add .gitattributes
git add .gitattributes
git commit -m "Configure Git LFS"
```

## Next Steps

1. ✅ Repository created on GitHub
2. 📝 Add detailed README.md (already included)
3. 📋 Create project board for task tracking
4. 🐛 Set up issue templates
5. 📖 Write documentation in Wiki
6. 🔄 Set up CI/CD pipeline (already included)
7. 📊 Add badges to README (build status, coverage)

## Example README Badges

Add these to your README.md:

```markdown
![Build Status](https://github.com/YOUR-USERNAME/flask-lms-cloud/workflows/CI%2FCD%20Pipeline/badge.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Python](https://img.shields.io/badge/python-3.9+-blue.svg)
![React](https://img.shields.io/badge/react-18.2-blue.svg)
```

---

## Support

For help with Git/GitHub:
- Git Documentation: https://git-scm.com/doc
- GitHub Docs: https://docs.github.com
- Git Cheat Sheet: https://education.github.com/git-cheat-sheet-education.pdf

---

**Your repository is ready to go! 🚀**
