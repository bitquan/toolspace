/// Example integration of PaywallGuard for heavy tools.
///
/// This file demonstrates the pattern to follow for all 5 heavy tools.
///
/// Tools to integrate:
/// 1. file_merger - requiresHeavyOp, check file sizes
/// 2. image_resizer - requiresHeavyOp, check file sizes, batch size
/// 3. md_to_pdf - requiresHeavyOp, check file size
/// 4. qr_maker (batch mode) - requiresHeavyOp, batch size
/// 5. json_flatten (CSV export) - requiresHeavyOp

import 'package:flutter/material.dart';
import '../../billing/billing_service.dart';
import '../../billing/widgets/paywall_guard.dart';

/// Example: Wrapping File Merger with PaywallGuard
class FileMergerScreenExample extends StatelessWidget {
  const FileMergerScreenExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PaywallGuard(
      permission: const ToolPermission(
        toolId: 'file_merger',
        requiresHeavyOp: true,
        // File size check happens per-file in the upload logic
      ),
      billingService: BillingService(),
      child: Scaffold(
        appBar: AppBar(title: const Text('File Merger')),
        body: const Center(
          child: Text('File Merger Tool UI'),
          // Actual tool implementation here
        ),
      ),
    );
  }
}

/// Example: Image Resizer with batch check
class ImageResizerScreenExample extends StatelessWidget {
  const ImageResizerScreenExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PaywallGuard(
      permission: const ToolPermission(
        toolId: 'image_resizer',
        requiresHeavyOp: true,
        // Dynamic checks in UI for file size and batch count
      ),
      billingService: BillingService(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Image Resizer')),
        body: const Center(
          child: Text('Image Resizer Tool UI'),
        ),
      ),
    );
  }
}

/// Integration Notes:
///
/// 1. **PaywallGuard Placement**: Wrap the entire screen or main content area
///
/// 2. **Permission Configuration**:
///    - toolId: Must match pricing.json tool IDs
///    - requiresHeavyOp: true for all 5 heavy tools
///    - fileSize: Check individual files before upload
///    - batchSize: Check before starting batch operation
///
/// 3. **Usage Tracking**: Call after successful operation
///    ```dart
///    await billingService.trackHeavyOp();
///    await billingService.trackFileProcessed(fileSize);
///    ```
///
/// 4. **Dynamic Checks**: For operations with variable inputs
///    ```dart
///    final canProcess = await billingService.canProcessFileSize(fileSize);
///    if (!canProcess.allowed) {
///      // Show error or upgrade prompt
///    }
///    ```
///
/// 5. **QuotaBanner**: Automatically shown by PaywallGuard when approaching limits
