// Web implementation using dart:html
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:convert';

/// Pick a CSV file using HTML file input
void pickCsvFile(Function(String content, String fileName) onFileLoaded) {
  final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
  uploadInput.accept = '.csv';
  uploadInput.click();

  uploadInput.onChange.listen((e) {
    final files = uploadInput.files;
    if (files == null || files.isEmpty) return;

    final file = files[0];
    final fileName = file.name;

    final reader = html.FileReader();
    reader.readAsText(file);

    reader.onLoad.listen((e) {
      final content = reader.result as String;
      onFileLoaded(content, fileName);
    });
  });
}

/// Download CSV file using HTML anchor element
void downloadCsv(String csvContent, String fileName) {
  final bytes = utf8.encode(csvContent);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..target = 'download'
    ..download = fileName;
  anchor.click();

  html.Url.revokeObjectUrl(url);
}
