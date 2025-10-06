# Manual Dependabot PR Cleanup Guide

## Quick Steps to Close Failed Dependabot PRs

### 1. Go to Pull Requests Page

- Navigate to: https://github.com/bitquan/toolspace/pulls
- Or click "Pull requests" tab in your repo

### 2. Filter for Dependabot PRs

- In the search box, paste: `is:pr author:app/dependabot is:open`
- This shows only open Dependabot PRs

### 3. Identify Failed PRs

Look for PRs with **red ❌** status (these have failed CI checks):

- `deps(functions)(deps): Bump firebase-admin from 12.7.0 to 13.5.0`
- `deps(flutter)(deps): Bump flutter_lints from 3.0.2 to 6.0.0`
- `deps(actions)(deps): Bump actions/checkout from 4 to 5`
- `deps(actions)(deps): Bump actions/setup-node from 4 to 5`
- Any others with red ❌

### 4. Close Each Failed PR

For each failed PR:

1. **Click on the PR title** (opens the PR page)
2. **Scroll down** to the bottom of the page
3. **Click "Close pull request"** button
4. **Add comment** (optional): "Closing due to CI conflicts. Will be handled in grouped updates."
5. **Confirm closure**

### 5. Keep Successful PRs

**DO NOT close** PRs with:

- ✅ Green checkmark (successful)
- 🟡 Yellow dot (still running)

## What NOT to Close

Keep these if they exist:

- Any PR that shows ✅ (successful CI)
- PRs that are currently running (🟡)
- PRs that update compatible versions

## After Cleanup

You should have:

- No failed (❌) Dependabot PRs
- Only successful (✅) or pending (🟡) PRs remaining
- Much cleaner PR list

## Future Prevention

The new Dependabot config will:

- Group related packages together
- Limit to max 6 open PRs
- Reduce conflicts significantly
