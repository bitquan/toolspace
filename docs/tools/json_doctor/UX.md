# JSON Doctor - User Experience Documentation

**Tool ID:** `json_doctor`  
**Route:** `/tools/json-doctor`  
**UX Architect:** Toolspace Design Team  
**Last Updated:** October 11, 2025

## 1. User Experience Overview

JSON Doctor provides a sophisticated yet intuitive interface for JSON processing, designed around three core workflows: validation & repair, schema validation, and JSONPath querying. The UX prioritizes immediate feedback, progressive disclosure, and seamless cross-tool integration.

**Design Principles:**

- **Immediate Feedback**: Real-time validation with <100ms response times
- **Progressive Disclosure**: Advanced features revealed contextually
- **Error Prevention**: Proactive guidance to prevent common mistakes
- **Professional Efficiency**: Optimized for power users and frequent JSON work

### 1.1 Interface Architecture

#### Three-Tab Structure

```dart
// Tab-based navigation for distinct workflows
class JsonDoctorTabs {
  static const List<TabDefinition> tabs = [
    TabDefinition(
      icon: Icons.healing,
      label: 'Validate & Fix',
      tooltip: 'JSON validation and auto-repair',
      shortcut: 'Cmd+1',
    ),
    TabDefinition(
      icon: Icons.schema,
      label: 'Schema',
      tooltip: 'JSON Schema validation',
      shortcut: 'Cmd+2',
    ),
    TabDefinition(
      icon: Icons.search,
      label: 'JSONPath',
      tooltip: 'Query and extract data',
      shortcut: 'Cmd+3',
    ),
  ];
}
```

#### Visual Status System

```dart
// Comprehensive status visualization
enum UiState {
  empty,         // No input - show getting started guide
  typing,        // User actively typing - show real-time feedback
  validating,    // Processing in progress - show progress indicator
  valid,         // Success state - green indicators and checkmarks
  invalid,       // Error state - red indicators with fix suggestions
  repairing,     // Auto-repair in progress - animated healing icon
  repaired,      // Successfully repaired - celebration animation
  schemaValid,   // Schema validation passed - detailed success info
  schemaInvalid, // Schema validation failed - error breakdown
}
```

### 1.2 Design Language

#### Color System

```dart
class JsonDoctorColors {
  // Status-based color coding
  static const Color validGreen = Color(0xFF388E3C);
  static const Color invalidRed = Color(0xFFD32F2F);
  static const Color repairingOrange = Color(0xFFFF9800);
  static const Color processingBlue = Color(0xFF1976D2);

  // Syntax highlighting colors
  static const Color jsonKey = Color(0xFF1976D2);
  static const Color jsonString = Color(0xFF388E3C);
  static const Color jsonNumber = Color(0xFFE65100);
  static const Color jsonBoolean = Color(0xFF7B1FA2);
  static const Color jsonNull = Color(0xFF616161);

  // Interactive element colors
  static const Color buttonPrimary = Color(0xFF1976D2);
  static const Color buttonSecondary = Color(0xFF757575);
  static const Color hoverState = Color(0xFFE3F2FD);
}
```

#### Typography & Spacing

```dart
class JsonDoctorTypography {
  // Code-optimized fonts for JSON display
  static const TextStyle codeFont = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize: 14,
    letterSpacing: 0.5,
    height: 1.4,
  );

  // Interface text styles
  static const TextStyle heading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: Color(0xFF757575),
  );
}
```

## 2. User Workflows

### 2.1 Primary Workflow: JSON Validation

#### Entry Points

```dart
// Multiple ways users can start validation
class ValidationEntryPoints {
  // Direct text input
  static Widget buildTextInput() {
    return CodeEditor(
      controller: _inputController,
      language: 'json',
      theme: 'vs-dark',
      features: [
        'syntax-highlighting',
        'auto-completion',
        'bracket-matching',
        'error-squiggles',
      ],
      onChanged: _debounceValidation,
      placeholder: 'Paste or type JSON here...',
    );
  }

  // File upload with drag-and-drop
  static Widget buildFileUpload() {
    return DropZone(
      acceptedTypes: ['.json', '.txt', '.js'],
      maxFileSize: 10 * 1024 * 1024, // 10MB
      onFileDropped: _handleFileUpload,
      placeholder: 'Drag JSON file here or click to browse',
    );
  }

  // ShareBus integration
  static Widget buildImportButton() {
    return ImportDataButton(
      acceptedTypes: [SharedDataType.json, SharedDataType.text],
      onImport: _handleSharedData,
      tooltip: 'Import from other tools',
    );
  }
}
```

