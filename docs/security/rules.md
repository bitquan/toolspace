# Firestore Security Rules Documentation

Comprehensive guide to Firebase security rules implementation for Neo-Playground Toolspace.

## Overview

Our security model follows these principles:

1. **Per-User Data Isolation**: Users can only access their own data
2. **Authentication Required**: All reads/writes require authentication
3. **Email Verification for Billing**: Subscription operations require verified email
4. **Admin Override**: Admin users have elevated permissions (future)

## Security Rule Structure

```
firestore.rules
├── users/{uid}                    # User documents
│   ├── billing/                   # Billing profiles and usage
│   ├── tools/                     # Tool-specific user data
│   └── storage/                   # File metadata
├── ops/                           # Operational data (admin only)
└── public/                        # Public read-only data
```

## Rule Files

### `firestore.rules` - Firestore Database Rules

Located at: `firestore.rules`

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(uid) {
      return isAuthenticated() && request.auth.uid == uid;
    }

    function emailVerified() {
      return request.auth.token.email_verified == true;
    }

    // Users collection
    match /users/{uid} {
      // User can read/write their own document
      allow read, write: if isOwner(uid);

      // Billing subcollection
      match /billing/{document=**} {
        // Read own billing data
        allow read: if isOwner(uid);

        // Write only through Cloud Functions or if emailVerified
        allow write: if isOwner(uid) && emailVerified();
      }

      // Tools subcollection (file merger, invoice, etc.)
      match /tools/{toolId}/{document=**} {
        allow read, write: if isOwner(uid);
      }

      // Storage metadata
      match /storage/{document=**} {
        allow read, write: if isOwner(uid);
      }
    }

    // Operational data (admin only - future)
    match /ops/{document=**} {
      allow read: if false;  // No direct reads
      allow write: if false; // Only Cloud Functions
    }

    // Public read-only data (config, pricing, etc.)
    match /public/{document=**} {
      allow read: if true;
      allow write: if false; // Only admin/Cloud Functions
    }
  }
}
```

### `storage.rules` - Firebase Storage Rules

Located at: `storage.rules`

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {

    // User files: users/{uid}/...
    match /users/{uid}/{allPaths=**} {
      // Users can read/write their own files
      allow read, write: if request.auth != null
                         && request.auth.uid == uid;

      // File size limit: 10MB
      allow write: if request.resource.size < 10 * 1024 * 1024;
    }

    // Public files (avatars, assets)
    match /public/{allPaths=**} {
      allow read: if true;
      allow write: if false; // Only admin
    }
  }
}
```

## Rule Functions Explained

### `isAuthenticated()`

Checks if user is signed in.

```javascript
function isAuthenticated() {
  return request.auth != null;
}
```

**Used for**: All authenticated endpoints

### `isOwner(uid)`

Checks if authenticated user matches the resource owner.

```javascript
function isOwner(uid) {
  return isAuthenticated() && request.auth.uid == uid;
}
```

**Used for**: User data access, billing, tools

### `emailVerified()`

Checks if user's email is verified.

```javascript
function emailVerified() {
  return request.auth.token.email_verified == true;
}
```

**Used for**: Billing operations, premium feature gates

## Testing Security Rules

### Local Testing with Emulator

1. **Start Firestore Emulator**:

```bash
firebase emulators:start --only firestore
```

2. **Run Security Rule Tests**:

```bash
# From project root
npm test

# Or specific test file
npx jest test/firestore.rules.test.js
```

### Example Test Cases

Create `test/firestore.rules.test.js`:

```javascript
const firebase = require("@firebase/rules-unit-testing");
const fs = require("fs");

const PROJECT_ID = "test-project";
const RULES = fs.readFileSync("firestore.rules", "utf8");

describe("Firestore Security Rules", () => {
  let testEnv;

  beforeAll(async () => {
    testEnv = await firebase.initializeTestEnvironment({
      projectId: PROJECT_ID,
      firestore: {
        rules: RULES,
        host: "localhost",
        port: 8080,
      },
    });
  });

  afterAll(async () => {
    await testEnv.cleanup();
  });

  test("authenticated user can read own data", async () => {
    const alice = testEnv.authenticatedContext("alice");
    await firebase.assertSucceeds(alice.firestore().doc("users/alice").get());
  });

  test("user cannot read another user's data", async () => {
    const alice = testEnv.authenticatedContext("alice");
    await firebase.assertFails(alice.firestore().doc("users/bob").get());
  });

  test("unauthenticated user cannot read user data", async () => {
    const unauth = testEnv.unauthenticatedContext();
    await firebase.assertFails(unauth.firestore().doc("users/alice").get());
  });

  test("user with verified email can write billing data", async () => {
    const alice = testEnv.authenticatedContext("alice", {
      email_verified: true,
    });
    await firebase.assertSucceeds(
      alice.firestore().doc("users/alice/billing/profile").set({
        planId: "pro",
        status: "active",
      })
    );
  });

  test("user without verified email cannot write billing data", async () => {
    const alice = testEnv.authenticatedContext("alice", {
      email_verified: false,
    });
    await firebase.assertFails(
      alice.firestore().doc("users/alice/billing/profile").set({
        planId: "pro",
        status: "active",
      })
    );
  });
});
```

