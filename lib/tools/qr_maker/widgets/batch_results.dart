import 'package:flutter/material.dart';
import '../logic/batch_generator.dart';

/// Batch results display widget
class BatchResults extends StatelessWidget {
  final BatchResult result;
  final VoidCallback onDownloadAll;
  final VoidCallback onClose;

  const BatchResults({
    super.key,
    required this.result,
    required this.onDownloadAll,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Batch Generation Complete',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close),
                tooltip: 'Close',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle,
                  iconColor: Colors.green,
                  label: 'Successful',
                  value: '${result.successful.length}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  icon: Icons.error,
                  iconColor: Colors.red,
                  label: 'Errors',
                  value: '${result.errors.length}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  icon: Icons.speed,
                  iconColor: Colors.blue,
                  label: 'Time',
                  value: '${result.processingTime.inMilliseconds}ms',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Success rate progress
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Success Rate'),
                    Text(
                      '${(result.successRate * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: result.successRate,
                    minHeight: 8,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      result.successRate >= 0.8 ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Download all button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: result.successful.isEmpty ? null : onDownloadAll,
              icon: const Icon(Icons.download),
              label: Text(
                  'Download All (${result.successful.length} QR Codes)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5722),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Error list (if any)
          if (result.errors.isNotEmpty) ...[
            Text(
              'Errors (${result.errors.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: result.errors.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final error = result.errors[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.error_outline,
                          color: Colors.red, size: 20),
                      title: Text(
                        error.item.content.length > 50
                            ? '${error.item.content.substring(0, 50)}...'
                            : error.item.content,
                        style: theme.textTheme.bodySmall,
                      ),
                      subtitle: Text(
                        error.errorMessage,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ] else ...[
            // Success list
            Text(
              'Generated QR Codes (${result.successful.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: result.successful.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = result.successful[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.qr_code,
                          color: Color(0xFFFF5722), size: 20),
                      title: Text(
                        item.filename ?? 'qr_${index + 1}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        item.content.length > 50
                            ? '${item.content.substring(0, 50)}...'
                            : item.content,
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: const Icon(Icons.check_circle,
                          color: Colors.green, size: 20),
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Stat card widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
