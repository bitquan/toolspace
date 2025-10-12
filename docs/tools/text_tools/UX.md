# Text Tools - User Experience Documentation

**Last Updated:** October 11, 2025  
**Version:** 2.3.0  
**Owner:** Text Tools Team

## 1. User Flow Overview

### Primary User Journey

```
Landing → Text Tools → Input Text → Select Operation → View Result → Copy/Share → [Chain Operations]
```

### Entry Points

1. **Home Screen Tool Card** - Click "Text Tools" card from main dashboard
2. **Direct Link** - Navigate to `/tools/text-tools`
3. **Cross-Tool Sharing** - Receive shared text from JSON Doctor, CSV Cleaner, etc.
4. **Deep Link** - External links with preset content
5. **Search** - Search for "text" or "formatting" on home screen

## 2. Screen Layout & Components

### Mobile Layout (320px - 768px)

```
┌─────────────────────────────┐
│ [Back] Text Tools     [⚙️]   │ ← Header Bar
├─────────────────────────────┤
│ ┌─┐┌─┐┌─┐┌─┐┌─┐┌─┐         │ ← Tab Bar (scrollable)
│ │1││2││3││4││5││6│         │
│ └─┘└─┘└─┘└─┘└─┘└─┘         │
├─────────────────────────────┤
│ Input Text Area             │ ← Full width input
│ ┌─────────────────────────┐ │
│ │ Type or paste text...   │ │
│ │                         │ │
│ │                         │ │
│ └─────────────────────────┘ │
├─────────────────────────────┤
│ [Btn1] [Btn2] [Btn3]        │ ← Operation buttons
│ [Btn4] [Btn5] [Btn6]        │   (responsive grid)
├─────────────────────────────┤
│ Output Text Area            │ ← Full width output
│ ┌─────────────────────────┐ │
│ │ Processed text appears  │ │
│ │ here...                 │ │
│ └─────────────────────────┘ │
├─────────────────────────────┤
│ [Copy] [Share] [Clear]      │ ← Action buttons
└─────────────────────────────┘
```

### Desktop Layout (>768px)

```
┌───────────────────────────────────────────────────────────┐
│ [Back] Text Tools                              [⚙️] [📤]   │ ← Header
├───────────────────────────────────────────────────────────┤
│ ┌─┐┌─┐┌─┐┌─┐┌─┐┌─┐                                       │ ← Tab Bar
│ │1││2││3││4││5││6│                                       │
│ └─┘└─┘└─┘└─┘└─┘└─┘                                       │
├─────────────────────────┬─────────────────────────────────┤
│ Input Text Area         │ Output Text Area                │ ← Split view
│ ┌─────────────────────┐ │ ┌─────────────────────────────┐ │
│ │ Type or paste...    │ │ │ Processed text appears...   │ │
│ │                     │ │ │                             │ │
│ │                     │ │ │                             │ │
│ │                     │ │ │                             │ │
│ │                     │ │ │                             │ │
│ └─────────────────────┘ │ └─────────────────────────────┘ │
│ [Import] [Clear]        │ [Copy] [Share] [🔗]             │ ← Action buttons
├─────────────────────────┼─────────────────────────────────┤
│ Operation Buttons       │ Statistics Panel                │ ← Bottom panels
│ [Btn1] [Btn2] [Btn3]    │ Characters: 1,234               │
│ [Btn4] [Btn5] [Btn6]    │ Words: 234                      │
│ [Btn7] [Btn8] [Btn9]    │ Lines: 12                       │
└─────────────────────────┴─────────────────────────────────┘
```

## 3. Tab Organization & Flow

### Tab 1: Case Conversion

**Purpose:** Transform text capitalization  
**Layout:** 3x3 button grid with preview

```
┌─────────────────────────────────────────┐
│ [Sentence case] [Title Case] [UPPER]    │
│ [lower case]    [snake_case] [kebab]    │
│ [camelCase]     [PascalCase] [CONSTANT] │
└─────────────────────────────────────────┘
```

**Interaction Flow:**

1. User selects Case tab
2. Input text automatically shows preview on button hover
3. Click button applies transformation instantly
4. Output updates with visual diff highlighting
5. Success toast: "Converted to Title Case"

### Tab 2: Text Cleaning

**Purpose:** Remove unwanted characters and formatting  
**Layout:** 2-column button layout with options

```
┌─────────────────────┬─────────────────────┐
│ [Remove Spaces]     │ [Remove Lines]      │
│ [Trim Whitespace]   │ [Remove Special]    │
│ [Remove Numbers]    │ [Remove Duplicates] │
│ [Sort Lines]        │ [Reverse Lines]     │
│ [Remove HTML]       │ [Decode Entities]   │
└─────────────────────┴─────────────────────┘
```

