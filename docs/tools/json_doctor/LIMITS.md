# JSON Doctor - Limits & Performance Documentation

**Tool ID:** `json_doctor`  
**Route:** `/tools/json-doctor`  
**Performance Architect:** Toolspace Platform Team  
**Last Updated:** October 11, 2025

## 1. Overview

JSON Doctor implements comprehensive limits to ensure optimal performance while handling JSON validation, schema checking, and JSONPath queries. These limits protect system resources, maintain user experience quality, and provide clear upgrade paths for power users requiring enhanced capabilities.

**Limit Categories:**

- **Input Size Limits** - JSON content and file size restrictions
- **Processing Limits** - Validation and query execution constraints
- **Schema Complexity Limits** - JSON Schema validation boundaries
- **JSONPath Query Limits** - Query execution and result set restrictions
- **Memory Management** - Browser memory usage optimization
- **Performance Targets** - Response time and throughput requirements

## 2. Input Size Limits

### 2.1 JSON Content Limits

#### Universal JSON Size Restrictions

```dart
class JsonInputLimits {
  // Maximum JSON input size
  static const int maxInputSize = 50 * 1024 * 1024; // 50MB
  static const int warningThreshold = 10 * 1024 * 1024; // 10MB
  static const int optimizedThreshold = 1 * 1024 * 1024; // 1MB

  // Character count limits
  static const int maxCharacterCount = 50000000; // 50 million chars
  static const int realTimeValidationLimit = 100000; // 100k chars

  // Nested structure limits
  static const int maxNestingDepth = 1000; // levels
  static const int warningNestingDepth = 100; // levels
  static const int maxArrayLength = 1000000; // elements
  static const int maxObjectProperties = 100000; // properties

  static ValidationLimits getValidationLimits(int inputSize) {
    if (inputSize <= optimizedThreshold) {
      return ValidationLimits.realTime();
    } else if (inputSize <= warningThreshold) {
      return ValidationLimits.standard();
    } else {
      return ValidationLimits.performance();
    }
  }
}
```

#### File Upload Restrictions

```dart
class FileUploadLimits {
  // File size limits
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  static const int maxFileSizeFree = 10 * 1024 * 1024; // 10MB (free tier)
  static const int maxFileSizePro = 25 * 1024 * 1024; // 25MB (Pro tier)
  static const int maxFileSizeProPlus = 50 * 1024 * 1024; // 50MB (Pro+ tier)

  // Supported file types
  static const Set<String> allowedExtensions = {
    '.json', '.txt', '.js', '.ts', '.config', '.jsonl'
  };

  // MIME type validation
  static const Set<String> allowedMimeTypes = {
    'application/json',
    'text/plain',
    'text/javascript',
    'application/javascript',
  };

  static bool isFileAllowed(String fileName, String mimeType, int fileSize) {
    // Check extension
    final extension = fileName.toLowerCase().substring(fileName.lastIndexOf('.'));
    if (!allowedExtensions.contains(extension)) {
      return false;
    }

    // Check MIME type
    if (!allowedMimeTypes.contains(mimeType.toLowerCase())) {
      return false;
    }

    // Check size
    return fileSize <= maxFileSize;
  }
}
```

### 2.2 Batch Processing Limits

#### Multi-File Handling

