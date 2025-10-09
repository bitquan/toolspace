# Toolspace

**Micro-tools platform for productivity and business needs**

Toolspace is a collection of focused, web-based micro-tools designed to help small businesses, freelancers, and individuals accomplish common tasks quickly and efficiently.

---

## 🚫 NOT READY FOR LAUNCH

> **⚠️ PRODUCTION DEPLOYMENT BLOCKED**
>
> All pull requests must pass the **PR CI pipeline** before deployment. The pipeline validates builds, tests, security, and code quality in <10 minutes.
>
> **Status:** [![PR CI](https://github.com/bitquan/toolspace/actions/workflows/pr-ci.yml/badge.svg)](https://github.com/bitquan/toolspace/actions/workflows/pr-ci.yml)

---

## � PRODUCTION STATUS

✅ **PRODUCTION READY**

**Current Status:** Complete production blueprint implemented with single-environment deployment strategy

**Key Features:**

- ✅ Real user authentication (Google, Apple, Email)
- ✅ Secure database rules and functions
- ✅ Stripe billing integration (Free/Pro $9/Pro+ $19)
- ✅ Comprehensive security audit complete
- ✅ CI/CD deployment pipeline
- ✅ Production monitoring and alerts

**Production Deployment:**

- 🌐 Live at: [toolspace.app](https://toolspace.app)
- 📊 Status: [![Production Deployment](https://github.com/bitquan/toolspace/actions/workflows/prod-release.yml/badge.svg)](https://github.com/bitquan/toolspace/actions/workflows/prod-release.yml)
- 🔧 Staging: [![Staging Deployment](https://github.com/bitquan/toolspace/actions/workflows/staging-release.yml/badge.svg)](https://github.com/bitquan/toolspace/actions/workflows/staging-release.yml)

## 🚀 Quick Start

### Run Locally

```bash
# 1. Get Flutter dependencies
flutter pub get

# 2. Run the Flutter web app
flutter run -d chrome

# 3. Set up backend (in separate terminal)
cd functions
npm ci
npm run qa

# 4. Start Firebase emulators
firebase emulators:start
```

## 📚 Documentation

Complete production deployment documentation:

- 📖 [Deployment Guide](DEPLOYMENT.md) - Step-by-step production deployment
- 🤝 [Contributing Guide](CONTRIBUTING.md) - Development workflow and standards
- 🏗️ [Architecture Overview](docs/development/coding-standards.md) - System design and patterns
- 🔧 [Environment Setup](docs/ENVIRONMENT.md) - Configuration and secrets management
- 🔒 [Security Guide](docs/security/) - Authentication, authorization, and compliance
- 📊 [API Documentation](docs/backend/API.md) - Backend services and endpoints
- 🚀 [Operations Manual](docs/ops/) - Monitoring, backup, and incident response
- ✅ [Production Checklist](PRODUCTION_CHECKLIST.md) - Pre-launch validation steps

### Development Workflow

```bash
# Frontend development
flutter analyze              # Check for issues
flutter test                 # Run tests

# Backend development
cd functions
npm run qa                   # Run all QA checks (lint + typecheck + test)
npm run build                # Build TypeScript
```

## ✨ Key Features

### Cross-Tool Data Sharing

Share data seamlessly between tools without manual copy-paste:

- 🔄 Share text, JSON, URLs, and more between tools
- 📋 One-click import from other tools
- 📜 History tracking for recent shares
- 🎯 Type-safe data transfer

Example: Format JSON in JSON Doctor → Share → Generate QR code in QR Maker

[Learn more about cross-tool data sharing](docs/tools/cross-tool-data-sharing.md)

## 🛠️ Tools

### Quick Invoice

Professional invoice generation with PDF export and email delivery.

- **Status**: 🚧 In Development
- **Type**: Full-stack (Flutter + Firebase Functions)

### Text Tools

Client-side text processing utilities (case conversion, formatting, validation).

- **Status**: 🚧 In Development
- **Type**: Client-only (Flutter)
- **Features**: Cross-tool data sharing enabled ✓

### JSON Doctor

JSON validation, formatting, and schema validation tool.

- **Status**: ✅ Available
- **Type**: Client-only (Flutter)
- **Features**: Cross-tool data sharing enabled ✓

### Text Diff

Compare texts with line-by-line and word-level differences.

- **Status**: ✅ Available
- **Type**: Client-only (Flutter)
- **Features**: Cross-tool data sharing enabled ✓

### QR Maker

Generate QR codes with customization options.

- **Status**: ✅ Available
- **Type**: Client-only (Flutter)
- **Features**: Cross-tool data sharing enabled ✓

### File Merger

Server-assisted file merging and processing for multiple file formats.

- **Status**: 🚧 In Development
- **Type**: Full-stack with server processing

## 🏗️ Architecture

### Frontend

- **Framework**: Flutter (web-first, mobile-responsive)
- **State Management**: Built-in Flutter state management
- **Routing**: Custom router with tool-specific routes
- **UI**: Material Design 3

### Backend

- **Platform**: Firebase Functions (Node.js 20+)
- **Language**: TypeScript with strict configuration
- **Database**: Cloud Firestore with security rules
- **Storage**: Cloud Storage for file processing
- **Authentication**: Firebase Auth

### Infrastructure

- **Hosting**: Firebase Hosting
- **CI/CD**: Two-tier GitHub Actions (Lean PR + Heavy Nightly)
- **Monitoring**: Firebase console + custom logging
- **Security**: Firestore security rules + input validation

## 🔄 CI/CD Pipeline

Toolspace uses a **two-tier CI strategy** for fast feedback and comprehensive validation:

### PR CI (Lean & Fast) - Required for Merge

Runs on every pull request in <10 minutes:

- ✅ **Flutter Build** - Dependencies, static analysis, web build
- ✅ **Functions Build** - Dependencies, linting, TypeScript type-check
- ✅ **Flutter Tests** - Unit tests with coverage
- ✅ **Functions Tests** - Unit tests (excluding E2E)
- ✅ **Security Smoke** - Critical security rules (@smoke tagged)

**Run locally before pushing:**

```bash
make pr-ci
```

### Nightly CI (Heavy & Comprehensive) - Informational

Runs overnight at 00:30 UTC for deep validation:

- 🔍 **Full E2E Suite** - Playwright tests with artifacts
- 🛡️ **Deep Security Scans** - CodeQL, Trivy, npm audit
- 📊 **Coverage Trends** - Track test coverage over time
- 📦 **Dependency Health** - Outdated packages, security advisories
- 📈 **Weekly Digest** - Velocity reports and insights

Nightly failures create GitHub issues but **don't block PRs**.

**Documentation:** See [docs/ops/ci.md](docs/ops/ci.md) for full details.

## 📚 Documentation

### For Users

- Getting started guides (coming soon)
- Tool-specific documentation in `docs/tools/`

### For Developers

- [Backend Architecture](docs/backend/README.md)
- [Testing Strategy](docs/quality/testing.md)
- [Triage Guidelines](docs/quality/triage.md)
- [API Documentation](docs/backend/API.md)

### Quality Assurance

- [Testing Policies](docs/policies/testing.md)
- [Always-on QA requirements](docs/policies/testing.md)

## 🔧 Development

### Prerequisites

- Flutter 3.3.0+
- Node.js 20+
- Firebase CLI
- Git

### Project Structure

```
toolspace/
├── lib/                    # Flutter app
├── core/                   # Shared components
├── tools/                  # Individual micro-tools
├── functions/              # Firebase Functions
├── docs/                   # Documentation
├── .github/                # CI/CD and templates
└── dev-log/                # Development logs
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes with tests
4. Ensure QA passes (`npm run qa` + `flutter analyze`)
5. Submit pull request

### Quality Standards

All PRs must pass these 5 checks:

- ✅ **flutter_build** - Code analysis and web build
- ✅ **functions_build** - Linting and TypeScript compilation
- ✅ **tests_flutter** - Unit tests with coverage
- ✅ **tests_functions** - Backend unit tests
- ✅ **security_smoke** - Critical security rules

Additional validation runs nightly (informational only).

## � Pricing

### Current Plans

- **Free**: $0 - Access to all tools with basic limits
- **Pro**: $9/month - Enhanced limits, batch processing, priority support
- **Pro+**: $19/month - Maximum limits, priority queue, advanced features

All pricing is managed through `config/pricing.json` with Stripe integration for paid plans.

## �🔒 Security

- All user data is isolated by tenant (user)
- Firestore security rules enforce access control
- Input validation on all endpoints
- Regular dependency security scanning
- No sensitive data in logs

## 📈 Status

**Current Phase**: Scaffold and Foundation (Phase 1)

### Completed ✅

- Project structure and tooling
- Firebase configuration
- CI/CD pipelines
- Documentation framework
- Security foundation

### In Progress 🚧

- Core UI components
- Authentication integration
- First tool implementations

### Planned 📋

- Tool-specific features
- Payment integration
- Mobile app optimization
- Advanced analytics

## 📞 Support

- **Issues**: Use GitHub Issues with appropriate labels
- **Discussions**: GitHub Discussions for questions
- **Security**: Email security issues privately

## 📄 License

[License details to be added]

---

Built with ❤️ for productivity and efficiency.
