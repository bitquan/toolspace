## 🔒 OPS-Perms Hardening

### Scope

**This PR:** Adds explicit `permissions:` blocks to GitHub Actions workflows with least privilege.

**What changed:**

- ✅ Set default least-privilege: `{contents: read, actions: read}`
- ✅ Elevated only where writes are required (issues/PRs/commits/security-events/actions)
- ✅ Created automation script `scripts/set-workflow-perms.mjs` for future audits

**Non-goals:** Fixing unrelated failing workflows (tracked separately in follow-up issues).

**Audit:** See [baseline audit comment](https://github.com/bitquan/toolspace/pull/96#issuecomment-3383851046) for detailed failure analysis.

---

### Results

✅ **26 workflows hardened** with explicit least-privilege permissions
✅ **Security warnings eliminated** across the entire CI/CD pipeline
✅ **Automation available** for future permission audits

---

###🔧 Elevated Permissions (Only Where Needed)

| Workflow                            | Permissions                                                   | Reason                                              |
| ----------------------------------- | ------------------------------------------------------------- | --------------------------------------------------- |
| `nightly-ci.yml`                    | `contents: write, issues: write`                              | Creates maintenance issues + commits weekly digest  |
| `delta-*.yml`                       | `issues: write, pull-requests: write, contents: write`        | Adaptive sprint manager creates milestones/comments |
| `dev-log-updater.yml`               | `contents: write, pull-requests: read, issues: read`          | Writes dev logs back to repo                        |
| `zeta-scan.yml`                     | `issues: write, pull-requests: write, security-events: write` | Security scanner creates issues/alerts              |
| `zeta-autofix.yml`                  | `contents: write, pull-requests: write`                       | Auto-creates fix PRs                                |
| `firebase-hosting-pull-request.yml` | `checks: write, pull-requests: write`                         | Posts preview URLs + check status                   |
| `workflow-cleanup.yml`              | `actions: write`                                              | Deletes old workflow runs                           |

---

### All Other Workflows

**Read-only by default:** `{contents: read, actions: read}`

- ✅ PR CI pipeline
- ✅ Auth security checks
- ✅ Quality & performance checks
- ✅ Test runners
- ✅ CodeQL scans

---

### Usage

```bash
# Audit current permissions
npm run perms:dry

# Apply permissions hardening
npm run perms:apply
```

---

### Security Impact

**Before:** All workflows had implicit full permissions (security risk)
**After:** Explicit least-privilege enforcement (secure by default)

---

### Testing & Validation

**Audit report:** [PR comment](https://github.com/bitquan/toolspace/pull/96#issuecomment-3383851046) shows all failing checks are pre-existing (not introduced by this PR).

**Verification:**

- ✅ Permissions script tested with dry-run mode
- ✅ 26 workflows successfully hardened
- ✅ Elevated permissions reviewed for actual requirements
- ✅ Baseline comparison confirms no new regressions

---

**Follow-up:** Separate issues created for pre-existing CI failures (Firebase setup, dependency conflicts). These are tracked independently and will not block this security improvement.
