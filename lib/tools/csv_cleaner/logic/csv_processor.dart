/// CSV processing utilities for cleaning and manipulating CSV data
class CsvProcessor {
  /// Parse CSV string into a list of rows (each row is a list of cells)
  static List<List<String>> parseCsv(String csvContent) {
    if (csvContent.trim().isEmpty) {
      return [];
    }

    final lines = csvContent.split('\n');
    final List<List<String>> rows = [];

    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      
      // Simple CSV parsing (handles basic comma-separated values)
      // For production, consider using a proper CSV library
      final cells = _parseCsvLine(line);
      rows.add(cells);
    }

    return rows;
  }

  /// Parse a single CSV line, handling quoted values
  static List<String> _parseCsvLine(String line) {
    final List<String> cells = [];
    final buffer = StringBuffer();
    bool inQuotes = false;
    
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      
      if (char == '"') {
        // Handle escaped quotes
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++; // Skip next quote
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        cells.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    
    // Add the last cell
    cells.add(buffer.toString());
    
    return cells;
  }

  /// Convert rows back to CSV string
  static String toCsv(List<List<String>> rows) {
    if (rows.isEmpty) return '';

    final buffer = StringBuffer();
    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      final escapedCells = row.map((cell) => _escapeCsvCell(cell));
      buffer.write(escapedCells.join(','));
      if (i < rows.length - 1) {
        buffer.write('\n');
      }
    }

    return buffer.toString();
  }

  /// Escape a CSV cell (add quotes if needed)
  static String _escapeCsvCell(String cell) {
    // Add quotes if the cell contains comma, newline, or quotes
    if (cell.contains(',') || cell.contains('\n') || cell.contains('"')) {
      // Escape quotes by doubling them
      final escaped = cell.replaceAll('"', '""');
      return '"$escaped"';
    }
    return cell;
  }

  /// Trim whitespace from all cells
  static List<List<String>> trimWhitespace(List<List<String>> rows) {
    return rows.map((row) => row.map((cell) => cell.trim()).toList()).toList();
  }

  /// Lowercase headers (first row)
  static List<List<String>> lowercaseHeaders(List<List<String>> rows) {
    if (rows.isEmpty) return rows;

    final result = List<List<String>>.from(rows);
    result[0] = result[0].map((header) => header.toLowerCase()).toList();
    return result;
  }

  /// Remove duplicate rows
  /// If keyColumnIndex is provided, only considers that column for uniqueness
  /// If keyColumnIndex is null, considers the entire row
  static List<List<String>> removeDuplicates(
    List<List<String>> rows, {
    int? keyColumnIndex,
  }) {
    if (rows.isEmpty) return rows;

    final seen = <String>{};
    final result = <List<String>>[];

    for (final row in rows) {
      String key;
      
      if (keyColumnIndex != null && keyColumnIndex < row.length) {
        // Use specific column as key
        key = row[keyColumnIndex];
      } else {
        // Use entire row as key
        key = row.join('|');
      }

      if (!seen.contains(key)) {
        seen.add(key);
        result.add(row);
      }
    }

    return result;
  }

  /// Get column names (headers) from the first row
  static List<String> getHeaders(List<List<String>> rows) {
    if (rows.isEmpty) return [];
    return rows[0];
  }

  /// Apply all cleaning operations
  static List<List<String>> cleanAll(
    List<List<String>> rows, {
    bool trimWhitespace = true,
    bool lowercaseHeaders = true,
    int? dedupeKeyColumn,
  }) {
    var result = rows;

    if (trimWhitespace) {
      result = CsvProcessor.trimWhitespace(result);
    }

    if (lowercaseHeaders) {
      result = CsvProcessor.lowercaseHeaders(result);
    }

    if (dedupeKeyColumn != null) {
      // -1 means dedupe by entire row
      result = removeDuplicates(
        result,
        keyColumnIndex: dedupeKeyColumn == -1 ? null : dedupeKeyColumn,
      );
    }

    return result;
  }

  /// Validate CSV data
  static CsvValidationResult validate(List<List<String>> rows) {
    if (rows.isEmpty) {
      return CsvValidationResult(
        isValid: false,
        error: 'CSV is empty',
      );
    }

    // Check if all rows have the same number of columns
    final columnCount = rows[0].length;
    for (int i = 1; i < rows.length; i++) {
      if (rows[i].length != columnCount) {
        return CsvValidationResult(
          isValid: false,
          error: 'Row ${i + 1} has ${rows[i].length} columns, expected $columnCount',
          rowNumber: i + 1,
        );
      }
    }

    return CsvValidationResult(isValid: true);
  }
}

/// Result of CSV validation
class CsvValidationResult {
  final bool isValid;
  final String? error;
  final int? rowNumber;

  const CsvValidationResult({
    required this.isValid,
    this.error,
    this.rowNumber,
  });
}
