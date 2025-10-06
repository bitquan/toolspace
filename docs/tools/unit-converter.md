# Unit Converter Documentation

## Overview

Unit Converter is a comprehensive unit conversion tool supporting multiple measurement categories with smart search functionality. All conversions are performed client-side with instant results.

## Features

### 1. Multiple Categories

The tool supports 7 major unit categories:

- **Length**: meter, kilometer, centimeter, millimeter, mile, yard, foot, inch, nautical mile
- **Mass**: kilogram, gram, milligram, ton, pound, ounce, stone
- **Temperature**: celsius, fahrenheit, kelvin
- **Data Storage**: byte, kilobyte, megabyte, gigabyte, terabyte, petabyte, bit, kilobit, megabit, gigabit
- **Time**: second, millisecond, microsecond, nanosecond, minute, hour, day, week, month, year
- **Area**: square meter, square kilometer, square centimeter, hectare, acre, square mile, square foot
- **Volume**: liter, milliliter, cubic meter, gallon, quart, pint, cup, fluid ounce, tablespoon, teaspoon

### 2. Smart Fuzzy Search

Quickly find units using intelligent search:

- **Exact Match**: Type full unit name for precise matches
- **Partial Match**: Search with partial text (e.g., "kilo" finds kilometer, kilogram, kilobyte)
- **Alias Support**: Use common abbreviations (e.g., "km" for kilometer, "kg" for kilogram, "°C" for celsius)
- **Category Filtering**: Search results filtered by selected category
- **Ranked Results**: Most relevant matches appear first

**Example Searches:**
```
"m" → meter, mile, millimeter, minute
"kg" → kilogram
"ft" → foot
"°f" → fahrenheit
```

### 3. Bidirectional Conversion

Convert between any units in a category:

- **Live Updates**: Results update automatically as you type
- **Swap Function**: Quick swap button to reverse conversion direction
- **High Precision**: Accurate conversions using standard conversion factors

**Example Conversions:**
```
Length:
  1 kilometer = 0.621 miles
  100 centimeters = 1 meter

Temperature:
  0°C = 32°F = 273.15K
  100°C = 212°F

Data Storage:
  1 gigabyte = 1024 megabytes
  8 bits = 1 byte
```

### 4. Precision Control

Adjust decimal places for results:

- **Range**: 0 to 10 decimal places
- **Slider Control**: Easy adjustment with visual feedback
- **Default**: 2 decimal places
- **Real-time Updates**: Results refresh immediately when precision changes

### 5. Conversion History

Track your recent conversions:

- **Recent Pairs**: Shows last 20 conversion pairs
- **Quick Access**: Tap any history item to reuse that conversion
- **Timestamp**: Each conversion is timestamped
- **Smart Deduplication**: Duplicate conversions are consolidated

### 6. Popular Conversions

Quick access to commonly used conversions:

- Kilometer ↔ Mile (Length)
- Celsius ↔ Fahrenheit (Temperature)
- Kilogram ↔ Pound (Mass)
- Meter ↔ Foot (Length)
- Liter ↔ Gallon (Volume)
- Gigabyte ↔ Megabyte (Data Storage)

## Usage

### Basic Conversion

1. Select a category (Length, Mass, etc.)
2. Enter a value in the "From" field
3. Select source unit
4. Select target unit
5. View instant conversion result

### Using Search

1. Tap the search icon or unit dropdown
2. Type unit name or alias
3. Select from filtered results
4. Conversion updates automatically

### Swap Units

1. Tap the swap icon (↕) between input and output cards
2. Units exchange positions
3. Conversion recalculates automatically

### Adjust Precision

1. Locate the Precision slider
2. Drag slider to desired decimal places (0-10)
3. Result updates with new precision

## Technical Details

### Conversion Accuracy

- **Standard Units**: Uses internationally recognized conversion factors
- **Temperature**: Special handling for celsius, fahrenheit, and kelvin
- **Data Storage**: Binary-based (1024) calculations
- **Time**: Approximate month (30 days) and year (365 days)

### Error Handling

- **Invalid Input**: Shows "Invalid input" message
- **Empty State**: Shows popular conversions when no history exists
- **Boundary Cases**: Properly handles zero and negative values

### Performance

- **Client-Side**: All calculations performed locally
- **Instant Results**: Real-time conversion updates
- **No Network**: Works completely offline
- **Animated UI**: Smooth transitions and feedback

## Examples

### Example 1: Length Conversion

```
Convert 10 miles to kilometers:
Input: 10 mile
Output: 16.09 kilometer
```

### Example 2: Temperature Conversion

```
Convert 100°C to Fahrenheit:
Input: 100 celsius
Output: 212 fahrenheit
```

### Example 3: Data Storage Conversion

```
Convert 5 GB to MB:
Input: 5 gigabyte
Output: 5120 megabyte
```

## UI Components

### Category Selector

- Horizontal scrollable chip list
- Selected category highlighted
- One-tap category switching

### Input Card

- Text field for numeric input
- Clear button for quick reset
- Unit dropdown with search

### Output Card

- Read-only result display
- Copy button for clipboard
- Unit dropdown with search

### Controls

- Swap button for bidirectional conversion
- Precision slider for decimal control
- Search floating action button

## Best Practices

1. **Use Aliases**: Speed up unit selection with common abbreviations
2. **Check Precision**: Adjust decimal places for your use case
3. **Review History**: Reuse recent conversions quickly
4. **Popular First**: Start with popular conversions for common tasks

## Future Enhancements

Planned features for future releases:

- [ ] Custom unit favorites
- [ ] Batch conversion mode
- [ ] Export conversion history
- [ ] More unit categories (speed, pressure, energy)
- [ ] Unit comparison charts
- [ ] Dark mode support

## Support

For issues or feature requests, please file an issue in the repository.

## Route

Access at: `/tools/unit-converter`
