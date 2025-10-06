# Roadmap System

This directory contains structured roadmaps that can automatically generate GitHub Issues for project planning and tracking.

## How It Works

1. **Edit roadmap files** (like `phase-1.md`) with structured markdown tables
2. **Run the workflow** via GitHub Actions to generate issues
3. **Auto-created issues** get proper labels, assignments, and epic linking
4. **Branches are created** automatically for each issue (via existing Issue→Branch workflow)

## Table Schema

Each roadmap file must contain a markdown table with these columns:

| Column     | Description            | Required | Example                                  |
| ---------- | ---------------------- | -------- | ---------------------------------------- |
| `epic`     | Group related tasks    | Yes      | "File Merger v1"                         |
| `title`    | Issue title            | Yes      | "UI: drag/drop + progress"               |
| `desc`     | Issue description      | No       | "Flutter UI + upload mgr + progress bar" |
| `labels`   | Comma-separated labels | No       | "feat,tool:file-merger,area:frontend"    |
| `tool`     | Tool/component name    | No       | "file_merger"                            |
| `area`     | Code area              | No       | "frontend", "backend", "ops"             |
| `priority` | Priority level         | No       | "P0-blocker", "P1", "P2"                 |
| `estimate` | Time estimate          | No       | "0.5d", "1w"                             |
| `sprint`   | When to create         | Yes      | "now", "later", "backlog"                |
| `assignee` | GitHub username        | No       | "@bitquan"                               |

## Sprint Control

Only rows with `sprint: now` are processed for issue creation:

- `now` → Create issues immediately
- `later` → Skip for now (future sprint)
- `backlog` → Skip (not prioritized)

## Running the Workflow

### Via GitHub UI (Recommended)

1. Go to **Actions** → **Roadmap → Issues**
2. Click **"Run workflow"**
3. Set parameters:
   - **Path**: `docs/roadmap/phase-1.md` (or your file)
   - **Dry run**: `true` (to preview) or `false` (to create)
4. Review the workflow output

### Via File Changes

The workflow also runs automatically when you push changes to `docs/roadmap/**` files (always in dry-run mode for safety).

## Safety Features

- **Dry run by default**: Must explicitly set `dry_run=false` to create real issues
- **Duplicate detection**: Won't create issues with identical titles
- **Epic management**: Auto-creates epic issues and links child issues
- **Label validation**: Adds appropriate tool/area/priority labels
- **Sprint filtering**: Only processes `sprint: now` items

## Labels Used

The system expects these labels to exist in your repository:

### Issue Types

- `type: epic` - Epic tracking issues
- `feat` - New features
- `fix` - Bug fixes
- `chore` - Maintenance tasks

### Priorities

- `P0-blocker` - Critical/blocking
- `P1` - High priority
- `P2` - Medium priority

### Areas

- `area:frontend` - Flutter/UI work
- `area:backend` - Firebase Functions/API
- `area:ops` - CI/CD/DevOps
- `area:docs` - Documentation

### Tools

- `tool:text-tools` - Text processing tool
- `tool:file-merger` - File merging tool
- `tool:auth` - Authentication system

### Workflow

- `ready` - Ready for development (triggers branch creation)
- `in-progress` - Being worked on

## Examples

### Minimal Example

```markdown
| epic       | title            | sprint |
| ---------- | ---------------- | ------ |
| My Feature | Add login button | now    |
```

### Full Example

```markdown
| epic    | title             | desc                    | labels        | tool | area    | priority | estimate | sprint | assignee |
| ------- | ----------------- | ----------------------- | ------------- | ---- | ------- | -------- | -------- | ------ | -------- |
| Auth v2 | OAuth integration | Add Google/GitHub OAuth | feat,security | auth | backend | P1       | 1d       | now    | @bitquan |
```

## Troubleshooting

### Workflow Fails to Parse Table

- Ensure your table has proper markdown formatting with `|` separators
- Check that you have at least a header row, separator row, and one data row
- Verify column names match the expected schema

### Issues Not Created

- Check if `sprint` column is set to `now`
- Verify the workflow has `issues: write` permissions
- Look for duplicate issues with the same title

### Labels Not Applied

- Ensure required labels exist in your repository
- Check the labels are spelled correctly in the roadmap table
- Priority labels must match exactly: `P0-blocker`, `P1`, `P2`

## Integration with Existing Workflows

This system works with your existing workflows:

1. **Issue→Branch**: When issues get the `ready` label, branches are auto-created
2. **CI/CD**: All branches run through your standard CI pipeline
3. **Project Management**: Issues can be automatically added to GitHub Projects (configure the project number in the workflow)

## Best Practices

1. **Start with dry runs** to preview what will be created
2. **Use consistent epic names** to group related work
3. **Keep titles concise** but descriptive
4. **Add estimates** to help with sprint planning
5. **Update sprint status** as priorities change
6. **Use descriptive labels** for better filtering and automation

## Next Steps

To extend this system:

1. Add project board integration (update project number in workflow)
2. Implement milestone mapping from roadmap dates
3. Add issue templates for different types of work
4. Create reports showing roadmap progress vs actual completion
