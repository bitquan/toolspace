# Issue Triage Rules

This document outlines the triage process and priority levels for issues in the Toolspace project.

## Priority Levels

### P0-blocker: Critical Issues 🔥

**Response Time: Immediate (< 2 hours)**

Issues that completely break core functionality:

- Authentication system down
- Payment processing broken
- Data loss or corruption
- Security vulnerabilities
- Complete service outage

**Actions:**

- Stop all other work immediately
- Assign to senior developer
- Create incident channel
- Implement hotfix if possible
- Post-mortem required

### P1: High Priority ⚡

**Response Time: Same day**

User-visible issues that significantly impact functionality:

- Tool not working as expected
- UI/UX problems affecting usability
- Performance degradation
- Important features broken
- API endpoints returning errors

**Actions:**

- Fix in next sprint
- Assign owner within 24 hours
- Regular status updates
- Consider workaround if available

### P2: Medium Priority 📋

**Response Time: Within 1 week**

Polish, improvements, and minor issues:

- UI polish and improvements
- Performance optimizations
- Code refactoring
- Documentation updates
- Non-critical feature requests

**Actions:**

- Add to backlog
- Schedule for upcoming sprint
- Can be delayed for higher priorities

### P3: Low Priority 💡

**Response Time: Best effort**

Nice-to-have improvements:

- Minor UI tweaks
- Code cleanup
- Developer experience improvements
- Non-essential features

**Actions:**

- Backlog for consideration
- Good for new contributors
- Can be postponed indefinitely

## Tool-Specific Triage

### Quick Invoice Tool

- Revenue-impacting issues → P0/P1
- Invoice generation failures → P1
- Template/formatting issues → P2

### Text Tools

- Core text processing broken → P1
- UI/UX improvements → P2
- New text operations → P2/P3

### File Merger

- File corruption/loss → P0
- Processing failures → P1
- Format support → P2

## Area-Specific Guidelines

### Backend Issues

- Database issues → P0/P1
- API failures → P1
- Performance → P1/P2

### Frontend Issues

- App won't load → P1
- UI broken → P1/P2
- Mobile responsiveness → P2

### DevOps Issues

- CI/CD broken → P1
- Deployment failures → P1
- Monitoring gaps → P2

## Escalation Process

1. **Initial Triage**: Assign priority label within 2 hours
2. **Review**: Senior developer reviews P0/P1 issues daily
3. **Weekly Review**: Re-evaluate all open issues
4. **Monthly Cleanup**: Close stale issues, update priorities

## Labels to Apply

Always add these labels during triage:

- **Priority**: P0-blocker, P1, P2, or P3
- **Type**: type:bug, type:feature, type:enhancement, type:task
- **Area**: area:backend, area:frontend, area:devops, area:docs
- **Tool**: tool:quick-invoice, tool:text-tools, tool:file-merger (if applicable)
- **Size**: size:xs, size:s, size:m, size:l, size:xl (estimate)

## Common Triage Decisions

### When to close immediately:

- Duplicate issues
- Issues that can't be reproduced
- Issues outside project scope
- Spam or inappropriate content

### When to request more info:

- Unclear bug reports
- Missing reproduction steps
- No environment details
- Vague feature requests

### When to escalate:

- Security vulnerabilities
- Legal compliance issues
- Customer-reported revenue impact
- Repeated issues indicating systemic problems
