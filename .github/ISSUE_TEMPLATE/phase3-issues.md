# Phase-3 Trio Implementation Issues

This file contains the 11 issues for Phase-3 implementation.
Each issue will be created via GitHub CLI with proper labels and structure.

## Issue Template Structure

- **Type**: feature
- **Area**: frontend, backend, or tools
- **Labels**: tools, ready (for auto-branching)
- **Milestone**: Phase-3 Trio

---

## 1. Invoice Lite - Service Layer

**Title**: Implement Invoice Lite Service Layer with Business Logic

**Labels**: `feature`, `tools`, `area:frontend`, `ready`

**Description**:
Implement the core service layer for Invoice Lite including invoice creation, calculation logic, PDF generation requests, and pay link creation.

**Acceptance Criteria**:
- [ ] Create `lib/tools/invoice_lite/invoice_lite_service.dart`
- [ ] Implement `createInvoice()` - generate new invoice with unique ID
- [ ] Implement `updateInvoice()` - update existing invoice
- [ ] Implement `saveBusinessInfo()` - persist business details to Firestore
- [ ] Implement `loadBusinessInfo()` - retrieve last-used business info
- [ ] Implement `calculateTotals()` - compute subtotal, tax, discount, total
- [ ] Implement `validateInvoice()` - check required fields, amounts
- [ ] Implement `getInvoicePdfUrl()` - call backend function (mock for now)
- [ ] Implement `createPayLink()` - call Stripe checkout creation (mock for now)
- [ ] Add error handling with proper exceptions
- [ ] Store invoices under `users/{uid}/invoices/{invoiceId}` in Firestore

**Tests Required**:
- [ ] Unit test: `calculateTotals()` with various tax/discount scenarios
- [ ] Unit test: Edge cases (negative amounts, zero items, rounding)
- [ ] Unit test: `validateInvoice()` catches missing required fields
- [ ] Unit test: Business info persistence round-trip

**Files to Create**:
```
lib/tools/invoice_lite/
├── invoice_lite_service.dart
test/tools/invoice_lite/
├── invoice_lite_service_test.dart
```

**Documentation**:
- [ ] Add `docs/tools/invoice-lite.md` with API usage examples
- [ ] Document calculation formulas and rounding behavior

**Dependencies**:
- Requires `lib/tools/invoice_lite/models.dart` (already created)
- Uses `cloud_firestore` for persistence
- Uses `firebase_auth` for user scoping

---

## 2. Invoice Lite - Screen UI

**Title**: Build Invoice Lite Screen with Reactive Form and Paywalls

**Labels**: `feature`, `tools`, `area:frontend`, `ready`

**Description**:
Create the complete Invoice Lite user interface with form inputs, dynamic item rows, totals panel, and action buttons with proper billing gates.

**Acceptance Criteria**:
- [ ] Create `lib/tools/invoice_lite/invoice_lite_screen.dart`
- [ ] Business info section: name, email, address, phone (auto-fill from last saved)
- [ ] Client info section: name, email, address
- [ ] Invoice details: invoice number (auto-generated), dates (invoice/due), currency selector
- [ ] Dynamic items list with add/remove rows
- [ ] Each item row: description, quantity, unit price, subtotal (computed), notes (optional)
- [ ] Tax rate input (percentage) with live calculation
- [ ] Discount amount input with live calculation
- [ ] Totals panel: subtotal, tax amount, discount, **grand total** (prominent display)
- [ ] "Generate PDF" button with `PaywallGuard` (Pro required)
- [ ] "Create Pay Link" button with `PaywallGuard` (Pro required)
- [ ] "Send to..." dropdown menu (JSON Doctor, QR Maker, Markdown→PDF)
- [ ] `QuotaBanner` in header showing remaining heavy ops
- [ ] `BillingButton` in app bar
- [ ] Form validation with error messages
- [ ] Loading states for async operations
- [ ] Success/error snackbars with clear messaging

**Widget Tests Required**:
- [ ] Form renders all sections correctly
- [ ] Add/remove item rows updates UI
- [ ] Totals recalculate on input changes
- [ ] PaywallGuard blocks free users from PDF/PayLink
- [ ] Validation shows errors for required fields

