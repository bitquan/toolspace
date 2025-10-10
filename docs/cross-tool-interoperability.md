# Cross-Tool Interoperability Documentation

## Overview

Toolspace implements a sophisticated cross-tool data sharing system that enables seamless data flow between different tools within the application. This system is built around the ShareBus architecture and provides users with powerful workflow automation capabilities.

## Architecture Components

### 1. ShareBus System

The ShareBus is a singleton event bus that manages cross-tool communication with TTL-based expiry and multiple subscribers.

**Key Features:**
- **Event-Driven**: Uses Flutter's ChangeNotifier for reactive updates
- **TTL Management**: Automatic cleanup of expired data (5-minute default)
- **Multiple Data Types**: Supports text, JSON, CSV, file URLs, data URLs, markdown, and images
- **Queue-Based**: Maintains chronological order of data sharing events

**API Methods:**
```dart
// Publishing data
ShareBus.instance.publish(ShareEnvelope envelope)

// Retrieving data
ShareBus.instance.getLatest(ShareKind kind)
ShareBus.instance.getByKind(ShareKind kind)
ShareBus.instance.getAll()

// Consuming (get and remove) data
ShareBus.instance.consume(ShareKind kind)
ShareBus.instance.consumeEnvelope(ShareEnvelope envelope)

// Utility methods
ShareBus.instance.has(ShareKind kind)
ShareBus.instance.clear()
ShareBus.instance.count
```

### 2. ShareEnvelope

Data wrapper that carries payload and metadata between tools.

**Structure:**
```dart
class ShareEnvelope {
  final ShareKind kind;        // Data type identifier
  final dynamic value;         // Actual data payload
  final Map<String, dynamic> meta;  // Metadata (source tool, etc.)
  final DateTime timestamp;    // Creation timestamp
}
```

**Supported ShareKind Types:**
- `text`: Plain text strings
- `json`: JSON objects and arrays
- `csv`: Tabular data as List<List<String>>
- `markdown`: Markdown formatted text
- `fileUrl`: File URLs for large assets
- `dataUrl`: Base64-encoded data URLs
- `image`: Image data and metadata

### 3. ShareToolbar Widget

Universal cross-tool integration widget that provides import/export/send functionality.

**Features:**
- **Import Menu**: PopupMenuButton with available data types from ShareBus
- **Export Data**: Tool-specific data export with automatic ShareBus publishing
- **Send to Tool**: Direct navigation to target tools with data handoff
- **Tool Preferences**: Configurable tool mappings for different data types
- **Undo Functionality**: Revert import operations

**Integration Pattern:**
```dart
ShareToolbar(
  toolId: 'your-tool-id',
  onImport: (envelope, sourceTool) {
    // Handle imported data
    setState(() {
      _controller.text = envelope.value;
    });
  },
  getExportData: () => {
    ShareKind.text: _controller.text,
    ShareKind.json: _parseAsJson(),
  },
)
```

### 4. HandoffStore Persistence

Long-term storage for cross-tool data that survives app restarts.

**Features:**
- **Firebase Firestore**: Cloud-based persistence
- **User-Specific**: Data isolated per authenticated user
- **Automatic Cleanup**: TTL-based expiry (24 hours default)
- **Offline Support**: Local caching with online sync

## Data Flow Patterns

### 1. Simple Data Sharing
```
Tool A → ShareBus → Tool B
```
1. User exports data from Tool A
2. Data published to ShareBus with ShareEnvelope
3. User navigates to Tool B
4. ShareToolbar shows available import options
5. User imports data into Tool B

### 2. Multi-Tool Workflows
```
JSON → Text Tools → JSON Doctor → Text Diff
```
Example: JSON processing pipeline
1. Raw JSON input in Text Tools
2. Formatted and cleaned in JSON Doctor  
3. Compared versions in Text Diff
4. Final output ready for use

### 3. Automated Test Flows
```
E2E Playground → Automated Testing → Validation
```
1. E2E Playground seeds test data
2. Automated flows simulate user interactions
3. Data flows validated across tool boundaries
4. Results logged for verification

## Tool Integration Guidelines

### For New Tools

1. **Add ShareToolbar Widget**:
   ```dart
   ShareToolbar(
     toolId: 'unique-tool-id',
     onImport: _handleImport,
     getExportData: _getExportData,
   )
   ```

