# Backup and Recovery

Comprehensive backup and disaster recovery procedures for Toolspace production environment.

## Overview

**RTO (Recovery Time Objective):** 4 hours
**RPO (Recovery Point Objective):** 24 hours
**Backup Frequency:** Daily automated + on-demand

## Firestore Database Backup

### Automated Daily Exports

**Scheduled Export:**

```bash
# Daily export via Cloud Scheduler
gcloud firestore export gs://FIREBASE_PROJECT_ID-backups/firestore/$(date +%Y-%m-%d)

# With specific collections
gcloud firestore export \
  gs://FIREBASE_PROJECT_ID-backups/firestore/$(date +%Y-%m-%d) \
  --collection-ids=users,billing,usage
```

**Retention Policy:**

- Daily backups: 30 days
- Weekly backups: 12 weeks
- Monthly backups: 12 months

### Manual Backup

```bash
# Full database export
gcloud firestore export gs://FIREBASE_PROJECT_ID-backups/manual/$(date +%Y-%m-%d-%H%M)

# Specific collections
gcloud firestore export \
  gs://FIREBASE_PROJECT_ID-backups/manual/billing-$(date +%Y-%m-%d) \
  --collection-ids=users
```

### Backup Verification

```bash
# List available backups
gsutil ls gs://FIREBASE_PROJECT_ID-backups/firestore/

# Verify backup integrity
gcloud firestore operations list --filter="type:EXPORT_DOCUMENTS"
```

## Cloud Storage Backup

### User Files Backup

```bash
# Sync to backup bucket
gsutil -m rsync -r -d \
  gs://FIREBASE_PROJECT_ID.appspot.com/ \
  gs://FIREBASE_PROJECT_ID-backups/storage/$(date +%Y-%m-%d)/
```

### Automated Storage Backup

```yaml
# Cloud Build trigger
apiVersion: cloudbuild/v1
kind: Build
metadata:
  name: storage-backup
spec:
  steps:
    - name: "gcr.io/google.com/cloudsdktool/cloud-sdk"
      script: |
        gsutil -m rsync -r -d \
          gs://${PROJECT_ID}.appspot.com/ \
          gs://${PROJECT_ID}-backups/storage/$(date +%Y-%m-%d)/
```

## Stripe Data Backup

### Customer and Subscription Data

**Important:** Stripe is the system of record for billing data.

```bash
# Export customers (via Stripe CLI)
stripe customers list --limit 100 > customers-$(date +%Y-%m-%d).json

# Export subscriptions
stripe subscriptions list --limit 100 > subscriptions-$(date +%Y-%m-%d).json

# Export products and prices
stripe products list > products-$(date +%Y-%m-%d).json
stripe prices list > prices-$(date +%Y-%m-%d).json
```

**Note:** Stripe data cannot be imported back. This is for audit/analysis only.

## Recovery Procedures

### Firestore Database Recovery

#### Full Database Restore

```bash
# Import from backup
gcloud firestore import gs://FIREBASE_PROJECT_ID-backups/firestore/2025-10-09

# Monitor import status
gcloud firestore operations list --filter="type:IMPORT_DOCUMENTS"
```

#### Selective Collection Restore

```bash
# Restore specific collections to temporary project
gcloud firestore import \
  gs://FIREBASE_PROJECT_ID-backups/firestore/2025-10-09 \
  --collection-ids=users \
  --project=temp-recovery-project

# Migrate specific documents back to production
# (Manual process using admin SDK)
```

#### Point-in-Time Recovery

**Limitation:** Firestore doesn't support PITR. Use nearest daily backup.

**Process:**

1. Identify the last good backup before incident
2. Calculate data loss window (since last backup)
3. Restore from backup to temporary environment
4. Manually reconcile recent changes if possible

### Cloud Storage Recovery

#### Full Storage Restore

```bash
# Restore from backup bucket
gsutil -m rsync -r -d \
  gs://FIREBASE_PROJECT_ID-backups/storage/2025-10-09/ \
  gs://FIREBASE_PROJECT_ID.appspot.com/
```

#### Selective File Recovery

```bash
# Restore specific user folder
gsutil -m cp -r \
  gs://FIREBASE_PROJECT_ID-backups/storage/2025-10-09/uploads/user123/ \
  gs://FIREBASE_PROJECT_ID.appspot.com/uploads/user123/
```

