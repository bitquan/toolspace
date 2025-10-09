# Backend API Documentation

**Version:** 1.0.0
**Base URL:** `https://us-central1-FIREBASE_PROJECT_ID.cloudfunctions.net`

## Authentication

All API endpoints (except health check) require Firebase Authentication.

### Headers

```http
Authorization: Bearer <firebase-id-token>
Content-Type: application/json
```

### Security Model

- **withAuth**: Validates Firebase ID token
- **withEmailVerified**: Requires verified email address
- **Ownership Checks**: Users can only access their own data

## Callable Functions

### createCheckoutSession

Creates a Stripe checkout session for subscription upgrade.

**Endpoint:** `POST /createCheckoutSession`

**Request:**

```json
{
  "planId": "pro",
  "successUrl": "https://PROD_DOMAIN/billing/success",
  "cancelUrl": "https://PROD_DOMAIN/billing/cancel"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "url": "https://checkout.stripe.com/c/pay/cs_...",
    "sessionId": "cs_test_..."
  }
}
```

**Errors:**

```json
{
  "success": false,
  "error": {
    "code": "INVALID_PLAN",
    "message": "Plan ID 'invalid' not found"
  }
}
```

**Security:**

- Requires `withAuth` + `withEmailVerified`
- Rate limited: 5 requests per minute per user

### createPortalLink

Creates a Stripe customer portal link for billing management.

**Endpoint:** `POST /createPortalLink`

**Request:**

```json
{
  "returnUrl": "https://PROD_DOMAIN/account"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "url": "https://billing.stripe.com/p/login/...",
    "expiresAt": "2025-10-09T12:00:00.000Z"
  }
}
```

**Errors:**

```json
{
  "success": false,
  "error": {
    "code": "NO_CUSTOMER",
    "message": "No Stripe customer found for user"
  }
}
```

**Security:**

- Requires `withAuth` + `withEmailVerified`
- Only works for users with existing Stripe customers

## HTTP Endpoints

### Health Check

**Endpoint:** `GET /api/health`

**Response:**

```json
{
  "status": "healthy",
  "timestamp": "2025-10-09T12:00:00.000Z",
  "version": "1.0.0",
  "services": {
    "firestore": "connected",
    "stripe": "connected"
  }
}
```

**No authentication required**

### Stripe Webhook

**Endpoint:** `POST /webhook`

Handles Stripe webhook events for subscription management.

**Supported Events:**

- `customer.subscription.created`
- `customer.subscription.updated`
- `customer.subscription.deleted`
- `invoice.payment_succeeded`
- `invoice.payment_failed`

**Security:**

- Validates Stripe webhook signature
- Idempotent processing using `event.id`

**Processing:**

1. Validates webhook signature with `STRIPE_WEBHOOK_SECRET`
2. Updates Firestore `users/{uid}/billing/profile`
3. Logs event for monitoring

## Error Handling

### Standard Error Format

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable description",
    "details": {
      "field": "Additional context"
    }
  }
}
```

### Common Error Codes

| Code                 | Description                 | HTTP Status |
| -------------------- | --------------------------- | ----------- |
| `UNAUTHENTICATED`    | No valid Firebase token     | 401         |
| `EMAIL_NOT_VERIFIED` | Email verification required | 403         |
| `PERMISSION_DENIED`  | Insufficient permissions    | 403         |
| `INVALID_PLAN`       | Plan ID not found           | 400         |
| `RATE_LIMITED`       | Too many requests           | 429         |
| `STRIPE_ERROR`       | Stripe API error            | 500         |
| `INTERNAL_ERROR`     | Server error                | 500         |

## Data Models

### BillingProfile

```typescript
interface BillingProfile {
  stripeCustomerId?: string;
  planId: "free" | "pro" | "pro_plus";
  status: "free" | "active" | "past_due" | "canceled";
  currentPeriodStart?: number; // Unix timestamp
  currentPeriodEnd?: number; // Unix timestamp
  cancelAtPeriodEnd: boolean;
  createdAt: number;
  updatedAt: number;
}
```

### UsageRecord

```typescript
interface UsageRecord {
  date: string; // YYYY-MM-DD
  heavyOps: number;
  lightOps: number;
  filesProcessed: number;
  bytesProcessed: number;
  lastUpdated: number; // Unix timestamp
}
```

## Rate Limiting

| Endpoint                | Limit       | Window   |
| ----------------------- | ----------- | -------- |
| `createCheckoutSession` | 5 requests  | 1 minute |
| `createPortalLink`      | 10 requests | 1 minute |
| Health check            | No limit    | -        |

## Monitoring

### Metrics

- Request count by endpoint
- Error rate by error code
- Response time percentiles
- Stripe webhook processing time

### Logs

All requests logged with:

- User ID (if authenticated)
- Request method and path
- Response status and time
- Error details (if any)

### Alerts

- Error rate > 5% for 5 minutes
- Response time > 10s for 1 minute
- Webhook processing failures

## Testing

### Local Testing

```bash
# Start Firebase emulators
firebase emulators:start --only functions,firestore

# Test with curl
curl -X POST http://localhost:5001/FIREBASE_PROJECT_ID/us-central1/createCheckoutSession \
  -H "Authorization: Bearer <test-token>" \
  -H "Content-Type: application/json" \
  -d '{"planId": "pro", "successUrl": "http://localhost:3000/success"}'
```

### Test Data

Use Firebase Auth emulator for test tokens:

```bash
# Get test token
firebase auth:export users.json --project demo-project
```

---

**Security Note:** Never expose live Stripe keys in logs or client-side code.
