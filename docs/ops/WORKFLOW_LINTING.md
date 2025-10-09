# GitHub Actions Workflow Linting

## Context Access Warnings (Expected)

The VS Code GitHub Actions extension reports warnings for repository secrets:

```yaml
Context access might be invalid: FIREBASE_TOKEN
Context access might be invalid: FIREBASE_PROJECT_ID
Context access might be invalid: PROD_DOMAIN
```

### Why These Warnings Appear

These are **false positives**. The GitHub Actions schema validator cannot validate repository secrets at parse time because:

1. Secrets are stored in the repository settings, not in the workflow file
2. The linter has no access to your repository's secret store
3. Secret validation only happens at workflow runtime

### Verification

These secrets are correctly referenced using the standard syntax:

```yaml
env:
  FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
```

### What You Should Do

✅ **Ignore these warnings** - they don't affect workflow execution

✅ **Verify secrets exist** in your repository settings:

- Go to: Settings → Secrets and variables → Actions
- Ensure these secrets are defined:
  - `FIREBASE_TOKEN`
  - `FIREBASE_PROJECT_ID`
  - `PROD_DOMAIN`

✅ **Secret validation** is performed at the start of each workflow job to fail fast if secrets are missing

### Additional Context

- GitHub Actions documentation: [Using secrets in GitHub Actions](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions)
- These warnings will disappear once you configure the secrets in your repository settings
- The workflows include explicit validation steps that check for secret existence before deployment

## Summary

**Status**: ✅ All workflows are correctly configured

**Action Required**: Configure the required secrets in your repository settings before running production workflows
