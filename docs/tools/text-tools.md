# Text Tools Documentation

## Overview

Text Tools is a comprehensive suite of text processing utilities for common text manipulation tasks. All operations are performed client-side with no backend dependencies.

## Features

### 1. Case Conversion

Transform text between different case formats:

- **UPPERCASE**: Converts all characters to uppercase
- **lowercase**: Converts all characters to lowercase
- **Title Case**: Capitalizes The First Letter Of Each Word
- **Sentence case**: Capitalizes only the first letter of the sentence
- **camelCase**: Converts to camelCase format (first word lowercase, subsequent words capitalized)
- **PascalCase**: Converts to PascalCase format (all words capitalized, no spaces)
- **snake_case**: Converts to snake_case format (lowercase with underscores)
- **kebab-case**: Converts to kebab-case format (lowercase with hyphens)

**Example Usage:**

```
Input: "Hello World Test"
Output Examples:
- UPPERCASE: "HELLO WORLD TEST"
- camelCase: "helloWorldTest"
- snake_case: "hello_world_test"
```

### 2. Text Cleaning

Clean and normalize text content:

- **Collapse Spaces**: Converts multiple consecutive spaces to single spaces
- **Clean Whitespace**: Trims and collapses whitespace in one operation
- **Strip Punctuation**: Removes punctuation marks (optionally keeping basic ones)
- **Normalize Unicode**: Normalizes Unicode characters and removes problematic ones
- **Strip Numbers**: Removes all numeric characters
- **Clean All**: Applies multiple cleaning operations at once

**Example Usage:**

```
Input: "  Hello    world!!!  123  "
- Collapse Spaces: " Hello world!!! 123 "
- Clean Whitespace: "Hello world!!! 123"
- Strip Punctuation: "Hello world 123"
- Strip Numbers: "Hello world"
```

### 3. JSON Tools

Validate, format, and manipulate JSON data:

- **Validate**: Checks JSON syntax and reports errors with line/column information
- **Pretty Print**: Formats JSON with proper indentation (2 or 4 spaces)
- **Minify**: Removes all unnecessary whitespace from JSON
- **Sort Keys**: Alphabetically sorts object keys while preserving structure

**Features:**

- Detailed error reporting with exact line and column numbers
- Preserves data types and structure during formatting
- Handles nested objects and arrays
- Statistics on JSON structure (object count, array count, etc.)

**Example Usage:**

```
Input: {"name":"test","value":123,"nested":{"key":"value"}}

Pretty Print (2 spaces):
{
  "name": "test",
  "value": 123,
  "nested": {
    "key": "value"
  }
}

Validation with Error Pinpointing:
Input: {"name": test}
Output: 
Invalid JSON ✗
Error at line 1, column 10
Unexpected character (at character 10)
```

### 4. URL Slugify

Convert text to URL-safe slugs:

- **Create Slug**: Converts text to lowercase, URL-safe format with hyphens
- **Custom Options**: Configure separator, accent handling, and length limits
- **Filename Safe**: Create filesystem-safe names
- **Validation**: Check if text is already a valid slug

**Features:**

- Removes or converts accents (café → cafe)
- Handles special characters and punctuation
- Configurable separators (-, \_, etc.)
- Maximum length limits
- Unicode normalization

**Example Usage:**

```
Input: "Café & Restaurant Reviews!"
- Standard Slug: "cafe-restaurant-reviews"
- Keep Accents: "café-restaurant-reviews"
- Underscore Separator: "cafe_restaurant_reviews"
```

### 5. Text Analysis & Counters

Comprehensive text statistics and analysis:

**Basic Counts:**

- Characters (total and excluding spaces)
- Words, sentences, paragraphs, lines
- Average words per sentence
- Average characters per word

**Advanced Analysis:**

- Word frequency analysis with top words
- Reading time estimation
- Text complexity metrics

**Example Output:**

```
Text: "Hello world. This is a test sentence with multiple words."

Statistics:
- Characters: 58
- Characters (no spaces): 49
- Words: 11
- Sentences: 2
- Paragraphs: 1
- Lines: 1
- Avg words per sentence: 5.5
- Avg chars per word: 4.5

Top Words:
- "a": 1
- "is": 1
- "test": 1
```

### 6. UUID Generator

Generate various UUID formats for development and testing:

**Formats Available:**

- **Standard UUID v4**: `550e8400-e29b-41d4-a716-446655440000`
- **Simple (no dashes)**: `550e8400e29b41d4a716446655440000`
- **Uppercase**: `550E8400-E29B-41D4-A716-446655440000`
- **Short (8 chars)**: `550e8400` (not guaranteed unique)
- **Bulk Generation**: Generate multiple UUIDs at once

**Features:**

