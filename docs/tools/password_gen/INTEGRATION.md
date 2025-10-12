# Password Generator - Integration Architecture

This document details the integration patterns, data flow, and communication protocols for the Password Generator tool within the Toolspace ecosystem and external systems.

## ShareBus Integration

### Data Broadcasting

The Password Generator publishes password data to the ShareBus system for consumption by other tools, enabling seamless cross-tool workflows and data sharing.

**Password Generation Event**

```dart
// Single password broadcast
void _broadcastGeneratedPassword(String password, PasswordConfig config) {
  final data = PasswordGenerationData(
    type: 'password_generated',
    source: 'password_gen',
    timestamp: DateTime.now(),
    password: password,
    configuration: config,
    entropy: PasswordGenerator.calculateEntropy(password),
    strength: PasswordGenerator.getStrengthLabel(password),
    metadata: PasswordMetadata(
      characterCount: password.length,
      characterSets: config.getEnabledCharacterSets(),
      ambiguousFiltered: config.avoidAmbiguous,
      generationDuration: _lastGenerationDuration,
    ),
  );

  ShareBus.instance.broadcast('password.generated', data);
}
```

**Batch Generation Event**

```dart
// Batch password broadcast
void _broadcastBatchGeneration(List<String> passwords, PasswordConfig config) {
  final batchData = BatchPasswordData(
    type: 'password_batch_generated',
    source: 'password_gen',
    timestamp: DateTime.now(),
    passwords: passwords,
    configuration: config,
    batchMetrics: BatchMetrics(
      count: passwords.length,
      averageEntropy: _calculateAverageEntropy(passwords),
      entropyRange: _calculateEntropyRange(passwords),
      generationTime: _batchGenerationDuration,
    ),
  );

  ShareBus.instance.broadcast('password.batch_generated', batchData);
}
```

### Data Structures

**Core Password Data Model**

```dart
class PasswordGenerationData {
  final String type;
  final String source;
  final DateTime timestamp;
  final String password;
  final PasswordConfig configuration;
  final double entropy;
  final String strength;
  final PasswordMetadata metadata;

  const PasswordGenerationData({
    required this.type,
    required this.source,
    required this.timestamp,
    required this.password,
    required this.configuration,
    required this.entropy,
    required this.strength,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'source': source,
    'timestamp': timestamp.toIso8601String(),
    'password': password,
    'configuration': configuration.toJson(),
    'entropy': entropy,
    'strength': strength,
    'metadata': metadata.toJson(),
  };
}
```

**Password Metadata**

```dart
class PasswordMetadata {
  final int characterCount;
  final List<String> characterSets;
  final bool ambiguousFiltered;
  final Duration generationDuration;
  final String? context; // Optional context for password usage

  const PasswordMetadata({
    required this.characterCount,
    required this.characterSets,
    required this.ambiguousFiltered,
    required this.generationDuration,
    this.context,
  });

  Map<String, dynamic> toJson() => {
    'character_count': characterCount,
    'character_sets': characterSets,
    'ambiguous_filtered': ambiguousFiltered,
    'generation_duration_ms': generationDuration.inMilliseconds,
    'context': context,
  };
}
```

**Batch Password Data**

```dart
class BatchPasswordData {
  final String type;
  final String source;
  final DateTime timestamp;
  final List<String> passwords;
  final PasswordConfig configuration;
  final BatchMetrics batchMetrics;

  Map<String, dynamic> toJson() => {
    'type': type,
    'source': source,
    'timestamp': timestamp.toIso8601String(),
    'passwords': passwords,
    'configuration': configuration.toJson(),
    'batch_metrics': batchMetrics.toJson(),
  };
}

class BatchMetrics {
  final int count;
  final double averageEntropy;
  final EntropyRange entropyRange;
  final Duration generationTime;

  Map<String, dynamic> toJson() => {
    'count': count,
    'average_entropy': averageEntropy,
    'entropy_range': entropyRange.toJson(),
    'generation_time_ms': generationTime.inMilliseconds,
  };
}
```

### Event Listeners

**Password Request Handling**

