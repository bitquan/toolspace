# Toolspace

**Micro-tools platform for productivity and business needs**

Toolspace is a collection of focused, web-based micro-tools designed to help small businesses, freelancers, and individuals accomplish common tasks quickly and efficiently.

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
- **CI/CD**: GitHub Actions
- **Monitoring**: Firebase console + custom logging
- **Security**: Firestore security rules + input validation

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

**All pushes are blocked by the Local Gate. Run `npm run preflight` until green.**

1. Fork the repository
2. Create a feature branch
3. Run `npm run setup:hooks` (one-time setup)
4. Make changes with tests
5. Run `npm run preflight` - must pass before push
6. Submit pull request

See [docs/ops/local-gate.md](docs/ops/local-gate.md) for details on the Local Gate system.

### Quality Standards

- ✅ **Local Gate**: `npm run preflight` must pass (enforced pre-push)
- ✅ Backend: All functions tests + lint
- ✅ Frontend: Flutter analyze + tests + build
- ✅ Security: Rules tests pass
- ✅ Documentation must be updated

## 🔒 Security

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
