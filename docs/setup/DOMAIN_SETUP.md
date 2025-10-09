# 🌐 Domain Setup Guide for toolz.space

## Quick Setup Steps

### 1. Deploy to Firebase Hosting

```bash
# Build and deploy
./scripts/deploy.ps1

# Or manually:
flutter build web --release --web-renderer html
firebase deploy --project toolspace-beta
```

### 2. Add Custom Domain in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: `toolspace-beta`
3. Navigate to **Hosting** section
4. Click **Add custom domain**
5. Enter domain: `toolz.space`
6. Follow the DNS verification steps

### 3. DNS Configuration

You'll need to add these DNS records to your domain registrar:

#### For domain verification

```dns
Type: TXT
Name: @
Value: [Firebase will provide this]
```

#### For hosting

```dns
Type: A
Name: @
Value: [Firebase will provide these IPs]

Type: A
Name: @
Value: [Multiple A records for redundancy]
```

#### For www subdomain (recommended)

```dns
Type: CNAME
Name: www
Value: toolz.space
```

### 4. SSL Certificate

Firebase automatically provisions SSL certificates for custom domains. This may take up to 24 hours.

### 5. Verify Setup

After DNS propagation (up to 48 hours):

- ✅ <https://toolz.space> should load your app
- ✅ <https://www.toolz.space> should redirect to main domain
- ✅ SSL certificate should be valid

## Advanced Configuration

### Environment Variables

Create `.env` file in functions directory:

```env
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

### Custom Headers (Already configured in firebase.json)

- Cache control for static assets
- Security headers
- CORS configuration

### Monitoring

- Enable Firebase Analytics
- Set up Firebase Performance Monitoring
- Configure error reporting

## Troubleshooting

### Domain not resolving

1. Check DNS propagation: <https://dnschecker.org/>
2. Verify A records point to Firebase IPs
3. Ensure TTL is not too high (max 300 seconds during setup)

### SSL certificate issues

1. Wait 24-48 hours for automatic provisioning
2. Ensure domain is verified in Firebase Console
3. Check that www subdomain redirects properly

### Build issues

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build web --release
```

## Production Checklist

- [ ] Domain verified in Firebase Console
- [ ] DNS records configured
- [ ] SSL certificate active
- [ ] Environment variables set
- [ ] Analytics enabled
- [ ] Performance monitoring active
- [ ] Error reporting configured
- [ ] Backup/rollback plan ready

## Commands Reference

```bash
# Deploy everything
firebase deploy --project toolspace-beta

# Deploy only hosting
firebase deploy --only hosting --project toolspace-beta

# Deploy only functions
firebase deploy --only functions --project toolspace-beta

# Preview deployment
firebase hosting:channel:deploy preview --project toolspace-beta

# Check project status
firebase projects:list
```

---

🎉 **Once configured, your app will be live at <https://toolz.space>!**