```dart
// Listen for password requests from other tools
class PasswordGenShareBusListener {
  static void initialize() {
    ShareBus.instance.listen('password.request', _handlePasswordRequest);
    ShareBus.instance.listen('password.batch_request', _handleBatchRequest);
    ShareBus.instance.listen('password.validate', _handlePasswordValidation);
  }

  static Future<void> _handlePasswordRequest(Map<String, dynamic> request) async {
    try {
      final config = PasswordConfig.fromJson(request['configuration']);
      final context = request['context'] as String?;
      final requestId = request['request_id'] as String;

      // Generate password based on request
      final password = PasswordGenerator.generate(config);

      // Respond with generated password
      ShareBus.instance.respond(requestId, {
        'success': true,
        'password': password,
        'entropy': PasswordGenerator.calculateEntropy(password),
        'strength': PasswordGenerator.getStrengthLabel(password),
        'generated_at': DateTime.now().toIso8601String(),
        'context': context,
      });
    } catch (e) {
      ShareBus.instance.respond(request['request_id'], {
        'success': false,
        'error': e.toString(),
      });
    }
  }
}
```

## Cross-Tool Communication

### Integration with Text Tools

**Text Template Password Injection**

```dart
// Text Tools can request passwords for template variables
class TextToolsIntegration {
  static Future<String> injectPasswordsIntoTemplate(String template) async {
    final passwordRegex = RegExp(r'\{\{password:([^}]+)\}\}');

    String result = template;

    for (final match in passwordRegex.allMatches(template)) {
      final configString = match.group(1)!;
      final config = _parsePasswordConfig(configString);

      // Request password from Password Generator
      final password = await _requestPassword(config);
      result = result.replaceFirst(match.group(0)!, password);
    }

    return result;
  }

  static PasswordConfig _parsePasswordConfig(String configString) {
    // Parse config like "length:16,uppercase:true,symbols:false"
    final params = Map<String, String>.fromEntries(
      configString.split(',').map((pair) {
        final parts = pair.split(':');
        return MapEntry(parts[0].trim(), parts[1].trim());
      }),
    );

    return PasswordConfig(
      length: int.parse(params['length'] ?? '16'),
      includeUppercase: params['uppercase']?.toLowerCase() == 'true',
      includeLowercase: params['lowercase']?.toLowerCase() != 'false',
      includeDigits: params['digits']?.toLowerCase() != 'false',
      includeSymbols: params['symbols']?.toLowerCase() == 'true',
      avoidAmbiguous: params['ambiguous']?.toLowerCase() == 'false',
    );
  }
}
```

### Integration with JSON Doctor

**JSON Secret Field Population**

```dart
// JSON Doctor can request passwords for secret fields
class JsonDoctorIntegration {
  static Future<Map<String, dynamic>> populateSecretFields(
    Map<String, dynamic> jsonData,
    List<String> secretFields,
  ) async {
    final result = Map<String, dynamic>.from(jsonData);

    for (final fieldPath in secretFields) {
      if (_isPasswordField(fieldPath)) {
        final config = _determinePasswordConfig(fieldPath);
        final password = await _requestSecurePassword(config);

        _setNestedValue(result, fieldPath, password);
      }
    }

    return result;
  }

  static bool _isPasswordField(String fieldPath) {
    final passwordPatterns = [
      'password', 'secret', 'key', 'token', 'credential'
    ];
    return passwordPatterns.any(
      (pattern) => fieldPath.toLowerCase().contains(pattern)
    );
  }

  static PasswordConfig _determinePasswordConfig(String fieldPath) {
    // API keys typically need longer, symbol-heavy passwords
    if (fieldPath.contains('api') || fieldPath.contains('key')) {
      return const PasswordConfig(
        length: 32,
        includeUppercase: true,
        includeLowercase: true,
        includeDigits: true,
        includeSymbols: true,
        avoidAmbiguous: true, // For clarity in configuration files
      );
    }

    // Standard user passwords
    return const PasswordConfig(
      length: 16,
      includeUppercase: true,
      includeLowercase: true,
      includeDigits: true,
      includeSymbols: false, // Avoid symbols for user passwords
    );
  }
}
```

### Integration with File Merger

**Encrypted File Password Generation**

