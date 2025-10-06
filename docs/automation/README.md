# GitHub Copilot Automation System

This directory contains a comprehensive automation system for integrating VS Code with GitHub Copilot development workflows. The system provides both manual and automatic issue assignment to trigger the OPS-Gamma and OPS-Zeta pipelines.

## 🚀 Quick Start

### Prerequisites

1. **GitHub Token**: Create a personal access token with `repo` and `issues` permissions

   - Visit: https://github.com/settings/tokens
   - Required scopes: `repo`, `issues`

2. **Environment Setup**:

   ```powershell
   # Windows (PowerShell)
   $env:GITHUB_TOKEN="your_token_here"

   # Optional: Set repository (auto-detected from git remote)
   $env:GITHUB_REPOSITORY="owner/repo"
   ```

3. **Dependencies**:
   ```bash
   npm install
   ```

## 📋 Available Tools

### 1. Manual Issue Assignment

**VS Code Task**: "Assign Issue to Copilot"

- **Usage**: Command Palette → "Tasks: Run Task" → "Assign Issue to Copilot"
- **Prompts**: Issue number
- **Action**: Assigns existing issue to github-copilot user and adds 'ready' label

**Script**:

```bash
node scripts/assign-to-copilot.mjs <issue_number>
# or
npm run assign <issue_number>
```

### 2. Issue Creation

**VS Code Tasks**:

- "Create Issue" - Interactive issue creation
- "Create Issue and Assign to Copilot" - Create + auto-assign

**Scripts**:

```bash
# Create issue only
node scripts/create-and-assign-issue.mjs
npm run create-issue

# Create and auto-assign
node scripts/create-and-assign-issue.mjs --assign
npm run create-and-assign

# Dry run (preview only)
node scripts/create-and-assign-issue.mjs --dry-run
```

### 3. Bulk Auto-Assignment

**VS Code Task**: "Run Auto-Assignment (Dry Run)"

**Scripts**:

```bash
# Auto-assign recent issues (default: 24 hours)
node scripts/auto-assign-new-issues.mjs

# Dry run (preview only)
node scripts/auto-assign-new-issues.mjs --dry-run

# Custom time window
node scripts/auto-assign-new-issues.mjs --max-age=12

# NPM shortcuts
npm run auto-assign
```

### 4. Automatic GitHub Actions

**Workflow**: `.github/workflows/auto-assign-issues.yml`

**Triggers**:

- **Automatic**: New issue creation
- **Manual**: Workflow dispatch with options

**Manual Trigger**:

1. Go to Actions tab in GitHub
2. Select "Auto-Assign New Issues to Copilot"
3. Click "Run workflow"
4. Choose options:
   - Dry run: Preview without changes
   - Max age: Hours to look back for issues

## 🔄 Pipeline Integration

### OPS-Gamma Integration

When an issue is assigned to `github-copilot` with the `ready` label:

1. OPS-Gamma detects the assignment
2. Creates a feature branch
3. Sets up development environment

### OPS-Zeta Integration

The OPS-Zeta workflow (`.github/workflows/zeta-autodev.yml`) activates when:

1. Issue has `ready` label
2. Issue is assigned to `github-copilot`
3. Performs auto-development, testing, and PR creation

## 📊 Monitoring and Logs

### Log Files

All automation activities are logged to:

- `logs/issue-assignments.log` - Manual assignments
- `logs/auto-assignments.log` - Bulk auto-assignments
- `logs/issue-creation.log` - Issue creation activities

### GitHub Actions Logs

- View workflow runs in the Actions tab
- Download log artifacts for troubleshooting
- Failed runs create issues automatically

## 🛠️ Troubleshooting

### Common Issues

**1. Authentication Errors**

```
ERROR: GITHUB_TOKEN environment variable is required
```

**Solution**: Set your GitHub token in environment variables

**2. Permission Errors**

```
HINT: Token might not have sufficient permissions
```

**Solution**: Ensure token has `repo` and `issues` scopes

**3. Repository Detection Issues**

```
ERROR: Could not determine repository from git remote
```

**Solution**: Set `GITHUB_REPOSITORY` environment variable

### Debug Commands

```bash
# Test assignment with dry run
node scripts/assign-to-copilot.mjs 25 --dry-run

# Check recent issues
node scripts/auto-assign-new-issues.mjs --dry-run --max-age=1

# Verify GitHub token
gh auth status
```

## 📁 File Structure

```
scripts/
├── assign-to-copilot.mjs          # Manual issue assignment
├── auto-assign-new-issues.mjs     # Bulk auto-assignment
└── create-and-assign-issue.mjs    # Issue creation

.github/workflows/
└── auto-assign-issues.yml         # GitHub Actions automation

.vscode/
└── tasks.json                     # VS Code task definitions

logs/                               # Activity logs (auto-created)
├── issue-assignments.log
├── auto-assignments.log
└── issue-creation.log
```

## 🔧 Configuration

### Assignment Rules

Issues are auto-assigned when they:

- ✅ Are open (not closed)
- ✅ Are actual issues (not PRs)
- ✅ Are within the time window (default: 24 hours)
- ✅ Are not already assigned to someone else
- ❌ Skip if already assigned to Copilot
- ❌ Skip if already have 'ready' label

### Label Management

- `ready` - Triggers OPS-Zeta auto-development
- Auto-suggested labels based on content:
  - `enhancement` - Feature keywords
  - `bug` - Bug/fix keywords
  - `documentation` - Doc keywords
  - `ui/ux` - Interface keywords
  - `performance` - Speed/optimization keywords
  - `testing` - Test-related keywords

## 🚦 Testing the Pipeline

### Manual Test (Recommended)

1. Run VS Code task "Assign Issue to Copilot"
2. Enter issue number (e.g., 25)
3. Verify in GitHub:
   - Issue assigned to `github-copilot`
   - Has `ready` label
   - Has automation comment
4. Monitor OPS-Gamma for branch creation
5. Monitor OPS-Zeta for auto-development

### Dry Run Test

```bash
# Test manual assignment (safe)
npm run test-assignment

# Test bulk assignment (safe)
npm run auto-assign -- --dry-run
```

## 📚 NPM Scripts Reference

```json
{
  "assign": "Manual assignment",
  "auto-assign": "Bulk auto-assignment",
  "test-assignment": "Test with issue #25",
  "create-issue": "Interactive issue creation",
  "create-and-assign": "Create + auto-assign"
}
```

## 🔄 Workflow Integration

This automation system integrates with:

- **OPS-Gamma**: Branch management and feature workflows
- **OPS-Zeta**: Auto-development pipeline
- **OPS-Delta**: Sprint management and velocity tracking
- **GitHub Actions**: CI/CD and automation workflows

## 🆘 Support

For issues with this automation system:

1. Check the troubleshooting section above
2. Review log files in the `logs/` directory
3. Test with dry-run mode first
4. Verify GitHub token permissions
5. Create an issue in the repository (it might get auto-assigned!)

---

_Automated GitHub Copilot Integration System v1.0_
