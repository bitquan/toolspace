# Subtitle Maker Tool

> **Status**: Production Ready (Phase-4)  
> **Tool ID**: `subtitle-maker`  
> **Min Plan**: Free  
> **Category**: Media Processing

## Overview

The Subtitle Maker tool converts text transcripts into formatted subtitle files supporting both SRT and VTT formats, with real-time preview and editing capabilities.

## Features

### Supported Output Formats

- **SRT** - SubRip Text format (most widely supported)
- **VTT** - WebVTT format (web-optimized captions)

### Input Support

- **Plain Text** - Paste or type transcript content
- **Multi-line Text** - Automatic sentence detection
- **Clipboard Integration** - Easy paste from other tools

### Key Capabilities

- ✅ Real-time subtitle preview with timecode
- ✅ Format switching between SRT and VTT
- ✅ Automatic sentence parsing and timing
- ✅ Copy to clipboard functionality
- ✅ Download subtitle files
- ✅ Clean, professional formatting

## User Interface

### Input Section

- Large text area for transcript input
- Character count and validation
- Clear/reset functionality
- Paste from clipboard support

### Format Selection

- Toggle between SRT and VTT formats
- Visual format indicators
- Real-time format conversion

### Preview Section

- Live preview of generated subtitles
- Proper timecode formatting
- Scrollable subtitle display
- Copy and download buttons

## Technical Implementation

### Service Layer

- Intelligent sentence parsing
- Automatic timing calculation
- SRT and VTT format generation
- Text validation and cleaning

### Subtitle Generation

- **Timing**: 3-second duration per subtitle
- **Parsing**: Sentence-based splitting
- **Formatting**: Professional subtitle standards
- **Validation**: Text length and content checks

## Usage Example

```dart
// Generate subtitles from transcript text
final transcript = "Hello world. This is a sample transcript. "
                  "It will be converted to subtitles.";

final result = SubtitleMakerService.generateSubtitles(transcript);

print('SRT Format:');
print(result.srtContent);

print('VTT Format:');
print(result.vttContent);
```

### Example Output

**SRT Format:**

```
1
00:00:00,000 --> 00:00:03,000
Hello world.

2
00:00:03,000 --> 00:00:06,000
This is a sample transcript.

3
00:00:06,000 --> 00:00:09,000
It will be converted to subtitles.
```

**VTT Format:**

```
WEBVTT

00:00:00.000 --> 00:00:03.000
Hello world.

00:00:03.000 --> 00:00:06.000
This is a sample transcript.

00:00:06.000 --> 00:00:09.000
It will be converted to subtitles.
```

## Cross-Tool Integration

The Subtitle Maker completes the media processing pipeline:

**Complete Workflow:**

1. **Video Converter**: Extract audio from video files
2. **Audio Transcriber**: Generate text transcripts from audio
3. **Subtitle Maker**: Create subtitle files from transcripts ← You are here

**Data Sources:**

- Manual text input
- Clipboard content from Audio Transcriber
- Cross-tool data sharing via ShareEnvelope

## Format Specifications

### SRT Format Features

- **Numbering**: Sequential subtitle numbers
- **Timecode**: `HH:MM:SS,mmm --> HH:MM:SS,mmm` format
- **Text**: Plain text with line breaks
- **Compatibility**: Universal video player support

### VTT Format Features

- **Header**: `WEBVTT` declaration
- **Timecode**: `HH:MM:SS.mmm --> HH:MM:SS.mmm` format
- **Text**: Rich text support with styling
- **Web Optimized**: HTML5 video element support

## Performance Considerations

- **Text Processing**: Instant subtitle generation
- **Memory Usage**: Minimal resource requirements
- **File Size**: Compact subtitle file output
- **Browser Support**: Works across all modern browsers

## Error Handling

### Input Validation

- **Empty Text**: Prevents generation with no content
- **Long Text**: Handles large transcript inputs
- **Special Characters**: Properly escapes subtitle text
- **Format Errors**: Validates subtitle structure

### Error Messages

- Clear feedback for invalid inputs
- Guidance for text formatting
- Visual indicators for processing status

## Testing

### Manual Testing Checklist

- [ ] Input various text lengths and formats
- [ ] Test SRT format generation and download
- [ ] Test VTT format generation and download
- [ ] Verify clipboard copy functionality
- [ ] Test format switching with live preview
- [ ] Validate with empty and invalid inputs

### Automated Testing

- Unit tests for subtitle generation logic
- Widget tests for UI components
- Format validation tests
- Cross-browser compatibility tests

## Related Tools

- **[Video Converter](./video-converter.md)** - Extract audio from video files
- **[Audio Transcriber](./audio-transcriber.md)** - Generate text transcripts
- **[Text Tools](./text-tools.md)** - Additional text processing utilities

## API Reference

### SubtitleMakerService

```dart
class SubtitleMakerService {
  /// Generate subtitles from transcript text
  static SubtitleResult generateSubtitles(String transcript);

  /// Validate transcript text
  static bool isValidTranscript(String text);

  /// Parse text into sentences
  static List<String> parseSentences(String text);
}

class SubtitleResult {
  final String srtContent;
  final String vttContent;
  final int subtitleCount;
  final Duration totalDuration;
}
```

## Best Practices

### Transcript Formatting

- Use clear, complete sentences
- Avoid extremely long sentences
- Include proper punctuation
- Remove filler words and stutters

### Subtitle Guidelines

- Keep subtitles concise and readable
- Aim for 1-2 lines per subtitle
- Ensure proper timing synchronization
- Test with actual video content

## Accessibility Features

- **Screen Reader Support**: Proper ARIA labels
- **Keyboard Navigation**: Full keyboard accessibility
- **High Contrast**: Clear visual hierarchy
- **Text Scaling**: Responsive font sizing

## Support

For issues or questions:

- GitHub Issues: [toolspace/issues](https://github.com/bitquan/toolspace/issues)
- Documentation: This file and related tool docs

---

**Last Updated**: October 11, 2025  
**Version**: 1.0.0 (Initial release as part of modular VATS architecture)