**Files to Create**:
```
lib/tools/invoice_lite/
├── invoice_lite_screen.dart
├── widgets/
│   ├── business_info_section.dart
│   ├── client_info_section.dart
│   ├── invoice_items_list.dart
│   ├── invoice_totals_panel.dart
test/tools/invoice_lite/
├── invoice_lite_screen_test.dart
```

**UI/UX Requirements**:
- Use Neo-Playground theme (glass cards, gradient chips)
- Responsive layout (mobile/tablet/desktop)
- Keyboard shortcuts: Cmd/Ctrl+Enter → Generate PDF
- Add subtle confetti animation on "PDF Generated!" success

**Dependencies**:
- `lib/tools/invoice_lite/invoice_lite_service.dart`
- `lib/billing/widgets/paywall_guard.dart`
- `lib/billing/widgets/quota_banner.dart`
- `lib/shared/cross_tool/share_bus.dart`

---

## 3. Invoice Lite - Backend Functions

**Title**: Implement Invoice PDF Generation and Pay Link Backend Functions

**Labels**: `feature`, `tools`, `area:backend`, `ready`

**Description**:
Create Cloud Functions for generating invoice PDFs and creating Stripe payment links with proper auth, validation, and plan gates.

**Acceptance Criteria**:
- [ ] Create `functions/src/invoice/generateInvoicePdf.ts`
- [ ] Create `functions/src/invoice/createInvoicePayLink.ts`
- [ ] Create `functions/src/invoice/index.ts` with exports
- [ ] **generateInvoicePdf**:
  - [ ] Enforce authentication with `withAuth` middleware
  - [ ] Validate user has Pro plan
  - [ ] Accept `InvoiceLite` JSON payload
  - [ ] Render PDF using `pdfkit` or `pdfmake`
  - [ ] Include logo placeholder, business/client info, items table, totals
  - [ ] Upload to `users/{uid}/invoices/{id}/invoice.pdf` in Storage
  - [ ] Return signed URL (1 hour expiry)
  - [ ] Track heavy op usage
- [ ] **createInvoicePayLink**:
  - [ ] Enforce authentication
  - [ ] Validate user has Pro plan
  - [ ] Accept amount, currency, metadata (invoiceId, clientEmail)
  - [ ] Create Stripe Checkout Session in test mode
  - [ ] Return checkout URL
  - [ ] Store payment session ID with invoice
- [ ] Add request validation schemas
- [ ] Add proper error handling (400/403/500)
- [ ] Add logging for debugging

**Tests Required**:
- [ ] Unit test: Auth required (401 for anon)
- [ ] Unit test: Free plan rejected (403)
- [ ] Unit test: Pro plan success path
- [ ] Unit test: PDF rendering produces valid PDF buffer
- [ ] Unit test: Stripe session created with correct metadata
- [ ] Unit test: Signed URL has correct expiry
- [ ] Integration test: End-to-end PDF generation flow

**Files to Create**:
```
functions/src/invoice/
├── generateInvoicePdf.ts
├── createInvoicePayLink.ts
├── index.ts
├── types.ts
functions/test/invoice/
├── generateInvoicePdf.test.ts
├── createInvoicePayLink.test.ts
```

**Dependencies**:
- `pdfkit` or `pdfmake` for PDF rendering
- `@google-cloud/storage` for file uploads
- `stripe` SDK for payment links
- `functions/src/middleware/withAuth.ts`

---

## 4. Invoice Lite - Cross-Tool Integration

**Title**: Wire Invoice Lite Cross-Tool Data Sharing and Handoffs

**Labels**: `feature`, `tools`, `area:frontend`, `ready`

**Description**:
Implement cross-tool import/export for Invoice Lite supporting JSON data import, PDF export, and Pay Link sharing to other tools.

**Acceptance Criteria**:
- [ ] **Import Support**:
  - [ ] Accept `ShareEnvelope(kind: json)` with invoice data
  - [ ] Accept `ShareEnvelope(kind: text)` for plain text parsing (client name, items)
  - [ ] Show toast: "Imported from {source} · Undo"
  - [ ] Prefill form fields with imported data
  - [ ] Handle incomplete/invalid data gracefully