#### Real-time Feedback System

```dart
// Progressive validation feedback
class ValidationFeedback {
  static Widget buildStatusIndicator(JsonDoctorStatus status) {
    switch (status) {
      case JsonDoctorStatus.empty:
        return StatusChip(
          icon: Icons.edit_outlined,
          label: 'Ready for input',
          color: Colors.grey,
        );

      case JsonDoctorStatus.typing:
        return StatusChip(
          icon: Icons.keyboard,
          label: 'Typing...',
          color: Colors.blue,
          animated: true,
        );

      case JsonDoctorStatus.valid:
        return StatusChip(
          icon: Icons.check_circle,
          label: 'Valid JSON',
          color: JsonDoctorColors.validGreen,
          celebrateOnAppear: true,
        );

      case JsonDoctorStatus.invalid:
        return StatusChip(
          icon: Icons.error,
          label: 'Syntax errors found',
          color: JsonDoctorColors.invalidRed,
          pulse: true,
        );

      case JsonDoctorStatus.repairing:
        return StatusChip(
          icon: Icons.healing,
          label: 'Auto-repairing...',
          color: JsonDoctorColors.repairingOrange,
          animated: true,
        );
    }
  }
}
```

#### Error Display & Suggestions

```dart
// Comprehensive error presentation
class ErrorDisplay {
  static Widget buildErrorPanel(JsonError error) {
    return ErrorCard(
      severity: error.type.severity,
      title: error.description,
      subtitle: 'At position ${error.position}',
      children: [
        // Visual error location
        CodeHighlight(
          position: error.position,
          length: error.suggestedFixLength,
          color: JsonDoctorColors.invalidRed,
        ),

        // Fix suggestions
        if (error.possibleFixes.isNotEmpty)
          SuggestionsList(
            title: 'Suggested fixes:',
            suggestions: error.possibleFixes,
            onSuggestionTap: _applyFix,
          ),

        // Quick action buttons
        ActionRow(
          actions: [
            if (error.canAutoFix)
              ActionButton(
                icon: Icons.auto_fix_high,
                label: 'Auto-fix',
                onPressed: () => _autoFix(error),
              ),
            ActionButton(
              icon: Icons.help_outline,
              label: 'Learn more',
              onPressed: () => _showHelp(error.type),
            ),
          ],
        ),
      ],
    );
  }
}
```

### 2.2 Advanced Workflow: Schema Validation

#### Schema Input Methods

```dart
// Multiple schema input approaches
class SchemaInputMethods {
  // Manual schema editing
  static Widget buildSchemaEditor() {
    return SchemaEditor(
      controller: _schemaController,
      features: [
        'schema-intellisense',
        'keyword-completion',
        'reference-validation',
        'example-generation',
      ],
      onSchemaChanged: _validateAgainstSchema,
      templates: _getSchemaTemplates(),
    );
  }

  // Schema generation from sample data
  static Widget buildSchemaGenerator() {
    return SchemaGenerator(
      sourceData: _currentJsonData,
      onSchemaGenerated: _setGeneratedSchema,
      options: SchemaGenerationOptions(
        includeExamples: true,
        strictTypes: false,
        allowAdditionalProperties: true,
        generateDescriptions: true,
      ),
    );
  }

  // Schema library integration
  static Widget buildSchemaLibrary() {
    return SchemaLibrary(
      categories: ['web-apis', 'config-files', 'data-formats'],
      onSchemaSelected: _loadSchemaFromLibrary,
      searchEnabled: true,
      favoriteSchemas: _getUserFavoriteSchemas(),
    );
  }
}
```

#### Validation Results Visualization

