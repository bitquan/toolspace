# Text Tools - Limits & Quotas Documentation

**Last Updated:** October 11, 2025  
**Version:** 2.3.0  
**Owner:** Text Tools Team

## 1. Overview

Text Tools operates entirely client-side and has no server-side quotas or billing restrictions. All limitations are browser-based for performance and user experience optimization.

**Key Principle:** Text Tools is completely free for all users with only technical limits for optimal performance.

## 2. Input Size Limits

### Text Input Limits

- **Maximum Size:** 1MB (1,048,576 characters)
- **Reason:** Browser memory optimization and performance
- **Enforcement:** Real-time validation with warning at 800KB
- **Error Message:** "Text exceeds 1MB limit. Please reduce the size or split into smaller chunks."

### Per-Operation Limits

| Operation        | Input Limit | Reason                   | Performance Target |
| ---------------- | ----------- | ------------------------ | ------------------ |
| Case Conversion  | 1MB         | Memory usage             | <100ms             |
| Text Cleaning    | 1MB         | DOM manipulation         | <200ms             |
| JSON Processing  | 10MB        | Parsing complexity       | <500ms             |
| Text Analysis    | 500KB       | Statistical computation  | <300ms             |
| URL Extraction   | 1MB         | Regex performance        | <100ms             |
| Encoding/Hashing | 1MB         | Cryptographic operations | <200ms             |

### Line-Based Limits

- **Maximum Lines:** 100,000 lines
- **Reason:** UI rendering performance
- **Operations Affected:** Line sorting, duplicate removal, line counting
- **Fallback:** Automatically switches to streaming mode for large files

## 3. Generation Limits

### Batch Generation Quotas

| Generation Type | Maximum Batch | Reason                        | Performance Target |
| --------------- | ------------- | ----------------------------- | ------------------ |
| UUID v4         | 1,000 items   | Random generation efficiency  | <500ms             |
| UUID v1         | 1,000 items   | Timestamp collision avoidance | <500ms             |
| NanoID          | 1,000 items   | Custom alphabet processing    | <300ms             |
| Passwords       | 100 items     | Secure random generation      | <200ms             |
| Sample Text     | 10,000 words  | Memory allocation             | <1000ms            |
| Names           | 500 items     | Database lookup simulation    | <300ms             |
| Emails          | 500 items     | Domain validation             | <300ms             |

### Single Generation Limits

- **Password Length:** 1-256 characters
- **NanoID Length:** 1-128 characters
- **Sample Text:** 1-10,000 words per generation
- **Custom Pattern:** 1-1,000 repetitions

## 4. Processing Performance Limits

### Response Time Targets

| Operation Category   | Target Time | Warning Threshold | Maximum Time |
| -------------------- | ----------- | ----------------- | ------------ |
| Simple Text (Case)   | <50ms       | 100ms             | 200ms        |
| Complex Text (Clean) | <100ms      | 200ms             | 500ms        |
| JSON Processing      | <200ms      | 500ms             | 1000ms       |
| Text Analysis        | <300ms      | 500ms             | 1000ms       |
| Bulk Generation      | <500ms      | 1000ms            | 2000ms       |
| Encoding Operations  | <100ms      | 200ms             | 500ms        |

### Memory Usage Limits

- **Peak Memory:** 100MB per operation
- **Persistent Memory:** 50MB maximum
- **Cleanup Trigger:** 80MB threshold
- **Emergency Cleanup:** 95MB threshold

### Browser Compatibility Limits

| Browser       | Minimum Version | Text Limit | Performance Notes              |
| ------------- | --------------- | ---------- | ------------------------------ |
| Chrome        | 88+             | 1MB        | Full performance               |
| Firefox       | 85+             | 1MB        | Full performance               |
| Safari        | 14+             | 800KB      | Reduced for memory constraints |
| Edge          | 88+             | 1MB        | Full performance               |
| Mobile Safari | 14+             | 500KB      | Mobile memory limits           |
| Mobile Chrome | 88+             | 800KB      | Mobile optimization            |

## 5. Feature-Specific Limits

### JSON Processing Limits

- **Maximum Depth:** 100 levels of nesting
- **Maximum Keys:** 10,000 keys per object
- **Maximum Array Length:** 100,000 items
- **Path Extraction:** 1,000 paths maximum
- **Validation Timeout:** 5 seconds for complex JSON

### Text Analysis Limits

- **Word Frequency:** Top 1,000 words displayed
- **Sentence Detection:** 10,000 sentences maximum
- **Readability Calculation:** 100KB text for accuracy
- **Language Detection:** 10KB sample minimum

### URL Processing Limits

- **Maximum URLs:** 1,000 URLs per text
- **URL Length:** 2,048 characters per URL
- **Domain Extraction:** 500 unique domains
- **Validation Timeout:** 100ms per URL

### Encoding Limits

- **Base64 Input:** 1MB raw data
- **Hash Input:** 10MB for MD5/SHA-256
- **URL Encoding:** 8,192 characters (URL length limit)
- **Binary Data:** 50MB maximum

## 6. Cross-Tool Sharing Limits

### Data Transfer Limits

