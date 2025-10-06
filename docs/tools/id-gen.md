# ID Generator Documentation

## Overview

ID Generator is a comprehensive tool for generating various types of unique identifiers. It supports UUID v4 (random), UUID v7 (timestamp-based), and NanoID with customizable options. The tool is designed for developers who need to generate IDs for databases, APIs, testing, or any other application requiring unique identifiers.

**Route**: /tools/id-gen  
**UI**: Flutter (Material 3, UX-Play playful theme)  
**Backend**: false (all generation happens client-side)

## Features

### ID Types

#### UUID v4 (Random)
- **Format**: `xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx`
- **Standard**: RFC 4122 compliant
- **Size**: 128-bit (36 characters with dashes)
- **Use Case**: General purpose unique identifiers
- **Collision Probability**: Extremely low (~1 in 5.3×10³⁶)

#### UUID v7 (Timestamp-based)
- **Format**: `xxxxxxxx-xxxx-7xxx-yxxx-xxxxxxxxxxxx`
- **Standard**: RFC 9562 compliant
- **Size**: 128-bit (36 characters with dashes)
- **Use Case**: Sortable IDs with temporal ordering
- **Features**: 
  - First 48 bits contain Unix timestamp in milliseconds
  - Remaining bits are random
  - Naturally sortable by creation time
  - Ideal for database primary keys and time-series data

#### NanoID
- **Format**: Customizable length and alphabet
- **Default**: 21 characters, URL-safe alphabet
- **Size**: Configurable (8-64 characters recommended)
- **Use Case**: Compact, URL-friendly unique identifiers
- **Features**:
  - Smaller than UUID (21 chars vs 36)
  - URL-safe by default
  - Customizable alphabet
  - Better performance than UUID
  - Similar collision resistance to UUID

### Batch Generation

Generate up to **1,000 IDs** in a single batch:
- Adjust batch count with slider (1-1000)
- Real-time batch processing
- Progress feedback
- Efficient generation for large batches

### NanoID Customization

#### Alphabet Presets
- **URL-Safe** (default): `0-9A-Za-z_-` (64 characters)
- **Alphanumeric**: `0-9A-Za-z` (62 characters)
- **Numbers**: `0-9` (10 characters)
- **Lowercase**: `a-z` (26 characters)
- **Uppercase**: `A-Z` (26 characters)
- **Hexadecimal**: `0-9a-f` (16 characters)
- **Custom**: Define your own alphabet

#### Length Customization
- Adjustable from 8 to 64 characters
- Default: 21 characters
- Collision probability calculator shows safety of chosen length

#### Collision Probability
The tool automatically calculates and displays the collision probability based on:
- Selected alphabet size
- Chosen ID length
- Uses birthday paradox approximation

Example: With default settings (21 chars, 64-char alphabet), ~1% collision probability occurs after ~4.8 quadrillion IDs.

### Copy Functionality

#### Individual Copy
- Click the copy icon next to any generated ID
- Instant clipboard copy
- Visual feedback confirmation

#### Copy All
- Copy all generated IDs at once
- IDs are separated by newlines
- Perfect for importing into spreadsheets or other tools

### User Interface

#### Layout
- **Left Panel (Configuration)**: 
  - ID type selection
  - Batch count control
  - NanoID customization options
  - Generate button
  
- **Right Panel (Results)**:
  - Generated IDs list
  - Individual copy buttons
  - Numbered display
  - Selectable text for manual copying

#### Animations
- Playful bounce animation when generating IDs
- Smooth transitions between ID types
- Material 3 motion design

#### Visual Design
- Purple accent color (`#9C27B0`)
- Material 3 components
- Responsive layout
- Clear visual hierarchy
- Accessible color contrast

## Usage Examples

### Example 1: Generate Single UUID v4
1. Open ID Generator
2. Select "UUID v4" (default)
3. Click "Generate ID"
4. Copy the generated UUID

**Result**: `550e8400-e29b-41d4-a716-446655440000`

### Example 2: Generate 100 Sortable UUIDs
1. Select "UUID v7"
2. Adjust batch count slider to 100
3. Click "Generate 100 IDs"
4. Click "Copy All" to copy all IDs

**Use Case**: Generating sortable database primary keys for batch import.

### Example 3: Generate Short Numeric IDs
1. Select "NanoID"
2. Adjust length to 12
3. Select "Numbers" preset
4. Set batch count to 50
5. Click "Generate 50 IDs"

**Result**: `847263951037`, `615829473510`, etc.

**Use Case**: Order numbers, invoice IDs, or ticket numbers.

### Example 4: Generate Custom IDs for Voucher Codes
1. Select "NanoID"
2. Adjust length to 8
3. Select "Custom" preset
4. Enter alphabet: `ABCDEFGHJKLMNPQRSTUVWXYZ23456789` (no ambiguous chars)
5. Set batch count to 1000
6. Click "Generate 1000 IDs"

**Result**: `XK8P92VR`, `N4YH6ZM3`, etc.

**Use Case**: Voucher codes, discount codes, or promotional codes that avoid ambiguous characters (0/O, 1/I, etc.).

## Technical Details

### UUID Generation

#### UUID v4 Algorithm
```
1. Generate 16 random bytes
2. Set version bits: byte[6] = (byte[6] & 0x0F) | 0x40
3. Set variant bits: byte[8] = (byte[8] & 0x3F) | 0x80
4. Format as xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

#### UUID v7 Algorithm
```
1. Get current timestamp in milliseconds
2. Fill first 48 bits (6 bytes) with timestamp
3. Fill remaining 10 bytes with random data
4. Set version bits: byte[6] = (byte[6] & 0x0F) | 0x70
5. Set variant bits: byte[8] = (byte[8] & 0x3F) | 0x80
6. Format as xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