```dart
// File Merger can request passwords for file encryption
class FileMergerIntegration {
  static Future<Map<String, String>> generateFilePasswords(
    List<String> fileNames,
  ) async {
    final passwords = <String, String>{};

    // Generate unique password for each file
    for (final fileName in fileNames) {
      final config = _getEncryptionPasswordConfig(fileName);
      final password = await _requestPassword(config);
      passwords[fileName] = password;
    }

    // Broadcast batch encryption event
    ShareBus.instance.broadcast('file_encryption.passwords_generated', {
      'file_count': fileNames.length,
      'files': fileNames,
      'generated_at': DateTime.now().toIso8601String(),
    });

    return passwords;
  }

  static PasswordConfig _getEncryptionPasswordConfig(String fileName) {
    // Strong encryption passwords for files
    return const PasswordConfig(
      length: 24,
      includeUppercase: true,
      includeLowercase: true,
      includeDigits: true,
      includeSymbols: true,
      avoidAmbiguous: false, // Full character set for encryption
    );
  }
}
```

## API Integration

### RESTful Password Service

**Password Generation Endpoint**

```dart
// Future: REST API for password generation
class PasswordGenAPI {
  static const String baseUrl = '/api/v1/password-gen';

  // Generate single password
  static Future<PasswordResponse> generatePassword(
    PasswordConfig config,
    {String? context}
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'configuration': config.toJson(),
        'context': context,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      return PasswordResponse.fromJson(jsonDecode(response.body));
    } else {
      throw PasswordGenerationException(
        'Failed to generate password: ${response.body}'
      );
    }
  }

  // Generate password batch
  static Future<BatchPasswordResponse> generateBatch(
    PasswordConfig config,
    int count,
    {String? context}
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/batch'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'configuration': config.toJson(),
        'count': count,
        'context': context,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      return BatchPasswordResponse.fromJson(jsonDecode(response.body));
    } else {
      throw PasswordGenerationException(
        'Failed to generate password batch: ${response.body}'
      );
    }
  }
}
```

**API Response Models**

```dart
class PasswordResponse {
  final String password;
  final double entropy;
  final String strength;
  final DateTime generatedAt;
  final Duration generationTime;
  final String? context;

  const PasswordResponse({
    required this.password,
    required this.entropy,
    required this.strength,
    required this.generatedAt,
    required this.generationTime,
    this.context,
  });

  factory PasswordResponse.fromJson(Map<String, dynamic> json) =>
    PasswordResponse(
      password: json['password'],
      entropy: json['entropy'].toDouble(),
      strength: json['strength'],
      generatedAt: DateTime.parse(json['generated_at']),
      generationTime: Duration(milliseconds: json['generation_time_ms']),
      context: json['context'],
    );
}

class BatchPasswordResponse {
  final List<String> passwords;
  final int count;
  final BatchMetrics metrics;
  final DateTime generatedAt;
  final String? context;

  factory BatchPasswordResponse.fromJson(Map<String, dynamic> json) =>
    BatchPasswordResponse(
      passwords: List<String>.from(json['passwords']),
      count: json['count'],
      metrics: BatchMetrics.fromJson(json['metrics']),
      generatedAt: DateTime.parse(json['generated_at']),
      context: json['context'],
    );
}
```

### Webhook Integration

**Password Generation Webhooks**

```dart
// Future: Webhook notifications for enterprise integrations
class PasswordGenWebhooks {
  static Future<void> notifyPasswordGeneration(
    PasswordGenerationData data,
    String userId,
  ) async {
    final webhookConfig = await WebhookService.getConfig('password_generated');

    if (webhookConfig != null && webhookConfig.enabled) {
      final payload = {
        'event': 'password_generated',
        'user_id': userId,
        'timestamp': data.timestamp.toIso8601String(),
        'password_metadata': {
          'length': data.configuration.length,
          'character_sets': data.configuration.getEnabledCharacterSets(),
          'entropy': data.entropy,
          'strength': data.strength,
        },
        'context': data.metadata.context,
      };

      try {
        await http.post(
          Uri.parse(webhookConfig.url),
          headers: {
            'Content-Type': 'application/json',
            'X-Webhook-Signature': _generateSignature(payload, webhookConfig.secret),
          },
          body: jsonEncode(payload),
        );
      } catch (e) {
        logger.warning('Failed to send password generation webhook: $e');
      }
    }
  }

  static String _generateSignature(Map<String, dynamic> payload, String secret) {
    final payloadString = jsonEncode(payload);
    final hmac = Hmac(sha256, utf8.encode(secret));
    final digest = hmac.convert(utf8.encode(payloadString));
    return 'sha256=$digest';
  }
}
```

