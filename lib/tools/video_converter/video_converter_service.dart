import 'dart:math';
import 'dart:typed_data';

class VideoConverterService {
  /// Converts video to audio (mock implementation)
  Future<ConversionResult> convertVideoToAudio(
    Uint8List videoData,
    String fileName,
  ) async {
    // Simulate processing time
    await Future.delayed(const Duration(seconds: 2));

    // Mock video processing
    if (videoData.isEmpty) {
      throw Exception('Video file is empty');
    }

    // Simulate different video lengths based on file size
    final fileSizeMB = videoData.length / (1024 * 1024);
    final estimatedDurationMinutes = (fileSizeMB * 0.5).clamp(0.5, 60.0);
    final duration = Duration(
      minutes: estimatedDurationMinutes.floor(),
      seconds: ((estimatedDurationMinutes % 1) * 60).floor(),
    );

    // Generate mock audio URL
    final audioUrl = 'mock://audio/${DateTime.now().millisecondsSinceEpoch}.mp3';

    return ConversionResult(
      audioUrl: audioUrl,
      duration: duration,
    );
  }

  /// Gets audio bytes for download (mock implementation)
  Future<Uint8List> getAudioBytes(String audioUrl) async {
    // Simulate download delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Generate mock audio data
    final random = Random();
    const audioSize = 1024 * 1024; // 1MB mock audio
    final audioBytes = Uint8List(audioSize);

    for (int i = 0; i < audioSize; i++) {
      audioBytes[i] = random.nextInt(256);
    }

    return audioBytes;
  }

  /// Validates video file format
  bool isValidVideoFormat(String fileName) {
    final supportedFormats = ['mp4', 'mov', 'webm', 'avi', 'mkv'];
    final extension = fileName.toLowerCase().split('.').last;
    return supportedFormats.contains(extension);
  }

  /// Gets estimated processing time
  Duration getEstimatedProcessingTime(int fileSizeBytes) {
    final fileSizeMB = fileSizeBytes / (1024 * 1024);
    final estimatedSeconds = (fileSizeMB * 2).clamp(5, 300); // 2 seconds per MB
    return Duration(seconds: estimatedSeconds.round());
  }
}

class ConversionResult {
  final String audioUrl;
  final Duration duration;

  const ConversionResult({
    required this.audioUrl,
    required this.duration,
  });
}