```dart
class BatchProcessingLimits {
  // Free tier batch limits
  static const int freeTierMaxFiles = 5;
  static const int freeTierMaxTotalSize = 10 * 1024 * 1024; // 10MB

  // Pro tier batch limits
  static const int proTierMaxFiles = 25;
  static const int proTierMaxTotalSize = 100 * 1024 * 1024; // 100MB

  // Pro+ tier batch limits
  static const int proPlusTierMaxFiles = 100;
  static const int proPlusTierMaxTotalSize = 500 * 1024 * 1024; // 500MB

  // Processing time limits
  static const Duration maxBatchProcessingTime = Duration(minutes: 10);
  static const Duration warningBatchTime = Duration(minutes: 2);

  static BatchLimits getLimitsForPlan(BillingPlan plan) {
    switch (plan) {
      case BillingPlan.free:
        return BatchLimits(
          maxFiles: freeTierMaxFiles,
          maxTotalSize: freeTierMaxTotalSize,
          maxProcessingTime: Duration(minutes: 2),
        );
      case BillingPlan.pro:
        return BatchLimits(
          maxFiles: proTierMaxFiles,
          maxTotalSize: proTierMaxTotalSize,
          maxProcessingTime: Duration(minutes: 5),
        );
      case BillingPlan.proPlus:
        return BatchLimits(
          maxFiles: proPlusTierMaxFiles,
          maxTotalSize: proPlusTierMaxTotalSize,
          maxProcessingTime: Duration(minutes: 10),
        );
    }
  }
}
```

## 3. Processing Performance Limits

### 3.1 Validation Performance

#### Real-time Validation Constraints

```dart
class ValidationPerformanceLimits {
  // Response time targets
  static const Duration targetValidationTime = Duration(milliseconds: 50);
  static const Duration maxValidationTime = Duration(milliseconds: 200);
  static const Duration timeoutValidationTime = Duration(seconds: 5);

  // Debouncing configuration
  static const Duration inputDebounceDelay = Duration(milliseconds: 300);
  static const Duration schemaDebounceDelay = Duration(milliseconds: 500);

  // Processing thresholds
  static const int instantValidationLimit = 10000; // characters
  static const int asyncValidationThreshold = 100000; // characters
  static const int backgroundProcessingThreshold = 1000000; // characters

  // Memory usage during validation
  static const int maxValidationMemory = 100 * 1024 * 1024; // 100MB
  static const int warningMemoryUsage = 50 * 1024 * 1024; // 50MB

  static ValidationStrategy getValidationStrategy(int inputSize) {
    if (inputSize <= instantValidationLimit) {
      return ValidationStrategy.realTime;
    } else if (inputSize <= asyncValidationThreshold) {
      return ValidationStrategy.debounced;
    } else {
      return ValidationStrategy.backgroundProcessing;
    }
  }
}
```

#### Auto-Repair Limits

```dart
class AutoRepairLimits {
  // Repair attempt limits
  static const int maxRepairAttempts = 10;
  static const Duration maxRepairTime = Duration(seconds: 2);
  static const int maxSimultaneousRepairs = 5;

  // Repairable error types (ordered by complexity)
  static const List<RepairType> supportedRepairs = [
    RepairType.trailingCommas,
    RepairType.missingQuotes,
    RepairType.missingCommas,
    RepairType.bracketMismatch,
    RepairType.escapeSequences,
  ];

  // Size limits for auto-repair
  static const int maxRepairableSize = 1 * 1024 * 1024; // 1MB
  static const int complexRepairLimit = 100000; // 100k chars

  static bool canAttemptRepair(String jsonContent, JsonError error) {
    // Check size limits
    if (jsonContent.length > maxRepairableSize) {
      return false;
    }

    // Check if error type is repairable
    if (!supportedRepairs.contains(error.type)) {
      return false;
    }

    // Check complexity for certain repairs
    if (error.type == RepairType.bracketMismatch &&
        jsonContent.length > complexRepairLimit) {
      return false;
    }

    return true;
  }
}
```

### 3.2 Schema Validation Limits

#### Schema Complexity Constraints