## Database Integration

### Password History Storage

**Local Storage Schema**

```dart
// SQLite schema for password history (optional feature)
class PasswordHistoryDB {
  static const String createTableSQL = '''
    CREATE TABLE password_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      password_hash TEXT NOT NULL,
      configuration TEXT NOT NULL,
      entropy REAL NOT NULL,
      strength TEXT NOT NULL,
      generated_at TEXT NOT NULL,
      context TEXT,
      user_id TEXT,
      expires_at TEXT
    );
  ''';

  static const String createIndexSQL = '''
    CREATE INDEX idx_password_history_user_generated
    ON password_history(user_id, generated_at);
  ''';
}

class PasswordHistoryService {
  static Future<void> storePasswordGeneration(
    PasswordGenerationData data,
    String userId,
  ) async {
    final db = await DatabaseService.instance.database;

    // Store only hash for security, not the actual password
    final passwordHash = sha256.convert(utf8.encode(data.password)).toString();

    await db.insert('password_history', {
      'password_hash': passwordHash,
      'configuration': jsonEncode(data.configuration.toJson()),
      'entropy': data.entropy,
      'strength': data.strength,
      'generated_at': data.timestamp.toIso8601String(),
      'context': data.metadata.context,
      'user_id': userId,
      'expires_at': _calculateExpiryDate().toIso8601String(),
    });
  }

  static DateTime _calculateExpiryDate() {
    // Password history expires after 30 days
    return DateTime.now().add(const Duration(days: 30));
  }
}
```

### Analytics Storage

**Password Generation Analytics**

```dart
// Analytics for password generation patterns
class PasswordGenAnalytics {
  static Future<void> recordPasswordGeneration(
    PasswordConfig config,
    double entropy,
    String userId,
  ) async {
    final analyticsData = {
      'event': 'password_generated',
      'user_id': userId,
      'timestamp': DateTime.now().toIso8601String(),
      'properties': {
        'password_length': config.length,
        'character_sets': config.getEnabledCharacterSets(),
        'entropy': entropy,
        'strength_category': PasswordGenerator.getStrengthCategory(entropy),
        'ambiguous_filtered': config.avoidAmbiguous,
        'generation_method': 'single',
      },
    };

    await AnalyticsService.record(analyticsData);
  }

  static Future<void> recordBatchGeneration(
    PasswordConfig config,
    List<String> passwords,
    String userId,
  ) async {
    final averageEntropy = passwords.fold<double>(
      0.0,
      (sum, password) => sum + PasswordGenerator.calculateEntropy(password),
    ) / passwords.length;

    final analyticsData = {
      'event': 'password_batch_generated',
      'user_id': userId,
      'timestamp': DateTime.now().toIso8601String(),
      'properties': {
        'batch_size': passwords.length,
        'password_length': config.length,
        'character_sets': config.getEnabledCharacterSets(),
        'average_entropy': averageEntropy,
        'ambiguous_filtered': config.avoidAmbiguous,
        'generation_method': 'batch',
      },
    };

    await AnalyticsService.record(analyticsData);
  }
}
```

## Security Integration

### Authentication Integration

**User Context in Password Generation**