### Manual Testing in Emulator UI

1. Open emulator UI: `http://localhost:4000/firestore`
2. Try to create documents under different paths
3. Test with different auth states (signed in, signed out, different UIDs)
4. Verify rules are enforced correctly

## Common Security Patterns

### Pattern 1: User-Scoped Data

```javascript
match /users/{uid}/{document=**} {
  allow read, write: if isOwner(uid);
}
```

**Use**: User profiles, preferences, tool data

### Pattern 2: Email Verification Gate

```javascript
match /users/{uid}/billing/{document=**} {
  allow write: if isOwner(uid) && emailVerified();
}
```

**Use**: Billing, subscriptions, payments

### Pattern 3: Read-Only Public Data

```javascript
match /public/{document=**} {
  allow read: if true;
  allow write: if false;
}
```

**Use**: Configuration, pricing, public assets

### Pattern 4: Admin-Only Operations

```javascript
match /ops/{document=**} {
  allow read, write: if false; // Only Cloud Functions
}
```

**Use**: Audit logs, billing events, system data

## Deployment

### Deploy Rules to Firebase

```bash
# Deploy all rules
firebase deploy --only firestore:rules,storage:rules

# Deploy specific rules
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
```

### Verify Deployment

1. Check Firebase Console > Firestore Database > Rules
2. Check Firebase Console > Storage > Rules
3. Verify timestamps match deployment time

## Monitoring & Debugging

### Enable Firestore Debug Logging

```javascript
// In browser console
firebase.firestore.setLogLevel("debug");
```

### Common Error Messages

**Error**: "Missing or insufficient permissions"

**Cause**: Security rule denied the operation

**Solution**: Check if user is authenticated and has correct permissions

**Error**: "PERMISSION_DENIED"

**Cause**: Rule explicitly denied access

**Solution**: Review rule conditions and auth state

### Firebase Console Monitoring

1. Go to Firebase Console > Firestore Database
2. Click "Usage" tab
3. Monitor read/write operations
4. Check for denied requests

## Security Checklist

### Pre-Production

- [ ] All rules tested locally with emulator
- [ ] Email verification enforced for billing
- [ ] User data isolation verified
- [ ] No public write access except intended
- [ ] Storage file size limits configured
- [ ] Admin paths secured (write: false)

### Production

- [ ] Rules deployed to production
- [ ] Monitoring enabled for denied requests
- [ ] Audit logs configured
- [ ] Regular security reviews scheduled
- [ ] Incident response plan in place

## Best Practices

### DO

✅ Always require authentication for sensitive data
✅ Use email verification for financial operations
✅ Limit file sizes in storage rules
✅ Test rules thoroughly with emulator
✅ Use helper functions for complex conditions
✅ Document rule intentions with comments

### DON'T

❌ Allow unauthenticated writes
❌ Use `allow read, write: if true` for user data
❌ Trust client-side validation alone
❌ Deploy untested rules to production
❌ Expose sensitive data in public paths
❌ Skip email verification for billing

## Troubleshooting

### Issue: Rule changes not taking effect

**Solution**: Redeploy rules and clear browser cache

```bash
firebase deploy --only firestore:rules --force
```

### Issue: Tests failing in CI

**Solution**: Ensure emulator is running and ports are correct

```bash
firebase emulators:start --only firestore --project test-project
```

### Issue: Production rules too permissive

**Solution**: Review and tighten rules, deploy immediately

```bash
# Emergency rule deployment
firebase deploy --only firestore:rules --project production
```

## Support & Resources

- [Firebase Security Rules Documentation](https://firebase.google.com/docs/rules)
- [Firestore Security Rules Guide](https://firebase.google.com/docs/firestore/security/get-started)
- [Storage Security Rules Guide](https://firebase.google.com/docs/storage/security)
- [Rules Unit Testing](https://firebase.google.com/docs/rules/unit-tests)

---

**Last Updated**: October 2025
**Version**: 1.0.0
**Status**: Production Ready