**Batch Operations:**

- Checkbox: "Apply multiple cleaners"
- When enabled, user can select multiple operations
- "Apply All" button processes in optimal order

### Tab 3: Text Generation

**Purpose:** Generate new text content  
**Layout:** Generation type selector with configuration

```
┌─────────────────────────────────────────┐
│ Generation Type: [UUID ▼]               │
├─────────────────────────────────────────┤
│ ┌─ UUID Options ───────────────────────┐ │
│ │ ○ UUID v4 (Random)                  │ │
│ │ ○ UUID v1 (Timestamp)               │ │
│ │ Format: [Standard ▼]                │ │
│ │ Quantity: [1    ] (max 1000)        │ │
│ └─────────────────────────────────────┘ │
├─────────────────────────────────────────┤
│           [Generate]                    │
└─────────────────────────────────────────┘
```

**Generation Types:**

- UUID (v1, v4 with format options)
- NanoID (custom alphabet, length)
- Password (length, character sets)
- Placeholder text (words, sentences, paragraphs)
- Names (first, last, full with gender options)
- Emails (domains, formats)

### Tab 4: Text Analysis

**Purpose:** Analyze text statistics and readability  
**Layout:** Auto-updating stats with visual indicators

```
┌─────────────────────────────────────────┐
│ ┌─ Basic Stats ─────┬─ Advanced Stats ─┐ │
│ │ Characters: 1,234 │ Reading: 5.2 min │ │
│ │ Words: 234        │ Level: College   │ │
│ │ Lines: 12         │ Score: 65.4      │ │
│ │ Paragraphs: 3     │ Avg Word: 5.3    │ │
│ └───────────────────┴─────────────────┘ │
├─────────────────────────────────────────┤
│ ┌─ Word Frequency ──────────────────────┐ │
│ │ the: 23 ████████████████████████████ │ │
│ │ and: 18 ██████████████████████       │ │
│ │ with: 12 ███████████████             │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### Tab 5: JSON Processing

**Purpose:** Format, validate, and process JSON  
**Layout:** JSON-specific tools with validation

```
┌─────────────────────────────────────────┐
│ Status: [✅ Valid JSON] [⚠️ 2 warnings]  │
├─────────────────────────────────────────┤
│ [Format] [Minify] [Validate] [Extract]  │
├─────────────────────────────────────────┤
│ ┌─ JSONPath Extractor ──────────────────┐ │
│ │ Path: $.users[*].name                │ │
│ │ [Extract Values]                     │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### Tab 6: URL & Encoding

**Purpose:** Process URLs and handle encoding  
**Layout:** URL tools with encoding options

