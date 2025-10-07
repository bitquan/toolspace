import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// URL Shortener - Create and manage short URLs (dev-only)
class UrlShortScreen extends StatefulWidget {
  const UrlShortScreen({super.key});

  @override
  State<UrlShortScreen> createState() => _UrlShortScreenState();
}

class _UrlShortScreenState extends State<UrlShortScreen>
    with TickerProviderStateMixin {
  final TextEditingController _urlController = TextEditingController();
  final List<ShortUrl> _urls = [];

  bool _isLoading = false;
  final bool _isDevUser = true; // TODO: Implement actual dev user check
  String? _validationError;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _urlController.addListener(_onUrlChanged);
    _loadUrls();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _onUrlChanged() {
    setState(() {
      _validationError = _validateUrl(_urlController.text);
    });
  }

  String? _validateUrl(String url) {
    if (url.isEmpty) {
      return null;
    }

    // Basic URL validation
    final urlPattern = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );

    if (!urlPattern.hasMatch(url)) {
      return 'Please enter a valid URL';
    }

    if (url.length > 2048) {
      return 'URL is too long (max 2048 characters)';
    }

    return null;
  }

  Future<void> _loadUrls() async {
    if (!_isDevUser) return;

    setState(() {
      _isLoading = true;
    });

    // TODO: Load URLs from backend
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _shortenUrl() async {
    final url = _urlController.text.trim();
    final error = _validateUrl(url);

    if (error != null) {
      _showError(error);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Call backend to create short URL
      await Future.delayed(const Duration(seconds: 1));

      // Generate mock short code
      final shortCode = _generateShortCode();
      final shortUrl = ShortUrl(
        id: DateTime.now().toString(),
        originalUrl: url,
        shortCode: shortCode,
        createdAt: DateTime.now(),
      );

      setState(() {
        _urls.insert(0, shortUrl);
        _urlController.clear();
        _validationError = null;
      });

      _bounceController.forward().then((_) => _bounceController.reverse());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Short URL created: /u/$shortCode'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Copy',
              textColor: Colors.white,
              onPressed: () => _copyToClipboard(shortUrl),
            ),
          ),
        );
      }
    } catch (e) {
      _showError('Failed to create short URL: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _generateShortCode() {
    // Simple random code generator (6 characters)
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(
          DateTime.now().microsecondsSinceEpoch % chars.length,
        ),
      ),
    );
  }

  void _copyToClipboard(ShortUrl url) {
    final shortUrl = 'https://toolspace.app/u/${url.shortCode}';
    Clipboard.setData(ClipboardData(text: shortUrl));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Short URL copied to clipboard!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteUrl(ShortUrl url) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Short URL'),
        content: Text('Delete /u/${url.shortCode}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        // TODO: Call backend to delete URL
        await Future.delayed(const Duration(milliseconds: 500));

        setState(() {
          _urls.remove(url);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Short URL deleted'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        _showError('Failed to delete URL: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_isDevUser) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('URL Shortener'),
          backgroundColor: theme.colorScheme.inversePrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Dev Access Only',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'This tool is only available to developers',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('URL Shortener'),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.code,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'DEV',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // URL Input Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    labelText: 'Enter URL to shorten',
                    hintText: 'https://example.com/very/long/url',
                    errorText: _validationError,
                    prefixIcon: const Icon(Icons.link),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _shortenUrl(),
                ),
                const SizedBox(height: 16),
                AnimatedBuilder(
                  animation: _bounceAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _bounceAnimation.value,
                      child: child,
                    );
                  },
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _shortenUrl,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.content_cut),
                    label: Text(_isLoading ? 'Creating...' : 'Shorten URL'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // URL List Section
          Expanded(
            child: _urls.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.link_off,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No short URLs yet',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter a URL above to get started',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _urls.length,
                    itemBuilder: (context, index) {
                      final url = _urls[index];
                      return _UrlCard(
                        url: url,
                        onCopy: () => _copyToClipboard(url),
                        onDelete: () => _deleteUrl(url),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Card widget for displaying a short URL
class _UrlCard extends StatefulWidget {
  final ShortUrl url;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  const _UrlCard({
    required this.url,
    required this.onCopy,
    required this.onDelete,
  });

  @override
  State<_UrlCard> createState() => _UrlCardState();
}

class _UrlCardState extends State<_UrlCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Card(
        elevation: _isHovered ? 4 : 1,
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Short URL
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.link,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '/u/${widget.url.shortCode}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.url.originalUrl,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Actions
              Row(
                children: [
                  Text(
                    _formatDate(widget.url.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: widget.onCopy,
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copy'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: widget.onDelete,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Model for short URL data
class ShortUrl {
  final String id;
  final String originalUrl;
  final String shortCode;
  final DateTime createdAt;

  ShortUrl({
    required this.id,
    required this.originalUrl,
    required this.shortCode,
    required this.createdAt,
  });
}
