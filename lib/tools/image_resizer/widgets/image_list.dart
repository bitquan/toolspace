import 'package:flutter/material.dart';
import '../logic/upload_manager.dart';

/// Displays list of uploaded images
class ImageList extends StatelessWidget {
  final List<ImageUpload> images;
  final Function(int) onRemove;
  final bool isEnabled;

  const ImageList({
    super.key,
    required this.images,
    required this.onRemove,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.memory(
                  image.bytes,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.image,
                      color: Colors.grey.shade400,
                    );
                  },
                ),
              ),
            ),
            title: Text(
              image.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(image.formattedSize),
            trailing: isEnabled
                ? IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => onRemove(index),
                    color: Colors.red,
                  )
                : null,
          ),
        );
      },
    );
  }
}