- [ ] **Export Support**:
  - [ ] "Send to JSON Doctor" → publish `ShareEnvelope(kind: json, value: invoiceJson)`
  - [ ] "Send to QR Maker" → publish `ShareEnvelope(kind: text, value: payLinkUrl)`
  - [ ] "Send to Markdown→PDF" → publish `ShareEnvelope(kind: markdown, value: invoiceMarkdown)`
  - [ ] After PDF generation → publish `ShareEnvelope(kind: fileUrl, value: pdfSignedUrl)`
- [ ] Add "Send to..." dropdown in screen with icon menu
- [ ] Use `ShareBus.instance.publish()` for all exports
- [ ] Listen to `ShareBus` on screen init for incoming data
- [ ] Add undo functionality for imports (restore previous state)

**Tests Required**:
- [ ] Unit test: Parse JSON invoice and prefill form
- [ ] Unit test: Export invoice as JSON matches schema
- [ ] Unit test: Generate markdown representation
- [ ] Widget test: Import from ShareBus updates UI
- [ ] Integration test: Invoice Lite → JSON Doctor → Invoice Lite round-trip

**Files to Modify**:
```
lib/tools/invoice_lite/invoice_lite_screen.dart
  - Add ShareBus listener in initState
  - Add export menu actions
lib/tools/json_doctor/json_doctor_screen.dart
  - Add "Send to Invoice Lite" option
lib/tools/qr_maker/qr_maker_screen.dart
  - Accept fileUrl and text envelopes
```

**Dependencies**:
- `lib/shared/cross_tool/share_bus.dart`
- `lib/shared/cross_tool/share_envelope.dart`
- `lib/shared/cross_tool/share_intent.dart`

---

## 5. Audio Converter - Full Tool Implementation

**Title**: Implement Audio Converter Tool with Format Conversion and Batch Support

**Labels**: `feature`, `tools`, `area:frontend`, `area:backend`, `ready`

**Description**:
Build complete audio conversion tool supporting multiple formats (mp3, wav, ogg, m4a) with client-side and server-side processing.

**Acceptance Criteria**:

**Frontend**:
- [ ] Create `lib/tools/audio_converter/audio_converter_screen.dart`
- [ ] File upload: drag/drop zone + file picker
- [ ] Show file list with: name, size, format, status
- [ ] Per-file settings:
  - [ ] Output format selector (mp3, wav, ogg, m4a)
  - [ ] Bitrate selector (128k, 192k, 256k, 320k)
  - [ ] Trim controls (start/end time)
  - [ ] Normalize audio toggle
- [ ] "Convert" button (single file on Free, batch on Pro)
- [ ] Progress bars: per-file and overall
- [ ] Download converted files (individual or zip for batch)
- [ ] "Send to File Compressor" cross-tool action
- [ ] `PaywallGuard` for batch and >10MB files
- [ ] `QuotaBanner` in header

**Backend**:
- [ ] Create `functions/src/media/convertAudio.ts`
- [ ] Accept file Storage paths or upload URLs
- [ ] Use `ffmpeg-static` or `fluent-ffmpeg` for conversions
- [ ] Support format conversion, bitrate adjustment, trimming, normalization
- [ ] Write output to `users/{uid}/converted/{id}/output.{ext}`
- [ ] Return signed URLs for downloads
- [ ] Enforce auth, plan checks, size limits (50MB Pro, 10MB Free)
- [ ] Track heavy ops

**Tests**:
- [ ] Widget test: File list renders correctly
- [ ] Widget test: PaywallGuard blocks batch for Free users
- [ ] Unit test: Backend converts mp3→wav successfully
- [ ] Unit test: Size limits enforced

**Files to Create**:
```
lib/tools/audio_converter/
├── audio_converter_screen.dart
├── audio_converter_service.dart
├── models.dart
functions/src/media/
├── convertAudio.ts
├── index.ts
test/tools/audio_converter/
├── audio_converter_test.dart
functions/test/media/
├── convertAudio.test.ts
```

**Documentation**:
- [ ] Add `docs/tools/audio-converter.md`
- [ ] Document supported formats and quality settings

---

## 6. File Compressor - Full Tool Implementation

**Title**: Implement File Compressor Tool with Image/Doc Compression Profiles

**Labels**: `feature`, `tools`, `area:frontend`, `area:backend`, `ready`

**Description**:
Build file compression tool supporting images (quality/resize), documents (zip), with batch processing and cross-tool ingest.