```dart
// Rich schema validation results
class SchemaValidationDisplay {
  static Widget buildValidationResults(List<SchemaValidationError> errors) {
    if (errors.isEmpty) {
      return SuccessPanel(
        title: 'Schema validation passed',
        subtitle: 'All properties match the schema requirements',
        icon: Icons.verified,
        color: JsonDoctorColors.validGreen,
      );
    }

    return ValidationErrorsList(
      errors: errors,
      groupBy: ValidationErrorGrouping.byPath,
      expandable: true,
      children: errors.map((error) => ValidationErrorCard(
        error: error,
        showPath: true,
        showContext: true,
        onErrorTap: () => _navigateToError(error),
        actions: [
          if (error.hasQuickFix)
            ActionButton(
              icon: Icons.build,
              label: 'Fix',
              onPressed: () => _applySchemaFix(error),
            ),
          ActionButton(
            icon: Icons.info_outline,
            label: 'Details',
            onPressed: () => _showErrorDetails(error),
          ),
        ],
      )).toList(),
    );
  }
}
```

### 2.3 Power User Workflow: JSONPath Queries

#### Query Builder Interface

```dart
// Visual query construction
class JsonPathQueryBuilder {
  static Widget buildQueryInterface() {
    return Column(
      children: [
        // Path navigation breadcrumb
        PathBreadcrumb(
          path: _currentPath,
          data: _jsonData,
          onPathSegmentTap: _navigateToPath,
          onPathEdit: _setCustomPath,
        ),

        // Available operations based on current context
        OperationsPanel(
          currentData: _getDataAtPath(_currentPath),
          availableOps: _getAvailableOperations(),
          onOperationSelected: _addQueryOperation,
        ),

        // Query preview with syntax highlighting
        QueryPreview(
          query: _buildCurrentQuery(),
          syntax: 'jsonpath',
          editable: true,
          onQueryEdit: _handleManualQueryEdit,
        ),

        // Live result preview
        ResultPreview(
          data: _jsonData,
          query: _currentQuery,
          maxResults: 100,
          onResultClick: _highlightResultInData,
        ),
      ],
    );
  }
}
```

#### Interactive Data Explorer

```dart
// Visual JSON structure navigation
class JsonDataExplorer {
  static Widget buildDataTree(dynamic data, String currentPath) {
    return TreeView(
      data: data,
      currentPath: currentPath,
      expandedPaths: _expandedPaths,
      onNodeExpand: _handleNodeExpand,
      onNodeSelect: _handleNodeSelect,
      decorations: [
        TreeNodeDecoration.typeIndicator,
        TreeNodeDecoration.valuePreview,
        TreeNodeDecoration.arrayCount,
        TreeNodeDecoration.objectKeyCount,
      ],
      contextMenuItems: [
        ContextMenuItem(
          icon: Icons.copy,
          label: 'Copy path',
          action: (path) => _copyPathToClipboard(path),
        ),
        ContextMenuItem(
          icon: Icons.search,
          label: 'Query this path',
          action: (path) => _addPathToQuery(path),
        ),
        ContextMenuItem(
          icon: Icons.filter_list,
          label: 'Filter by value',
          action: (path) => _filterByValue(path),
        ),
      ],
    );
  }
}
```

## 3. Interaction Patterns

### 3.1 Keyboard Shortcuts

#### Global Shortcuts

```dart
class JsonDoctorShortcuts {
  static const Map<String, ShortcutDefinition> globalShortcuts = {
    // Tab navigation
    'cmd+1': ShortcutDefinition(
      action: 'switch_to_validate_tab',
      description: 'Switch to Validate & Fix tab',
    ),
    'cmd+2': ShortcutDefinition(
      action: 'switch_to_schema_tab',
      description: 'Switch to Schema tab',
    ),
    'cmd+3': ShortcutDefinition(
      action: 'switch_to_jsonpath_tab',
      description: 'Switch to JSONPath tab',
    ),

    // Common actions
    'cmd+shift+f': ShortcutDefinition(
      action: 'format_json',
      description: 'Format JSON with current settings',
    ),
    'cmd+shift+v': ShortcutDefinition(
      action: 'validate_json',
      description: 'Force validation refresh',
    ),
    'cmd+shift+r': ShortcutDefinition(
      action: 'auto_repair',
      description: 'Attempt auto-repair',
    ),

    // Copy operations
    'cmd+shift+c': ShortcutDefinition(
      action: 'copy_formatted',
      description: 'Copy formatted JSON',
    ),
    'cmd+alt+c': ShortcutDefinition(
      action: 'copy_minified',
      description: 'Copy minified JSON',
    ),
  };
}
```

#### Context-Specific Shortcuts

