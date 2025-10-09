# Performance Optimization Guide

## Overview

This guide covers performance best practices, monitoring, and optimization strategies for Toolspace production deployment.

## Frontend Performance

### Flutter Web Optimization

```bash
# Build optimized production bundle
flutter build web --release --web-renderer html

# Analyze bundle size
flutter build web --analyze-size

# Profile performance
flutter run --profile -d chrome
```

### Key Metrics

- **First Contentful Paint (FCP)**: < 1.8s
- **Largest Contentful Paint (LCP)**: < 2.5s
- **First Input Delay (FID)**: < 100ms
- **Cumulative Layout Shift (CLS)**: < 0.1

### Optimization Techniques

#### Code Splitting

```dart
// Lazy load tool modules
class ToolLoader {
  static Future<Widget> loadTool(String toolId) async {
    switch (toolId) {
      case 'invoice':
        return await import('./tools/invoice/invoice_tool.dart');
      case 'text':
        return await import('./tools/text/text_tools.dart');
      default:
        return Container();
    }
  }
}
```

#### Asset Optimization

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/icons/
    - assets/images/
  fonts:
    - family: Inter
      fonts:
        - asset: fonts/Inter-Regular.woff2
          weight: 400
        - asset: fonts/Inter-Bold.woff2
          weight: 700
```

## Backend Performance

### Firebase Function Optimization

```typescript
// Optimize cold starts
import { onRequest } from "firebase-functions/v2/https";
import { setGlobalOptions } from "firebase-functions/v2";

setGlobalOptions({
  region: "us-central1",
  memory: "256MiB",
  timeoutSeconds: 60,
  minInstances: 1, // Keep warm
});

export const api = onRequest(
  {
    concurrency: 80,
    cpu: 1,
  },
  async (req, res) => {
    // Function logic
  }
);
```

### Database Optimization

#### Firestore Query Optimization

```typescript
// Use composite indexes
const invoices = await db
  .collection("invoices")
  .where("userId", "==", userId)
  .where("status", "==", "active")
  .orderBy("createdAt", "desc")
  .limit(20)
  .get();

// Paginate large datasets
const startAfter = lastVisible;
const next = await query.startAfter(startAfter).limit(pageSize).get();
```

#### Connection Pooling

```typescript
// Reuse database connections
const admin = getFirestore();
admin.settings({
  ignoreUndefinedProperties: true,
  maxIdleChannels: 10,
});
```

## Monitoring and Alerts

### Performance Monitoring

```typescript
// Custom performance tracking
import { getPerformance, trace } from "firebase/performance";

const perf = getPerformance();

// Trace custom operations
const t = trace(perf, "invoice_generation");
t.start();
await generateInvoice(data);
t.stop();
```

### Error Monitoring

```typescript
// Sentry integration
import * as Sentry from '@sentry/flutter';

await SentryFlutter.init(
  (options) {
    options.dsn = 'YOUR_DSN';
    options.tracesSampleRate = 0.1;
    options.profilesSampleRate = 0.1;
  },
  appRunner: () => runApp(MyApp()),
);
```

### Health Checks

```typescript
// Function health endpoint
export const health = onRequest(async (req, res) => {
  const checks = {
    database: await checkDatabase(),
    storage: await checkStorage(),
    auth: await checkAuth(),
  };

  const healthy = Object.values(checks).every(Boolean);

  res.status(healthy ? 200 : 503).json({
    status: healthy ? "healthy" : "unhealthy",
    checks,
    timestamp: new Date().toISOString(),
  });
});
```

## Caching Strategy

### Client-Side Caching

```dart
// HTTP cache configuration
final dio = Dio();
dio.interceptors.add(DioCacheInterceptor(
  options: CacheOptions(
    store: MemCacheStore(),
    policy: CachePolicy.forceCache,
    maxStale: const Duration(hours: 1),
  ),
));
```

### CDN Configuration

```yaml
# firebase.json
{
  "hosting":
    {
      "headers":
        [
          {
            "source": "**/*.@(js|css|woff2)",
            "headers":
              [
                {
                  "key": "Cache-Control",
                  "value": "public, max-age=31536000, immutable",
                },
              ],
          },
          {
            "source": "**/*.@(png|jpg|jpeg|gif|svg|webp)",
            "headers":
              [{ "key": "Cache-Control", "value": "public, max-age=86400" }],
          },
        ],
    },
}
```

## Load Testing

### Artillery Configuration

```yaml
# artillery-config.yml
config:
  target: "https://toolspace.app"
  phases:
    - duration: 60
      arrivalRate: 10
      name: Warm up
    - duration: 300
      arrivalRate: 50
      name: Load test

scenarios:
  - name: Invoice generation
    weight: 70
    flow:
      - post:
          url: "/api/invoices"
          headers:
            Authorization: "Bearer {{ token }}"
          json:
            customer: "Test Customer"
            items: [{ description: "Test", amount: 100 }]

  - name: Text processing
    weight: 30
    flow:
      - post:
          url: "/api/text/format"
          json:
            text: "Sample text"
            operation: "uppercase"
```

### Running Load Tests

```bash
# Install Artillery
npm install -g artillery

# Run load test
artillery run artillery-config.yml

# Generate report
artillery run --output report.json artillery-config.yml
artillery report report.json
```

## Performance Checklist

### Pre-Deployment

- [ ] Bundle size analysis completed
- [ ] Lighthouse audit score > 90
- [ ] Core Web Vitals in green
- [ ] Database queries optimized
- [ ] Caching strategy implemented
- [ ] Error monitoring configured

### Post-Deployment

- [ ] Real User Monitoring (RUM) active
- [ ] Performance budgets set
- [ ] Alerting thresholds configured
- [ ] Load testing schedule established
- [ ] Performance regression detection enabled

## Troubleshooting Common Issues

### Slow Page Load

1. Check network waterfall in DevTools
2. Analyze bundle size with webpack-bundle-analyzer
3. Review database query performance
4. Verify CDN cache hit rates

### High Memory Usage

1. Profile memory leaks with DevTools
2. Check for large object retention
3. Review image optimization
4. Analyze JavaScript heap snapshots

### Poor Core Web Vitals

1. Optimize Largest Contentful Paint (LCP)
2. Reduce First Input Delay (FID)
3. Minimize Cumulative Layout Shift (CLS)
4. Implement resource hints (preload, prefetch)

## Additional Resources

- [Firebase Performance Monitoring](https://firebase.google.com/docs/perf-mon)
- [Flutter Web Performance](https://docs.flutter.dev/perf/web)
- [Core Web Vitals](https://web.dev/vitals/)
- [Artillery Load Testing](https://artillery.io/docs/)