```dart
class SchemaValidationLimits {
  // Schema size limits
  static const int maxSchemaSize = 1 * 1024 * 1024; // 1MB
  static const int maxSchemaProperties = 10000;
  static const int maxSchemaNesting = 50; // levels

  // Validation complexity limits
  static const int maxValidationPaths = 100000;
  static const int maxConditionalSchemas = 1000; // if/then/else
  static const int maxCompositionSchemas = 500; // allOf/anyOf/oneOf

  // Performance targets
  static const Duration targetSchemaValidationTime = Duration(milliseconds: 100);
  static const Duration maxSchemaValidationTime = Duration(seconds: 5);
  static const Duration timeoutSchemaValidation = Duration(seconds: 10);

  // Memory usage during schema validation
  static const int maxSchemaValidationMemory = 150 * 1024 * 1024; // 150MB

  // Supported JSON Schema features
  static const Set<String> supportedKeywords = {
    // Core keywords
    'type', 'enum', 'const',
    // Numeric keywords
    'multipleOf', 'maximum', 'exclusiveMaximum', 'minimum', 'exclusiveMinimum',
    // String keywords
    'maxLength', 'minLength', 'pattern', 'format',
    // Array keywords
    'items', 'additionalItems', 'maxItems', 'minItems', 'uniqueItems', 'contains',
    // Object keywords
    'maxProperties', 'minProperties', 'required', 'properties',
    'patternProperties', 'additionalProperties', 'dependencies',
    // Conditional keywords
    'if', 'then', 'else',
    // Composition keywords
    'allOf', 'anyOf', 'oneOf', 'not',
    // Metadata keywords
    'title', 'description', 'default', 'examples',
  };

  static bool isSchemaValid(Map<String, dynamic> schema) {
    // Check schema size
    final schemaString = jsonEncode(schema);
    if (schemaString.length > maxSchemaSize) {
      return false;
    }

    // Check nesting depth
    final depth = _calculateNestingDepth(schema);
    if (depth > maxSchemaNesting) {
      return false;
    }

    // Check property count
    final propertyCount = _countProperties(schema);
    if (propertyCount > maxSchemaProperties) {
      return false;
    }

    return true;
  }
}
```

### 3.3 JSONPath Query Limits

#### Query Execution Constraints

```dart
class JsonPathQueryLimits {
  // Query complexity limits
  static const int maxQueryLength = 1000; // characters
  static const int maxQueryDepth = 20; // recursive descent levels
  static const int maxFilterExpressions = 10;
  static const int maxResultSetSize = 10000; // results

  // Execution time limits
  static const Duration targetQueryTime = Duration(milliseconds: 100);
  static const Duration maxQueryTime = Duration(seconds: 2);
  static const Duration timeoutQueryTime = Duration(seconds: 10);

  // Memory limits for query results
  static const int maxQueryResultMemory = 50 * 1024 * 1024; // 50MB
  static const int maxResultItemSize = 1 * 1024 * 1024; // 1MB per item

  // Supported JSONPath features
  static const Set<String> supportedOperators = {
    '$',           // Root
    '.',           // Child
    '..',          // Recursive descent
    '[n]',         // Array index
    '[start:end]', // Array slice
    '[*]',         // Wildcard
    '[?(expr)]',   // Filter expression
  };

  // Filter expression limits
  static const Set<String> supportedFilterOperators = {
    '==', '!=', '<', '<=', '>', '>=',
    '&&', '||', '!',
    'in', 'nin', 'size', 'empty',
  };

  static QueryValidationResult validateQuery(String query) {
    // Check query length
    if (query.length > maxQueryLength) {
      return QueryValidationResult.error('Query too long');
    }

    // Check query depth
    final depth = query.split('..').length - 1;
    if (depth > maxQueryDepth) {
      return QueryValidationResult.error('Query too deep');
    }

    // Check filter expressions
    final filterCount = RegExp(r'\[\?\(.*?\)\]').allMatches(query).length;
    if (filterCount > maxFilterExpressions) {
      return QueryValidationResult.error('Too many filter expressions');
    }

    return QueryValidationResult.valid();
  }
}
```

## 4. Memory Management Limits

### 4.1 Browser Memory Constraints

#### Client-Side Memory Management

