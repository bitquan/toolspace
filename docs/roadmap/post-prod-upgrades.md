# Post-Production Upgrade Backlog

**Created:** October 6, 2025  
**Purpose:** Capture enhancement ideas for all 17 tools after production launch  
**Status:** Planning only - no issues created yet  
**Next Phase:** OPS-Beta (automated issue generation post-deploy)

---

## 📋 Overview

This document captures 2-3 upgrade ideas per tool to enhance functionality and create monetization opportunities. These will feed the OPS-Beta epic generator after successful production deployment.

**Guidelines:**

- Focus on high-value features that justify Pro/Pro+ plans
- Consider backend processing for heavy operations
- Prioritize user-requested features (from roadmap/discussions)
- Keep scope realistic (1-3 days implementation per feature)

---

## 🔧 Tools Roadmap

### 1. Text Tools ✅ Complete

**Current State:** Client-side text operations (case conversion, trimming, formatting, word count)

**Upgrades:**

1. **Regex Find/Replace (Pro)**

   - Backend processing for large files (>1MB)
   - Batch file processing
   - Save regex patterns library
   - Monetization: Free limited to 100KB files

2. **Advanced Statistics (Pro+)**

   - Readability scores (Flesch-Kincaid, etc.)
   - Sentiment analysis
   - Keyword extraction
   - Language detection
   - Monetization: Free shows basic stats only

3. **Text Translation (Pro+)**
   - Integrate Google Translate API
   - Support 100+ languages
   - Batch translation
   - Translation memory
   - Monetization: Free gets 1,000 characters/day

---

### 2. File Merger ✅ Complete

**Current State:** PDF/image merge with basic ordering

**Upgrades:**

1. **PDF Bookmarks & TOC (Pro)**

   - Auto-generate table of contents
   - Add bookmarks for merged sections
   - Custom bookmark naming
   - Monetization: Free gets flat merge only

2. **OCR Integration (Pro+)**

   - Scan images and extract text
   - Searchable PDF output
   - Support for 50+ languages
   - Monetization: Heavy backend processing

3. **Advanced PDF Editing (Pro+)**
   - Add watermarks
   - Page numbering
   - Header/footer insertion
   - Split pages
   - Compress output
   - Monetization: Each feature counts as heavy op

---

### 3. JSON Doctor ✅ Complete

**Current State:** Validation, formatting, error highlighting, auto-repair

**Upgrades:**

1. **Schema Library (Pro)**

   - Save custom JSON schemas
   - Validate against schemas
   - Auto-suggest fixes
   - Schema marketplace (share/discover)
   - Monetization: Free limited to 3 saved schemas

2. **Remote Fetch & Validation (Pro)**

   - Fetch JSON from URLs
   - Scheduled monitoring
   - API endpoint validation
   - Webhook alerts on schema changes
   - Monetization: Free 3 URLs, Pro 50 URLs

3. **JSON-to-TypeScript/Dart Generator (Pro+)**
   - Generate type definitions
   - Support nested types
   - Custom naming conventions
   - Code formatting options
   - Monetization: Heavy backend processing

---

### 4. Text Diff ✅ Complete

**Current State:** Line-by-line comparison, side-by-side view, inline diff

**Upgrades:**

1. **File Diff (Pro)**

   - Compare local files (not just pasted text)
   - Batch compare multiple file pairs
   - Export diff reports (HTML/PDF)
   - Monetization: Free text-only, Pro files

2. **Directory Diff (Pro+)**

   - Compare entire folders
   - Recursive subdirectory scanning
   - Filter by file type
   - Generate migration scripts
   - Monetization: Heavy backend scanning

3. **Merge Conflict Resolver (Pro+)**
   - Git-style 3-way merge
   - Interactive conflict resolution
   - Preview merged output
   - Save merge history
   - Monetization: Advanced feature

---

### 5. QR Maker ✅ Complete

**Current State:** Single/batch QR generation, multiple formats (URL, WiFi, vCard, etc.)

**Upgrades:**