**Acceptance Criteria**:

**Frontend**:
- [ ] Create `lib/tools/file_compressor/file_compressor_screen.dart`
- [ ] Drag/drop multi-file upload
- [ ] Compression profiles:
  - [ ] **Images**: quality slider (0-100), max dimension (px), format (jpg/png/webp)
  - [ ] **Documents**: zip compression level (fastest/balanced/smallest)
  - [ ] **Misc**: tar/zip toggles
- [ ] File list with preview thumbnails
- [ ] "Compress" button with progress indicator
- [ ] Download result (single file or zip archive)
- [ ] Cross-tool ingest: accept `ShareEnvelope(kind: fileUrl)` or text list of URLs
- [ ] `PaywallGuard` for batch (>5 files) and >10MB total size
- [ ] `QuotaBanner` in header

**Backend**:
- [ ] Create `functions/src/files/compressFiles.ts`
- [ ] Accept list of `gs://` Storage paths
- [ ] For images: use Sharp or ImageMagick for compression/resize
- [ ] For documents: create zip with compression level
- [ ] Write output to `users/{uid}/compressed/{id}.zip`
- [ ] Return signed URL
- [ ] Enforce auth, plan checks, size limits
- [ ] Track heavy ops

**Tests**:
- [ ] Widget test: Profile selection updates UI
- [ ] Widget test: Cross-tool ingest prefills file list
- [ ] Unit test: Image compression reduces file size
- [ ] Unit test: Zip creation includes all files

**Files to Create**:
```
lib/tools/file_compressor/
├── file_compressor_screen.dart
├── file_compressor_service.dart
├── models.dart
functions/src/files/
├── compressFiles.ts
├── index.ts
test/tools/file_compressor/
├── file_compressor_test.dart
functions/test/files/
├── compressFiles.test.ts
```

**Documentation**:
- [ ] Add `docs/tools/file-compressor.md`
- [ ] Document compression profiles and limits

---

## 7. Routes and Home Grid Integration

**Title**: Register New Tools in Routes and Add to Home Grid

**Labels**: `feature`, `tools`, `area:frontend`, `ready`

**Description**:
Add route definitions for the three new tools and integrate them into the home screen grid with "New" badges.

**Acceptance Criteria**:
- [ ] Add routes to `lib/core/routes.dart`:
  - [ ] `/tools/invoice-lite` → `InvoiceLiteScreen`
  - [ ] `/tools/audio-converter` → `AudioConverterScreen`
  - [ ] `/tools/file-compressor` → `FileCompressorScreen`
- [ ] Update `lib/screens/home_screen.dart` or grid component:
  - [ ] Add `ToolCard` for Invoice Lite (icon: receipt, color: gradient green)
  - [ ] Add `ToolCard` for Audio Converter (icon: audiotrack, color: gradient purple)
  - [ ] Add `ToolCard` for File Compressor (icon: compress, color: gradient orange)
  - [ ] Add "New" pill badge to all three cards
- [ ] Update existing tools with "Send to..." menus:
  - [ ] Text Tools → add "Send to Invoice Lite"
  - [ ] JSON Doctor → add "Send to Invoice Lite"
  - [ ] QR Maker → accept file URLs and pay links
- [ ] Ensure deep links work: `/tools/invoice-lite?intent={base64}`

**Tests**:
- [ ] Widget test: New tool cards render on home screen
- [ ] Widget test: Navigation to each new tool works
- [ ] Integration test: Deep link with intent parameter loads correctly

**Files to Modify**:
```
lib/core/routes.dart
lib/screens/home_screen.dart (or lib/screens/neo_home_screen.dart)
lib/tools/text_tools/text_tools_screen.dart
lib/tools/json_doctor/json_doctor_screen.dart
lib/tools/qr_maker/qr_maker_screen.dart
```

---

## 8. Billing Configuration Update

**Title**: Update Pricing Config and Billing Service for New Tool Capabilities

**Labels**: `feature`, `billing`, `area:frontend`, `ready`

**Description**:
Extend billing configuration to include new heavy operations for Invoice Lite, Audio Converter, and File Compressor.

