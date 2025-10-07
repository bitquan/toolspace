import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'logic/unit_converter.dart';
import 'logic/unit_search.dart';
import 'logic/conversion_history.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  String _selectedCategory = 'Length';
  String _fromUnit = 'meter';
  String _toUnit = 'kilometer';
  final TextEditingController _inputController =
      TextEditingController(text: '1');
  String _result = '';
  int _precision = 2;

  final TextEditingController _searchController = TextEditingController();
  List<UnitSearchResult> _searchResults = [];
  bool _showSearchResults = false;
  String? _searchTarget; // 'from' or 'to'

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    _performConversion();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _inputController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _performConversion() {
    if (_inputController.text.isEmpty) {
      setState(() => _result = '');
      return;
    }

    final input = double.tryParse(_inputController.text);
    if (input == null) {
      setState(() => _result = 'Invalid input');
      return;
    }

    double convertedValue;
    if (_selectedCategory.toLowerCase() == 'temperature') {
      convertedValue =
          UnitConverter.convertTemperature(input, _fromUnit, _toUnit);
    } else {
      convertedValue =
          UnitConverter.convert(input, _fromUnit, _toUnit, _selectedCategory);
    }

    setState(() {
      _result = convertedValue.toStringAsFixed(_precision);
    });

    // Add to history
    ConversionHistory.add(ConversionPair(
      fromUnit: _fromUnit,
      toUnit: _toUnit,
      category: _selectedCategory,
    ));
  }

  void _swapUnits() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
    });
    _animationController.reset();
    _animationController.forward();
    _performConversion();
  }

  void _updateCategory(String category) {
    setState(() {
      _selectedCategory = category;
      final units = UnitConverter.getUnitsForCategory(category);
      if (units.isNotEmpty) {
        _fromUnit = units[0];
        _toUnit = units.length > 1 ? units[1] : units[0];
      }
    });
    _performConversion();
  }

  void _showUnitPicker(String target) {
    setState(() {
      _searchTarget = target;
      _searchController.clear();
      _searchResults = [];
      _showSearchResults = true;
    });
  }

  void _performSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = UnitSearch.search(query)
            .where((r) =>
                r.category.toLowerCase() == _selectedCategory.toLowerCase())
            .take(10)
            .toList();
      }
    });
  }

  void _selectSearchResult(UnitSearchResult result) {
    setState(() {
      if (_searchTarget == 'from') {
        _fromUnit = result.unit;
      } else {
        _toUnit = result.unit;
      }
      _showSearchResults = false;
      _searchController.clear();
      _searchResults = [];
    });
    _performConversion();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unit Converter'),
        backgroundColor: colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Category selector
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: UnitConverter.getCategories().length,
              itemBuilder: (context, index) {
                final category = UnitConverter.getCategories()[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) => _updateCategory(category),
                    selectedColor: colorScheme.primaryContainer,
                  ),
                );
              },
            ),
          ),

          // Main conversion area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Input card
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'From',
                              style: theme.textTheme.labelLarge,
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _inputController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                hintText: 'Enter value',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _inputController.clear();
                                    _performConversion();
                                  },
                                ),
                              ),
                              onChanged: (_) => _performConversion(),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () => _showUnitPicker('from'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: colorScheme.outline),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _fromUnit,
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                    Icon(Icons.arrow_drop_down,
                                        color: colorScheme.onSurface),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Swap button
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: IconButton(
                        icon: const Icon(Icons.swap_vert),
                        onPressed: _swapUnits,
                        iconSize: 32,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),

                  // Output card
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'To',
                              style: theme.textTheme.labelLarge,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _result.isEmpty ? '—' : _result,
                                      style: theme.textTheme.headlineSmall,
                                    ),
                                  ),
                                  if (_result.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.content_copy),
                                      onPressed: () {
                                        Clipboard.setData(
                                            ClipboardData(text: _result));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Copied to clipboard'),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () => _showUnitPicker('to'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: colorScheme.outline),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _toUnit,
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                    Icon(Icons.arrow_drop_down,
                                        color: colorScheme.onSurface),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Precision control
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Precision',
                                style: theme.textTheme.labelLarge,
                              ),
                              Text(
                                '$_precision decimal places',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          Slider(
                            value: _precision.toDouble(),
                            min: 0,
                            max: 10,
                            divisions: 10,
                            onChanged: (value) {
                              setState(() {
                                _precision = value.toInt();
                              });
                              _performConversion();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Conversion history
                  if (ConversionHistory.size > 0) ...[
                    Text(
                      'Recent Conversions',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Column(
                        children:
                            ConversionHistory.getRecent(limit: 5).map((pair) {
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.history, size: 20),
                            title: Text(
                              '${pair.fromUnit} → ${pair.toUnit}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            subtitle: Text(
                              pair.category,
                              style: theme.textTheme.bodySmall,
                            ),
                            onTap: () {
                              setState(() {
                                _selectedCategory = pair.category;
                                _fromUnit = pair.fromUnit;
                                _toUnit = pair.toUnit;
                              });
                              _performConversion();
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  // Popular conversions when no history
                  if (ConversionHistory.isEmpty) ...[
                    Text(
                      'Popular Conversions',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Column(
                        children:
                            UnitSearch.getPopularConversions().map((pair) {
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.trending_up, size: 20),
                            title: Text(
                              '${pair.fromUnit} → ${pair.toUnit}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            subtitle: Text(
                              pair.category,
                              style: theme.textTheme.bodySmall,
                            ),
                            onTap: () {
                              setState(() {
                                _selectedCategory = pair.category;
                                _fromUnit = pair.fromUnit;
                                _toUnit = pair.toUnit;
                              });
                              _performConversion();
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),

      // Search overlay
      floatingActionButton: _showSearchResults
          ? null
          : FloatingActionButton(
              onPressed: () => _showUnitPicker('from'),
              child: const Icon(Icons.search),
            ),
    );
  }

  // Search dialog widget moved to separate method for clarity
  // ignore: unused_element
  Widget _buildSearchDialog() {
    return Dialog(
      child: Container(
        height: 500,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search units...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() => _showSearchResults = false);
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: _performSearch,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _searchResults.isEmpty
                  ? Center(
                      child: Text(
                        _searchController.text.isEmpty
                            ? 'Type to search units'
                            : 'No results found',
                      ),
                    )
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        return ListTile(
                          title: Text(result.displayName),
                          subtitle: Text(result.category),
                          onTap: () => _selectSearchResult(result),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
