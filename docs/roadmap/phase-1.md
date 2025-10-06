# Toolspace Roadmap — Phase 1

> Only rows with `sprint: now` are created automatically.

| epic                         | title                                   | desc                                                        | labels                                  | tool               | area         | priority | estimate | sprint | assignee     |
|------------------------------|-----------------------------------------|-------------------------------------------------------------|------------------------------------------|--------------------|--------------|----------|----------|--------|--------------|
| File Merger v1               | Merge callable: happy path              | Implement `mergePdfs` callable w/ tests                     | feat,tool:file-merger,area:backend       | file_merger        | backend      | P1       | 0.5d     | now    | @bitquan     |
| File Merger v1               | UI: drag/drop + progress                | Flutter UI + upload mgr + progress bar                      | feat,tool:file-merger,area:frontend      | file_merger        | frontend     | P1       | 0.5d     | now    |              |
| File Merger v1               | Storage rules + signed URL              | Tighten rules + signed URL endpoint                         | chore,area:backend                       | file_merger        | backend      | P2       | 0.3d     | backlog|              |
| Text Tools                   | JSON validator: error pinpoint          | Show line/col + highlight                                   | feat,tool:text-tools,area:frontend       | text_tools         | frontend     | P2       | 0.3d     | later  |              |
| Text Tools                   | Export functionality                    | Add export to PDF/Word for processed text                   | feat,tool:text-tools,area:frontend       | text_tools         | frontend     | P2       | 0.4d     | later  |              |
| CI/CD Enhancement            | Test coverage reporting                 | Add codecov integration and coverage badges                 | chore,area:ops,ci                        | ops                | ops          | P2       | 0.2d     | later  |              |
| CI/CD Enhancement            | Automated deployment                    | Set up Firebase hosting auto-deploy on main                 | chore,area:ops,ci                        | ops                | ops          | P1       | 0.3d     | backlog|              |
| Security Audit               | Authentication flow review              | Audit Firebase Auth implementation                           | security,area:backend                    | auth               | security     | P1       | 0.5d     | backlog|              |
| Performance                  | Bundle size optimization                | Analyze and optimize Flutter web bundle size                | perf,area:frontend                       | core               | frontend     | P2       | 0.4d     | later  |              |
| Documentation                | API documentation                       | Generate and publish API docs for all functions             | docs,area:docs                          | docs               | docs         | P2       | 0.3d     | later  |              |

## Notes

- **labels**: Comma-separated; add `feat|fix|chore` etc.
- **tool & area**: Help auto-label; priority must match repo labels (P0-blocker, P1, P2).
- **sprint**: Controls creation: `now` = create immediately. `later|backlog` = ignore for now.
- **assignee**: Optional GitHub username like `@bitquan`.
- **epic**: Free text; generator will create/find an Epic issue labeled `type: epic` and link child issues to it.

## Epic Descriptions

### File Merger v1
Complete PDF/image merging tool with Firebase Functions backend, quota management, and Flutter web UI.

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