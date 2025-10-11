import 'dart:typed_data';

class AudioTranscriberService {
  /// Transcribes audio to text (mock implementation)
  Future<TranscriptionResult> transcribeAudio(
    Uint8List audioData,
    String fileName,
  ) async {
    // Simulate processing time based on file size
    final fileSizeMB = audioData.length / (1024 * 1024);
    final processingTimeSeconds = (fileSizeMB * 3).clamp(2, 30);
    await Future.delayed(Duration(seconds: processingTimeSeconds.round()));

    // Mock transcription
    if (audioData.isEmpty) {
      throw Exception('Audio file is empty');
    }

    // Generate mock transcript based on file size
    final transcript = _generateMockTranscript(fileSizeMB);

    // Estimate duration based on file size (rough approximation)
    final estimatedDurationMinutes = (fileSizeMB * 2).clamp(0.5, 120.0);
    final duration = Duration(
      minutes: estimatedDurationMinutes.floor(),
      seconds: ((estimatedDurationMinutes % 1) * 60).floor(),
    );

    return TranscriptionResult(
      transcript: transcript,
      duration: duration,
    );
  }

  /// Validates audio file format
  bool isValidAudioFormat(String fileName) {
    final supportedFormats = ['mp3', 'wav', 'm4a', 'ogg', 'flac'];
    final extension = fileName.toLowerCase().split('.').last;
    return supportedFormats.contains(extension);
  }

  /// Gets estimated processing time
  Duration getEstimatedProcessingTime(int fileSizeBytes) {
    final fileSizeMB = fileSizeBytes / (1024 * 1024);
    final estimatedSeconds = (fileSizeMB * 3).clamp(5, 300); // 3 seconds per MB
    return Duration(seconds: estimatedSeconds.round());
  }

  String _generateMockTranscript(double fileSizeMB) {
    final sentences = [
      "Welcome to our audio transcription service.",
      "This is a demonstration of how speech recognition technology works.",
      "The system processes your audio file and converts spoken words into accurate text.",
      "Our AI-powered transcription service supports multiple languages and accents.",
      "You can use this transcript for meeting notes, interviews, lectures, or any other audio content.",
      "The accuracy of transcription depends on audio quality, speaker clarity, and background noise levels.",
      "For best results, ensure your audio is recorded in a quiet environment with clear speech.",
      "This technology uses advanced machine learning models to understand natural language patterns.",
      "The transcription includes proper punctuation and formatting for readability.",
      "You can download the transcript as a text file or copy it to your clipboard.",
      "Our service maintains the privacy and security of your audio content throughout the process.",
      "Thank you for using our audio transcription tool.",
    ];

    final numSentences = (fileSizeMB * 4).clamp(3, sentences.length).round();

    final selectedSentences = <String>[];
    for (int i = 0; i < numSentences; i++) {
      selectedSentences.add(sentences[i % sentences.length]);
    }

    return selectedSentences.join(' ');
  }
}

class TranscriptionResult {
  final String transcript;
  final Duration duration;

  const TranscriptionResult({
    required this.transcript,
    required this.duration,
  });
}