```dart
class MemoryManagementLimits {
  // Browser memory limits
  static const Map<String, int> browserMemoryLimits = {
    'chrome': 200 * 1024 * 1024,   // 200MB
    'firefox': 150 * 1024 * 1024,  // 150MB
    'safari': 100 * 1024 * 1024,   // 100MB
    'edge': 200 * 1024 * 1024,     // 200MB
    'mobile': 50 * 1024 * 1024,    // 50MB for mobile browsers
  };

  // Memory allocation by operation
  static const Map<String, int> operationMemoryLimits = {
    'validation': 50 * 1024 * 1024,      // 50MB
    'schema_validation': 75 * 1024 * 1024, // 75MB
    'jsonpath_query': 50 * 1024 * 1024,   // 50MB
    'auto_repair': 25 * 1024 * 1024,      // 25MB
    'formatting': 30 * 1024 * 1024,       // 30MB
  };

  // Cache limits
  static const int maxCachedResults = 20;
  static const int maxCacheMemory = 20 * 1024 * 1024; // 20MB
  static const Duration cacheExpiration = Duration(hours: 1);

  // Garbage collection thresholds
  static const double memoryPressureThreshold = 0.8; // 80%
  static const double criticalMemoryThreshold = 0.95; // 95%

  static int getMemoryLimit(String browser) {
    return browserMemoryLimits[browser] ?? browserMemoryLimits['mobile']!;
  }

  static bool shouldTriggerGC(int currentMemory, int maxMemory) {
    final usage = currentMemory / maxMemory;
    return usage > memoryPressureThreshold;
  }
}
```

#### Memory Optimization Strategies

```dart
class MemoryOptimization {
  // Large JSON streaming
  static const int streamingThreshold = 5 * 1024 * 1024; // 5MB
  static const int chunkSize = 1024 * 1024; // 1MB chunks

  // Virtual scrolling for large results
  static const int virtualScrollThreshold = 1000; // items
  static const int renderWindow = 100; // visible items

  // Progressive loading
  static const int progressiveLoadingThreshold = 10 * 1024 * 1024; // 10MB
  static const int initialLoadSize = 1 * 1024 * 1024; // 1MB

  static ProcessingStrategy getProcessingStrategy(int dataSize) {
    if (dataSize < streamingThreshold) {
      return ProcessingStrategy.inMemory;
    } else if (dataSize < progressiveLoadingThreshold) {
      return ProcessingStrategy.streaming;
    } else {
      return ProcessingStrategy.progressive;
    }
  }
}
```

### 4.2 Resource Cleanup

#### Automatic Resource Management

```dart
class ResourceCleanup {
  // Cleanup intervals
  static const Duration cleanupInterval = Duration(minutes: 5);
  static const Duration forceCleanupInterval = Duration(minutes: 15);

  // Resource tracking
  static final Map<String, DateTime> _resourceAges = {};
  static final Set<String> _activeOperations = {};

  // Cleanup triggers
  static const int maxIdleResources = 10;
  static const Duration resourceTimeout = Duration(minutes: 30);

  static Future<void> performCleanup() async {
    final now = DateTime.now();

    // Clean up expired cached results
    _cleanupExpiredCache(now);

    // Release idle resources
    _releaseIdleResources(now);

    // Force garbage collection if needed
    if (_shouldForceGC()) {
      await _forceGarbageCollection();
    }
  }

  static bool _shouldForceGC() {
    return _resourceAges.length > maxIdleResources ||
           _getMemoryUsage() > MemoryManagementLimits.memoryPressureThreshold;
  }
}
```

## 5. Performance Targets & Monitoring

### 5.1 Response Time Targets

#### Operation Performance Goals

