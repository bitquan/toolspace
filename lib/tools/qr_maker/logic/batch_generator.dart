/// Result of a batch QR code generation
class QrBatchResult {
  final bool success;
  final List<QrCodeData> qrCodes;
  final String? error;
  final int totalGenerated;

  const QrBatchResult({
    required this.success,
    required this.qrCodes,
    this.error,
    required this.totalGenerated,
  });
}

/// Individual QR code data
class QrCodeData {
  final String id;
  final String data;
  final String type;
  final Map<String, dynamic>? metadata;

  const QrCodeData({
    required this.id,
    required this.data,
    required this.type,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'data': data,
        'type': type,
        'metadata': metadata,
      };
}

/// Batch QR code generator
class QrBatchGenerator {
  /// Generate multiple QR codes from a list of data
  static QrBatchResult generateBatch(
    List<String> dataList, {
    String type = 'text',
    Map<String, dynamic>? commonMetadata,
  }) {
    try {
      if (dataList.isEmpty) {
        return QrBatchResult(
          success: false,
          qrCodes: [],
          error: 'No data provided',
          totalGenerated: 0,
        );
      }

      final qrCodes = <QrCodeData>[];
      for (int i = 0; i < dataList.length; i++) {
        final data = dataList[i].trim();
        if (data.isEmpty) continue;

        qrCodes.add(QrCodeData(
          id: 'qr_${i + 1}_${DateTime.now().millisecondsSinceEpoch}',
          data: data,
          type: type,
          metadata: commonMetadata,
        ));
      }

      return QrBatchResult(
        success: true,
        qrCodes: qrCodes,
        totalGenerated: qrCodes.length,
      );
    } catch (e) {
      return QrBatchResult(
        success: false,
        qrCodes: [],
        error: e.toString(),
        totalGenerated: 0,
      );
    }
  }

  /// Generate QR codes from CSV data
  static QrBatchResult generateFromCsv(
    String csvContent, {
    int dataColumnIndex = 0,
    bool hasHeader = true,
    String type = 'text',
  }) {
    try {
      final lines = csvContent.split('\n').where((l) => l.trim().isNotEmpty);
      final dataList = <String>[];

      for (int i = 0; i < lines.length; i++) {
        if (hasHeader && i == 0) continue;

        final line = lines.elementAt(i);
        final columns = _parseCsvLine(line);

        if (columns.length > dataColumnIndex) {
          dataList.add(columns[dataColumnIndex]);
        }
      }

      return generateBatch(dataList, type: type);
    } catch (e) {
      return QrBatchResult(
        success: false,
        qrCodes: [],
        error: 'CSV parsing error: ${e.toString()}',
        totalGenerated: 0,
      );
    }
  }

  /// Generate QR codes with sequential numbering
  static QrBatchResult generateSequential({
    required String prefix,
    required int count,
    int startNumber = 1,
    String? suffix,
    String type = 'text',
  }) {
    try {
      if (count <= 0) {
        return QrBatchResult(
          success: false,
          qrCodes: [],
          error: 'Count must be greater than 0',
          totalGenerated: 0,
        );
      }

      if (count > 1000) {
        return QrBatchResult(
          success: false,
          qrCodes: [],
          error: 'Maximum count is 1000',
          totalGenerated: 0,
        );
      }

      final dataList = <String>[];
      for (int i = 0; i < count; i++) {
        final number = startNumber + i;
        final data = '$prefix$number${suffix ?? ''}';
        dataList.add(data);
      }

      return generateBatch(dataList, type: type);
    } catch (e) {
      return QrBatchResult(
        success: false,
        qrCodes: [],
        error: e.toString(),
        totalGenerated: 0,
      );
    }
  }

  /// Generate QR codes from a template
  static QrBatchResult generateFromTemplate({
    required String template,
    required Map<String, List<String>> variables,
    String type = 'text',
  }) {
    try {
      // Find all variables in template (format: {{variable}})
      final variablePattern = RegExp(r'\{\{(\w+)\}\}');
      final matches = variablePattern.allMatches(template);

      if (matches.isEmpty) {
        return QrBatchResult(
          success: false,
          qrCodes: [],
          error: 'No variables found in template',
          totalGenerated: 0,
        );
      }

      // Get the first variable to determine count
      final firstMatch = matches.first;
      final firstVar = firstMatch.group(1)!;

      if (!variables.containsKey(firstVar)) {
        return QrBatchResult(
          success: false,
          qrCodes: [],
          error: 'Variable "$firstVar" not provided',
          totalGenerated: 0,
        );
      }

      final count = variables[firstVar]!.length;
      final dataList = <String>[];

      for (int i = 0; i < count; i++) {
        String data = template;
        for (final match in matches) {
          final varName = match.group(1)!;
          if (variables.containsKey(varName) &&
              i < variables[varName]!.length) {
            data = data.replaceAll('{{$varName}}', variables[varName]![i]);
          }
        }
        dataList.add(data);
      }

      return generateBatch(dataList, type: type);
    } catch (e) {
      return QrBatchResult(
        success: false,
        qrCodes: [],
        error: e.toString(),
        totalGenerated: 0,
      );
    }
  }

  /// Parse a CSV line handling quoted fields
  static List<String> _parseCsvLine(String line) {
    final List<String> fields = [];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        fields.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    if (buffer.isNotEmpty) {
      fields.add(buffer.toString().trim());
    }

    return fields;
  }

  /// Export batch results to JSON
  static String exportToJson(QrBatchResult result) {
    if (!result.success || result.qrCodes.isEmpty) {
      return '{"success": false, "error": "${result.error}"}';
    }

    final buffer = StringBuffer();
    buffer.write('{\n');
    buffer.write('  "success": true,\n');
    buffer.write('  "totalGenerated": ${result.totalGenerated},\n');
    buffer.write('  "qrCodes": [\n');

    for (int i = 0; i < result.qrCodes.length; i++) {
      final qr = result.qrCodes[i];
      buffer.write('    {\n');
      buffer.write('      "id": "${qr.id}",\n');
      buffer.write('      "data": "${_escapeJson(qr.data)}",\n');
      buffer.write('      "type": "${qr.type}"\n');
      buffer.write('    }');
      if (i < result.qrCodes.length - 1) {
        buffer.write(',');
      }
      buffer.write('\n');
    }

    buffer.write('  ]\n');
    buffer.write('}\n');

    return buffer.toString();
  }

  /// Escape JSON special characters
  static String _escapeJson(String value) {
    return value
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }

  /// Get batch generation statistics
  static Map<String, dynamic> getBatchStats(QrBatchResult result) {
    if (!result.success) {
      return {
        'success': false,
        'error': result.error,
      };
    }

    final types = <String, int>{};
    for (final qr in result.qrCodes) {
      types[qr.type] = (types[qr.type] ?? 0) + 1;
    }

    return {
      'success': true,
      'totalGenerated': result.totalGenerated,
      'typeBreakdown': types,
      'avgDataLength': result.qrCodes.isEmpty
          ? 0
          : result.qrCodes.map((qr) => qr.data.length).reduce((a, b) => a + b) /
              result.qrCodes.length,
    };
  }
}
