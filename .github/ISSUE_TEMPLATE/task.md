---
name: Task
about: General task or development work
title: "[TASK] "
labels: ["type:task", "P2"]
assignees: ""
---

## Task Description

<!-- Clear description of what needs to be done -->

## Context

<!-- Why is this task needed? What's the background? -->

## Scope

<!-- What's included and what's not included in this task -->

## Technical Requirements

<!-- Any specific technical requirements or constraints -->

- [ ]
- [ ]

## Done When

<!-- Specific, measurable criteria for task completion -->

- [ ]
- [ ]

---

## Autonomous Workflow

<!-- This issue is compatible with the autonomous development workflow -->

**Branch Type**: `feat` | `fix` | `chore` | `docs` (select one)
**Tools/Area**: <!-- e.g., file_merger, text_tools, core, etc. -->
**Estimated Effort**: <!-- e.g., 0.5d, 1d, 2d -->

### Workflow Steps

1. Add `ready` label when this issue is ready for development
2. System will auto-create branch: `{type}/issue-{number}-{slug}`
3. Make changes, commit with issue references: `#123 Your commit message`
4. Push triggers CI (tests, lint, security scan)
5. When CI passes, system auto-creates PR
6. After review approval, system auto-merges and closes issue
7. Dev log automatically updated

**Ready for autonomous development?** Add the `ready` label to start the workflow!

- [ ]
- [ ]
- [ ]

## Dependencies

<!-- What other tasks or external factors does this depend on? -->

- Depends on: #issue_number
- Blocks: #issue_number

## Estimated Effort

- [ ] size:xs (< 1 day)
- [ ] size:s (1-2 days)
- [ ] size:m (3-5 days)
- [ ] size:l (1-2 weeks)
- [ ] size:xl (> 2 weeks)

## Notes

<!-- Any additional notes, links, or context -->
