# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Production deployment blueprint (single-env)
- Comprehensive CI/CD workflows
- Branch protection documentation
- API documentation for backend functions
- Performance monitoring setup
- Security compliance framework

### Changed

- Updated pricing display consistency across UI
- Improved billing success screen messaging
- Enhanced marketing pricing screen structure

### Fixed

- Removed "free trial" messaging from Pro plan buttons
- Corrected Pro+ plan naming from "Pro Plus" to "Pro+"

### Documentation

- Added DEPLOYMENT.md with end-to-end release guide
- Created CONTRIBUTING.md with development workflows
- Added comprehensive backend API documentation
- Created troubleshooting and debugging guides

## [1.0.0] - TBD

### Added

#### Monetization v1 Foundation

- Stripe subscription integration (Free/Pro/Pro+)
- Quota enforcement system
- PaywallGuard component for premium features
- Billing management UI with upgrade flows
- Webhook processing for subscription events

#### Auth-01 Epic

- Firebase Authentication with email/password
- Google OAuth integration
- Email verification requirements
- Secure user session management
- Account management interface

#### OPS-Gamma/Delta/Epsilon

- GitHub Actions CI/CD pipeline
- Automated testing workflows
- Security rules validation
- Preview deployments
- Production release automation

#### Core Platform

- 17+ productivity micro-tools
- Cross-tool data sharing system
- Neo-Playground UI design system
- Responsive mobile-first interface
- Real-time processing capabilities

#### Tools Suite

- **Text Tools**: Case conversion, formatting, validation
- **File Merger**: Combine multiple files with options
- **Image Resizer**: Batch image processing and optimization
- **JSON Doctor**: Format, validate, and repair JSON
- **QR Generator**: Single and batch QR code creation
- **URL Shortener**: Create and manage short links
- **Codec Lab**: Encode/decode various formats
- **Time Converter**: Timezone and format conversion
- **Regex Tester**: Test regular expressions with examples
- **ID Generator**: UUID and other ID generation
- **Palette Extractor**: Extract colors from images
- **CSV Cleaner**: Clean and format CSV data
- **Password Generator**: Secure password creation
- **JSON Flattener**: Flatten nested JSON structures
- **Unit Converter**: Convert between measurement units
- **Markdown to PDF**: Convert markdown documents
- **Quick Invoice**: Professional invoice generation

### Security

- Firestore security rules with user isolation
- Input validation on all endpoints
- HTTPS enforcement everywhere
- Secrets management via GitHub Secrets
- Regular dependency security scanning

### Infrastructure

- Firebase Hosting for web application
- Cloud Functions for backend logic
- Cloud Firestore for data storage
- Cloud Storage for file uploads
- Stripe for payment processing

---

**Legend:**

- **Added**: New features
- **Changed**: Modifications to existing features
- **Deprecated**: Features marked for removal
- **Removed**: Deleted features
- **Fixed**: Bug fixes
- **Security**: Security improvements
- **Documentation**: Documentation updates
