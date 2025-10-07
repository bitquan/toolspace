# Billing FAQ

Frequently asked questions about Toolspace subscriptions and billing.

---

## General Questions

### What payment methods do you accept?

We accept all major credit and debit cards through Stripe:

- Visa
- Mastercard
- American Express
- Discover
- And more

### Is my payment information secure?

Yes! We use Stripe, a PCI-compliant payment processor trusted by millions of businesses. We never store your credit card information on our servers.

### Can I cancel anytime?

Yes, you can cancel your subscription at any time with no cancellation fees. Your plan will remain active until the end of your current billing period.

---

## Plans & Limits

### What counts as a "heavy operation"?

Heavy operations are resource-intensive tasks:

- **File Merger**: Merging PDF/image files
- **Image Resizer**: Batch resizing images
- **Markdown to PDF**: Converting markdown documents
- **Batch QR Generator**: Creating multiple QR codes
- **JSON to CSV**: Exporting flattened JSON

Light operations (text tools, converters, etc.) don't count toward your quota.

### When does my daily quota reset?

Daily quotas reset at midnight UTC (Coordinated Universal Time). Your remaining operations are shown in the quota banner when you use heavy tools.

### What happens if I hit my daily limit?

You'll see an upgrade prompt when you reach your limit. Free users get 3 heavy operations per day. You can upgrade to Pro for 200/day or Pro+ for 2,000/day.

### Can I process larger files?

File size limits depend on your plan:

- **Free**: 10MB max per file
- **Pro**: 50MB max per file
- **Pro+**: 100MB max per file

### What is batch processing?

Batch processing lets you handle multiple files at once:

- **Free**: 1 file at a time only
- **Pro**: Up to 20 files per batch
- **Pro+**: Up to 100 files per batch

---

## Billing & Payments

### How does billing work?

- Plans are billed **monthly** on a subscription basis
- First payment is charged immediately upon upgrade
- Subsequent payments on the same day each month
- You'll receive email receipts for all payments

### Can I get a refund?

We offer refunds within 7 days of your first payment if you're not satisfied. Contact support@toolspace.dev with your request.

For subsequent months, we generally don't offer refunds, but you can cancel anytime to prevent future charges.

### What happens if my payment fails?

If a payment fails:

1. Stripe will retry the payment automatically
2. You'll receive an email notification
3. Your plan remains active for 3 days (grace period)
4. If payment continues to fail, you'll be downgraded to Free

Update your payment method in the billing portal to avoid interruption.

### Can I change my plan?

Yes! You can upgrade or downgrade at any time:

**Upgrading** (Free → Pro or Pro → Pro+):

- Takes effect immediately
- Charged prorated amount for remainder of month
- Higher limits apply right away

**Downgrading** (Pro+ → Pro or Pro → Free):

- Takes effect at end of current billing period
- No prorated refund
- You keep your current plan until period ends

### Do you offer annual plans?

Currently, we only offer monthly plans. Annual billing with discounts may be added in the future.

### Can I get a receipt for my subscription?

Yes! Stripe automatically sends email receipts for all payments. You can also view and download invoices from the billing portal.

---

## Account Management

### How do I upgrade my plan?

1. Click the **"Upgrade"** button in the navbar
2. Select your desired plan (Pro or Pro+)
3. Click **"Upgrade to [Plan]"**
4. Complete payment through Stripe
5. You'll be redirected back with upgraded features

### How do I cancel my subscription?

1. Click **"Manage Billing"** in the navbar
2. In the customer portal, find your subscription
3. Click **"Cancel subscription"**
4. Confirm cancellation
5. Your plan remains active until the end of your billing period

### How do I update my payment method?

1. Click **"Manage Billing"** in the navbar
2. In the customer portal, go to payment methods
3. Add a new card or update existing one
4. Set as default for future payments

### How do I view my billing history?

1. Click **"Manage Billing"** in the navbar
2. In the customer portal, view invoices section
3. Download any invoice as PDF

### What happens to my data if I cancel?

Your account and data remain intact. You'll be downgraded to the Free plan and can continue using all tools with Free plan limits.

### Can I reactivate after canceling?

Yes! Simply click **"Upgrade"** again to resubscribe. Your billing starts fresh from the new activation date.

---

## Features & Access

### What tools are available on the Free plan?

All 17 tools are accessible on the Free plan! However, heavy tools have daily operation limits (3/day) and file size restrictions (10MB max).

### Do Pro features work immediately after payment?

Yes! Features unlock within seconds after your payment is processed. If there's a delay, try refreshing the page.

### Can I use Toolspace offline?

Toolspace is a Progressive Web App (PWA) with offline support for cached pages. However, processing operations require an internet connection to communicate with our servers.

### Is there a trial period?

The Free plan serves as an unlimited trial. Try all tools with no time limit, then upgrade when you need higher quotas or larger files.

---

## Technical Questions

### Which browsers are supported?

Toolspace works best on:

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

### Do I need to install anything?

No installation required! Toolspace runs entirely in your browser. You can optionally install it as a PWA for a native app experience.

### Where is my data stored?

Your usage data and billing information are stored securely in Firebase Firestore. Files you upload for processing are temporarily stored in Firebase Storage and deleted after processing.

### Is my data private?

Yes! We follow strict privacy practices:

- Files are processed and immediately deleted
- We don't access your content
- Payment data is handled by Stripe (PCI-compliant)
- See our [Privacy Policy](/legal/privacy.md)

---

## Support

### How do I get support?

Support level depends on your plan:

- **Free**: Community support (FAQ, docs)
- **Pro**: Email support (support@toolspace.dev)
- **Pro+**: Priority email support (24-48hr response)

### I found a bug. Where do I report it?

Email support@toolspace.dev with:

- Description of the issue
- Steps to reproduce
- Browser and OS information
- Screenshots if applicable

### Can I request a feature?

Absolutely! We love feedback. Send feature requests to support@toolspace.dev or vote on existing requests in our roadmap.

### Where can I find the latest updates?

Check our changelog at [toolspace.dev/changelog](/changelog) or follow us on social media for announcements.

---

## Still Have Questions?

Can't find what you're looking for? Contact us:

- **Email**: support@toolspace.dev
- **Docs**: [docs/billing/README.md](./README.md)
- **Status**: status.toolspace.dev

We typically respond within 24-48 hours (faster for Pro+ subscribers).
