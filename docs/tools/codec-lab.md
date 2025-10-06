# Codec Lab - Base64/Hex/URL Encoder-Decoder

**Route**: /tools/codec-lab  
**Status**: ✅ Active  
**Version**: 1.0.0

## Overview

Codec Lab is a powerful, client-side encoding and decoding tool that supports Base64, Hexadecimal, and URL encoding formats. It provides both text and file processing capabilities with an intuitive Material 3 interface.

## Features

### Text Mode
- **Multiple Format Support**: Base64, Hexadecimal, and URL encoding
- **Bidirectional Conversion**: Encode and decode with a single click
- **Real-time Processing**: Instant conversion as you type
- **Auto-Detection**: Automatically detect the format of encoded text
- **Swap Functionality**: Quickly swap input and output
- **Clear Error Messages**: Helpful validation messages for invalid input
- **Copy to Clipboard**: One-click copy of results

### File Mode
- **File Encoding**: Encode files to Base64 or Hex
- **File Decoding**: Decode Base64/Hex back to files
- **Progress Indicators**: Visual feedback for file processing
- **Streaming Support**: Efficient handling of large files
- **Download Support**: Save decoded files

## Usage

### Encoding Text

1. Select the **Text Mode** tab
2. Choose your desired format (Base64, Hex, or URL)
3. Ensure **Encode** is selected
4. Enter your text in the input field
5. The encoded result appears instantly in the output field
6. Click the copy button to copy the result

### Decoding Text

1. Select the **Text Mode** tab
2. Choose the format of your encoded text
3. Select **Decode** mode
4. Paste your encoded text in the input field
5. The decoded result appears in the output field
6. Use **Auto-detect** if you're unsure of the format

### Encoding Files

1. Select the **File Mode** tab
2. Choose Base64 or Hex format
3. Ensure **Encode File** is selected
4. Click to upload a file
5. Click **Encode File** button
6. Copy the encoded output

### Decoding Files

1. Select the **File Mode** tab
2. Choose the format (Base64 or Hex)
3. Select **Decode to File**
4. Paste the encoded data
5. Click **Decode to File**
6. The decoded data will be prepared for download

## Supported Formats

### Base64
- **Standard Base64**: RFC 4648 compliant
- **Whitespace Handling**: Automatically removes whitespace
- **Padding**: Proper = padding support
- **Use Cases**: Email attachments, data URLs, API communication

### Hexadecimal
- **Case Insensitive**: Handles both uppercase and lowercase
- **Flexible Separators**: Supports `:`, `-`, ` `, and `,` separators
- **Even Length Validation**: Ensures valid hex pairs
- **Use Cases**: Binary data inspection, color codes, checksums

### URL Encoding
- **Percent Encoding**: RFC 3986 compliant
- **Special Character Handling**: Properly encodes reserved characters
- **Unicode Support**: Full UTF-8 character support
- **Use Cases**: Query parameters, URL-safe strings, form data

## Technical Details

### Architecture
- **Client-Side Only**: All processing happens in your browser
- **No Server Required**: Complete privacy - no data leaves your device
- **Streaming Processing**: Efficient handling of large files
- **Zero Dependencies**: Uses Dart's built-in encoding libraries

### Validation
- **Format Detection**: Automatic detection of Base64, Hex, and URL encoding
- **Input Validation**: Real-time validation with clear error messages
- **Roundtrip Testing**: All conversions are tested for accuracy

### Performance
- **Real-time Processing**: Sub-millisecond conversion for typical text
- **Efficient Memory Usage**: Streaming approach for large files
- **Progressive UI**: Progress indicators for long operations

## Error Handling

### Common Errors

**Invalid Base64**
- Error: "Invalid Base64 input"
- Solution: Ensure the string uses valid Base64 characters (A-Z, a-z, 0-9, +, /, =)

**Invalid Hexadecimal**
- Error: "Invalid hexadecimal characters" or "Hex string must have even length"
- Solution: Use only hex digits (0-9, A-F) and ensure even length

**Invalid URL Encoding**
- Error: "Invalid URL encoded input"
- Solution: Check percent signs are followed by two hex digits

## Privacy & Security

- **100% Client-Side**: All encoding/decoding happens in your browser
- **No Data Transmission**: Nothing is sent to any server
- **No Storage**: Data is not saved or logged anywhere
- **Safe Processing**: Input is validated before processing

## Browser Compatibility

- ✅ Chrome 90+
- ✅ Firefox 88+
- ✅ Safari 14+
- ✅ Edge 90+

## Keyboard Shortcuts

- `Ctrl/Cmd + V`: Paste into input
- `Ctrl/Cmd + C`: Copy from output (when focused)
- `Ctrl/Cmd + A`: Select all text in field

## Tips & Tricks

1. **Quick Format Detection**: Use the Auto-detect button to automatically identify the encoding format
2. **Swap Direction**: Use the swap button to quickly reverse input and output
3. **Large Files**: File mode supports streaming for efficient processing
4. **Copy Results**: Click the clipboard icon to instantly copy results
5. **Clear Data**: Use the Clear button to reset both input and output

## Use Cases

### For Developers
- Encode/decode API tokens
- Debug Base64 encoded data
- Convert binary data to hex
- URL-safe string generation

### For System Administrators
- Inspect encoded configuration files
- Decode log entries
- Convert certificate data
- Process encoded credentials

### For Data Analysts
- Decode data URLs
- Process encoded datasets
- Convert binary formats
- Validate encoded data

## Testing

The Codec Lab includes comprehensive test coverage:

- **Unit Tests**: 100+ tests for encoding/decoding logic
- **Widget Tests**: UI component testing
- **Integration Tests**: End-to-end conversion testing
- **Roundtrip Tests**: Verify encoding/decoding accuracy

## Changelog

### Version 1.0.0 (2024)
- Initial release
- Base64, Hex, and URL encoding support
- Text and file processing modes
- Auto-format detection
- Real-time conversion
- Material 3 UI with playful theme
- Comprehensive test coverage

## Support

For issues, feature requests, or questions:
- Open an issue on GitHub
- Contact the development team
- Check the documentation

## Related Tools

- **Text Tools**: Additional text manipulation utilities
- **JSON Doctor**: JSON validation and formatting
- **Text Diff**: Compare text differences

---

**Last Updated**: 2024  
**Maintainer**: Toolspace Team
