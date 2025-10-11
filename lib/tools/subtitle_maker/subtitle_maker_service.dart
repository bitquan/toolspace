class SubtitleMakerService {
  /// Generates subtitle files from transcript text
  SubtitleResult generateSubtitles(String transcript) {
    if (transcript.trim().isEmpty) {
      throw Exception('Transcript cannot be empty');
    }

    // Split transcript into sentences
    final sentences = _splitIntoSentences(transcript);

    // Generate SRT content
    final srtContent = _generateSRT(sentences);

    // Generate VTT content
    final vttContent = _generateVTT(sentences);

    return SubtitleResult(
      srtContent: srtContent,
      vttContent: vttContent,
    );
  }

  List<String> _splitIntoSentences(String transcript) {
    // Split by sentence endings and clean up
    final sentences = transcript
        .split(RegExp(r'[.!?]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // If no sentence markers found, split by line breaks
    if (sentences.length == 1) {
      return transcript.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }

    return sentences;
  }

  String _generateSRT(List<String> sentences) {
    final buffer = StringBuffer();

    for (int i = 0; i < sentences.length; i++) {
      final startTime = _formatSRTTime(Duration(seconds: i * 3));
      final endTime = _formatSRTTime(Duration(seconds: (i + 1) * 3));

      buffer.writeln(i + 1);
      buffer.writeln('$startTime --> $endTime');
      buffer.writeln(sentences[i]);
      buffer.writeln();
    }

    return buffer.toString();
  }

  String _generateVTT(List<String> sentences) {
    final buffer = StringBuffer();
    buffer.writeln('WEBVTT');
    buffer.writeln();

    for (int i = 0; i < sentences.length; i++) {
      final startTime = _formatVTTTime(Duration(seconds: i * 3));
      final endTime = _formatVTTTime(Duration(seconds: (i + 1) * 3));

      buffer.writeln('$startTime --> $endTime');
      buffer.writeln(sentences[i]);
      buffer.writeln();
    }

    return buffer.toString();
  }

  String _formatSRTTime(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final milliseconds = (duration.inMilliseconds % 1000).toString().padLeft(3, '0');
    return '$hours:$minutes:$seconds,$milliseconds';
  }

  String _formatVTTTime(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final milliseconds = (duration.inMilliseconds % 1000).toString().padLeft(3, '0');
    return '$hours:$minutes:$seconds.$milliseconds';
  }

  /// Validates subtitle format
  bool isValidSubtitleFormat(String format) {
    final supportedFormats = ['srt', 'vtt', 'ass', 'ssa'];
    return supportedFormats.contains(format.toLowerCase());
  }
}

class SubtitleResult {
  final String srtContent;
  final String vttContent;

  const SubtitleResult({
    required this.srtContent,
    required this.vttContent,
  });
}
