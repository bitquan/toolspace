# E2E Local Checklist - Cross-Tool Data Flows

This checklist verifies that cross-tool data sharing works correctly in local development environment.

## Prerequisites

- [ ] Flutter app running in Chrome (`flutter run -d chrome`)
- [ ] Firebase emulators active (Auth, Firestore, Functions)
- [ ] User authenticated (any email/password in Auth emulator)

## Access E2E Playground

1. Navigate to `/dev/e2e-playground` in browser
2. Should see orange warning banner "Development Only"
3. Should see test buttons and ShareBus status

## Automated Test Flows

### 1. JSON → Text Tools Flow

- [ ] Click "JSON → Text Tools" button
- [ ] Check test log shows: "✅ Published JSON envelope to ShareBus"
- [ ] Check test log shows: "✅ JSON envelope available in ShareBus"
- [ ] ShareBus status should show 1 envelope of type `json`
- [ ] Navigate to Text Tools (`/tools/text_tools`)
- [ ] Click Import button - should see the JSON data available
- [ ] Import the data - should populate input field with JSON

### 2. Text → JSON Doctor Flow

- [ ] Click "Text → JSON Doctor" button
- [ ] Check test log shows successful text envelope publication
- [ ] Navigate to JSON Doctor (`/tools/json_doctor`)
- [ ] Click Import button - should see the text data available
- [ ] Import the text - should populate input field and validate JSON

### 3. JSON → QR Maker Flow

- [ ] Click "JSON → QR Maker" button
- [ ] Check test log shows payment link publication
- [ ] Navigate to QR Maker (`/tools/qr_maker`)
- [ ] Click Import button - should see the payment URL available
- [ ] Import the URL - should populate QR code generation field

### 4. File → Compressor Flow

- [ ] Click "File → Compressor" button
- [ ] Check test log shows file URL publication
- [ ] Navigate to File Compressor (`/tools/file_compressor`)
- [ ] Click Import button - should see the file URL available
- [ ] Import should trigger file download/processing setup

## Manual Data Seeding

### 1. Seed JSON Data

- [ ] Click "Seed JSON Data" button
- [ ] ShareBus status should show invoice JSON envelope
- [ ] Navigate to any tool that accepts JSON (JSON Doctor, Invoice Lite)
- [ ] Should be able to import the seeded invoice data

### 2. Seed Text Data

- [ ] Click "Seed Text Data" button
- [ ] ShareBus status should show contact text envelope
- [ ] Navigate to Text Tools
- [ ] Should be able to import the contact information

### 3. Seed File URL

- [ ] Click "Seed File URL" button
- [ ] ShareBus status should show file URL envelope
- [ ] Navigate to File Merger or File Compressor
- [ ] Should be able to import the file URL

### 4. Seed CSV Data

- [ ] Click "Seed CSV Data" button
- [ ] ShareBus status should show CSV envelope
- [ ] Navigate to CSV Cleaner
- [ ] Should be able to import the CSV data

## Cross-Tool Navigation with Intents

### 1. Direct Navigation

- [ ] In Text Tools, enter some JSON text
- [ ] Click Share → "Send to JSON Doctor"
- [ ] Should navigate to JSON Doctor with data pre-filled
- [ ] Should show snackbar: "Sent JSON to JSON Doctor"

### 2. Import/Export Workflow

- [ ] In JSON Doctor, format some JSON
- [ ] Click Export → "Export as JSON"
- [ ] Should show snackbar: "Exported JSON to share bus"
- [ ] Navigate to any tool
- [ ] Click Import - should see the JSON available

### 3. Undo Functionality

- [ ] Import some data in any tool
- [ ] Should see snackbar with "Undo" action
- [ ] Click "Undo" - data should be re-published to ShareBus
- [ ] Should be able to import again in another tool

## ShareBus Behavior Verification

### 1. TTL (Time-To-Live) Testing

- [ ] Seed some data
- [ ] Wait and verify envelopes show age (e.g., "15s ago")
- [ ] Click "Test TTL Expiry" - should explain TTL mechanism
- [ ] Note: Full TTL test requires waiting 5 minutes

### 2. Multiple Envelopes

- [ ] Seed multiple different data types
- [ ] ShareBus status should show all envelopes
- [ ] Each should have different icons and timestamps
- [ ] Tools should only see relevant envelope types in import

### 3. Clear ShareBus

- [ ] Click "Clear ShareBus" button
- [ ] ShareBus status should show "No envelopes available"
- [ ] All tools should show no import options

## Error Handling

### 1. Empty ShareBus

- [ ] Clear ShareBus
- [ ] Navigate to any tool
- [ ] Import button should be disabled or show "No data available"

### 2. Expired Envelopes

- [ ] Note: Auto-cleanup happens after 5 minutes
- [ ] Old envelopes should not appear in import options

### 3. Invalid Data

- [ ] Manually publish invalid JSON as text
- [ ] JSON Doctor should handle gracefully (show as text)
- [ ] Should not crash or show errors

## Production Exclusion

### 1. E2E Playground Access

- [ ] E2E Playground should only be accessible in development
- [ ] Should not appear in production builds
- [ ] Routes should be dev-only

## Integration with Existing Tools

### 1. ShareToolbar Presence

- [ ] Navigate to Text Tools - should see Import/Export/Send buttons
- [ ] Navigate to JSON Doctor - should see cross-tool actions
- [ ] All major tools should have ShareToolbar integrated

### 2. PaywallGuard Integration

- [ ] Heavy tools (File Merger, Image Resizer) should show PaywallGuard
- [ ] Should work with cross-tool data flows
- [ ] Should not block Import/Export operations

## Success Criteria

- [ ] All automated tests pass (green checkmarks in logs)
- [ ] All manual flows work as expected
- [ ] No console errors during cross-tool navigation
- [ ] Data persists correctly across tool switches
- [ ] Import/Export operations show appropriate user feedback
- [ ] ShareBus state updates in real-time

## Troubleshooting

### Common Issues

1. **Import button disabled**: Clear ShareBus and seed new data
2. **Data not appearing**: Check ShareBus status for envelope count
3. **Navigation errors**: Verify tool routes are correctly configured
4. **Import fails**: Check data types match tool expectations

### Debug Steps

1. Open browser DevTools console for error messages
2. Check ShareBus status in E2E Playground
3. Verify Firebase emulators are running
4. Check user authentication status

---

**Expected Duration**: 15-20 minutes for complete checklist
**Environment**: Local development with Firebase emulators
**Browser**: Chrome (recommended for Flutter web development)

**Last Updated**: October 9, 2025
