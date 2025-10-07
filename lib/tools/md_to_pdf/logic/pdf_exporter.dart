class ExportOptions {
  final String theme;
  final String pageSize;
  final bool includePageNumbers;
  final PageMargins margins;

  const ExportOptions({
    required this.theme,
    required this.pageSize,
    required this.includePageNumbers,
    required this.margins,
  });

  Map<String, dynamic> toMap() {
    return {
      'theme': theme,
      'pageSize': pageSize,
      'includePageNumbers': includePageNumbers,
      'margins': margins.toMap(),
    };
  }
}

class PageMargins {
  final double top;
  final double bottom;
  final double left;
  final double right;

  const PageMargins({
    required this.top,
    required this.bottom,
    required this.left,
    required this.right,
  });

  Map<String, dynamic> toMap() {
    return {
      'top': top,
      'bottom': bottom,
      'left': left,
      'right': right,
    };
  }
}