1. **Branded QR Codes (Pro)**

   - Add logos to center
   - Custom colors and gradients
   - Rounded corners
   - Eye shape customization
   - Monetization: Free gets black/white only

2. **Dynamic QR Codes (Pro+)**

   - Backend-hosted QR codes
   - Update destination URL anytime
   - Click tracking and analytics
   - Expiration dates
   - Password protection
   - Monetization: Requires backend storage

3. **QR Code Scanner (Pro)**
   - Upload image to decode QR
   - Batch decode multiple codes
   - Extract vCard/WiFi data
   - Export decoded data as CSV
   - Monetization: Backend OCR processing

---

### 6. URL Shortener ✅ Complete

**Current State:** Create short URLs, click tracking, list/delete

**Upgrades:**

1. **Custom Slugs (Pro)**

   - Choose your own short code
   - Branded domains (toolspace.app/your-brand/abc)
   - Slug availability check
   - Reserved keywords protection
   - Monetization: Free gets random slugs only

2. **Advanced Analytics (Pro+)**

   - Geographic click distribution (map view)
   - Referrer tracking
   - Device/browser breakdown
   - Time-series graphs
   - Export analytics as CSV/PDF
   - Monetization: Backend analytics processing

3. **Link Management (Pro+)**
   - Organize links in folders
   - Tags and categories
   - Bulk operations (archive, delete)
   - Team sharing (multi-user access)
   - API access for integration
   - Monetization: Premium feature set

---

### 7. Codec Lab ✅ Complete

**Current State:** Base64, Hex, URL encoding/decoding for text and files

**Upgrades:**

1. **Additional Encodings (Pro)**

   - Binary, Octal
   - ROT13, Caesar cipher
   - Morse code
   - ASCII art conversion
   - Monetization: Free gets Base64/Hex only

2. **File Format Conversion (Pro+)**

   - JSON ↔ XML ↔ YAML
   - CSV ↔ JSON
   - Markdown ↔ HTML
   - Batch conversion
   - Monetization: Heavy backend processing

3. **Compression Tools (Pro+)**
   - GZIP, Brotli compression
   - Compare compression ratios
   - Batch file compression
   - Monetization: Backend processing

---

### 8. Time Converter ✅ Complete

**Current State:** Timestamp conversion, format parsing, natural language

**Upgrades:**

1. **Timezone Calculator (Pro)**

   - Meeting time finder (cross-timezone)
   - Recurring event converter
   - Daylight saving aware
   - Export calendar events (.ics)
   - Monetization: Free limited to 3 timezones

2. **Duration Calculator (Pro)**

   - Calculate time between dates
   - Working hours only option
   - Holiday calendar integration
   - Batch calculations
   - Monetization: Advanced calculations

3. **World Clock Dashboard (Pro+)**
   - Live time in multiple cities
   - Custom clock faces
   - Countdown timers
   - Time-based reminders
   - Monetization: Premium feature

---

### 9. Regex Tester ✅ Complete

**Current State:** Live match highlighting, capture groups, pattern testing

**Upgrades:**

1. **Regex Library (Pro)**

   - Save favorite patterns
   - Pattern marketplace (share/discover)
   - Categorized templates (email, phone, URL, etc.)
   - Pattern explanations
   - Monetization: Free 3 saved patterns

2. **Regex Builder (Pro)**

   - Visual regex constructor
   - No coding required
   - Pattern preview
   - Convert to code (JS, Python, Dart, etc.)
   - Monetization: Premium tool

3. **Multi-file Regex Search (Pro+)**
   - Upload files, search with regex
   - Batch find/replace
   - Export results
   - Monetization: Backend file processing

---

### 10. ID Generator ✅ Complete

**Current State:** UUID v4/v7, NanoID, batch support

**Upgrades:**

1. **Custom ID Formats (Pro)**

   - Define custom patterns (ABC-123-XYZ)
   - Sequential IDs with prefix
   - Checksum digit generation
   - Save templates
   - Monetization: Free gets UUID only