```dart
class PerformanceTargets {
  // Validation performance targets
  static const Map<String, Duration> validationTargets = {
    'small_json': Duration(milliseconds: 10),   // < 1KB
    'medium_json': Duration(milliseconds: 50),  // 1KB - 100KB
    'large_json': Duration(milliseconds: 200),  // 100KB - 1MB
    'xlarge_json': Duration(seconds: 1),        // 1MB - 10MB
    'xxlarge_json': Duration(seconds: 5),       // 10MB+
  };

  // Schema validation targets
  static const Map<String, Duration> schemaValidationTargets = {
    'simple_schema': Duration(milliseconds: 20),
    'complex_schema': Duration(milliseconds: 100),
    'enterprise_schema': Duration(milliseconds: 500),
  };

  // JSONPath query targets
  static const Map<String, Duration> queryTargets = {
    'simple_query': Duration(milliseconds: 5),
    'filter_query': Duration(milliseconds: 50),
    'complex_query': Duration(milliseconds: 200),
    'recursive_query': Duration(milliseconds: 500),
  };

  // UI responsiveness targets
  static const Duration uiResponseTarget = Duration(milliseconds: 16); // 60fps
  static const Duration maxUiBlockingTime = Duration(milliseconds: 50);

  static Duration getTargetTime(String operation, int dataSize) {
    if (operation == 'validation') {
      if (dataSize < 1024) return validationTargets['small_json']!;
      if (dataSize < 100 * 1024) return validationTargets['medium_json']!;
      if (dataSize < 1024 * 1024) return validationTargets['large_json']!;
      if (dataSize < 10 * 1024 * 1024) return validationTargets['xlarge_json']!;
      return validationTargets['xxlarge_json']!;
    }

    return Duration(milliseconds: 100); // Default
  }
}
```

### 5.2 Performance Monitoring

#### Real-time Performance Tracking

```dart
class PerformanceMonitoring {
  static final Map<String, List<Duration>> _operationTimes = {};
  static final Map<String, int> _operationCounts = {};

  static void recordOperation(String operation, Duration time, int dataSize) {
    final key = '${operation}_${_getSizeCategory(dataSize)}';
    _operationTimes.putIfAbsent(key, () => []).add(time);
    _operationCounts[key] = (_operationCounts[key] ?? 0) + 1;

    // Alert if performance target exceeded
    final target = PerformanceTargets.getTargetTime(operation, dataSize);
    if (time > target * 2) {
      _alertPerformanceIssue(operation, time, target);
    }
  }

  static PerformanceReport generateReport() {
    return PerformanceReport(
      averageTimes: _calculateAverageTimes(),
      operationCounts: Map.from(_operationCounts),
      performanceAlerts: _getRecentAlerts(),
      memoryUsage: _getCurrentMemoryUsage(),
      timestamp: DateTime.now(),
    );
  }

  static String _getSizeCategory(int size) {
    if (size < 1024) return 'small';
    if (size < 100 * 1024) return 'medium';
    if (size < 1024 * 1024) return 'large';
    if (size < 10 * 1024 * 1024) return 'xlarge';
    return 'xxlarge';
  }
}
```

## 6. Error Handling & Graceful Degradation

### 6.1 Limit Enforcement

#### User-Friendly Limit Messages

```dart
class LimitEnforcement {
  static String getLimitExceededMessage(LimitType type, dynamic currentValue, dynamic limit) {
    switch (type) {
      case LimitType.fileSize:
        final sizeMB = (currentValue as int) / (1024 * 1024);
        final limitMB = (limit as int) / (1024 * 1024);
        return 'File size (${sizeMB.toStringAsFixed(1)}MB) exceeds the limit of ${limitMB.toStringAsFixed(1)}MB. '
               'Consider breaking large files into smaller chunks or upgrading your plan.';

      case LimitType.nestingDepth:
        return 'JSON nesting depth ($currentValue levels) exceeds the limit of $limit levels. '
               'Consider flattening deeply nested structures for better performance.';

      case LimitType.queryComplexity:
        return 'JSONPath query is too complex. Simplify the query or break it into multiple operations.';

      case LimitType.processingTime:
        return 'Operation timed out after ${(currentValue as Duration).inSeconds} seconds. '
               'Try reducing the data size or complexity.';

      case LimitType.memoryUsage:
        final memoryMB = (currentValue as int) / (1024 * 1024);
        return 'Memory usage (${memoryMB.toStringAsFixed(1)}MB) is too high. '
               'Please reduce the size of your JSON data.';

      default:
        return 'Operation limit exceeded. Please reduce the scope of your request.';
    }
  }

  static Widget buildLimitExceededDialog(LimitType type, dynamic value, dynamic limit) {
    return LimitExceededDialog(
      title: 'Limit Exceeded',
      message: getLimitExceededMessage(type, value, limit),
      actions: _getSuggestedActions(type),
      upgradeOption: _getUpgradeOption(type),
    );
  }
}
```

