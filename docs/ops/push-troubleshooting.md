# Push Troubleshooting Guide

This guide helps resolve common git push issues using the **GIT-01 Push Stabilizer** system.

## 🚀 Quick Start

Use the automated push system for reliable git operations:

```bash
# Recommended: Safe push with preflight checks
npm run push

# Manual preflight check only
npm run push:preflight

# Traditional push (not recommended)
git push
```

## 🔧 How It Works

The Push Stabilizer performs these checks before every push:

1. **Remote & Branch Info** - Shows current remote and branch
2. **User Configuration** - Ensures git user.name and user.email are set
3. **Working Directory** - Checks for uncommitted changes
4. **Sync Status** - Validates local vs remote state
5. **Upstream Setup** - Configures upstream tracking if needed

## 🔍 Common Issues & Fixes

### Issue: "You have uncommitted changes!"

**Problem**: Working directory has modified files

```
❌ ERROR: You have uncommitted changes!
   Please commit or stash your changes before pushing.
```

**Fix**: Commit or stash your changes

```bash
# Option 1: Commit changes
git add .
git commit -m "Your commit message"

# Option 2: Stash changes temporarily
git stash
# ... do your push ...
git stash pop  # Restore changes later
```

### Issue: "Local branch is behind remote!"

**Problem**: Remote has commits you don't have locally

```
❌ ERROR: Local branch is behind remote!
   Please pull/rebase before pushing:
   git pull --rebase origin main
```

**Fix**: Pull and rebase

```bash
# Rebase your changes on top of remote
git pull --rebase origin main

# If conflicts occur, resolve them and continue
git add .
git rebase --continue
```

### Issue: "No upstream set"

**Problem**: Branch doesn't have upstream tracking

```
No upstream set for feature-branch
Will set upstream during push: origin/feature-branch
```

**Fix**: This is handled automatically! The system will set upstream during push.

### Issue: "Branches have diverged"

**Problem**: Local and remote have different commits

```
⚠️  WARNING: Branches have diverged
   Consider rebasing: git pull --rebase origin main
```

**Fix**: Rebase to linearize history

```bash
# Recommended: Rebase to keep clean history
git pull --rebase origin main

# Alternative: Merge (creates merge commit)
git pull origin main
```

### Issue: User configuration missing

**Problem**: Git user.name or user.email not set

```
Setting user.name to 'bitquan-bot'
Setting user.email to 'bot@toolspace'
```

**Fix**: This is handled automatically, or set manually:

```bash
# Set for this repository only
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Set globally for all repositories
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## 🛠️ Advanced Troubleshooting

### Force Push (Dangerous)

Only use force push when you're certain it's safe:

```bash
# Force push (overwrites remote history)
git push --force-with-lease origin branch-name

# Nuclear option (very dangerous)
git push --force origin branch-name
```

**⚠️ Warning**: Force pushing can lose work for other collaborators!

### Reset to Remote State

If local branch is corrupted, reset to match remote:

```bash
# Backup current work first!
git stash

# Reset to match remote exactly
git fetch origin
git reset --hard origin/main
```

### Create New Branch from Remote

Start fresh from remote state:

```bash
# Create new branch from remote
git fetch origin
git checkout -b new-branch-name origin/main
```

## 🔍 Diagnostic Tools

### Run Full Diagnostics

Trigger the diagnostic workflow in GitHub:

1. Go to **Actions** tab in GitHub
2. Select **"🔧 Push Diagnostics"** workflow
3. Click **"Run workflow"**
4. Review the generated report

### Manual Checks

Check your git configuration:

```bash
# View remotes
git remote -v

# Check current branch
git branch

# Check user config
git config user.name
git config user.email

# Check working directory status
git status

# Check relationship to remote
git status -u no -v
```

### Branch Information

```bash
# Show all branches
git branch -a

# Show branch tracking info
git branch -vv

# Show remote branches
git branch -r
```

## 📋 Preflight Checklist

Before pushing, ensure:

- [ ] All changes are committed (`git status` is clean)
- [ ] Local branch is up to date with remote
- [ ] User name and email are configured
- [ ] Branch has proper upstream tracking
- [ ] No rebase/merge conflicts exist

## 🚨 Emergency Procedures

### Recover from Failed Push

If push fails and repository is in bad state:

```bash
# 1. Check what happened
git status
git log --oneline -5

# 2. If in middle of rebase
git rebase --abort  # Cancel rebase
# or
git rebase --continue  # Continue after fixing conflicts

# 3. If in middle of merge
git merge --abort  # Cancel merge

# 4. Return to last known good state
git reflog  # Find the commit you want
git reset --hard HEAD@{n}  # Replace n with reflog index
```

### Contact Support

If you're stuck:

1. Run `npm run push:preflight` and save the output
2. Run the GitHub diagnostics workflow
3. Include both outputs when asking for help
4. Describe what you were trying to accomplish

## 📖 Additional Resources

- [Git Documentation](https://git-scm.com/docs)
- [GitHub Flow Guide](https://guides.github.com/introduction/flow/)
- [Atlassian Git Tutorials](https://www.atlassian.com/git/tutorials)

## 🔄 Workflow Integration

The Push Stabilizer integrates with:

- **OPS-Delta**: Sprint management and velocity tracking
- **OPS-Epsilon**: Notification system for failed pushes
- **OPS-Gamma**: Auto-PR creation and management
- **OPS-Zeta**: Automated code quality checks

For issues with these integrations, check their respective documentation.
