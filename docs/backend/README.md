# Backend Architecture

This document provides an overview of the Toolspace backend architecture.

## Overview

The Toolspace backend is built using Firebase Functions with TypeScript, providing a serverless architecture that scales automatically with usage.

## Technology Stack

- **Runtime**: Node.js 20+
- **Language**: TypeScript
- **Framework**: Firebase Functions v5
- **Database**: Cloud Firestore
- **Storage**: Cloud Storage
- **Authentication**: Firebase Auth

## Project Structure

```
functions/
├── src/
│   ├── admin.ts              # Firebase admin initialization
│   ├── index.ts              # Function exports
│   ├── api/                  # HTTP API endpoints
│   │   └── health.ts         # Health check endpoint
│   ├── billing/              # Billing and subscription logic
│   │   └── index.ts          # Billing functions
│   ├── middleware/           # Express middleware
│   │   └── auth.ts           # Authentication middleware
│   ├── types/                # TypeScript type definitions
│   │   └── index.ts          # Shared types
│   └── util/                 # Utility functions
│       ├── errors.ts         # Error classes
│       ├── guards.ts         # Authentication guards
│       └── logger.ts         # Logging utilities
├── package.json              # Dependencies and scripts
├── tsconfig.json             # TypeScript configuration
└── jest.config.js            # Test configuration
```

## Core Components

### Authentication & Authorization

- Firebase Auth integration
- JWT token validation
- Role-based access control
- Tenant isolation (users can only access their own data)

### API Design

- RESTful HTTP endpoints
- Consistent error handling
- Request validation
- Rate limiting (planned)

### Data Layer

- Firestore for structured data
- Cloud Storage for files
- Atomic transactions where needed
- Optimistic concurrency control

### Error Handling

- Centralized error classes
- Structured error responses
- Logging and monitoring
- Graceful degradation

## API Endpoints

### Health Check

```
GET /health
Response: { "ok": true, "ts": 1234567890 }
```

### Billing (Planned)

```
POST /billing/subscription    # Create subscription
DELETE /billing/subscription  # Cancel subscription
GET /billing/status          # Get billing status
```

### Tool-Specific Endpoints (Planned)

```
POST /tools/quick-invoice/generate    # Generate invoice
POST /tools/file-merger/process       # Process file merge
```

## Security Considerations

### Data Protection

- All user data isolated by tenant
- Encryption at rest and in transit
- No sensitive data in logs
- Regular security audits

### Access Control

- Authentication required for all endpoints
- Users can only access their own data
- Admin functions require elevated permissions
- API rate limiting

### Storage Rules

Cloud Storage security is enforced through `storage.rules`:

- **User folders** (`/users/{userId}/`): Full read/write access for authenticated users to their own folders
- **Upload area** (`/uploads/{userId}/`): Temporary storage for file merger uploads, 10MB limit per file, PDF/image types only
- **Merged files** (`/merged/{userId}/`): Output files from file merger, read-only for users (backend writes via admin SDK)
- **Public assets** (`/public/`): Read-only access for all users
- All paths use deny-by-default security model

### Input Validation

- All inputs validated and sanitized
- File upload restrictions
- SQL injection prevention
- XSS protection

## Development Workflow

### Local Development

```bash
# Install dependencies
npm install

# Start emulators
firebase emulators:start

# Run tests
npm run qa

# Deploy functions
firebase deploy --only functions
```

### Quality Assurance

- TypeScript compilation
- ESLint static analysis
- Unit and integration tests
- Security vulnerability scanning

## Monitoring and Logging

### Application Logs

- Structured logging with context
- Error tracking and alerting
- Performance metrics
- User activity monitoring

### Infrastructure Monitoring

- Function execution metrics
- Database performance
- Storage usage
- Error rates and latency

## Scalability Considerations

### Function Architecture

- Stateless functions for horizontal scaling
- Cold start optimization
- Memory and timeout configuration
- Concurrent execution limits

### Database Design

- Efficient query patterns
- Proper indexing strategy
- Document size optimization
- Batch operations for bulk updates

### Cost Optimization

- Function resource allocation
- Database read/write optimization
- Storage lifecycle management
- Monitoring and alerting on costs

## Deployment Strategy

### Environments

- **Development**: Local emulators
- **Staging**: Firebase project for testing
- **Production**: Firebase project for live users

### CI/CD Pipeline

1. Code commit triggers build
2. Automated testing and quality checks
3. Deployment to staging environment
4. Manual approval for production
5. Automated rollback on failure

## Future Enhancements

### Performance

- Function warming strategies
- Database query optimization
- CDN integration for static assets
- Caching layer implementation

### Features

- WebSocket support for real-time features
- Background job processing
- Advanced analytics and reporting
- Multi-region deployment

### Security

- Advanced threat detection
- Audit logging
- Compliance certifications
- Zero-trust architecture