### 6.2 Progressive Performance Degradation

#### Adaptive Performance Features

```dart
class PerformanceDegradation {
  static JsonDoctorSettings getAdaptiveSettings(PerformanceContext context) {
    if (context.memoryPressure > 0.9) {
      // Critical memory pressure - maximum degradation
      return JsonDoctorSettings(
        realTimeValidation: false,
        syntaxHighlighting: false,
        autoCompleteEnabled: false,
        animationsEnabled: false,
        cacheEnabled: false,
        maxUndoSteps: 1,
      );
    } else if (context.memoryPressure > 0.8) {
      // High memory pressure - moderate degradation
      return JsonDoctorSettings(
        realTimeValidation: false,
        syntaxHighlighting: true,
        autoCompleteEnabled: false,
        animationsEnabled: false,
        cacheEnabled: true,
        maxUndoSteps: 5,
      );
    } else if (context.processingLoad > 0.8) {
      // High CPU load - reduce processing features
      return JsonDoctorSettings(
        realTimeValidation: false,
        syntaxHighlighting: true,
        autoCompleteEnabled: true,
        animationsEnabled: false,
        cacheEnabled: true,
        maxUndoSteps: 10,
      );
    }

    // Normal performance - all features enabled
    return JsonDoctorSettings.standard();
  }
}
```

## 7. Future Limit Adjustments

### 7.1 Planned Limit Increases

#### Technology-Driven Improvements

```dart
class FutureLimitPlanning {
  // 2025 Q4 targets
  static const Map<String, dynamic> q4Targets = {
    'max_file_size': 100 * 1024 * 1024,     // 100MB (up from 50MB)
    'validation_time': Duration(milliseconds: 25), // 25ms (down from 50ms)
    'schema_complexity': 20000,              // 20k properties (up from 10k)
    'query_result_limit': 50000,             // 50k results (up from 10k)
  };

  // 2026 targets (with WebAssembly optimization)
  static const Map<String, dynamic> wasmTargets = {
    'max_file_size': 500 * 1024 * 1024,     // 500MB
    'validation_time': Duration(milliseconds: 10), // 10ms
    'schema_complexity': 100000,             // 100k properties
    'query_result_limit': 1000000,           // 1M results
  };

  // Performance multipliers with technology upgrades
  static const Map<String, double> technologyMultipliers = {
    'webassembly': 5.0,        // 5x performance improvement
    'worker_threads': 2.0,     // 2x through parallelization
    'streaming_parser': 3.0,   // 3x for large files
    'memory_optimization': 2.0, // 2x memory efficiency
  };
}
```

### 7.2 Adaptive Limit System

#### Dynamic Limit Adjustment

```dart
class AdaptiveLimits {
  static JsonDoctorLimits calculateDynamicLimits({
    required BrowserCapabilities browser,
    required UserPlan plan,
    required SystemLoad load,
  }) {
    var baseLimits = JsonInputLimits.getBaseLimits(plan);

    // Browser capability adjustments
    baseLimits = baseLimits.adjustForBrowser(browser);

    // System load adjustments
    if (load.memoryPressure > 0.8) {
      baseLimits = baseLimits.reduce(factor: 0.5);
    } else if (load.cpuUsage > 0.8) {
      baseLimits = baseLimits.reduceComplexity(factor: 0.7);
    }

    return baseLimits;
  }
}
```

JSON Doctor's comprehensive limit system ensures optimal performance across all user scenarios while providing clear upgrade paths and graceful degradation when limits are approached or exceeded.
