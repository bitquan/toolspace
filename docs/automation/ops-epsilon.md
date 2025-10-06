# OPS-Epsilon: Notification & Insight Layer

**Status**: Active
**Version**: 1.0
**Dependencies**: OPS-Delta system
**Last Updated**: 2024-12-20

## Overview

OPS-Epsilon provides comprehensive notification and analytics capabilities for the OPS-Delta autonomous sprint management system. It delivers real-time alerts, periodic digest reports, and advanced insights to ensure full observability and predictive analytics for your development workflows.

## Architecture

```
OPS-Epsilon Layer
├── Real-time Notifications (delta-notify.yml)
├── Periodic Digests (delta-digest.yml)
├── Advanced Analytics (delta-insights.mjs)
└── Integration Hooks (embedded in delta workflows)
```

### Key Components

1. **Notification Engine** - Real-time Discord/Slack alerts
2. **Digest System** - Weekly/monthly performance summaries
3. **Insights Analytics** - Trend analysis and predictive modeling
4. **Integration Layer** - Hooks into existing OPS-Delta workflows

## Prerequisites

### Required Secrets

Add these secrets to your GitHub repository:

```
DISCORD_WEBHOOK_URL  # Optional: Discord webhook for notifications
SLACK_WEBHOOK_URL    # Optional: Slack webhook for notifications
```

### Webhook Setup

#### Discord Webhook

1. Go to your Discord server settings
2. Navigate to Integrations → Webhooks
3. Create a new webhook and copy the URL
4. Add to GitHub secrets as `DISCORD_WEBHOOK_URL`

#### Slack Webhook

1. Create a Slack app at https://api.slack.com/apps
2. Enable Incoming Webhooks
3. Create a webhook for your channel
4. Add to GitHub secrets as `SLACK_WEBHOOK_URL`

## Workflow Reference

### delta-notify.yml

**Purpose**: Reusable notification workflow for real-time alerts

**Inputs**:

- `event_type`: Type of event (workflow_failed, progress_update, etc.)
- `title`: Notification title
- `message`: Notification content
- `severity`: Alert level (info, warning, critical)
- `dry_run`: Test mode flag

**Example Usage**:

```yaml
- name: Send notification
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: |
    gh workflow run delta-notify.yml \
      -f event_type="workflow_failed" \
      -f title="🚨 Critical Workflow Failure" \
      -f message="Delta scheduler has failed 3 consecutive times" \
      -f severity="critical" \
      -f dry_run="false"
```

### delta-digest.yml

**Purpose**: Periodic performance summaries and trend analysis

**Schedule**:

- Weekly: Every Monday at 9 AM UTC
- Monthly: 1st of each month at 10 AM UTC

**Features**:

- Sprint velocity calculation
- Issue throughput metrics
- Health score assessment
- Priority distribution analysis
- Trend detection

**Manual Trigger**:

```bash
gh workflow run delta-digest.yml \
  -f digest_type="weekly" \
  -f dry_run="false"
```

### delta-insights.mjs

**Purpose**: Advanced analytics and predictive insights

**Capabilities**:

- Linear regression for velocity trends
- Bottleneck identification
- Health scoring algorithm
- Risk assessment
- Performance recommendations

**Usage**:

```bash
node scripts/delta-insights.mjs
```

## Integration Points

OPS-Epsilon automatically integrates with existing OPS-Delta workflows:

### delta-scheduler.yml

- **Trigger**: Daily scheduling completion
- **Notification**: Ready queue status updates
- **Severity**: Info

### delta-progress.yml

- **Trigger**: PR merge with issue closure
- **Notification**: Sprint progress updates
- **Severity**: Info

### delta-report.yml

- **Trigger**: Weekly report generation
- **Notification**: Report publication alerts
- **Severity**: Info

### delta-watchdog.yml

- **Trigger**: Critical workflow failures
- **Notification**: System health alerts
- **Severity**: Critical

## Notification Types

### Event Types

| Type               | Description                | Severity | Trigger                 |
| ------------------ | -------------------------- | -------- | ----------------------- |
| `workflow_failed`  | Critical workflow failures | Critical | 2+ consecutive failures |
| `progress_update`  | Sprint progress changes    | Info     | PR merges               |
| `sprint_scheduled` | Daily scheduling complete  | Info     | Scheduler runs          |
| `system_health`    | Health check summaries     | Info     | Manual health checks    |
| `report_published` | Weekly reports available   | Info     | Report generation       |
| `digest_summary`   | Performance summaries      | Info     | Weekly/monthly          |

### Severity Levels

- **Critical**: 🚨 Red alerts for immediate attention
- **Warning**: ⚠️ Yellow alerts for monitoring
- **Info**: ℹ️ Blue alerts for general updates

## Configuration

### Notification Preferences

Customize notification behavior by modifying workflow files:

```yaml
# Skip notifications for specific events
- name: Send notification
  if: github.event_name != 'schedule' # Skip for scheduled runs

# Conditional notifications based on severity
- name: Send critical alerts only
  if: steps.monitor.outputs.critical_failures > 0
```

