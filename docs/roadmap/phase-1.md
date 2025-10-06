# Toolspace Roadmap — Phase 1

> Only rows with `sprint: now` are created automatically.

| epic              | title                          | desc                                            | labels                              | tool        | area     | priority | estimate | sprint  | assignee |
| ----------------- | ------------------------------ | ----------------------------------------------- | ----------------------------------- | ----------- | -------- | -------- | -------- | ------- | -------- |
| File Merger v1    | Merge callable: happy path     | ✅ Implement `mergePdfs` callable w/ tests      | feat,tool:file-merger,area:backend  | file_merger | backend  | P1       | 0.5d     | done    | @bitquan |
| File Merger v1    | UI: drag/drop + progress       | ✅ Flutter UI + upload mgr + progress bar       | feat,tool:file-merger,area:frontend | file_merger | frontend | P1       | 0.5d     | done    |          |
| GIT-01 Stabilizer | Cross-platform push preflight | ✅ Bash/PowerShell scripts + npm integration    | feat,tool:git-ops,area:ops          | git_ops     | ops      | P1       | 0.4d     | done    | @bitquan |
| GIT-01 Stabilizer | GitHub Actions diagnostics    | ✅ Manual workflow for repo health checks       | feat,tool:git-ops,area:ops          | git_ops     | ops      | P1       | 0.2d     | done    | @bitquan |
| UX-Play Theme     | Material 3 playful design     | ✅ Purple theme + animated tools grid           | feat,area:frontend,ui               | core        | frontend | P1       | 0.6d     | done    | @bitquan |
| UX-Play Theme     | Animated interactions         | ✅ Staggered animations + hover effects         | feat,area:frontend,ui               | core        | frontend | P1       | 0.3d     | done    | @bitquan |
| T-ToolsPack       | JSON Doctor instant tool      | ✅ Real-time validation + auto-repair           | feat,tool:json-doctor,area:frontend | json_doctor | frontend | P1       | 0.4d     | done    | @bitquan |
| T-ToolsPack       | Text Diff comparison tool     | ✅ Line-by-line diff with visual highlighting   | feat,tool:text-diff,area:frontend   | text_diff   | frontend | P1       | 0.4d     | done    | @bitquan |
| T-ToolsPack       | QR Maker generation tool      | ✅ Multi-type QR codes with customization       | feat,tool:qr-maker,area:frontend    | qr_maker    | frontend | P1       | 0.4d     | done    | @bitquan |
| File Merger v1    | Storage rules + signed URL     | Tighten rules + signed URL endpoint             | chore,area:backend                  | file_merger | backend  | P2       | 0.3d     | now     |          |
| Text Tools        | JSON validator: error pinpoint | Show line/col + highlight                       | feat,tool:text-tools,area:frontend  | text_tools  | frontend | P2       | 0.3d     | now     |          |
| Text Tools        | Export functionality           | Add export to PDF/Word for processed text       | feat,tool:text-tools,area:frontend  | text_tools  | frontend | P2       | 0.4d     | later   |          |
| T-ToolsPack v2    | JSON Doctor schema validation  | Add JSONPath queries and schema validation      | feat,tool:json-doctor,area:frontend | json_doctor | frontend | P2       | 0.5d     | now     |          |
| T-ToolsPack v2    | Text Diff word-level compare  | Word-level diffing with three-way merge         | feat,tool:text-diff,area:frontend   | text_diff   | frontend | P2       | 0.4d     | now     |          |
| T-ToolsPack v2    | QR Maker batch generation     | Bulk QR generation with logo embedding          | feat,tool:qr-maker,area:frontend    | qr_maker    | frontend | P2       | 0.4d     | now     |          |
| Tool Integration  | Cross-tool data sharing       | Share data between tools seamlessly            | feat,area:frontend,integration      | core        | frontend | P2       | 0.5d     | now     |          |
| CI/CD Enhancement | Test coverage reporting        | Add codecov integration and coverage badges     | chore,area:ops,ci                   | ops         | ops      | P2       | 0.2d     | later   |          |
| CI/CD Enhancement | Automated deployment           | Set up Firebase hosting auto-deploy on main     | chore,area:ops,ci                   | ops         | ops      | P1       | 0.3d     | backlog |          |
| Security Audit    | Authentication flow review     | Audit Firebase Auth implementation              | security,area:backend               | auth        | security | P1       | 0.5d     | backlog |          |
| Performance       | Bundle size optimization       | Analyze and optimize Flutter web bundle size    | perf,area:frontend                  | core        | frontend | P2       | 0.4d     | later   |          |
| Documentation     | API documentation              | Generate and publish API docs for all functions | docs,area:docs                      | docs        | docs     | P2       | 0.3d     | later   |          |

## Notes

- **labels**: Comma-separated; add `feat|fix|chore` etc.
- **tool & area**: Help auto-label; priority must match repo labels (P0-blocker, P1, P2).
- **sprint**: Controls creation: `now` = create immediately. `later|backlog` = ignore for now.
- **assignee**: Optional GitHub username like `@bitquan`.
- **epic**: Free text; generator will create/find an Epic issue labeled `type: epic` and link child issues to it.

## Epic Descriptions

### File Merger v1 ✅ COMPLETED

Complete PDF/image merging tool with Firebase Functions backend, quota management, and Flutter web UI.

### GIT-01 Stabilizer ✅ COMPLETED

Cross-platform git push validation system with preflight checks, npm integration, and GitHub Actions diagnostics.

### UX-Play Theme ✅ COMPLETED

Material 3 playful design system with purple-based theme, animated tools grid, and delightful user interactions.

### T-ToolsPack ✅ COMPLETED

Three instant-win micro tools: JSON Doctor (validation/repair), Text Diff (comparison), and QR Maker (generation).

### T-ToolsPack v2

Enhanced versions of micro tools with advanced features like schema validation, word-level diffing, and batch processing.

### Tool Integration

Cross-tool data sharing and workflow integration to create seamless user experiences between different tools.

### Text Tools

Enhancements to the existing text processing toolset with better validation and export capabilities.

### CI/CD Enhancement

Improvements to build pipeline, testing, and deployment automation.

### Security Audit

Review and hardening of authentication and authorization systems.

### Performance

Frontend optimization for better user experience and faster load times.

### Documentation

Comprehensive documentation for developers and users.
