#!/bin/bash
# push-preflight.sh - Git push preflight checks for reliable pushes
# Part of GIT-01 Push Stabilizer

set -e  # Exit on any error

echo "🚀 Git Push Preflight Checks"
echo "============================"

# 1. Print remote + branch info
echo "📍 Remote and Branch Info:"
echo "Remote:"
git remote -v
echo ""
echo "Current branch:"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "  $CURRENT_BRANCH"
echo ""

# 2. Set user if missing
echo "👤 User Configuration:"
USER_NAME=$(git config user.name || echo "")
USER_EMAIL=$(git config user.email || echo "")

if [ -z "$USER_NAME" ]; then
    echo "  Setting user.name to 'bitquan-bot'"
    git config user.name "bitquan-bot"
else
    echo "  user.name: $USER_NAME"
fi

if [ -z "$USER_EMAIL" ]; then
    echo "  Setting user.email to 'bot@toolspace'"
    git config user.email "bot@toolspace"
else
    echo "  user.email: $USER_EMAIL"
fi
echo ""

# 3. Check for uncommitted changes
echo "🔍 Working Directory Status:"
if ! git diff-index --quiet HEAD --; then
    echo "❌ ERROR: You have uncommitted changes!"
    echo "   Please commit or stash your changes before pushing."
    git status --porcelain
    exit 1
else
    echo "✅ Working directory is clean"
fi
echo ""

# 4. Check if rebase is needed
echo "🔄 Sync Status:"
# Fetch latest from remote to check if rebase is needed
git fetch origin "$CURRENT_BRANCH" 2>/dev/null || echo "  (Remote branch not found, will create upstream)"

# Check if upstream exists
UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "")
if [ -z "$UPSTREAM" ]; then
    echo "  No upstream set for $CURRENT_BRANCH"
    echo "  Will set upstream during push: origin/$CURRENT_BRANCH"
else
    echo "  Upstream: $UPSTREAM"

    # Check if we're behind remote
    LOCAL_COMMIT=$(git rev-parse HEAD)
    REMOTE_COMMIT=$(git rev-parse @{u} 2>/dev/null || echo "$LOCAL_COMMIT")

    if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
        # Check if we can fast-forward
        if git merge-base --is-ancestor @{u} HEAD 2>/dev/null; then
            echo "✅ Local branch is ahead of remote"
        elif git merge-base --is-ancestor HEAD @{u} 2>/dev/null; then
            echo "❌ ERROR: Local branch is behind remote!"
            echo "   Please pull/rebase before pushing:"
            echo "   git pull --rebase origin $CURRENT_BRANCH"
            exit 1
        else
            echo "⚠️  WARNING: Branches have diverged"
            echo "   Consider rebasing: git pull --rebase origin $CURRENT_BRANCH"
            # Don't exit here - let user decide
        fi
    else
        echo "✅ Local and remote are in sync"
    fi
fi
echo ""

# 5. Ensure upstream will be set
echo "🎯 Push Configuration:"
if [ -z "$UPSTREAM" ]; then
    echo "  Will set upstream: git push -u origin $CURRENT_BRANCH"
else
    echo "  Upstream configured: git push"
fi
echo ""

echo "✅ All preflight checks passed!"
echo "Ready to push $CURRENT_BRANCH"
echo ""