```
┌─────────────────────────────────────────┐
│ [Slugify] [URL Encode] [URL Decode]     │
│ [Extract URLs] [Extract Domains]        │
├─────────────────────────────────────────┤
│ ┌─ Encoding Options ────────────────────┐ │
│ │ [Base64 Encode] [Base64 Decode]      │ │
│ │ [MD5 Hash] [SHA-256 Hash]            │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

## 4. Interaction Patterns

### Real-Time Feedback

- **Typing indicators** - Character count updates as user types
- **Validation feedback** - JSON syntax errors highlight immediately
- **Preview on hover** - Button hover shows preview of transformation
- **Progress indicators** - Loading states for operations taking >100ms

### Copy & Share Workflow

```
User clicks output → Text selected → Copy button highlighted →
Click copy → Success toast → Clipboard contains result
```

**Share Workflow:**

```
User clicks Share → Tool selector appears → User selects target →
Data packages with metadata → Navigation to target tool →
Target tool receives and displays shared data
```

### Keyboard Shortcuts Flow

```
User presses Ctrl+1 → Tab 1 activates → Input focus maintained →
User presses Ctrl+Shift+T → Title case applied → Output updates →
Success feedback appears
```

## 5. Empty States

### Initial Load State

```
┌─────────────────────────────────────────┐
│           🔤 Text Tools                  │
│                                         │
│  Transform and analyze text instantly   │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 📝 Type or paste text to begin...  │ │
│ │                                     │ │
│ │ Try: "hello world" → Title Case     │ │
│ │ Or paste JSON for formatting       │ │
│ │                                     │ │
│ └─────────────────────────────────────┘ │
│                                         │
│        [📋 Paste] [📄 Example]          │
└─────────────────────────────────────────┘
```

### No Results State

```
┌─────────────────────────────────────────┐
│              📭 No Output               │
│                                         │
│     Select an operation to see results  │
│                                         │
│           [🔄 Try an Operation]         │
└─────────────────────────────────────────┘
```

### Processing State

```
┌─────────────────────────────────────────┐
│              ⚡ Processing...            │
│                                         │
│              [████████████]             │
│           Analyzing text content        │
└─────────────────────────────────────────┘
```

## 6. Error States & Recovery

### Input Validation Errors

```
┌─────────────────────────────────────────┐
│ Input Text Area                         │
│ ┌─────────────────────────────────────┐ │ ← Red border
│ │ {"test":}                           │ │
│ │ ▲                                   │ │
│ │ └─ Syntax error here                │ │
│ └─────────────────────────────────────┘ │
│ ❌ JSON syntax error on line 1:        │ ← Error message
│    Expected property value             │
│ [🔧 Fix Automatically] [❓ Help]       │ ← Recovery options
└─────────────────────────────────────────┘
```

### Size Limit Error

```
┌─────────────────────────────────────────┐
│ ⚠️  Text Too Large                      │
│                                         │
│ Your text is 1.2MB but the limit is    │
│ 1MB. Please reduce the size or split    │
│ into smaller chunks.                    │
│                                         │
│ [✂️ Auto-Split] [📝 Edit] [❌ Cancel]   │
└─────────────────────────────────────────┘
```

### Operation Failed Error

```
┌─────────────────────────────────────────┐
│ ❌ Operation Failed                     │
│                                         │
│ The title case conversion failed due    │
│ to an unexpected error.                 │
│                                         │
│ [🔄 Try Again] [🐛 Report] [⬅️ Back]    │
└─────────────────────────────────────────┘
```

## 7. Loading & Performance States

### Large Text Warning

```
┌─────────────────────────────────────────┐
│ ⚡ Large Text Detected                  │
│                                         │
│ Processing 847KB of text may take a     │
│ few seconds and could slow your browser.│
│                                         │
│ [⚡ Continue] [✂️ Split Text] [❌ Cancel] │
└─────────────────────────────────────────┘
```

### Batch Generation Progress

```
┌─────────────────────────────────────────┐
│ Generating 500 UUIDs...                 │
│                                         │
│ [████████████████████░░░] 82%           │ ← Progress bar
│                                         │
│ Generated: 410/500                      │
│ Time remaining: ~3 seconds              │
│                                         │
│              [⏹️ Cancel]                 │
└─────────────────────────────────────────┘
```

## 8. Success & Feedback States

### Copy Success

```
┌─────────────────────────────────────────┐
│ ✅ Copied to Clipboard!                 │ ← Toast notification
│    235 characters copied                │   (auto-dismiss 3s)
└─────────────────────────────────────────┘
```

### Operation Success

```
┌─────────────────────────────────────────┐
│ ✅ Text Converted                       │
│    hello world → Hello World            │ ← Shows transformation
│    [Copy Result] [Share]                │
└─────────────────────────────────────────┘
```

### Share Success

```
┌─────────────────────────────────────────┐
│ 📤 Shared to QR Maker                   │
│    Opening tool with your text...       │
│    [🔗 Go Now] [↩️ Stay Here]           │
└─────────────────────────────────────────┘
```

## 9. Accessibility Considerations

### Screen Reader Announcements

- **Operation completion:** "Text converted to title case. 'Hello World' is now in the output area."
- **Error states:** "Error: JSON syntax error on line 1. Expected property value."
- **Success states:** "Success: Text copied to clipboard. 235 characters copied."

### Focus Management

- Tab key navigates: Input → Tab buttons → Operation buttons → Output → Action buttons
- Focus indicators clearly visible with high contrast
- Escape key returns focus to input area from any control

### Visual Indicators

- High contrast mode support
- Error states use icons + color + text (not color alone)
- Loading states provide text descriptions
- Success states include checkmark icons

## 10. Performance Considerations

### Optimization Strategies

- **Debounced analysis** - Text analysis updates 300ms after typing stops
- **Lazy rendering** - Only render visible tab content
- **Virtual scrolling** - For large word frequency lists
- **Memory management** - Clear large text from memory when switching tools
- **Progressive loading** - Load tab content on demand

### Performance Targets

- **Initial load:** <200ms to show interface
- **Operation response:** <100ms for simple operations
- **Large text (100KB):** <500ms for most operations
- **Batch generation:** <2s for 1000 items
- **Memory usage:** <50MB for typical use

This UX documentation provides complete interaction patterns and state management for the Text Tools interface with zero placeholders.
