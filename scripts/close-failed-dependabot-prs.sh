#!/bin/bash
# Script to close failed Dependabot PRs
# Requires GitHub CLI (gh) and jq to be installed and authenticated

# Check dependencies
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed. Please install it first."
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "❌ jq is not installed. Please install it first."
    echo "  On Ubuntu/Debian: sudo apt install jq"
    echo "  On macOS: brew install jq"
    exit 1
fi

echo "🔍 Finding failed Dependabot PRs..."

# Get all open Dependabot PRs and check their CI status
gh pr list --author app/dependabot --state open --json number,title,url,statusCheckRollup --jq '.[] | select(.statusCheckRollup[]? | select(.state == "FAILURE")) | {number: .number, title: .title, url: .url}' > failed_prs.json

if [ -s failed_prs.json ]; then
    echo "📋 Found failed PRs:"
    cat failed_prs.json | jq -r '"\(.number): \(.title)"'
    
    echo ""
    read -p "Do you want to close these failed PRs? (y/N): " confirmation
    
    if [[ $confirmation == "y" || $confirmation == "Y" ]]; then
        echo "🗑️ Closing failed PRs..."
        
        # Close each failed PR
        cat failed_prs.json | jq -r '.number' | while read pr_number; do
            echo "Closing PR #$pr_number..."
            gh pr close $pr_number --comment "Auto-closing due to CI failures. Dependencies will be updated in grouped PRs going forward."
        done
        
        echo "✅ Completed closing failed PRs"
    else
        echo "❌ Operation cancelled"
    fi
else
    echo "✅ No failed Dependabot PRs found"
fi

# Clean up
rm -f failed_prs.json

echo ""
echo "📊 Current Dependabot PR status:"
gh pr list --author app/dependabot --state open --json number,title,statusCheckRollup --jq '.[] | "\(.number): \(.title) - \(.statusCheckRollup[]?.state // "PENDING")"'
