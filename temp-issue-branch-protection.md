# 🔒 Configure Branch Protection (main/develop)

**Priority:** 🚨 BLOCKING PRODUCTION RELEASE

This issue tracks the required branch protection rules for production-ready repository governance. ALL protections must be configured before production release.

## Required Branch Protection Rules

Configure these in Repository Settings > Branches:

### 🛡️ Main Branch Protection

**Branch name pattern:** `main`

#### Pull Request Requirements
- [ ] ✅ Require a pull request before merging
- [ ] ✅ Require approvals (minimum: **2**)
- [ ] ✅ Dismiss stale PR approvals when new commits are pushed
- [ ] ✅ Require review from code owners (if CODEOWNERS file exists)

#### Status Check Requirements  
- [ ] ✅ Require status checks to pass before merging
- [ ] ✅ Require branches to be up to date before merging

**Required status checks:**
- [ ] `PR CI` - Main CI pipeline
- [ ] `CodeQL` - Security analysis
- [ ] `Auth-Security OK` - Security validation
- [ ] `Firebase Preview Deploy` - Deployment validation
- [ ] `Trivy` - Container/dependency scanning (if present)

#### Additional Restrictions
- [ ] ✅ Restrict pushes that create files that match `.github/workflows/*`
- [ ] ✅ Require linear history (no merge commits)
- [ ] ✅ Do not allow bypassing the above settings (even for admins)

### 🔄 Develop Branch Protection

**Branch name pattern:** `develop`

#### Pull Request Requirements
- [ ] ✅ Require a pull request before merging  
- [ ] ✅ Require approvals (minimum: **1**)
- [ ] ✅ Dismiss stale PR approvals when new commits are pushed

#### Status Check Requirements
- [ ] ✅ Require status checks to pass before merging
- [ ] ✅ Require branches to be up to date before merging

**Required status checks:**
- [ ] `PR CI` - Main CI pipeline
- [ ] `Auth-Security OK` - Security validation

#### Additional Settings
- [ ] ✅ Require linear history
- [ ] ✅ Auto-delete head branches after merge

## Repository-Level Settings

Configure these in Repository Settings > General:

### 🧹 Branch Management
- [ ] ✅ Automatically delete head branches (when PRs are merged)
- [ ] ✅ Default branch: `main`

### 🔐 Additional Security
- [ ] ✅ Disable force pushes to all protected branches
- [ ] ✅ Disable deletions of protected branches
- [ ] ✅ Require status checks for all branches (including administrators)

## Validation Steps

After configuring branch protection:

1. **Test main branch protection:**
   ```bash
   # This should be rejected
   git push origin main
   ```

2. **Test develop branch protection:**  
   ```bash
   # This should be rejected
   git push origin develop
   ```

3. **Test PR workflow:**
   ```bash
   # Create feature branch
   git checkout -b test/branch-protection
   echo "test" > test-file.txt
   git add . && git commit -m "test: branch protection"
   git push origin test/branch-protection
   
   # Open PR via GitHub UI
   # Verify required checks appear
   # Verify approval requirements enforced
   ```

## Implementation Commands

Run these GitHub CLI commands to configure protection (requires admin access):

```bash
# Main branch protection
gh api repos/OWNER/REPO/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["PR CI","CodeQL","Auth-Security OK","Firebase Preview Deploy","Trivy"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"dismiss_stale_reviews":true,"require_code_owner_reviews":true,"required_approving_review_count":2}' \
  --field restrictions=null

# Develop branch protection  
gh api repos/OWNER/REPO/branches/develop/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["PR CI","Auth-Security OK"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"dismiss_stale_reviews":true,"required_approving_review_count":1}' \
  --field restrictions=null
```

## Acceptance Criteria

- [ ] Main branch requires 2 approvals and all status checks
- [ ] Develop branch requires 1 approval and basic status checks
- [ ] Force pushes disabled on both protected branches
- [ ] Linear history enforced on both branches
- [ ] Admin bypass disabled for all protection rules
- [ ] Auto-delete head branches enabled
- [ ] All protection rules tested and verified

## Risk Assessment

**Impact if incomplete:** 
- Accidental direct pushes to main/develop
- Bypassing CI/security checks
- Potential production deployment of untested code

**Mitigation:** Configure all rules before any production deployment

---

**Assigned to:** Repository administrators  
**Due:** Before v1.0.0 production release  
**Labels:** `production`, `security`, `blocking`, `governance`