```dart
// Integrate with authentication system for user-specific features
class AuthenticatedPasswordGen {
  static Future<String> generatePasswordForUser(
    PasswordConfig config,
    String userId,
  ) async {
    // Validate user permissions
    final user = await AuthService.getUser(userId);
    if (user == null) {
      throw UnauthorizedException('User not found');
    }

    // Check billing tier limitations
    final allowedLength = PasswordGenQuotas.getMaxLength(user.plan);
    if (config.length > allowedLength) {
      throw QuotaExceededException(
        'Password length ${config.length} exceeds plan limit $allowedLength'
      );
    }

    // Generate password
    final password = PasswordGenerator.generate(config);

    // Record generation for analytics and billing
    await PasswordGenAnalytics.recordPasswordGeneration(
      config,
      PasswordGenerator.calculateEntropy(password),
      userId,
    );

    // Optional: Store in history
    if (user.preferences.storePasswordHistory) {
      await PasswordHistoryService.storePasswordGeneration(
        PasswordGenerationData(
          type: 'password_generated',
          source: 'password_gen',
          timestamp: DateTime.now(),
          password: password,
          configuration: config,
          entropy: PasswordGenerator.calculateEntropy(password),
          strength: PasswordGenerator.getStrengthLabel(password),
          metadata: PasswordMetadata(
            characterCount: password.length,
            characterSets: config.getEnabledCharacterSets(),
            ambiguousFiltered: config.avoidAmbiguous,
            generationDuration: Duration.zero, // Placeholder
          ),
        ),
        userId,
      );
    }

    return password;
  }
}
```

### Audit Trail Integration

**Security Audit Logging**

```dart
// Comprehensive audit logging for enterprise security
class PasswordGenAuditLogger {
  static Future<void> logPasswordGeneration(
    PasswordGenerationData data,
    String userId,
    String ipAddress,
  ) async {
    final auditEntry = AuditLogEntry(
      eventType: 'password_generation',
      userId: userId,
      timestamp: DateTime.now(),
      ipAddress: ipAddress,
      userAgent: await DeviceInfoService.getUserAgent(),
      details: {
        'password_length': data.configuration.length,
        'character_sets': data.configuration.getEnabledCharacterSets(),
        'entropy': data.entropy,
        'strength': data.strength,
        'context': data.metadata.context,
        'ambiguous_filtered': data.configuration.avoidAmbiguous,
      },
      riskLevel: _calculateRiskLevel(data),
    );

    await AuditLogger.log(auditEntry);
  }

  static String _calculateRiskLevel(PasswordGenerationData data) {
    if (data.entropy < 40) return 'HIGH'; // Weak passwords
    if (data.entropy < 60) return 'MEDIUM'; // Moderate passwords
    return 'LOW'; // Strong passwords
  }
}
```

## Export Integration

### Password Manager Export

**Multi-Format Export Support**

```dart
// Export passwords to various password manager formats
class PasswordManagerExporter {
  static Future<String> exportTo1Password(List<String> passwords) async {
    final export = {
      'accounts': [
        {
          'attrs': {},
          'vaults': [
            {
              'attrs': {
                'uuid': _generateUUID(),
                'desc': 'Toolspace Generated Passwords',
                'avatar': '',
                'name': 'Toolspace',
              },
              'items': passwords.asMap().entries.map((entry) => {
                'uuid': _generateUUID(),
                'favIndex': 0,
                'createdAt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
                'updatedAt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
                'state': 'active',
                'categoryUuid': '001', // Login category
                'details': {
                  'loginFields': [],
                  'notesPlain': 'Generated by Toolspace Password Generator',
                  'passwordHistory': [],
                  'sections': [
                    {
                      'title': '',
                      'fields': [
                        {
                          'title': 'password',
                          'id': 'password',
                          'value': {
                            'string': entry.value,
                          },
                          'indexAtSource': 0,
                          'guarded': true,
                          'multiline': false,
                          'dontGenerate': false,
                          'inputTraits': {
                            'keyboard': 'default',
                            'correction': 'default',
                            'capitalization': 'default',
                          },
                        },
                      ],
                    },
                  ],
                },
                'overview': {
                  'subtitle': '',
                  'title': 'Generated Password ${entry.key + 1}',
                  'url': '',
                  'ps': 0,
                  'pbe': 0.0,
                  'pgrng': false,
                },
              }).toList(),
            },
          ],
        },
      ],
    };

    return jsonEncode(export);
  }

  static Future<String> exportToBitwarden(List<String> passwords) async {
    final export = {
      'encrypted': false,
      'folders': [],
      'items': passwords.asMap().entries.map((entry) => {
        'id': _generateUUID(),
        'organizationId': null,
        'folderId': null,
        'type': 1, // Login type
        'name': 'Generated Password ${entry.key + 1}',
        'notes': 'Generated by Toolspace Password Generator on ${DateTime.now().toIso8601String()}',
        'favorite': false,
        'login': {
          'username': null,
          'password': entry.value,
          'totp': null,
        },
        'collectionIds': [],
      }).toList(),
    };

    return jsonEncode(export);
  }

  static Future<String> exportToCSV(
    List<String> passwords,
    {List<String>? labels}
  ) async {
    final buffer = StringBuffer();
    buffer.writeln('Title,Username,Password,URL,Notes');

    for (int i = 0; i < passwords.length; i++) {
      final title = labels?[i] ?? 'Generated Password ${i + 1}';
      final password = passwords[i];
      final notes = 'Generated by Toolspace on ${DateTime.now().toLocal()}';

      buffer.writeln('"$title","","$password","","$notes"');
    }

    return buffer.toString();
  }
}
```

