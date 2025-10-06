# Regex Tester

Test regex patterns with live match highlighting and capture group extraction.

## Overview

The Regex Tester is an interactive tool for testing regular expressions against text input. It provides real-time pattern validation, match highlighting, and detailed capture group information, making it easier to develop and debug regex patterns.

## Features

### Core Functionality

- **Live Pattern Testing**: Test regex patterns against text in real-time
- **Match Highlighting**: Visual highlighting of all matches in the test text
- **Capture Groups**: Extract and display numbered and named capture groups
- **Error Validation**: Clear error messages for invalid regex patterns
- **Pattern Library**: Pre-built common regex patterns for quick use

### Regex Flags

Control pattern matching behavior with standard regex flags:

- **Case Sensitive**: Match with exact case (default: on)
- **Multiline**: `^` and `$` match line boundaries (default: off)
- **Dot All**: `.` matches newline characters (default: off)
- **Unicode**: Enable Unicode mode (default: on)

### Pattern Library

Browse and use pre-built patterns organized by category:

- **Basic**: Email, URL, phone numbers, dates, times
- **Numbers**: Integers, decimals, percentages, currency
- **Text**: Words, sentences, hashtags, mentions
- **Programming**: HTML tags, hex colors, IP addresses, variable names
- **Validation**: Usernames, passwords, credit cards

## Usage

### Basic Workflow

1. Enter a regex pattern in the "Regex Pattern" field
2. Type or paste test text in the "Test Text" area
3. View live match results in the "Matches & Groups" panel
4. Toggle flags as needed to adjust matching behavior
5. Browse presets for common patterns (click library icon)

### Pattern Examples

#### Email Matching
```regex
\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b
```
Matches: `user@example.com`, `admin@test.org`

#### Phone Numbers (US)
```regex
\b\d{3}[-.]?\d{3}[-.]?\d{4}\b
```
Matches: `123-456-7890`, `123.456.7890`, `1234567890`

#### Date (ISO Format)
```regex
\b\d{4}-\d{2}-\d{2}\b
```
Matches: `2024-01-15`, `2023-12-31`

#### Capture Groups Example
```regex
(\d{4})-(\d{2})-(\d{2})
```
For text `2024-01-15`:
- Group 1: `2024` (year)
- Group 2: `01` (month)
- Group 3: `15` (day)

#### Named Capture Groups
```regex
(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})
```
Captures the same values as above with named groups.

## Interface

### Header Section

- **Status Indicator**: Visual feedback on pattern validity and matches
  - Gray circle: Ready (no input)
  - Green check: Successful matches found
  - Blue info: Valid pattern, no matches
  - Red error: Invalid pattern syntax
- **Status Message**: Describes current state and match count
- **Copy Button**: Copy the current pattern to clipboard

### Pattern Section

- **Pattern Input**: Enter your regex pattern here
  - Monospace font for clarity
  - Clear button to reset
  - Real-time validation with error messages
- **Flag Toggles**: Control matching behavior
  - Chips toggle on/off with visual feedback

### Test Section (Split View)

**Left Panel: Test Text**
- Large text area for input
- Supports multi-line text
- Monospace font

**Right Panel: Matches & Groups**
- Highlighted text showing all matches
- Expandable cards for each match showing:
  - Match position (start-end)
  - Full matched text
  - Capture groups (if any)

### Preset Library (Sidebar)

- Click library icon to toggle
- Categories organized by use case
- Expand categories to see patterns
- Click any preset to apply it
- Automatically populates pattern and example text

## Tips

### Pattern Development

1. Start with simple patterns and test incrementally
2. Use the preset library as a starting point
3. Test with multiple input samples
4. Pay attention to capture group extraction
5. Use flags to fine-tune matching behavior

### Common Regex Elements

- `.` - Any character (except newline)
- `\d` - Digit (0-9)
- `\w` - Word character (alphanumeric + underscore)
- `\s` - Whitespace
- `*` - Zero or more
- `+` - One or more
- `?` - Zero or one
- `^` - Start of string/line
- `$` - End of string/line
- `\b` - Word boundary
- `[...]` - Character class
- `(...)` - Capture group
- `(?<name>...)` - Named capture group

### Error Messages

The tool provides helpful error messages:
- "Unterminated group" - Check parentheses
- "Unmatched bracket" - Check square brackets
- "Invalid" - General syntax error

## Technical Details

### Implementation

- **Engine**: Dart's built-in RegExp class
- **UI Framework**: Flutter with Material 3
- **Animation**: Pulse effect on successful matches
- **Pattern Storage**: In-memory only (patterns not saved)

### Limitations

- Patterns are validated on each keystroke
- Very complex patterns may impact performance
- Maximum text length limited by UI constraints
- No persistent storage of custom patterns

### Regex Flavor

Uses Dart's regex implementation, which is based on ECMA-262 (JavaScript) regex syntax with some differences:
- No lookbehind assertions in older Dart versions
- Named groups use `(?<name>...)` syntax
- Unicode support enabled by default

## Keyboard Shortcuts

- **Ctrl/Cmd + C**: Copy pattern (when focused on pattern field)
- **Tab**: Navigate between fields
- **Ctrl/Cmd + A**: Select all text

## Accessibility

- Full keyboard navigation support
- Screen reader compatible
- High contrast mode support
- Touch-friendly tap targets

## Use Cases

### Development
- Test regex patterns before using in code
- Debug existing patterns
- Extract structured data from text
- Validate input formats

### Learning
- Learn regex syntax interactively
- Experiment with different patterns
- Understand capture groups
- Explore common patterns in the library

### Data Processing
- Extract emails from text
- Parse log files
- Extract phone numbers
- Match URL patterns

## Related Tools

- **Text Tools**: For text transformation and cleaning
- **JSON Doctor**: For JSON validation and formatting

## Support

For issues or feature requests, please file an issue in the Toolspace repository.

---

**Route**: `/tools/regex-tester`  
**Category**: Text Processing  
**Complexity**: Medium  
**Backend**: No
