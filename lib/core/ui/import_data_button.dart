import 'package:flutter/material.dart';
import '../services/shared_data_service.dart';

/// A reusable button for importing shared data from other tools
class ImportDataButton extends StatelessWidget {
  final List<SharedDataType> acceptedTypes;
  final Function(String data, SharedDataType type, String source) onImport;
  final String? label;
  final IconData? icon;
  final bool compact;

  const ImportDataButton({
    super.key,
    required this.acceptedTypes,
    required this.onImport,
    this.label,
    this.icon,
    this.compact = false,
  });

  void _importData(BuildContext context) {
    final service = SharedDataService.instance;
    final currentData = service.currentData;

    if (currentData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No data available to import'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!acceptedTypes.contains(currentData.type)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Cannot import ${currentData.type.name} data in this tool'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Import the data
    onImport(
      currentData.data.toString(),
      currentData.type,
      currentData.sourceTool,
    );

    // Consume the data
    service.consumeData();

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Imported ${currentData.type.name} from ${currentData.sourceTool}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SharedDataService.instance,
      builder: (context, _) {
        final service = SharedDataService.instance;
        final hasCompatibleData = service.hasData &&
            acceptedTypes.contains(service.currentData?.type);
        final displayIcon = icon ?? Icons.download;

        if (compact) {
          return IconButton(
            onPressed: hasCompatibleData ? () => _importData(context) : null,
            icon: Icon(displayIcon),
            tooltip: hasCompatibleData
                ? 'Import from ${service.currentData?.sourceTool}'
                : 'No data available',
          );
        }

        return FilledButton.icon(
          onPressed: hasCompatibleData ? () => _importData(context) : null,
          icon: Icon(displayIcon),
          label: Text(label ?? 'Import'),
        );
      },
    );
  }
}