- Cryptographically secure random generation
- RFC 4122 compliant UUID v4
- Validation of existing UUIDs
- Custom separator formatting
- Batch generation for testing

## Technical Implementation

### Architecture

- **Client-Side Only**: No backend dependencies, works entirely in the browser
- **Pure Dart**: All logic implemented in Dart for consistency and performance
- **Modular Design**: Each tool is a separate module that can be used independently
- **Material Design 3**: Modern, accessible UI following Google's design system

### Performance Characteristics

- **Real-time Processing**: Most operations complete in milliseconds
- **Memory Efficient**: Optimized for large text inputs
- **Unicode Support**: Full Unicode normalization and handling
- **Error Handling**: Graceful degradation with detailed error messages

### Browser Compatibility

- Modern browsers with WebAssembly support
- Clipboard API integration where available
- Responsive design for desktop and mobile

## API Reference

### CaseConverter

```dart
class CaseConverter {
  static String toUpperCase(String text)
  static String toLowerCase(String text)
  static String toTitleCase(String text)
  static String toSentenceCase(String text)
  static String toCamelCase(String text)
  static String toPascalCase(String text)
  static String toSnakeCase(String text)
  static String toKebabCase(String text)
  static List<String> get availableFormats
}
```

### TextCleaner

```dart
class TextCleaner {
  static String collapseSpaces(String text)
  static String cleanWhitespace(String text)
  static String normalizeUnicode(String text)
  static String stripPunctuation(String text, {bool keepBasic = true})
  static String stripNumbers(String text)
  static String cleanAll(String text, {bool keepBasicPunctuation = true})
}
```

### JsonTools

```dart
class JsonTools {
  static ValidationResult validateJson(String jsonString)
  static String prettyPrint(String jsonString, {int indent = 2})
  static String minify(String jsonString)
  static String sortKeys(String jsonString, {int indent = 2})
  static Map<String, dynamic> getStats(String jsonString)
}

class ValidationResult {
  final bool isValid
  final String? error
  final int? line
  final int? column
}
```

### Slugify

```dart
class Slugify {
  static String toSlug(String text, {String separator = '-', bool lowercase = true, int? maxLength})
  static String custom(String text, {bool removeAccents = true, String separator = '-', bool lowercase = true})
  static String toFilename(String text, {int? maxLength})
  static bool isValidSlug(String text, {String separator = '-'})
}
```

### TextCounters

```dart
class TextCounters {
  static CountResult analyze(String text)
}

class CountResult {
  final int characters
  final int charactersNoSpaces
  final int words
  final int sentences
  final int paragraphs
  final int lines
  final double avgWordsPerSentence
  final double avgCharsPerWord
  final Map<String, int> wordFrequency
}
```

### UuidGenerator

```dart
class UuidGenerator {
  static String generateV4()
  static String generateSimple()
  static String generateUppercase()
  static String generateShort()
  static List<String> generateMultiple(int count, {bool simple = false})
  static bool isValid(String uuid)
  static String formatWithSeparator(String uuid, String separator)
}
```

## Usage Examples

### Chaining Operations

Text Tools are designed to work well together:

```dart
// Clean and format text for URL
final input = "  My Blog Post Title!!!  ";
final cleaned = TextCleaner.cleanWhitespace(input);
final slug = Slugify.toSlug(cleaned);
// Result: "my-blog-post-title"

// Prepare text for API
final jsonString = '{"title": "' + cleaned + '", "slug": "' + slug + '"}';
final formatted = JsonTools.prettyPrint(jsonString);
```

### Batch Processing

```dart
// Generate test data
final uuids = UuidGenerator.generateMultiple(10);
final testData = uuids.map((uuid) => {
  'id': uuid,
  'slug': Slugify.toSlug('Test Item $uuid')
}).toList();
```

## Best Practices

1. **Input Validation**: Always validate input before processing large amounts of text
2. **Performance**: For very large texts (>1MB), consider breaking into chunks
3. **Unicode**: Use normalize operations when dealing with international text
4. **Error Handling**: Check validation results before proceeding with JSON operations
5. **Accessibility**: All tools support keyboard navigation and screen readers

## Integration

Text Tools integrates seamlessly with the Toolspace platform:

- **Clipboard Integration**: One-click copy for all results
- **Material Design**: Consistent with platform design system
- **Responsive**: Works on desktop and mobile devices
- **Keyboard Shortcuts**: Planned for future releases

## Development

To extend Text Tools:

1. Add new logic modules in `lib/tools/text_tools/logic/`
2. Create corresponding tests in `test/tools/`
3. Update the main screen UI to include new functionality
4. Follow the existing pattern for error handling and validation

All contributions should maintain the client-side-only architecture and include comprehensive tests.
