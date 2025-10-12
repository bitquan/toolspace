# 🧪 Toolspace Smoke Test Plan - Phase 3

## Overview

Comprehensive end-to-end testing of all tools using deterministic inputs and expected outputs.

## Test Environment

- **Frontend**: Flutter web (local)
- **Backend**: Firebase Functions (local emulators + production checks)
- **Billing**: Stripe test keys only
- **Date**: October 11, 2025

## Test Matrix

| Tool ID            | Tool Name               | Plan Required | Input                     | Expected Output          | Status | Notes                         |
| ------------------ | ----------------------- | ------------- | ------------------------- | ------------------------ | ------ | ----------------------------- |
| file_merger        | File Merger             | Pro           | 2 PDFs + 1 image          | Merged PDF (3 pages)     | ⏳     | Priority - fix internal error |
| json_doctor        | JSON Doctor             | Free          | valid.json + invalid.json | validation results       | ⏳     |                               |
| text_diff          | Text Diff               | Free          | "alpha" vs "alpha beta"   | 1 insertion detected     | ⏳     |                               |
| qr_maker           | QR Code Generator       | Free          | "https://example.com"     | QR code PNG              | ⏳     |                               |
| url_shortener      | URL Shortener           | Free          | https://example.com       | Shortened URL + redirect | ⏳     |                               |
| codec_lab          | Codec Lab               | Free          | Base64 encode "hello"     | "aGVsbG8="               | ⏳     |                               |
| time_converter     | Time Converter          | Free          | UTC to PST                | Correct time zone        | ⏳     |                               |
| regex_tester       | Regex Tester            | Free          | /\d+/ on "abc123"         | Match at index 3         | ⏳     |                               |
| id_generator       | ID Generator            | Free          | UUID v4                   | Valid UUID format        | ⏳     |                               |
| palette_extractor  | Color Palette Extractor | Free          | sample image              | 10 colors extracted      | ⏳     |                               |
| md_to_pdf          | Markdown to PDF         | Pro           | sample.md                 | PDF output               | ⏳     |                               |
| csv_cleaner        | CSV Cleaner             | Free          | CSV with duplicates       | Deduplicated CSV         | ⏳     |                               |
| image_resizer      | Image Resizer           | Pro           | 1000x1000 → 320x240       | Resized image            | ⏳     |                               |
| password_generator | Password Generator      | Free          | 16 chars + symbols        | Meets criteria           | ⏳     |                               |
| json_flatten       | JSON Flatten            | Free          | Nested JSON               | Flattened keys           | ⏳     |                               |
| unit_converter     | Unit Converter          | Free          | 1 mile to km              | 1.609344 km              | ⏳     |                               |
| audio_converter    | Audio Converter         | Pro           | MP3 to WAV                | Converted audio          | ⏳     |                               |
| file_compressor    | File Compressor         | Pro           | Multiple files            | ZIP archive              | ⏳     |                               |

## Test Scenarios

### Billing Flow Tests

1. **Free User → Pro Tool Access**

   - Expected: Paywall/upgrade prompt
   - Tool: File Merger

2. **Pro User → Pro Tool Access**

   - Expected: Tool functions normally
   - Tool: File Merger

3. **Stripe Webhook → Firestore Sync**
   - Expected: `planId: 'pro'` in user billing profile

### File Merger Priority Scenarios

1. **PDF + PDF Merge**

   - Input: `a.pdf` + `b.pdf`
   - Expected: 2-page merged PDF

2. **Image + PDF Merge**

   - Input: `a.jpg` + `b.pdf`
   - Expected: 2-page merged PDF (image converted to PDF page)

3. **Multiple Images Merge**
   - Input: `a.jpg` + `b.png`
   - Expected: 2-page PDF with images

## Success Criteria

- [ ] All Free tools: ✅ (accessible without upgrade)
- [ ] All Pro tools: Show paywall for Free users, work for Pro users
- [ ] File Merger: No `[firebase_functions/internal]` errors
- [ ] Stripe webhook: Proper Firestore sync
- [ ] Unit tests: Pass for critical functions

## Fixtures Required

- `fixtures/pdf/a.pdf` - Small test PDF (2 pages)
- `fixtures/pdf/b.pdf` - Small test PDF (1 page)
- `fixtures/img/a.jpg` - Test image (500x500)
- `fixtures/img/b.png` - Test image (300x300)
- `fixtures/json/valid.json` - Valid JSON object
- `fixtures/json/invalid.json` - Malformed JSON
- `fixtures/csv/sample.csv` - CSV with duplicates
- `fixtures/md/sample.md` - Markdown content

## Logging Strategy

- Functions: Verbose logging in File Merger pipeline
- Frontend: Console logs for tool interactions
- Errors: Structured error responses instead of generic "internal"

## Next Steps After Smoke Tests

1. Fix all ❌ items
2. Local deployment with test keys
3. Production deployment planning
