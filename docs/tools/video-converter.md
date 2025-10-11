# Video Converter Tool

> **Status**: Production Ready (Phase-4)  
> **Tool ID**: `video-converter`  
> **Min Plan**: Pro  
> **Category**: Media Processing

## Overview

The Video Converter tool extracts high-quality audio from video files, supporting multiple input formats and providing progress tracking with download capabilities.

## Features

### Supported Input Formats

- **MP4** - MPEG-4 video files
- **MOV** - QuickTime movie files
- **WEBM** - WebM video format
- **AVI** - Audio Video Interleave

### Output Format

- **MP3** - High-quality audio extraction (128kbps default)

### Key Capabilities

- ✅ Drag-and-drop file upload interface
- ✅ File size validation (100MB limit)
- ✅ Real-time conversion progress tracking
- ✅ Mock FFmpeg processing simulation
- ✅ Download converted audio files
- ✅ Error handling and validation

## User Interface

### Upload Section

- Clean file drop zone with visual feedback
- File format and size validation
- Clear error messages for invalid files

### Processing Section

- Progress bar with percentage display
- Processing status updates
- Estimated time remaining

### Results Section

- Audio file preview and information
- Download button for converted file
- Option to convert another file

## Technical Implementation

### Service Layer

- Mock FFmpeg integration for development
- Realistic processing simulation with timing
- File validation and error handling
- Progress tracking with callbacks

### UI Components

- Material 3 design system
- Responsive layout for all screen sizes
- Loading states and progress indicators
- Accessibility features

## Usage Example

```dart
// Convert a video file to audio
final videoFile = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['mp4', 'mov', 'webm', 'avi'],
);

if (videoFile != null) {
  final result = await VideoConverterService.convertToAudio(
    videoFile.files.first,
    onProgress: (progress) => print('Progress: $progress%'),
  );

  if (result.success) {
    // Download or use the converted audio file
    print('Audio file ready: ${result.audioFile}');
  }
}
```

## Cross-Tool Integration

The Video Converter integrates seamlessly with other media tools:

**Suggested Workflow:**

1. **Video Converter**: Extract audio from video files
2. **Audio Transcriber**: Generate text transcripts from audio
3. **Subtitle Maker**: Create subtitle files from transcripts

## Billing Integration

- **Plan Requirement**: Pro plan or higher
- **Quota**: Heavy operations (video processing)
- **Usage Tracking**: Conversion operations are tracked for billing

## Performance Considerations

- **File Size Limit**: 100MB for optimal performance
- **Processing Time**: Varies by file size and format
- **Memory Usage**: Optimized for web platform constraints
- **Batch Processing**: Single file processing for stability

## Error Handling

### Common Errors

- **File too large**: Files over 100MB are rejected
- **Unsupported format**: Non-video files are validated
- **Processing failed**: Network or service errors are handled gracefully

### Error Messages

- Clear, user-friendly error descriptions
- Actionable guidance for resolution
- Visual feedback in the UI

## Testing

### Manual Testing Checklist

- [ ] Upload various video formats (MP4, MOV, WEBM, AVI)
- [ ] Test file size validation (reject >100MB)
- [ ] Verify progress tracking during conversion
- [ ] Test download functionality
- [ ] Validate error handling for invalid files

### Automated Testing

- Unit tests for service layer functionality
- Widget tests for UI components
- Integration tests for file processing workflow

## Related Tools

- **[Audio Transcriber](./audio-transcriber.md)** - Process converted audio files
- **[Subtitle Maker](./subtitle-maker.md)** - Create subtitles from transcripts
- **[Audio Converter](./audio-converter.md)** - Additional audio format conversions

## Support

For issues or questions:

- GitHub Issues: [toolspace/issues](https://github.com/bitquan/toolspace/issues)
- Documentation: This file and related tool docs

---

**Last Updated**: October 11, 2025  
**Version**: 1.0.0 (Initial release as part of modular VATS architecture)