2. **Collision Detection (Pro+)**

   - Check ID uniqueness against database
   - Reserve IDs
   - API integration for ID generation
   - Monetization: Backend validation

3. **Barcode Generation (Pro+)**
   - Generate barcodes (EAN-13, Code128, etc.)
   - Batch barcode creation
   - Export as images
   - Monetization: Heavy rendering

---

### 11. Palette Extractor ✅ Complete

**Current State:** K-means clustering, color extraction, hex/RGB output

**Upgrades:**

1. **Color Harmony Generator (Pro)**

   - Complementary colors
   - Triadic, tetradic schemes
   - Analogous colors
   - Export as CSS/Sass variables
   - Monetization: Advanced algorithms

2. **Brand Kit Builder (Pro+)**

   - Upload logo, extract brand colors
   - Generate full color palette
   - Accessibility checker (WCAG compliance)
   - Export style guide (PDF)
   - Monetization: Backend processing + PDF generation

3. **Gradient Generator (Pro+)**
   - Create gradients from palette
   - Multiple gradient types (linear, radial, conic)
   - CSS/Swift/Kotlin code export
   - Preview on mockups
   - Monetization: Premium feature

---

### 12. Markdown to PDF ✅ Complete

**Current State:** Basic markdown → PDF with live preview

**Upgrades:**

1. **Advanced Markdown Features (Pro)**

   - Tables support
   - Syntax highlighting for code blocks
   - Mermaid diagrams
   - Math equations (LaTeX)
   - Footnotes
   - Monetization: Enhanced rendering

2. **PDF Themes (Pro)**

   - Professional templates
   - Custom fonts
   - Page headers/footers
   - Cover page builder
   - Monetization: Premium templates

3. **Batch Export (Pro+)**
   - Convert multiple MD files
   - Merge into single PDF
   - Auto-generate TOC
   - Cross-reference links
   - Monetization: Heavy backend processing

---

### 13. CSV Cleaner ✅ Complete

**Current State:** Trim, dedupe, normalize

**Upgrades:**

1. **Data Validation (Pro)**

   - Email format validation
   - Phone number formatting
   - Date standardization
   - Remove invalid rows
   - Monetization: Advanced parsing

2. **Column Transformations (Pro)**

   - Split columns (e.g., full name → first + last)
   - Merge columns
   - Apply formulas
   - Find/replace in columns
   - Monetization: Complex operations

3. **CSV to Database (Pro+)**
   - Export to SQL (MySQL, PostgreSQL)
   - Generate CREATE TABLE statements
   - Bulk INSERT generation
   - Schema suggestions
   - Monetization: Backend processing

---

### 14. Image Resizer ✅ Complete

**Current State:** Batch resize, format conversion

**Upgrades:**

1. **Preset Profiles (Pro)**

   - Social media presets (Instagram, Facebook, Twitter)
   - Device presets (iPhone, iPad, Desktop)
   - Custom preset library
   - Monetization: Free 1 preset only

2. **Advanced Filters (Pro)**

   - Brightness/contrast
   - Saturation/hue
   - Blur/sharpen
   - Rotate/flip
   - Crop
   - Monetization: Backend image processing

3. **Image Optimization (Pro+)**
   - Lossless compression
   - WebP/AVIF conversion
   - Responsive image sets
   - Bulk rename
   - Monetization: Heavy backend processing

---

### 15. Password Generator ✅ Complete

**Current State:** Secure passwords, entropy meter, customizable rules

**Upgrades:**

1. **Password Vault (Pro)**

   - Encrypted password storage
   - Auto-fill integration
   - Password strength audit
   - Breach detection (HaveIBeenPwned API)
   - Monetization: Backend encrypted storage

2. **Passphrase Generator (Pro)**

   - XKCD-style passphrases
   - Custom word lists
   - Multi-language support
   - Monetization: Premium feature

3. **Password Policy Manager (Pro+)**
   - Define organizational password policies
   - Compliance checker
   - Password expiration reminders
   - Audit logs
   - Monetization: Enterprise feature