### Digest Frequency

Modify schedule in `delta-digest.yml`:

```yaml
on:
  schedule:
    - cron: "0 9 * * 1" # Weekly: Monday 9 AM UTC
    - cron: "0 10 1 * *" # Monthly: 1st day 10 AM UTC
```

### Analytics Thresholds

Adjust thresholds in `delta-insights.mjs`:

```javascript
const HEALTH_THRESHOLDS = {
  CRITICAL: 0.3, // Below 30% health score
  WARNING: 0.6, // Below 60% health score
  HEALTHY: 0.8, // Above 80% health score
};
```

## Testing

### Dry Run Mode

All workflows support dry-run testing:

```bash
# Test notifications
gh workflow run delta-notify.yml \
  -f event_type="test" \
  -f title="Test Notification" \
  -f message="Testing epsilon system" \
  -f severity="info" \
  -f dry_run="true"

# Test digest
gh workflow run delta-digest.yml \
  -f digest_type="weekly" \
  -f dry_run="true"
```

### Manual Testing

1. **Webhook Validation**: Use dry-run mode to validate webhook URLs
2. **Format Testing**: Check Discord/Slack message formatting
3. **Integration Testing**: Trigger workflows manually to test integration points

## Monitoring

### Health Indicators

Monitor OPS-Epsilon health through:

1. **Workflow Success Rates**: Check Actions tab for failures
2. **Notification Delivery**: Verify webhooks are receiving messages
3. **Analytics Accuracy**: Review insight predictions vs actual outcomes

### Troubleshooting

#### Common Issues

1. **Webhook Failures**

   - Verify webhook URLs in secrets
   - Check Discord/Slack webhook permissions
   - Validate webhook URL format

2. **Missing Notifications**

   - Check workflow conditional logic
   - Verify dry_run parameters
   - Review workflow permissions

3. **Analytics Errors**
   - Ensure sufficient historical data
   - Check GitHub API rate limits
   - Validate repository permissions

#### Debug Commands

```bash
# Check workflow runs
gh run list --workflow=delta-notify.yml

# View workflow logs
gh run view [RUN_ID] --log

# Test GitHub CLI authentication
gh auth status
```

## Advanced Usage

### Custom Notification Channels

Add support for additional platforms by extending `delta-notify.yml`:

```yaml
- name: Send to custom webhook
  if: env.CUSTOM_WEBHOOK_URL != ''
  run: |
    curl -X POST "${{ env.CUSTOM_WEBHOOK_URL }}" \
      -H "Content-Type: application/json" \
      -d '{"text": "${{ inputs.message }}"}'
```

### Enhanced Analytics

Extend `delta-insights.mjs` with custom metrics:

```javascript
// Add custom performance indicators
const customMetrics = {
  bugFixRatio: bugIssues.length / totalIssues.length,
  featureVelocity: featureIssues.length / weeksPassed,
  technicalDebtRatio: techDebtIssues.length / totalIssues.length,
};
```

### Conditional Workflows

Create smart notification logic:

```yaml
- name: Smart notification
  if: |
    (steps.health.outputs.score < 0.6 && github.event_name == 'schedule') ||
    (steps.failures.outputs.count > 2 && github.event_name == 'workflow_run')
```

## Best Practices

### Notification Hygiene

1. **Avoid Spam**: Use appropriate severity levels
2. **Actionable Alerts**: Include relevant context and next steps
3. **Consistent Formatting**: Maintain message format standards
4. **Time Awareness**: Consider team time zones for digest scheduling

### Analytics Accuracy

1. **Sufficient Data**: Ensure at least 4 weeks of history for trends
2. **Clean Labels**: Maintain consistent issue labeling practices
3. **Regular Calibration**: Review prediction accuracy monthly
4. **Context Awareness**: Consider external factors affecting metrics

### Security Considerations

1. **Webhook Security**: Keep webhook URLs as secrets
2. **Minimal Permissions**: Use least-privilege GitHub tokens
3. **Audit Trail**: Monitor workflow execution logs
4. **Secret Rotation**: Regularly rotate webhook URLs

## Roadmap

### Planned Enhancements

- [ ] Microsoft Teams integration
- [ ] SMS notifications for critical alerts
- [ ] Machine learning for anomaly detection
- [ ] Custom dashboard integration
- [ ] Multi-repository support
- [ ] Enhanced trend forecasting

### Version History

- **v1.0** (2024-12-20): Initial release with Discord/Slack support
- **v0.9** (2024-12-19): Beta release with core notification engine
- **v0.8** (2024-12-18): Alpha release with basic analytics

## Support

For issues and feature requests:

1. Check workflow logs in GitHub Actions
2. Review this documentation for configuration options
3. Create an issue with the `ops-epsilon` label
4. Include relevant workflow run IDs and error messages

---

_OPS-Epsilon is part of the autonomous development pipeline. For related documentation, see [OPS-Delta Overview](./overview.md)._
