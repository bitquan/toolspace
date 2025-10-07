import 'package:flutter/material.dart';
import 'logic/password_generator.dart';
import '../../core/ui/clipboard_btn.dart';

class PasswordGenScreen extends StatefulWidget {
  const PasswordGenScreen({super.key});

  @override
  State<PasswordGenScreen> createState() => _PasswordGenScreenState();
}

class _PasswordGenScreenState extends State<PasswordGenScreen>
    with SingleTickerProviderStateMixin {
  int _length = 16;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeDigits = true;
  bool _includeSymbols = true;
  bool _avoidAmbiguous = false;

  String _generatedPassword = '';
  List<String> _batchPasswords = [];

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _generatePassword();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  PasswordConfig get _config => PasswordConfig(
        length: _length,
        includeUppercase: _includeUppercase,
        includeLowercase: _includeLowercase,
        includeDigits: _includeDigits,
        includeSymbols: _includeSymbols,
        avoidAmbiguous: _avoidAmbiguous,
      );

  void _generatePassword() {
    if (!_config.isValid()) {
      setState(() {
        _generatedPassword = '';
        _batchPasswords = [];
      });
      return;
    }

    setState(() {
      _generatedPassword = PasswordGenerator.generate(_config);
      _batchPasswords = [];
    });

    _animationController.forward(from: 0);
  }

  void _generateBatch() {
    if (!_config.isValid()) {
      return;
    }

    setState(() {
      _batchPasswords = PasswordGenerator.generateBatch(_config, count: 20);
      _generatedPassword = '';
    });

    _animationController.forward(from: 0);
  }

  double get _entropy => PasswordGenerator.calculateCharsetEntropy(_config);
  String get _strengthLabel => PasswordGenerator.getStrengthLabel(_entropy);
  int get _strengthScore => PasswordGenerator.getStrengthScore(_entropy);

  Color _getStrengthColor() {
    if (_strengthLabel == 'weak') return Colors.red;
    if (_strengthLabel == 'moderate') return Colors.orange;
    if (_strengthLabel == 'strong') return Colors.lightGreen;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final validationError = _config.getValidationError();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Generator'),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Configuration Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password Settings',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    // Length Slider
                    Text('Length: $_length characters'),
                    Slider(
                      value: _length.toDouble(),
                      min: 8,
                      max: 128,
                      divisions: 120,
                      label: _length.toString(),
                      onChanged: (value) {
                        setState(() {
                          _length = value.round();
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Character Set Toggles
                    Text(
                      'Character Sets',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: const Text('Uppercase (A-Z)'),
                      value: _includeUppercase,
                      onChanged: (value) {
                        setState(() {
                          _includeUppercase = value ?? true;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Lowercase (a-z)'),
                      value: _includeLowercase,
                      onChanged: (value) {
                        setState(() {
                          _includeLowercase = value ?? true;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Digits (0-9)'),
                      value: _includeDigits,
                      onChanged: (value) {
                        setState(() {
                          _includeDigits = value ?? true;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Symbols (!@#\$%^&*)'),
                      value: _includeSymbols,
                      onChanged: (value) {
                        setState(() {
                          _includeSymbols = value ?? true;
                        });
                      },
                    ),
                    const Divider(),
                    CheckboxListTile(
                      title: const Text('Avoid ambiguous characters'),
                      subtitle: const Text('Excludes: 0, O, 1, l, I'),
                      value: _avoidAmbiguous,
                      onChanged: (value) {
                        setState(() {
                          _avoidAmbiguous = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Entropy Meter Card
            if (_config.isValid())
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Password Strength',
                            style: theme.textTheme.titleMedium,
                          ),
                          Chip(
                            label: Text(
                              _strengthLabel.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: _getStrengthColor(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: _strengthScore / 100,
                        backgroundColor: Colors.grey[300],
                        color: _getStrengthColor(),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Entropy: ${_entropy.toStringAsFixed(1)} bits',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),

            // Validation Error
            if (validationError != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Card(
                  color: Colors.orange[100],
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            validationError,
                            style: const TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _config.isValid() ? _generatePassword : null,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Generate'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _config.isValid() ? _generateBatch : null,
                    icon: const Icon(Icons.batch_prediction),
                    label: const Text('Generate 20'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Single Password Display
            if (_generatedPassword.isNotEmpty)
              ScaleTransition(
                scale: _scaleAnimation,
                child: Card(
                  elevation: 3,
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Generated Password',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SelectableText(
                            _generatedPassword,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipboardButton(
                          text: _generatedPassword,
                          label: 'Copy Password',
                          icon: Icons.copy,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Batch Passwords Display
            if (_batchPasswords.isNotEmpty)
              ScaleTransition(
                scale: _scaleAnimation,
                child: Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Batch Generated (${_batchPasswords.length})',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 400),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: _batchPasswords.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final password = _batchPasswords[index];
                              return ListTile(
                                dense: true,
                                leading: CircleAvatar(
                                  radius: 14,
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                title: Text(
                                  password,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                  ),
                                ),
                                trailing: ClipboardButton(
                                  text: password,
                                  compact: true,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipboardButton(
                          text: _batchPasswords.join('\n'),
                          label: 'Copy All Passwords',
                          icon: Icons.copy_all,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