2. **Implement Data Handlers**:
   ```dart
   void _handleImport(ShareEnvelope envelope, String sourceTool) {
     switch (envelope.kind) {
       case ShareKind.text:
         _textController.text = envelope.value;
         break;
       case ShareKind.json:
         _loadJsonData(envelope.value);
         break;
     }
   }
   
   Map<ShareKind, dynamic> _getExportData() {
     return {
       ShareKind.text: _textController.text,
       if (_hasValidJson()) ShareKind.json: _getJsonData(),
     };
   }
   ```

3. **Configure Tool Preferences**:
   ```dart
   // In ShareToolbar widget
   toolPreferences: {
     ShareKind.text: ['text-tools', 'regex-tester'],
     ShareKind.json: ['json-doctor', 'json-flatten'],
   }
   ```

### For Existing Tools

1. **Audit Current Data Handling**: Identify export/import patterns
2. **Add ShareToolbar**: Replace custom export/import with unified widget
3. **Test Cross-Tool Flows**: Use E2E Playground for validation
4. **Update Documentation**: Document new sharing capabilities

## E2E Testing Framework

### E2E Playground Features

- **Automated Test Flows**: Pre-programmed multi-tool workflows
- **Manual Data Seeding**: Quick test data generation
- **ShareBus Monitoring**: Real-time data flow visualization
- **Test Result Logging**: Detailed execution reports
- **Navigation Testing**: Verify tool transitions

### Available Test Flows

1. **JSON→Text Tools**: JSON processing workflow
2. **Text→JSON Doctor**: Text to structured data conversion
3. **CSV→Data Tools**: Tabular data processing
4. **Cross-Tool Navigation**: Route and data persistence testing

### Running E2E Tests

1. Navigate to `/dev/e2e-playground` (development builds only)
2. Select automated test flow or manual data seeding
3. Monitor ShareBus status in real-time
4. Review test results and data flow integrity
5. Use checklist in `docs/e2e-local-checklist.md` for manual verification

## Performance Considerations

### ShareBus Optimization

- **TTL Cleanup**: Automatic removal of expired data prevents memory leaks
- **Selective Retrieval**: Use `getLatest()` instead of `getAll()` when possible
- **Listener Management**: Remove listeners in widget `dispose()` methods
- **Data Size Limits**: Large files should use `fileUrl` instead of direct data

### Memory Management

- **Envelope Lifecycle**: Data automatically expires after TTL
- **Clear on Navigation**: Optional clearing when leaving tools
- **Background Cleanup**: Periodic garbage collection of expired envelopes
- **User Control**: Manual clear options in ShareToolbar

## Security Considerations

### Data Isolation

- **User-Specific**: All shared data isolated by user authentication
- **Session-Based**: ShareBus clears on app restart (unless persisted)
- **No Cross-User Leakage**: Firebase security rules prevent data access

### Sensitive Data Handling

- **Metadata Only**: Avoid storing sensitive data in envelope metadata
- **TTL Enforcement**: Sensitive data expires quickly
- **User Awareness**: Clear indicators when data is being shared
- **Audit Trail**: Optional logging of data sharing events

## Troubleshooting

### Common Issues

1. **Data Not Appearing**: Check TTL expiry and ShareBus status
2. **Import/Export Failures**: Verify ShareKind compatibility
3. **Navigation Issues**: Ensure routes are properly configured
4. **Performance Problems**: Monitor ShareBus queue size

### Debug Tools

- **E2E Playground**: ShareBus status monitoring
- **Flutter Inspector**: Widget tree analysis
- **Console Logging**: ShareBus events and envelope lifecycle
- **Network Tab**: HandoffStore persistence operations

## Future Enhancements

### Planned Features

1. **Real-Time Collaboration**: Multi-user data sharing
2. **Version Control**: Track data modification history
3. **Workflow Automation**: Trigger-based tool chaining
4. **Advanced Filters**: Smart data type detection and conversion
5. **Plugin System**: Third-party tool integration
6. **Analytics**: Usage patterns and optimization insights

### Extension Points

- **Custom ShareKind Types**: Add new data formats
- **Tool-Specific Adapters**: Handle complex data transformations
- **Middleware Hooks**: Pre/post-processing of shared data
- **Storage Backends**: Alternative persistence options
- **Security Layers**: Enhanced encryption and access controls

## Conclusion

The cross-tool interoperability system in Toolspace provides a robust foundation for building powerful, interconnected workflows. By leveraging the ShareBus architecture, tools can seamlessly exchange data while maintaining performance, security, and user experience standards.

For implementation support, refer to the E2E testing framework and existing tool integrations as reference patterns.