**Acceptance Criteria**:
- [ ] Update `config/pricing.json`:
  - [ ] Add `invoice_lite.pdf` to `heavyTools` list (marked as `heavy`)
  - [ ] Add `invoice_lite.paylink` to `heavyTools` list
  - [ ] Add `audio_converter.convert` with `batch: true` flag
  - [ ] Add `file_compressor.compress` with `batch: true` flag
  - [ ] Ensure Free plan: 3 heavy ops/day, 10MB max
  - [ ] Ensure Pro plan: 100 heavy ops/day, 50MB max
  - [ ] Ensure Pro+ plan: unlimited heavy ops, 500MB max
- [ ] Update `lib/billing/billing_service.dart`:
  - [ ] Add `canAccessTool(String toolId)` method
  - [ ] Add `canPerformHeavyOp(String opId)` method
  - [ ] Add `trackHeavyOp(String opId)` to increment daily usage
  - [ ] Add `getRemainingHeavyOps()` to show quota
  - [ ] Ensure quota resets daily (use Firestore timestamps)
- [ ] Add `QuotaBanner` widget to all new tool screens

**Tests**:
- [ ] Unit test: `canPerformHeavyOp()` respects plan limits
- [ ] Unit test: `trackHeavyOp()` increments usage counter
- [ ] Unit test: Quota resets after 24 hours
- [ ] Unit test: Free user blocked from batch operations

**Files to Modify**:
```
config/pricing.json
lib/billing/billing_service.dart
lib/billing/billing_types.dart (if needed)
test/billing/billing_service_test.dart
```

---

## 9. Cross-Tool Wiring Verification

**Title**: Verify End-to-End Cross-Tool Data Flows

**Labels**: `feature`, `tools`, `area:testing`, `ready`

**Description**:
Create integration tests to verify cross-tool data sharing works correctly across all tool combinations.

**Acceptance Criteria**:
- [ ] Test: Text Tools → JSON Doctor (text → json)
- [ ] Test: JSON Doctor → Invoice Lite (json → form prefill)
- [ ] Test: Invoice Lite → QR Maker (pay link → qr generation)
- [ ] Test: Invoice Lite → Markdown→PDF (invoice data → pdf)
- [ ] Test: Audio Converter → File Compressor (audio files → compression)
- [ ] Test: File Compressor → QR Maker (download link → qr)
- [ ] Verify `ShareBus.instance` publishes and consumes correctly
- [ ] Verify `ShareEnvelope` TTL expiry (5 minutes)
- [ ] Verify `HandoffStore` persistence across sessions
- [ ] Verify toast notifications show correct source tool
- [ ] Verify undo functionality restores previous state

**Tests**:
- [ ] Integration test suite in `test/integration/cross_tool_test.dart`
- [ ] Each test: publish envelope → navigate → verify prefill → verify undo
- [ ] Test expired envelopes are not consumed
- [ ] Test multiple tools sharing simultaneously

**Files to Create**:
```
test/integration/
├── cross_tool_test.dart
├── test_helpers/
│   ├── share_bus_mock.dart
│   ├── envelope_factory.dart
```

---

## 10. Tests and CI Validation

**Title**: Add Comprehensive Tests and Ensure CI Passes

**Labels**: `feature`, `area:testing`, `ready`

**Description**:
Create unit tests, widget tests, and function tests for all new tools. Ensure CI pipeline passes with zero errors/warnings.

**Acceptance Criteria**:

**Dart Tests**:
- [ ] Invoice Lite:
  - [ ] Unit: totals calculation (subtotal, tax, discount, rounding)
  - [ ] Unit: validation logic
  - [ ] Widget: form rendering and interaction
  - [ ] Widget: paywall blocks free users
- [ ] Audio Converter:
  - [ ] Unit: file size validation
  - [ ] Widget: batch operations gated
- [ ] File Compressor:
  - [ ] Unit: compression profile logic
  - [ ] Widget: cross-tool ingest
- [ ] Cross-Tool:
  - [ ] Unit: ShareIntent URL encoding/decoding
  - [ ] Unit: ShareBus TTL cleanup
  - [ ] Unit: HandoffStore Firestore operations

**Functions Tests**:
- [ ] `generateInvoicePdf`: auth, plan check, PDF generation, signed URL
- [ ] `createInvoicePayLink`: auth, plan check, Stripe session creation
- [ ] `convertAudio`: auth, size limits, format conversion
- [ ] `compressFiles`: auth, batch limits, compression