```dart
class ContextualShortcuts {
  // Schema validation shortcuts
  static const Map<String, ShortcutDefinition> schemaShortcuts = {
    'cmd+g': ShortcutDefinition(
      action: 'generate_schema',
      description: 'Generate schema from current JSON',
    ),
    'cmd+l': ShortcutDefinition(
      action: 'load_schema_library',
      description: 'Open schema library',
    ),
  };

  // JSONPath query shortcuts
  static const Map<String, ShortcutDefinition> jsonPathShortcuts = {
    'cmd+e': ShortcutDefinition(
      action: 'execute_query',
      description: 'Execute current query',
    ),
    'cmd+b': ShortcutDefinition(
      action: 'open_query_builder',
      description: 'Open visual query builder',
    ),
  };
}
```

### 3.2 Drag & Drop Interactions

#### File Handling

```dart
class DragDropHandling {
  static void configureDragDropZones() {
    // Main input area
    DragDropZone.configure(
      target: 'main-input',
      acceptedTypes: ['.json', '.txt', '.js', '.config'],
      onDrop: _handleMainInputDrop,
      visualFeedback: DropVisualFeedback.highlight,
    );

    // Schema input area
    DragDropZone.configure(
      target: 'schema-input',
      acceptedTypes: ['.json', '.schema'],
      onDrop: _handleSchemaInputDrop,
      visualFeedback: DropVisualFeedback.outline,
    );

    // Cross-tool drag targets
    DragDropZone.configure(
      target: 'export-targets',
      acceptedSources: ['formatted-json', 'validation-results'],
      onDrop: _handleExportDrop,
      showTargetTools: true,
    );
  }
}
```

### 3.3 Progressive Disclosure

#### Feature Discovery

```dart
class FeatureDiscovery {
  // Contextual feature hints
  static Widget buildFeatureHints(BuildContext context) {
    return FeatureHintSystem(
      hints: [
        FeatureHint(
          trigger: TriggerCondition.firstTimeUser,
          content: 'Welcome to JSON Doctor! Paste JSON here to get started.',
          targetWidget: 'main-input',
          dismissible: true,
        ),
        FeatureHint(
          trigger: TriggerCondition.validJsonDetected,
          content: 'Great! Try the Schema tab to validate against a schema.',
          targetWidget: 'schema-tab',
          delay: Duration(seconds: 2),
        ),
        FeatureHint(
          trigger: TriggerCondition.complexJsonDetected,
          content: 'Use JSONPath to query and extract specific data.',
          targetWidget: 'jsonpath-tab',
          showOnce: true,
        ),
      ],
    );
  }

  // Advanced feature revelation
  static Widget buildAdvancedFeatures(JsonDoctorStatus status) {
    switch (status) {
      case JsonDoctorStatus.valid:
        return AdvancedOptions(
          options: [
            'Format with custom settings',
            'Generate TypeScript interfaces',
            'Export to other tools',
            'Save as template',
          ],
        );
      case JsonDoctorStatus.invalid:
        return RepairOptions(
          options: [
            'View detailed error analysis',
            'Apply suggested fixes',
            'Learn about JSON syntax',
          ],
        );
      default:
        return Container();
    }
  }
}
```

## 4. Mobile & Responsive Design

### 4.1 Mobile-First Adaptations

#### Touch-Optimized Interface

```dart
class MobileOptimizations {
  static Widget buildMobileLayout() {
    return AdaptiveLayout(
      mobile: MobileJsonDoctor(
        inputMethod: InputMethod.modal, // Full-screen input
        tabNavigation: TabNavigation.bottom,
        toolbarPosition: ToolbarPosition.floating,
      ),
      tablet: TabletJsonDoctor(
        inputMethod: InputMethod.sideBySide,
        tabNavigation: TabNavigation.top,
        toolbarPosition: ToolbarPosition.integrated,
      ),
      desktop: DesktopJsonDoctor(
        inputMethod: InputMethod.multiPane,
        tabNavigation: TabNavigation.top,
        toolbarPosition: ToolbarPosition.toolbar,
      ),
    );
  }

  // Touch gesture support
  static void configureTouchGestures() {
    GestureRecognizer.configure([
      SwipeGesture(
        direction: SwipeDirection.left,
        action: () => _nextTab(),
        zones: ['tab-content'],
      ),
      SwipeGesture(
        direction: SwipeDirection.right,
        action: () => _previousTab(),
        zones: ['tab-content'],
      ),
      PinchGesture(
        action: (scale) => _adjustFontSize(scale),
        zones: ['code-editor'],
      ),
    ]);
  }
}
```

