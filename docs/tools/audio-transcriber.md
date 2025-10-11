# Audio Transcriber Tool

> **Status**: Production Ready (Phase-4)  
> **Tool ID**: `audio-transcriber`  
> **Min Plan**: Pro  
> **Category**: Media Processing

## Overview

The Audio Transcriber tool converts speech in audio files to accurate text transcripts using AI-powered speech recognition, with support for multiple audio formats and clipboard integration.

## Features

### Supported Input Formats

- **MP3** - MPEG Audio Layer III
- **WAV** - Waveform Audio File Format
- **M4A** - MPEG-4 Audio
- **OGG** - Ogg Vorbis audio format

### Output Format

- **Plain Text** - Clean, formatted transcripts
- **Paragraph Structure** - Intelligent sentence grouping
- **Clipboard Ready** - One-click copy functionality

### Key Capabilities

- ✅ Dual-panel interface (input/output side-by-side)
- ✅ File size validation (50MB limit)
- ✅ Mock AI transcription with realistic output
- ✅ Real-time progress tracking
- ✅ Clipboard integration for easy copying
- ✅ Error handling and validation

## User Interface

### Split-Panel Design

- **Left Panel**: Audio file upload and controls
- **Right Panel**: Generated transcript display
- Responsive layout adapts to screen size

### Upload Section

- Drag-and-drop audio file interface
- File format and size validation
- Audio file information display

### Transcription Section

- Real-time progress indicator
- Generated transcript with formatting
- Copy to clipboard functionality
- Clear/reset options

## Technical Implementation

### Service Layer

- Mock Whisper API integration for development
- Realistic transcription simulation
- Intelligent paragraph generation
- Progress tracking with status updates

### AI Simulation

- Generates realistic transcript content
- Includes natural speech patterns
- Simulates processing delays
- Provides confidence metrics

## Usage Example

```dart
// Transcribe an audio file
final audioFile = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['mp3', 'wav', 'm4a', 'ogg'],
);

if (audioFile != null) {
  final result = await AudioTranscriberService.transcribeAudio(
    audioFile.files.first,
    onProgress: (progress) => print('Transcribing: $progress%'),
  );

  if (result.success) {
    print('Transcript: ${result.transcript}');
    // Copy to clipboard or use in other tools
  }
}
```

## Cross-Tool Integration

The Audio Transcriber integrates seamlessly with other media tools:

**Suggested Workflow:**

1. **Video Converter**: Extract audio from video files
2. **Audio Transcriber**: Generate text transcripts from audio ← You are here
3. **Subtitle Maker**: Create subtitle files from transcripts

**Data Sharing:**

- Transcripts can be copied to clipboard
- Integration with ShareEnvelope system for cross-tool data transfer
- Direct workflow from audio to subtitle generation

## Billing Integration

- **Plan Requirement**: Pro plan or higher
- **Quota**: Heavy operations (AI transcription)
- **Usage Tracking**: Transcription operations are tracked for billing
- **Cost Consideration**: AI processing is resource-intensive

## Performance Considerations

- **File Size Limit**: 50MB for optimal performance
- **Processing Time**: Varies by audio length and quality
- **Memory Usage**: Optimized for web platform constraints
- **Audio Quality**: Higher quality audio produces better transcripts

## Error Handling

### Common Errors

- **File too large**: Files over 50MB are rejected
- **Unsupported format**: Non-audio files are validated
- **Processing failed**: Network or service errors are handled gracefully
- **No speech detected**: Silent or music-only files

### Error Messages

- Clear, user-friendly error descriptions
- Actionable guidance for resolution
- Visual feedback in the UI
- Retry options where appropriate

## Transcription Quality

### Factors Affecting Accuracy

- **Audio Quality**: Clear audio produces better results
- **Speaker Clarity**: Single speaker vs. multiple speakers
- **Background Noise**: Minimal noise improves accuracy
- **Language**: Optimized for English speech

### Best Practices

- Use high-quality audio recordings
- Minimize background noise
- Ensure clear speech articulation
- Split long recordings for better processing

## Testing

### Manual Testing Checklist

- [ ] Upload various audio formats (MP3, WAV, M4A, OGG)
- [ ] Test file size validation (reject >50MB)
- [ ] Verify transcription progress tracking
- [ ] Test clipboard copy functionality
- [ ] Validate error handling for invalid files
- [ ] Test with different audio qualities

### Automated Testing

- Unit tests for service layer functionality
- Widget tests for dual-panel UI
- Integration tests for transcription workflow
- Mock API response testing

## Related Tools

- **[Video Converter](./video-converter.md)** - Extract audio from video files
- **[Subtitle Maker](./subtitle-maker.md)** - Create subtitles from transcripts
- **[Audio Converter](./audio-converter.md)** - Convert between audio formats

## API Reference

### AudioTranscriberService

```dart
class AudioTranscriberService {
  /// Transcribe audio file to text
  static Future<TranscriptionResult> transcribeAudio(
    PlatformFile audioFile, {
    void Function(int progress)? onProgress,
  });

  /// Validate audio file format and size
  static bool isValidAudioFile(PlatformFile file);
}

class TranscriptionResult {
  final bool success;
  final String transcript;
  final String? error;
  final double confidence;
}
```

## Support

For issues or questions:

- GitHub Issues: [toolspace/issues](https://github.com/bitquan/toolspace/issues)
- Documentation: This file and related tool docs

---

**Last Updated**: October 11, 2025  
**Version**: 1.0.0 (Initial release as part of modular VATS architecture)
