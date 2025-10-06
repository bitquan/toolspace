import 'package:flutter/material.dart';
import '../logic/upload_manager.dart';

/// Reorderable list of files with remove functionality
class FileList extends StatelessWidget {
  final List<FileUpload> files;
  final Function(int) onRemove;
  final Function(int, int) onReorder;
  final bool isEnabled;

  const FileList({
    super.key,
    required this.files,
    required this.onRemove,
    required this.onReorder,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      onReorder: isEnabled ? onReorder : (_, __) {},
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return _FileListItem(
          key: ValueKey(file.name + index.toString()),
          file: file,
          onRemove: isEnabled ? () => onRemove(index) : null,
          index: index,
        );
      },
    );
  }
}

class _FileListItem extends StatelessWidget {
  final FileUpload file;
  final VoidCallback? onRemove;
  final int index;

  const _FileListItem({
    super.key,
    required this.file,
    this.onRemove,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getFileTypeColor(),
          child: Icon(
            _getFileTypeIcon(),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          file.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text(file.formattedSize),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color:
                    file.isValid ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                file.isValid ? 'Valid' : 'Invalid',
                style: TextStyle(
                  fontSize: 10,
                  color: file.isValid
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${index + 1}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            if (onRemove != null)
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.remove_circle_outline),
                color: Colors.red,
                iconSize: 20,
              ),
            if (onRemove == null) const SizedBox(width: 48),
            const Icon(
              Icons.drag_handle,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileTypeIcon() {
    if (file.contentType.contains('pdf')) {
      return Icons.picture_as_pdf;
    } else if (file.contentType.contains('image')) {
      return Icons.image;
    }
    return Icons.insert_drive_file;
  }

  Color _getFileTypeColor() {
    if (file.contentType.contains('pdf')) {
      return Colors.red;
    } else if (file.contentType.contains('image')) {
      return Colors.blue;
    }
    return Colors.grey;
  }
}
