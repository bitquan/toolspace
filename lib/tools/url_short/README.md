# URL Shortener Tool

A dev-only tool for creating and managing short URLs with unique codes.

## Overview

The URL Shortener provides a clean interface for converting long URLs into short, memorable codes. It includes user-scoped management, click tracking, and a Material 3 UI with playful animations.

## Features

- **Create Short URLs**: Convert long URLs into 6-character codes
- **List Management**: View all your short URLs
- **Copy to Clipboard**: One-click copy functionality
- **Delete URLs**: Remove unwanted short URLs
- **Click Tracking**: Backend tracks usage (via Firebase)
- **Real-time Validation**: Instant URL format checking
- **Dev-only Access**: Restricted to developers

## File Structure

```
lib/tools/url_short/
├── README.md                   # This file
└── url_short_screen.dart       # Main screen implementation
```

## Components

### UrlShortScreen

Main screen widget that handles:
- URL input and validation
- Short URL creation
- List display
- User interactions

### _UrlCard

Widget for displaying individual short URLs with:
- Original URL display
- Short code display
- Copy and delete actions
- Hover effects
- Time since creation

### ShortUrl Model

Data model for short URL entries:
```dart
class ShortUrl {
  final String id;
  final String originalUrl;
  final String shortCode;
  final DateTime createdAt;
}
```

## Usage

```dart
import 'package:toolspace/tools/url_short/url_short_screen.dart';

// Navigate to the screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const UrlShortScreen(),
  ),
);
```

## Validation Rules

- URLs must be in valid format
- Maximum length: 2048 characters
- Must include protocol (http:// or https://)
- Real-time validation with error messages

## Backend Integration

The screen integrates with Firebase Functions for:
- Creating short URLs (`createShortUrl`)
- Fetching user's URLs (`getUserShortUrls`)
- Deleting URLs (`deleteShortUrl`)

Redirect endpoint: `/u/<code>` (handled by `redirectShortUrl`)

## Dev Access

The tool checks `_isDevUser` flag to determine access. Currently set to `true` for all authenticated users. Future implementations should integrate with a proper role-based access system.

## Testing

Tests are located in:
- `test/tools/url_short_widget_test.dart` - Widget tests
- `test/tools/url_short_test.dart` - Unit tests

## State Management

Uses StatefulWidget with local state management:
- `_urls`: List of user's short URLs
- `_isLoading`: Loading state flag
- `_validationError`: Current validation error
- Animation controllers for visual feedback

## Animations

- Bounce animation on URL creation
- Hover effects on URL cards
- Smooth loading states

## Future Enhancements

- Custom short codes
- Analytics dashboard
- QR code generation
- Batch operations
- Expiration dates
- Advanced click tracking

## Related Documentation

- [Full Tool Documentation](../../../docs/tools/url-short.md)
- [Dev Log](../../../docs/dev-log/features/url-shortener.md)
- [Backend Functions](../../../functions/src/tools/url-short/index.ts)
