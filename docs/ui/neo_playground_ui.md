# Neo-Playground UI System

The Neo-Playground UI is a modern, glassmorphic design system for Toolspace featuring animated gradients, hover effects, and Material 3 integration.

## Architecture

### Core Components

#### 1. **NeoPlaygroundTheme** (`lib/core/ui/neo_playground_theme.dart`)

Central theme system providing:

- **Design Tokens**: Consistent colors, gradients, shadows, and spacing
- **Material 3 Integration**: Light and dark theme configurations
- **Animation Constants**: Standardized durations and curves
- **Glass Decorations**: Reusable glassmorphic styling

```dart
// Usage in MaterialApp
MaterialApp(
  theme: NeoPlaygroundTheme.lightTheme(),
  darkTheme: NeoPlaygroundTheme.darkTheme(),
  themeMode: ThemeMode.system,
)
```

#### 2. **AnimatedBackground** (`lib/core/ui/animated_background.dart`)

Animated gradient background with floating blob effects:

- Custom painter rendering gradient blobs
- Sinusoidal motion for organic movement
- Responsive to screen size
- Minimal performance impact

```dart
// Usage as background layer
Stack(
  children: [
    const Positioned.fill(child: AnimatedBackground()),
    // Content here
  ],
)
```

#### 3. **GlassContainer** (`lib/core/ui/animated_background.dart`)

Reusable glassmorphic container widget:

- Backdrop blur effect
- Semi-transparent background
- Customizable border radius
- Consistent glass aesthetic

```dart
GlassContainer(
  borderRadius: 16,
  child: YourWidget(),
)
```

#### 4. **ToolCard** (`lib/core/widgets/tool_card.dart`)

Animated card component for tool display:

- **Hover Detection**: Mouse region for lift effect
- **Pulse Animation**: Subtle pulsing when idle
- **Gradient Borders**: Color-coded by category
- **Smooth Transitions**: Scale and opacity animations

```dart
ToolCard(
  id: 'tool-id',
  title: 'Tool Name',
  description: 'Tool description',
  icon: Icons.settings,
  accentColor: Colors.blue,
  onTap: () => navigateToTool(),
)
```

#### 5. **CategoryChip** (`lib/core/widgets/tool_card.dart`)

Filter chip for category selection:

- Selected/unselected states
- Color-coded by category
- Smooth state transitions
- Glass aesthetic

```dart
CategoryChip(
  label: 'Text',
  isSelected: selectedCategory == 'Text',
  onTap: () => setCategory('Text'),
  color: Colors.blue,
)
```

## Design System

### Color Palette

```dart
// Primary Colors
primaryPurple: Color(0xFF8B5CF6)
primaryBlue: Color(0xFF3B82F6)

// Accent Colors
accentPink: Color(0xFFEC4899)
accentOrange: Color(0xFFF59E0B)
accentTeal: Color(0xFF14B8A6)
```

### Gradients

```dart
// Primary Gradient (Purple → Blue)
primaryGradient: LinearGradient(
  colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)

// Accent Gradient (Pink → Orange)
accentGradient: LinearGradient(
  colors: [Color(0xFFEC4899), Color(0xFFF59E0B)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

### Glass Effects

**Glass Decoration:**

```dart
glassDecoration({
  double borderRadius = 16,
  bool isDark = false,
  Color? borderColor,
})
```

Features:

- Backdrop blur (10px)
- Semi-transparent background
- Subtle border
- Soft shadows

**Card Decoration:**

```dart
cardDecoration({
  bool isDark = false,
  Gradient? gradient,
})
```

Enhanced card styling with:

- Glass base
- Optional gradient border
- Stronger shadows
- Elevated appearance

### Typography

```dart
headingLarge: TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.bold,
  letterSpacing: -0.5,
)

headingMedium: TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w600,
  letterSpacing: -0.3,
)

bodyMedium: TextStyle(
  fontSize: 16,
  height: 1.6,
)

caption: TextStyle(
  fontSize: 13,
  letterSpacing: 0.3,
)
```

### Animation Timings

```dart
fastAnimation: Duration(milliseconds: 200)
normalAnimation: Duration(milliseconds: 300)
slowAnimation: Duration(milliseconds: 500)
```

### Shadows

```dart
// Glass shadow (subtle, ambient)
glassShadow: [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.1),
    blurRadius: 20,
    offset: Offset(0, 10),
  ),
]

// Card shadow (elevated)
cardShadow: [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.15),
    blurRadius: 30,
    offset: Offset(0, 15),
  ),
]

// Glow effect (accent)
glowShadow: BoxShadow(
  color: primaryPurple.withValues(alpha: 0.3),
  blurRadius: 40,
  spreadRadius: -10,
)
```

## Implementation Details

### Home Screen Integration

`NeoHomeScreen` (`lib/screens/neo_home_screen.dart`) demonstrates full system integration:

1. **Background Layer**: AnimatedBackground fills screen
2. **App Bar**: Logo + branding with gradient accent
3. **Search Bar**: GlassContainer with text field
4. **Category Filters**: Horizontal scrolling CategoryChips
5. **Tool Grid**: Staggered grid with animated ToolCards
6. **Navigation**: Smooth page transitions with fade + slide

### Responsive Design

- **Grid Layout**: `SliverGridDelegateWithMaxCrossAxisExtent`

  - Max card width: 350px
  - Auto-adjusts columns based on screen size
  - Consistent spacing: 20px

- **Staggered Entry Animation**:
  ```dart
  TweenAnimationBuilder<double>(
    duration: Duration(milliseconds: 300 + (index * 50)),
    tween: Tween(begin: 0.0, end: 1.0),
    curve: Curves.easeOutCubic,
  )
  ```

### Performance Optimizations

- **Background Animation**: Uses CustomPainter for efficient rendering
- **Hover Effects**: Limited to MouseRegion (desktop/web only)
- **Const Constructors**: Minimize rebuilds
- **Cached Decorations**: Reusable BoxDecoration objects

## Migration Guide

### From PlayfulTheme to NeoPlayground

1. **Update app_shell.dart**:

```dart
// Before
import 'theme/playful_theme.dart';
theme: PlayfulTheme.lightTheme,

// After
import 'core/ui/neo_playground_theme.dart';
theme: NeoPlaygroundTheme.lightTheme(),
```

2. **Update home screen**:

```dart
// Before
import 'screens/home_screen.dart';
home: const HomeScreen(),

// After
import 'screens/neo_home_screen.dart';
home: const NeoHomeScreen(),
```

3. **Tool screens**: No changes required (Material 3 compatibility)

## Best Practices

1. **Use Design Tokens**: Reference `NeoPlaygroundTheme` constants instead of hardcoded values
2. **Glass Hierarchy**: Apply glass effects consistently (lighter = higher elevation)
3. **Animation Timing**: Use standardized durations from theme
4. **Color Semantics**: Match accent colors to category meaning
5. **Accessibility**: Maintain contrast ratios for text on glass surfaces

## Future Enhancements

- [ ] Custom loading indicators with gradient spinners
- [ ] Enhanced micro-interactions (ripple, particle effects)
- [ ] Themed scroll bars and selection highlights
- [ ] Glass navigation rail for desktop layouts
- [ ] Theme customization UI (user-selectable accent colors)
- [ ] Reduced motion mode for accessibility
