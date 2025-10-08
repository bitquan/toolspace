# Time Converter Documentation

## Overview

Time Converter is a powerful timestamp conversion tool that converts between human-readable dates, Unix timestamps, and various time formats. It supports natural language parsing and multiple timezone conversions, making it easy to work with timestamps across different formats and contexts.

## Features

### 1. Natural Language Parsing

Parse intuitive time expressions without needing to know exact formats:

- **Current Time**: `now`, `today`
- **Relative Days**: `yesterday`, `tomorrow`
- **Relative Time**: `5 minutes ago`, `in 2 hours`, `3 days ago`, `1 week ago`
- **Multiple Units**: seconds, minutes, hours, days, weeks, months, years

**Example Usage:**

```
Input: "5 minutes ago"
Output (ISO 8601): "2024-01-15T10:25:00.000Z"

Input: "in 2 hours"
Output (Unix): "1705320600"

Input: "yesterday"
Output (Human Readable): "2024-01-14 10:30:00"
```

### 2. Unix Timestamp Conversion

Convert between Unix timestamps and human-readable formats:

- **Unix Seconds**: Standard Unix epoch timestamp (seconds since 1970-01-01)
- **Unix Milliseconds**: JavaScript-style timestamp (milliseconds since 1970-01-01)
- **Bidirectional**: Convert from Unix to human and vice versa

**Example Usage:**

```
Input: "1234567890"
Output (Human): "2009-02-13 23:31:30"

Input: "2024-01-15T10:30:00"
Output (Unix Seconds): "1705318200"
Output (Unix Milliseconds): "1705318200000"
```

### 3. Format Presets

Multiple output format options for different use cases:

- **ISO 8601**: International standard (e.g., `2024-01-15T10:30:00.000Z`)
- **RFC 3339**: Internet standard (e.g., `2024-01-15T10:30:00.000Z`)
- **Unix (seconds)**: Standard Unix timestamp (e.g., `1705318200`)
- **Unix (ms)**: JavaScript timestamp (e.g., `1705318200000`)
- **Human Readable**: Easy-to-read format (e.g., `2024-01-15 10:30:00`)
- **Date Only**: Just the date (e.g., `2024-01-15`)
- **Time Only**: Just the time (e.g., `10:30:00`)

**Features:**

- Switch between formats with one click
- All formats shown simultaneously in result panel
- Copy any format to clipboard
- Real-time conversion as you type

### 4. Timezone Support

Convert times between different timezones:

- **UTC**: Coordinated Universal Time
- **Local**: Your system's local timezone
- **Americas**: New York, Los Angeles, Chicago, Denver
- **Europe**: London, Paris, Berlin
- **Asia**: Tokyo, Shanghai, Dubai
- **Australia**: Sydney

**Example Usage:**

```
Input: "now"
Timezone: UTC
Output: "2024-01-15T10:30:00.000Z"

Input: "now"
Timezone: America/New_York
Output: Adjusted for EST/EDT
```

### 5. Relative Time Display

See how long ago or how far in the future a timestamp is:

- **Seconds**: "a few seconds ago"
- **Minutes**: "5 minutes ago"
- **Hours**: "3 hours from now"
- **Days**: "2 days ago"
- **Weeks**: "1 week ago"
- **Months**: "3 months from now"
- **Years**: "2 years ago"

### 6. Interactive Features

- **"Now" Button**: Instantly set input to current timestamp
- **Quick Templates**: One-click access to common time expressions
- **Real-time Parsing**: Immediate feedback as you type
- **Copy to Clipboard**: Copy any result format instantly
- **Share Integration**: Share timestamps with other tools
- **Import Data**: Import timestamps from other tools

## Usage Guide

### Basic Workflow

1. **Enter Input**: Type or paste a timestamp, date, or natural language expression
2. **Select Timezone**: Choose the appropriate timezone (default: UTC)
3. **Choose Format**: Select your preferred output format
4. **View Results**: See the converted timestamp in multiple formats
5. **Copy or Share**: Copy the result or share with other tools

### Quick Examples

Use the quick example buttons to try common patterns:
- Click "now" for current timestamp
- Click "yesterday" for 24 hours ago
- Click "5 minutes ago" for recent past
- Click "in 2 hours" for near future

### Supported Input Formats

The tool automatically detects and parses:
- Natural language (e.g., "now", "yesterday", "5 minutes ago")
- ISO 8601 dates (e.g., "2024-01-15T10:30:00Z")
- RFC 3339 dates (e.g., "2024-01-15T10:30:00.000Z")
- Unix timestamps in seconds (e.g., "1234567890")
- Unix timestamps in milliseconds (e.g., "1234567890000")
- Standard date formats (e.g., "2024-01-15")

### Error Handling

If the input cannot be parsed, the tool displays:
- Clear error message explaining the issue
- Suggestions for valid input formats
- Quick examples to guide you

## Use Cases

### For Developers

- Debug API timestamps
- Convert between JavaScript and server timestamps
- Test date/time logic
- Generate test data with specific timestamps

### For System Administrators

- Analyze log timestamps
- Convert between different log formats
- Schedule maintenance windows across timezones
- Calculate uptime and downtime

### For Data Analysts

- Normalize timestamp data
- Convert legacy timestamp formats
- Analyze time-series data
- Create consistent time representations

### For General Users

- Convert times between timezones for meetings
- Understand Unix timestamps in files or URLs
- Calculate time differences
- Plan events across time zones

## Technical Details

### Parsing Logic

The tool uses intelligent parsing to handle various inputs:

1. **Natural Language First**: Checks for common expressions
2. **Standard Formats**: Tries ISO 8601, RFC 3339, and other standards
3. **Unix Timestamps**: Detects and converts numeric timestamps
4. **Fallback**: Provides helpful error messages for unrecognized formats

### Timezone Handling

- Timezone selection affects input interpretation
- UTC is recommended for most technical use cases
- Local timezone uses system settings
- Named timezones (e.g., America/New_York) follow standard IANA database

### Precision

- Unix seconds: 1-second precision
- Unix milliseconds: 1-millisecond precision
- ISO 8601/RFC 3339: Full date-time precision including milliseconds
- Human Readable: Formatted for readability, maintains precision

## Limitations

- Natural language parsing for months and years uses approximations (30 days, 365 days)
- Timezone database limited to most common zones (can be expanded)
- Historical timezone changes not accounted for (uses current rules)
- No support for custom format strings (uses predefined formats)

## Future Enhancements

Potential future features:
- Custom format string support
- Timezone offset calculator
- Duration calculator (time between two dates)
- Calendar integration
- Recurring event calculator
- Batch timestamp conversion

## Integration

The Time Converter integrates with Toolspace's cross-tool data sharing:

- **Import**: Accept timestamps from other tools
- **Export**: Share converted timestamps with other tools
- **Format Compatibility**: Works with Text Tools, JSON Doctor, and other tools

## Accessibility

- Keyboard navigation support
- Clear visual feedback for all actions
- Error messages with helpful guidance
- Copy functionality for screen readers
- High contrast UI elements

## Performance

- Client-side only (no backend calls)
- Instant conversion with no network latency
- Efficient parsing algorithms
- Smooth animations and transitions
- Responsive on all devices

## Privacy

- All processing happens locally in your browser
- No data sent to servers
- No storage of personal information
- No tracking or analytics

## Support

For issues, feature requests, or questions:
- Open an issue on GitHub
- Check the Toolspace documentation
- Review the dev-log for updates