### NanoID Generation

#### Algorithm
```
1. Validate alphabet (unique characters, length ≤ 256)
2. For each character position:
   a. Generate random index in alphabet range
   b. Append alphabet[index] to result
3. Return generated ID
```

#### Security
- Uses `Random.secure()` for cryptographically secure random number generation
- Suitable for security-sensitive applications
- No predictable patterns

### Performance

#### Benchmarks (approximate)
- Single UUID generation: < 1ms
- Single NanoID generation: < 1ms
- Batch of 1000 UUIDs: ~5-10ms
- Batch of 1000 NanoIDs: ~5-10ms

#### Memory Usage
- Minimal memory footprint
- Efficient batch processing
- No server-side storage required

## Best Practices

### Choosing ID Type

**Use UUID v4 when:**
- You need a universally unique identifier
- Compatibility with existing UUID systems
- Don't need temporal ordering

**Use UUID v7 when:**
- You need sortable IDs by creation time
- Building time-series data structures
- Want better database indexing performance
- Need compatibility with UUID systems

**Use NanoID when:**
- You need compact, URL-friendly IDs
- Size matters (URLs, QR codes, UI display)
- Want customizable character set
- Need fast generation performance

### Security Considerations

1. **Don't use IDs as secrets**: IDs are unique but not secret
2. **Use secure generation**: Tool uses `Random.secure()` for all generation
3. **Avoid predictable alphabets**: For sensitive applications, use large alphabets
4. **Consider collision probability**: Use adequate ID length for your scale

### Database Integration

#### UUID v7 for Database Keys
- Excellent choice for primary keys
- Better indexing performance than UUID v4
- Maintains insertion order
- Compatible with UUID column types

#### NanoID for User-Facing IDs
- Shorter, more memorable
- Better for URLs and user interfaces
- Still collision-resistant with proper length

### Batch Generation Tips

1. **Use batch generation for efficiency**: Generating 1000 IDs at once is faster than 1000 separate calls
2. **Copy all for data import**: Use "Copy All" button for importing into databases or spreadsheets
3. **Test collision probability**: Use the calculator to ensure adequate ID length for your use case
4. **Consider alphabet size**: Larger alphabets provide better collision resistance

## API Reference

### UUID Generator

```dart
// Generate UUID v4
String uuid = UuidGenerator.generateV4();

// Generate UUID v7
String uuid = UuidGenerator.generateV7();

// Generate multiple UUIDs
List<String> uuids = UuidGenerator.generateMultiple(100);

// Validate UUID
bool isValid = UuidGenerator.isValid('550e8400-e29b-41d4-a716-446655440000');
```

### NanoID Generator

```dart
// Generate default NanoID (21 chars, URL-safe)
String id = NanoidGenerator.generate();

// Generate custom size
String id = NanoidGenerator.generateCustom(size: 12);

// Generate with custom alphabet
String id = NanoidGenerator.generateCustom(
  size: 8,
  alphabet: '0123456789ABCDEF',
);

// Generate multiple
List<String> ids = NanoidGenerator.generateMultiple(
  100,
  size: 21,
  alphabet: NanoidGenerator.defaultAlphabet,
);

// Presets
String numeric = NanoidGenerator.generateNumeric(size: 12);
String hex = NanoidGenerator.generateHex(size: 16);
String alphanumeric = NanoidGenerator.generateAlphanumeric();

// Calculate collision probability
String prob = NanoidGenerator.calculateCollisionProbability(21, 64);
```

## Troubleshooting

### Issue: "Alphabet must contain unique characters"
**Solution**: Ensure your custom alphabet has no duplicate characters.

### Issue: Generated IDs look similar
**Solution**: This is normal for small batches. The randomness is cryptographically secure, but patterns may appear in small samples.

### Issue: Need shorter IDs but worried about collisions
**Solution**: Use the collision probability calculator to find the right balance. Generally:
- 8 chars with 64-char alphabet: safe up to millions of IDs
- 12 chars with 62-char alphabet: safe up to billions of IDs
- 21 chars (default): safe up to quadrillions of IDs

### Issue: IDs not displaying in results
**Solution**: Check that batch count is at least 1 and click the "Generate" button.

## Testing

The ID Generator includes comprehensive tests:

### Unit Tests
- UUID v4 format validation
- UUID v7 format validation and sortability
- NanoID generation with various alphabets
- Custom alphabet validation
- Batch generation correctness
- Collision probability calculations

### Widget Tests
- Generator type selection
- Batch count controls
- NanoID customization options
- Copy functionality (individual and all)
- Clear functionality
- UI state management

### Integration Tests
- Large batch generation (1000 IDs)
- Performance validation
- Memory usage testing
- Uniqueness verification across large batches

## Related Tools

- **Text Tools**: For additional text manipulation
- **QR Maker**: Generate QR codes from your IDs
- **JSON Doctor**: Format ID collections as JSON

## Resources

- [RFC 4122 (UUID v4)](https://www.rfc-editor.org/rfc/rfc4122)
- [RFC 9562 (UUID v7)](https://www.rfc-editor.org/rfc/rfc9562.html)
- [NanoID](https://github.com/ai/nanoid)
- [Collision Probability Calculator](https://zelark.github.io/nano-id-cc/)

## Changelog

### Version 1.0.0 (Initial Release)
- UUID v4 generation
- UUID v7 generation with timestamp sorting
- NanoID generation with customizable size
- Custom alphabet support
- Batch generation up to 1000 IDs
- Copy individual and copy all functionality
- Collision probability calculator
- Alphabet presets (URL-Safe, Alphanumeric, Numbers, etc.)
- Material 3 UI with playful animations
