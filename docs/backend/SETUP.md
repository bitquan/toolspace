# Backend Development Setup

Complete guide for setting up the Firebase Functions backend locally.

## Prerequisites

- Node.js 20+ (LTS recommended)
- Firebase CLI (`npm install -g firebase-tools`)
- Access to Firebase project
- Stripe CLI (for webhook testing)

## Project Structure

```text
functions/
├── src/
│   ├── index.ts              # Main function exports
│   ├── admin.ts              # Firebase admin initialization
│   ├── api/                  # HTTP API endpoints
│   │   └── health.ts         # Health check endpoint
│   ├── billing/              # Stripe billing logic
│   │   ├── checkout.ts       # Checkout session creation
│   │   ├── portal.ts         # Customer portal links
│   │   └── webhook.ts        # Stripe webhook handler
│   ├── middleware/           # Express middleware
│   │   ├── auth.ts           # Authentication guards
│   │   └── cors.ts           # CORS configuration
│   ├── types/                # TypeScript definitions
│   │   ├── billing.ts        # Billing-related types
│   │   └── api.ts            # API response types
│   └── utils/                # Utility functions
│       ├── errors.ts         # Error handling
│       ├── logger.ts         # Structured logging
│       └── validation.ts     # Input validation
├── test/                     # Test files
├── package.json              # Dependencies
├── tsconfig.json             # TypeScript config
└── .env                      # Environment variables
```

## Initial Setup

### 1. Install Dependencies

```bash
cd functions
npm ci
```

### 2. Configure Environment

Create `.env` file:

```bash
# Copy template
cp .env.template .env

# Edit with your values
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
FIREBASE_PROJECT_ID=your-project-id
```

### 3. Firebase Configuration

```bash
# Login to Firebase
firebase login

# Set project
firebase use FIREBASE_PROJECT_ID

# Set runtime configuration
firebase functions:config:set \
  stripe.secret_key="sk_test_..." \
  stripe.webhook_secret="whsec_..."
```

## Development Workflow

### 1. Start Emulators

```bash
# Start all emulators
firebase emulators:start

# Or specific emulators
firebase emulators:start --only functions,firestore
```

**Emulator URLs:**

- Functions: <http://localhost:5001>
- Firestore: <http://localhost:8080>
- Auth: <http://localhost:9099>

### 2. Build and Watch

```bash
# Build once
npm run build

# Build and watch for changes
npm run build:watch
```

### 3. Test Functions

```bash
# Run unit tests
npm test

# Run tests with coverage
npm run test:coverage

# Run security rules tests
npm run test:rules
```

## Environment Variables

### Local Development (.env)

```bash
STRIPE_SECRET_KEY=sk_test_51...
STRIPE_WEBHOOK_SECRET=whsec_1...
FIREBASE_PROJECT_ID=toolspace-dev
NODE_ENV=development
```

### Production (Firebase Config)

```bash
# Set production config
firebase functions:config:set \
  stripe.secret_key="sk_live_..." \
  stripe.webhook_secret="whsec_..." \
  --project FIREBASE_PROJECT_ID
```

## Testing

### Unit Tests

```bash
# Run all tests
npm test

# Run specific test file
npm test -- checkout.test.ts

# Run with watch mode
npm run test:watch
```

### Integration Tests

```bash
# Start emulators first
firebase emulators:start --only functions,firestore &

# Run integration tests
npm run test:integration
```

### Security Rules Tests

```bash
# Test Firestore security rules
npm run test:rules
```

## Local API Testing

### Health Check

```bash
curl http://localhost:5001/FIREBASE_PROJECT_ID/us-central1/api/health
```

### Authenticated Endpoints

```bash
# Get test token from Firebase Auth emulator
AUTH_TOKEN="eyJhbGciOiJSUzI1NiIs..."

# Test checkout session creation
curl -X POST \
  http://localhost:5001/FIREBASE_PROJECT_ID/us-central1/createCheckoutSession \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"planId": "pro", "successUrl": "http://localhost:3000/success"}'
```

## Stripe Webhook Testing

### 1. Install Stripe CLI

```bash
# Windows (Scoop)
scoop install stripe

# macOS (Homebrew)
brew install stripe/stripe-cli/stripe

# Linux - download from GitHub releases
```

### 2. Forward Webhooks

```bash
# Login to Stripe
stripe login

# Forward webhooks to local function
stripe listen --forward-to \
  http://localhost:5001/FIREBASE_PROJECT_ID/us-central1/webhook
```

### 3. Trigger Test Events

```bash
# Test subscription created
stripe trigger customer.subscription.created

# Test payment succeeded
stripe trigger invoice.payment_succeeded
```

## Deployment

### Deploy to Development

```bash
# Deploy functions only
firebase deploy --only functions

# Deploy with environment
firebase deploy --only functions --project dev-project
```

### Deploy to Production

```bash
# Switch to production project
firebase use production-project

# Deploy
firebase deploy --only functions
```

## Debugging

### Local Debugging

1. **VS Code Launch Configuration:**

```json
{
  "type": "node",
  "request": "launch",
  "name": "Debug Functions",
  "program": "${workspaceFolder}/functions/lib/index.js",
  "env": {
    "FUNCTIONS_EMULATOR": "true",
    "FIREBASE_PROJECT_ID": "demo-project"
  }
}
```

### Function Logs

```bash
# View logs in emulator
firebase emulators:start --inspect-functions

# View production logs
firebase functions:log

# Tail logs
firebase functions:log --tail
```

### Error Debugging

Common issues and solutions:

```bash
# Permission denied
firebase login --reauth

# Module not found
cd functions && npm ci

# TypeScript errors
npm run build

# Port already in use
lsof -ti:5001 | xargs kill -9
```

## Performance Optimization

### Cold Start Reduction

- Use Node.js 20 runtime
- Minimize dependencies
- Implement function warming

### Memory Management

```typescript
// Set memory allocation
export const heavyFunction = functions
  .runWith({ memory: "1GB" })
  .https.onRequest(handler);
```

### Concurrent Execution

```typescript
// Set max instances
export const scalableFunction = functions
  .runWith({ maxInstances: 100 })
  .https.onRequest(handler);
```

## Monitoring

### Local Monitoring

- Firebase Emulator UI: <http://localhost:4000>
- Function execution logs in terminal
- Firestore data viewer in emulator

### Production Monitoring

- Cloud Functions console
- Cloud Logging for error tracking
- Cloud Monitoring for metrics

## Troubleshooting

### Common Issues

**Build Failures:**

```bash
# Clear node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

**Emulator Issues:**

```bash
# Kill all Firebase processes
pkill -f firebase
firebase emulators:start
```

**Permission Errors:**

```bash
# Check Firebase project access
firebase projects:list

# Verify service account permissions
firebase functions:config:get
```

---

**Next Steps:** See `API.md` for endpoint documentation and testing examples.
