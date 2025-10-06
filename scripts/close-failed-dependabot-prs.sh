#!/bin/bash
# Script to close failed Dependabot PRs
# Requires GitHub CLI (gh) to be installed and authenticated

echo "🔍 Finding failed Dependabot PRs..."

# Get all open Dependabot PRs and check their CI status
gh pr list --author app/dependabot --state open --json number,title,url,statusCheckRollup --jq '.[] | select(.statusCheckRollup[]? | select(.state == "FAILURE")) | {number: .number, title: .title, url: .url}' > failed_prs.json

if [ -s failed_prs.json ]; then
    echo "📋 Found failed PRs:"
    cat failed_prs.json | jq -r '"\(.number): \(.title)"'
    
    echo ""
    echo "🗑️ Closing failed PRs..."
    
    # Close each failed PR
    cat failed_prs.json | jq -r '.number' | while read pr_number; do
        echo "Closing PR #$pr_number..."
        gh pr close $pr_number --comment "Auto-closing due to CI failures. Dependencies will be updated in grouped PRs going forward."
    done
    
    echo "✅ Completed closing failed PRs"
else
    echo "✅ No failed Dependabot PRs found"
fi

# Clean up
rm -f failed_prs.json

echo ""
echo "📊 Current Dependabot PR status:"
gh pr list --author app/dependabot --state open --json number,title,statusCheckRollup --jq '.[] | "\(.number): \(.title) - \(.statusCheckRollup[]?.state // "PENDING")"'