**CI Validation**:
- [ ] Run `flutter test --coverage`
- [ ] Run `cd functions && npm test`
- [ ] Run `scripts/preflight.mjs` locally
- [ ] Ensure PR CI workflow passes (all checks green)
- [ ] Ensure Security Gates workflow passes
- [ ] Ensure UI Smoke tests pass

**Coverage Requirements**:
- [ ] >80% line coverage for services
- [ ] >70% line coverage for screens
- [ ] 100% coverage for billing logic

**Files to Create**:
```
test/tools/invoice_lite/
├── invoice_lite_service_test.dart
├── invoice_lite_screen_test.dart
├── models_test.dart
test/tools/audio_converter/
├── audio_converter_test.dart
test/tools/file_compressor/
├── file_compressor_test.dart
test/shared/cross_tool/
├── share_envelope_test.dart
├── share_bus_test.dart
├── share_intent_test.dart
├── handoff_store_test.dart
functions/test/invoice/
├── generateInvoicePdf.test.ts
├── createInvoicePayLink.test.ts
functions/test/media/
├── convertAudio.test.ts
functions/test/files/
├── compressFiles.test.ts
```

---

## 11. Documentation and Dev-Log Update

**Title**: Create Documentation and Dev-Log Entries for Phase-3 Tools

**Labels**: `documentation`, `tools`, `ready`

**Description**:
Write comprehensive documentation for all three new tools and update dev-logs with implementation details and screenshots.

**Acceptance Criteria**:

**Tool Documentation**:
- [ ] Create `docs/tools/invoice-lite.md`:
  - [ ] Feature overview
  - [ ] Usage guide (business/client setup, items, PDF generation, pay links)
  - [ ] Cross-tool examples (export to JSON Doctor, QR Maker)
  - [ ] API reference for `invoice_lite_service.dart`
  - [ ] Billing and quota information
  - [ ] Troubleshooting section
- [ ] Create `docs/tools/audio-converter.md`:
  - [ ] Supported formats and codecs
  - [ ] Quality settings and bitrates
  - [ ] Batch processing limits
  - [ ] Cross-tool integration examples
- [ ] Create `docs/tools/file-compressor.md`:
  - [ ] Compression profiles (images, docs, misc)
  - [ ] Quality vs. size tradeoffs
  - [ ] Batch limits and plan gates

**Roadmap Update**:
- [ ] Update `docs/roadmap/phase-3.md`:
  - [ ] Mark acceptance criteria as completed
  - [ ] Add implementation notes
  - [ ] Add screenshots (desktop/mobile)
  - [ ] Add performance metrics (if applicable)

**Dev-Log**:
- [ ] Create `dev-log/features/phase-3-trio-2025-10-09.md`:
  - [ ] Implementation summary
  - [ ] Technical decisions (why pdfkit, why ffmpeg, etc.)
  - [ ] Challenges and solutions
  - [ ] Cross-tool architecture diagram
  - [ ] Screenshots with annotations
  - [ ] Performance considerations
  - [ ] Future enhancements

**Main Docs Update**:
- [ ] Update `DOCUMENTATION_SUMMARY.md`:
  - [ ] Add links to new tool docs
  - [ ] Update feature list
  - [ ] Update cross-tool section

**README Update**:
- [ ] Update `README.md`:
  - [ ] Add Invoice Lite, Audio Converter, File Compressor to tool list
  - [ ] Update tool count (was 17, now 20)
  - [ ] Add "New in Phase-3" section with highlights

**Files to Create/Modify**:
```
docs/tools/
├── invoice-lite.md (new)
├── audio-converter.md (new)
├── file-compressor.md (new)
docs/roadmap/
├── phase-3.md (update)
dev-log/features/
├── phase-3-trio-2025-10-09.md (new)
DOCUMENTATION_SUMMARY.md (update)
README.md (update)
```

**Screenshots Needed**:
- [ ] Invoice Lite: empty form, filled form, PDF preview
- [ ] Audio Converter: file list, conversion in progress, success
- [ ] File Compressor: drag/drop, compression profiles, result
- [ ] Cross-tool flow: Text Tools → JSON Doctor → Invoice Lite → QR Maker

---