---

### 16. JSON Flatten ✅ Complete

**Current State:** Nested JSON → CSV with field selection

**Upgrades:**

1. **Unflatten Operation (Pro)**

   - CSV → nested JSON (reverse operation)
   - Infer structure from flat data
   - Custom delimiter support
   - Monetization: Complex parsing

2. **Schema Mapping (Pro)**

   - Map JSON fields to custom names
   - Apply transformations
   - Save mappings as templates
   - Monetization: Advanced feature

3. **Database Export (Pro+)**
   - Generate SQL INSERT statements
   - MongoDB import format
   - Firestore batch operations
   - Elasticsearch bulk API
   - Monetization: Backend processing

---

### 17. Unit Converter ✅ Complete

**Current State:** 8 categories (length, weight, temp, volume, area, speed, time, data)

**Upgrades:**

1. **Additional Categories (Pro)**

   - Currency conversion (live rates)
   - Energy
   - Pressure
   - Frequency
   - Fuel economy
   - Monetization: Free 8 categories only

2. **Custom Units (Pro)**

   - Define custom conversion factors
   - Save frequently used conversions
   - Batch conversion
   - Export conversion tables
   - Monetization: Premium feature

3. **Conversion Calculator (Pro+)**
   - Formula-based conversions
   - Multiple units in one expression
   - Conversion history
   - API access
   - Monetization: Advanced calculations

---

### 18. Quick Invoice 🚧 Not Yet Implemented

**Current State:** Placeholder screen only

**Complete Implementation (Phase 1):**

1. **Core Invoice System (Free)**

   - Create invoices with line items
   - Add company logo
   - Customer details
   - Due dates, payment terms
   - Generate PDF
   - Monetization: Free 3 invoices/month

2. **Advanced Features (Pro)**

   - Recurring invoices
   - Invoice templates
   - Tax calculations
   - Multi-currency support
   - Email delivery
   - Monetization: Unlimited invoices

3. **Business Suite (Pro+)**
   - Customer management
   - Payment tracking
   - Expense tracking
   - Financial reports
   - Stripe payment links
   - Monetization: Full business platform

---

## 📊 Monetization Summary

### Feature Distribution

**Free-only Enhancements:** 0  
**Pro Features:** 34  
**Pro+ Features:** 23  
**Total New Features:** 57

### Priority Matrix

| Priority      | Count | Description                                         |
| ------------- | ----- | --------------------------------------------------- |
| P0 (Critical) | 5     | Must-have for production (Quick Invoice core, etc.) |
| P1 (High)     | 18    | Strong user demand, clear monetization              |
| P2 (Medium)   | 22    | Nice-to-have, incremental value                     |
| P3 (Low)      | 12    | Long-term vision, experimental                      |

### Estimated Implementation Time

- **P0 features:** 5 features × 3 days = 15 days
- **P1 features:** 18 features × 2 days = 36 days
- **P2 features:** 22 features × 1 day = 22 days
- **P3 features:** 12 features × 1 day = 12 days

**Total:** 85 days (17 weeks / ~4 months for all enhancements)

---

## 🎯 Next Steps (Post-Production)

1. **Deploy Toolspace v1** to production
2. **Gather user feedback** (first 2 weeks)
3. **Prioritize features** based on:
   - User requests
   - Revenue potential
   - Implementation complexity
4. **Run OPS-Beta generator** to create issues from this doc
5. **Implement in sprints** (2-week cycles)

---

## 📝 Notes

- This document is a living roadmap and will be updated based on user feedback
- All features should be scoped to 1-3 days max (for rapid iteration)
- Backend-heavy features should be built with Cloud Functions (serverless)
- Consider API access for Pro+ users (future monetization)
- Each feature should have clear acceptance criteria before implementation

---

**Document Owner:** Product / Engineering  
**Review Cycle:** Monthly  
**Last Reviewed:** October 6, 2025  
**Next Review:** After production launch + 2 weeks
