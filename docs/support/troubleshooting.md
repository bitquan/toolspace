# Support and Troubleshooting Guide

## Getting Help

### Support Channels

- 📧 **Email Support**: support@toolspace.app
- 💬 **Community Forum**: [GitHub Discussions](https://github.com/bitquan/toolspace/discussions)
- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/bitquan/toolspace/issues)
- 📖 **Documentation**: [docs.toolspace.app](https://docs.toolspace.app)

### Response Times

- **Critical Issues**: 4 hours (billing, security, data loss)
- **High Priority**: 24 hours (broken features, performance issues)
- **Normal Priority**: 3-5 business days (feature requests, minor bugs)
- **Low Priority**: Best effort (documentation, enhancement suggestions)

## Common Issues and Solutions

### Authentication Problems

#### Issue: Cannot sign in with Google

**Symptoms**: "OAuth error" or redirect failures

**Solutions**:

1. Clear browser cache and cookies
2. Disable ad blockers temporarily
3. Try incognito/private mode
4. Check if third-party cookies are enabled

```javascript
// Check if in iframe (blocks OAuth)
if (window.self !== window.top) {
  console.error("OAuth blocked in iframe");
}
```

#### Issue: Account suspended or locked

**Symptoms**: "Account access denied" message

**Solutions**:

1. Contact support with account email
2. Verify account ownership via security questions
3. Review terms of service compliance

### Billing Issues

#### Issue: Subscription not updating after payment

**Symptoms**: Still shows previous plan after successful payment

**Solutions**:

1. Wait up to 15 minutes for sync
2. Refresh browser/clear cache
3. Check Stripe customer portal for payment status
4. Contact support with order ID

#### Issue: Unable to cancel subscription

**Symptoms**: Cancel button not working or errors

**Solutions**:

1. Try from different browser
2. Use Stripe customer portal directly
3. Contact support for manual cancellation

### Tool-Specific Issues

#### Quick Invoice

**Issue: PDF generation fails**

```
Error: Failed to generate PDF
```

**Solutions**:

1. Check invoice data completeness
2. Verify all required fields filled
3. Try with simpler invoice (fewer items)
4. Contact support if error persists

#### Text Tools

**Issue: Large text processing timeout**

```
Error: Request timeout
```

**Solutions**:

1. Break text into smaller chunks
2. Try client-side tools for offline processing
3. Check text encoding (UTF-8 required)

### Performance Issues

#### Issue: Slow page load times

**Symptoms**: Pages take >5 seconds to load

**Diagnosis Steps**:

1. Test internet connection speed
2. Try different browser
3. Check browser console for errors
4. Disable browser extensions

**Solutions**:

1. Clear browser cache
2. Update browser to latest version
3. Use Chrome for best performance
4. Report persistent issues to support

#### Issue: App crashes or freezes

**Symptoms**: White screen, unresponsive interface

**Solutions**:

1. Refresh page (Ctrl+F5 / Cmd+Shift+R)
2. Clear browser data
3. Restart browser
4. Try different device

## Self-Service Tools

### Account Management

```bash
# Reset account preferences
curl -X POST https://api.toolspace.app/account/reset-preferences \
  -H "Authorization: Bearer YOUR_TOKEN"

# Export account data
curl -X GET https://api.toolspace.app/account/export \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -o account-data.json
```

### Subscription Management

Visit [Stripe Customer Portal](https://billing.stripe.com/p/login/customer) to:

- View billing history
- Update payment methods
- Change subscription plans
- Download invoices
- Cancel subscriptions

### Data Export

#### Export Tool Data

```typescript
// Export specific tool data
const exportData = await fetch("/api/tools/export", {
  method: "POST",
  headers: {
    Authorization: `Bearer ${token}`,
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    tools: ["invoice", "text"],
    format: "json",
    dateRange: {
      start: "2024-01-01",
      end: "2024-12-31",
    },
  }),
});
```

## Error Codes Reference

### HTTP Status Codes

- **400 Bad Request**: Invalid request data
- **401 Unauthorized**: Authentication required
- **403 Forbidden**: Insufficient permissions
- **404 Not Found**: Resource doesn't exist
- **429 Too Many Requests**: Rate limit exceeded
- **500 Internal Server Error**: Server-side issue
- **503 Service Unavailable**: Temporary maintenance

### Application Error Codes

#### Authentication (A)

- **A001**: Invalid email format
- **A002**: Password too weak
- **A003**: Account not verified
- **A004**: Account suspended
- **A005**: OAuth provider error

#### Billing (B)

- **B001**: Payment method required
- **B002**: Subscription expired
- **B003**: Payment failed
- **B004**: Invalid coupon code
- **B005**: Billing address required

#### Tools (T)

- **T001**: File too large
- **T002**: Invalid file format
- **T003**: Processing timeout
- **T004**: Tool not available in plan
- **T005**: Daily usage limit exceeded

#### System (S)

- **S001**: Database connection error
- **S002**: External service unavailable
- **S003**: Rate limit exceeded
- **S004**: Maintenance mode
- **S005**: Feature temporarily disabled

## Escalation Process

### Level 1: Self-Service

1. Check this troubleshooting guide
2. Search community forum
3. Review status page
4. Try basic troubleshooting steps

### Level 2: Community Support

1. Post in GitHub Discussions
2. Tag relevant topics
3. Include error details and steps
4. Wait for community response

### Level 3: Direct Support

1. Email support@toolspace.app
2. Include account email
3. Provide detailed error description
4. Attach screenshots if relevant

### Level 4: Emergency Support

For critical issues affecting business operations:

1. Email support@toolspace.app with "URGENT" prefix
2. Include business impact description
3. Provide phone number for callback
4. Expected response within 4 hours

## Status and Monitoring

### Service Status

Check real-time status at: [status.toolspace.app](https://status.toolspace.app)

### Scheduled Maintenance

- Posted 48 hours in advance
- Typically during low-traffic hours (2-4 AM PST)
- Updates sent via email and status page

### Incident Reports

Post-incident reviews include:

- Root cause analysis
- Timeline of events
- Prevention measures
- Compensation details (if applicable)

## Feedback and Suggestions

### Feature Requests

1. Check existing GitHub issues
2. Create new issue with detailed description
3. Include use case and business value
4. Vote on existing requests

### Bug Reports

Use the [bug report template](.github/ISSUE_TEMPLATE/bug_report.yml):

- Clear reproduction steps
- Expected vs actual behavior
- Screenshots/videos
- Browser and device info

### Product Feedback

- Monthly user surveys
- In-app feedback widget
- Community discussions
- Direct email to product team

## Legal and Compliance

### Data Requests

For GDPR, CCPA, or other data requests:

1. Email privacy@toolspace.app
2. Provide identity verification
3. Specify request type (access, deletion, portability)
4. Allow 30 days for processing

### Security Issues

For security vulnerabilities:

1. Email security@toolspace.app
2. Include detailed vulnerability description
3. Provide proof-of-concept if safe
4. Allow coordinated disclosure timeline

### Terms Violations

Report violations to abuse@toolspace.app:

- Account information
- Description of violation
- Supporting evidence
- Requested action