| Data Type     | Maximum Size | Compression  | Target Tools             |
| ------------- | ------------ | ------------ | ------------------------ |
| Plain Text    | 1MB          | None         | All tools                |
| JSON Data     | 10MB         | Minification | JSON Doctor, CSV Cleaner |
| Regex Pattern | 1KB          | None         | Regex Tester             |
| URL List      | 100KB        | None         | URL Shortener            |
| Encoded Data  | 1MB          | Base64       | Codec Lab                |

### Share Performance Targets

- **Small Data (<10KB):** Instant transfer
- **Medium Data (10KB-100KB):** <100ms
- **Large Data (100KB-1MB):** <500ms
- **Streaming Required:** >1MB data

### HandoffStore Limits

- **Storage Duration:** 1 hour maximum
- **Maximum Entries:** 100 per user session
- **Entry Size:** 1MB per entry
- **Cleanup Frequency:** Every 15 minutes

## 7. Error Handling & Recovery

### Limit Exceeded Responses

#### Text Size Exceeded

```
⚠️ Text Too Large

Your text is 1.2MB but the limit is 1MB.

Options:
[✂️ Auto-Split] - Split into chunks automatically
[📝 Edit] - Manually reduce size
[❌ Cancel] - Go back

Tip: Try processing smaller sections separately.
```

#### Generation Limit Exceeded

```
⚠️ Generation Limit Exceeded

Requested: 5,000 UUIDs
Maximum: 1,000 UUIDs per batch

[🔄 Generate 1,000] - Use maximum allowed
[✂️ Split Request] - Generate in batches
[❌ Cancel] - Choose different amount
```

#### Performance Warning

```
⚡ Large Operation Warning

Processing 800KB of text may take up to 10 seconds
and could slow your browser.

[⚡ Continue] - Proceed with operation
[✂️ Split Text] - Process in smaller chunks
[❌ Cancel] - Choose smaller input
```

#### Memory Warning

```
🧠 Memory Usage High

This operation requires significant memory.
Close other browser tabs for best performance.

[🚀 Continue Anyway] - Proceed
[🔄 Restart Tool] - Clear memory and restart
[❌ Cancel] - Skip operation
```

## 8. Performance Optimization

### Automatic Optimizations

- **Lazy Loading:** Only process visible text portions
- **Debounced Input:** 300ms delay for real-time operations
- **Memory Cleanup:** Automatic cleanup after operations
- **Progress Streaming:** Show progress for operations >1 second
- **Background Processing:** Use Web Workers for heavy operations

### User-Triggered Optimizations

- **Text Chunking:** Automatic splitting for large inputs
- **Selective Processing:** Choose specific operations only
- **Quality Settings:** Reduce accuracy for faster processing
- **Batch Controls:** User-adjustable batch sizes

### Browser-Specific Optimizations

- **Safari:** Reduced memory usage, smaller chunks
- **Mobile:** Touch-optimized controls, reduced limits
- **Slow Connections:** Progressive loading, smaller operations
- **Low Memory:** Aggressive cleanup, warning thresholds

## 9. Quota Monitoring & Feedback

### Real-Time Indicators

- **Character Counter:** Live count with color coding
- **Memory Usage:** Progress bar for large operations
- **Performance Meter:** Speed indicator for complex operations
- **Batch Progress:** Item-by-item progress for generations

### Warning System

- **Yellow (80% limit):** "Approaching text size limit"
- **Orange (95% limit):** "Consider reducing text size"
- **Red (100% limit):** "Text size limit reached"

### User Education

- **Tips Panel:** Context-sensitive optimization suggestions
- **Help Tooltips:** Explain limits and workarounds
- **Performance Guide:** Best practices for large operations
- **Browser Recommendations:** Optimal browser settings

## 10. Development & Testing Limits

### Test Environment Limits

- **Unit Tests:** 10x smaller limits for speed
- **Performance Tests:** Dedicated large-data scenarios
- **Memory Tests:** Simulated low-memory conditions
- **Browser Tests:** Cross-browser limit validation

### Development Guidelines

- **Always Test Limits:** Validate all boundary conditions
- **Graceful Degradation:** Provide fallbacks for limit exceeded
- **Clear Messaging:** Explain limits and alternatives
- **Performance Monitoring:** Track operation times

### Monitoring & Analytics

- **Limit Hit Rates:** Track how often limits are reached
- **Performance Distribution:** Monitor operation times
- **Error Recovery:** Track user choices when limits hit
- **Browser Performance:** Monitor across different environments

## 11. Future Considerations

### Planned Improvements

- **Progressive Processing:** Stream large text processing
- **WebAssembly:** Move heavy operations to WASM
- **Service Workers:** Background processing for long operations
- **IndexedDB:** Client-side caching for repeated operations

### Scalability Planning

- **Cloud Processing:** Optional server-side for Pro users
- **Distributed Processing:** Split operations across workers
- **Adaptive Limits:** Dynamic limits based on device capability
- **Smart Caching:** Cache frequent operations locally

This limits documentation ensures Text Tools provides optimal performance while gracefully handling edge cases and user education about constraints.