### Cloud Storage Integration

**Encrypted Cloud Backup**

```dart
// Future: Encrypted cloud storage for password history
class PasswordCloudStorage {
  static Future<void> backupPasswordHistory(
    String userId,
    List<PasswordHistoryEntry> entries,
  ) async {
    // Encrypt password history before cloud storage
    final encryptionKey = await KeyManager.getUserEncryptionKey(userId);
    final encryptedData = await EncryptionService.encrypt(
      jsonEncode(entries.map((e) => e.toJson()).toList()),
      encryptionKey,
    );

    // Upload to cloud storage
    await CloudStorageService.upload(
      path: 'password_history/$userId/backup.enc',
      data: encryptedData,
      metadata: {
        'user_id': userId,
        'backup_date': DateTime.now().toIso8601String(),
        'entry_count': entries.length,
        'encryption_version': EncryptionService.currentVersion,
      },
    );
  }

  static Future<List<PasswordHistoryEntry>> restorePasswordHistory(
    String userId,
  ) async {
    try {
      final encryptedData = await CloudStorageService.download(
        'password_history/$userId/backup.enc',
      );

      final encryptionKey = await KeyManager.getUserEncryptionKey(userId);
      final decryptedJson = await EncryptionService.decrypt(
        encryptedData,
        encryptionKey,
      );

      final entriesJson = jsonDecode(decryptedJson) as List;
      return entriesJson
          .map((json) => PasswordHistoryEntry.fromJson(json))
          .toList();
    } catch (e) {
      logger.warning('Failed to restore password history: $e');
      return [];
    }
  }
}
```

## Error Handling & Resilience

### Integration Error Management

**Graceful Degradation**

```dart
// Handle integration failures gracefully
class PasswordGenIntegrationErrorHandler {
  static Future<String> generatePasswordWithFallback(
    PasswordConfig config,
    {String? context}
  ) async {
    try {
      // Try primary generation method
      return await PasswordGenerator.generate(config);
    } catch (e) {
      logger.warning('Primary password generation failed: $e');

      // Fallback to simplified generation
      return await _generateFallbackPassword(config);
    }
  }

  static Future<String> _generateFallbackPassword(PasswordConfig config) async {
    // Simplified generation without advanced features
    final simplifiedConfig = PasswordConfig(
      length: math.max(8, math.min(config.length, 32)),
      includeUppercase: true,
      includeLowercase: true,
      includeDigits: true,
      includeSymbols: false, // Simplified character set
      avoidAmbiguous: false,
    );

    return PasswordGenerator.generateBasic(simplifiedConfig);
  }
}
```

**Retry Mechanisms**

```dart
// Retry logic for network-dependent integrations
class IntegrationRetryHandler {
  static Future<T> withRetry<T>(
    Future<T> Function() operation,
    {int maxRetries = 3, Duration delay = const Duration(seconds: 1)}
  ) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await operation();
      } catch (e) {
        if (attempt == maxRetries) {
          rethrow;
        }

        await Future.delayed(delay * attempt);
      }
    }

    throw StateError('Should not reach here');
  }
}
```