### Application Recovery

#### Code Rollback

```bash
# Rollback to previous tag
git checkout v1.0.0
firebase deploy

# Or rollback specific components
firebase deploy --only hosting
firebase deploy --only functions
```

#### Configuration Recovery

```bash
# Restore Firebase configuration
firebase functions:config:set \
  stripe.secret_key="sk_live_..." \
  stripe.webhook_secret="whsec_..."

# Update Firestore security rules
firebase deploy --only firestore:rules
```

## Disaster Recovery Scenarios

### Scenario 1: Database Corruption

**Detection:**

- Monitoring alerts on data inconsistencies
- User reports of missing/incorrect data

**Response:**

1. Stop all writes to affected collections
2. Assess extent of corruption
3. Restore from latest clean backup
4. Reconcile recent transactions manually
5. Resume operations

**Timeline:** 2-4 hours

### Scenario 2: Accidental Data Deletion

**Detection:**

- Monitoring alerts on bulk deletions
- User reports of missing data

**Response:**

1. Immediately stop the deletion process
2. Identify deleted data scope
3. Restore from backup to staging environment
4. Export affected data
5. Import back to production
6. Verify data integrity

**Timeline:** 1-3 hours

### Scenario 3: Regional Outage

**Detection:**

- Firebase Console alerts
- Application health checks failing

**Response:**

1. Confirm regional outage with Google Cloud Status
2. Wait for Google to restore services (no action needed)
3. Monitor for service restoration
4. Verify application functionality post-restoration

**Timeline:** Depends on Google Cloud recovery

### Scenario 4: Complete Project Loss

**Detection:**

- Total inability to access Firebase project
- All services return permission errors

**Response:**

1. Create new Firebase project
2. Restore Firestore from latest backup
3. Restore Cloud Storage from backup
4. Reconfigure all services and secrets
5. Update DNS to point to new project
6. Migrate users with communication plan

**Timeline:** 4-8 hours

## Testing Recovery Procedures

### Monthly Recovery Drills

```bash
# Create test environment
firebase projects:create toolspace-recovery-test

# Test Firestore restore
gcloud firestore import gs://FIREBASE_PROJECT_ID-backups/firestore/latest \
  --project=toolspace-recovery-test

# Verify data integrity
npm run verify-backup --project=toolspace-recovery-test

# Cleanup
firebase projects:delete toolspace-recovery-test
```

### Backup Validation

```javascript
// Automated backup validation script
const admin = require("firebase-admin");

async function validateBackup(backupPath) {
  // Check user collection integrity
  const users = await admin.firestore().collection("users").get();
  console.log(`Users: ${users.size}`);

  // Check billing profiles
  const billing = await admin.firestore().collectionGroup("billing").get();
  console.log(`Billing profiles: ${billing.size}`);

  // Verify critical data relationships
  // ... validation logic
}
```

## Monitoring and Alerts

### Backup Success Monitoring

```yaml
# Cloud Monitoring alert
displayName: "Firestore Export Failed"
conditions:
  - displayName: "Export operation failed"
    conditionThreshold:
      filter: 'resource.type="gce_instance" AND log_name="projects/PROJECT_ID/logs/firestore_export"'
      comparison: COMPARISON_GREATER_THAN
      thresholdValue: 0
```

### Recovery Testing Alerts

- Monthly backup validation results
- Recovery drill completion status
- RTO/RPO compliance metrics

## Documentation and Runbooks

### Emergency Contacts

- **On-call Engineer:** [Contact info]
- **Firebase Support:** [Support case link]
- **Stripe Support:** [Support portal]

### Recovery Runbooks

1. `docs/runbooks/firestore-recovery.md`
2. `docs/runbooks/storage-recovery.md`
3. `docs/runbooks/full-disaster-recovery.md`

## Compliance and Auditing

### Backup Audit Trail

- All backup operations logged in Cloud Audit Logs
- Recovery operations require documented justification
- Monthly backup verification reports

### Data Retention

- Production backups: Follow legal requirements
- Development backups: 30 days maximum
- Test environment data: Delete after use

---

**Emergency Hotline:** Follow incident response procedures in `docs/support.md`