#### Responsive Breakpoints

```dart
class ResponsiveBreakpoints {
  static const Map<String, ScreenSize> breakpoints = {
    'mobile': ScreenSize(maxWidth: 768),
    'tablet': ScreenSize(minWidth: 769, maxWidth: 1024),
    'desktop': ScreenSize(minWidth: 1025),
  };

  // Layout adaptations per breakpoint
  static LayoutConfig getLayoutConfig(ScreenSize size) {
    if (size.width <= 768) {
      return MobileLayoutConfig(
        showSidebar: false,
        stackedTabs: true,
        compactToolbar: true,
        singlePaneInput: true,
      );
    } else if (size.width <= 1024) {
      return TabletLayoutConfig(
        showSidebar: true,
        stackedTabs: false,
        compactToolbar: false,
        dualPaneInput: true,
      );
    } else {
      return DesktopLayoutConfig(
        showSidebar: true,
        stackedTabs: false,
        fullToolbar: true,
        multiPaneInput: true,
      );
    }
  }
}
```

### 4.2 Accessibility Features

#### Screen Reader Support

```dart
class AccessibilityFeatures {
  static Widget buildAccessibleJsonEditor() {
    return Semantics(
      label: 'JSON input editor',
      hint: 'Type or paste JSON content here for validation',
      multiline: true,
      child: CodeEditor(
        accessibilityFeatures: [
          'screen-reader-optimized',
          'keyboard-navigation',
          'high-contrast-support',
          'error-announcements',
        ],
        onValidationChange: (isValid) {
          SemanticsService.announce(
            isValid ? 'JSON is valid' : 'JSON contains errors',
            TextDirection.ltr,
          );
        },
      ),
    );
  }

  // Keyboard navigation for complex interfaces
  static void configureKeyboardNavigation() {
    FocusTraversalPolicy.configure(
      order: [
        'input-area',
        'tab-navigation',
        'toolbar-actions',
        'output-area',
        'error-panel',
        'suggestions-panel',
      ],
    );
  }
}
```

## 5. Performance & Loading States

### 5.1 Loading State Management

#### Progressive Loading

```dart
class LoadingStates {
  static Widget buildLoadingProgress(JsonDoctorOperation operation) {
    switch (operation.type) {
      case OperationType.validation:
        return ValidationProgress(
          currentStep: operation.currentStep,
          totalSteps: operation.totalSteps,
          message: 'Analyzing JSON structure...',
        );

      case OperationType.schemaValidation:
        return SchemaValidationProgress(
          validatedPaths: operation.completedPaths,
          totalPaths: operation.totalPaths,
          currentPath: operation.currentPath,
        );

      case OperationType.jsonPathQuery:
        return QueryProgress(
          matchesFound: operation.matchesFound,
          nodesProcessed: operation.nodesProcessed,
          estimatedTotal: operation.estimatedTotal,
        );

      case OperationType.autoRepair:
        return RepairProgress(
          repairsAttempted: operation.repairsAttempted,
          repairsSuccessful: operation.repairsSuccessful,
          currentRepair: operation.currentRepair,
        );
    }
  }
}
```

#### Performance Optimization

```dart
class PerformanceOptimization {
  // Virtualized rendering for large JSON
  static Widget buildVirtualizedJsonView(String jsonContent) {
    return VirtualizedCodeView(
      content: jsonContent,
      syntax: 'json',
      virtualizeThreshold: 1000, // lines
      renderWindow: 100, // visible lines
      onDemandSyntaxHighlighting: true,
      memoryOptimized: true,
    );
  }

  // Debounced operations
  static void debounceOperation(String operationId, VoidCallback operation) {
    DebounceManager.schedule(
      operationId: operationId,
      operation: operation,
      delay: Duration(milliseconds: 300),
      cancelPrevious: true,
    );
  }
}
```

JSON Doctor's UX design balances power user efficiency with approachable beginner workflows, ensuring that both quick JSON validation tasks and complex schema analysis scenarios are handled with professional-grade user experience quality.
