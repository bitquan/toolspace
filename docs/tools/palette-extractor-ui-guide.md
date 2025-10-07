# Color Palette Extractor - UI Guide

## Screen Layouts

### Empty State

When the tool first loads, users see:

```
┌─────────────────────────────────────────────────┐
│ [🎨] Color Palette Extractor              [⋮] │
├─────────────────────────────────────────────────┤
│ Number of colors: 10                            │
│ [━━━●━━━━━━━━━━━━━━] 3 ──────── 20            │
├─────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────┐ │
│ │                                             │ │
│ │              [📷]                           │ │
│ │                                             │ │
│ │  Tap to select an image or drag & drop     │ │
│ │                                             │ │
│ │       PNG, JPG, WebP • Max 10MB            │ │
│ │                                             │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│                    [🎨]                         │
│                                                 │
│    Upload an image to extract its color        │
│              palette                            │
│                                                 │
│  The tool will extract the most dominant       │
│  colors using k-means clustering                │
│                                                 │
└─────────────────────────────────────────────────┘
```

### With Image Loaded

After image upload:

```
┌─────────────────────────────────────────────────┐
│ [🎨] Color Palette Extractor         [↓]  [⋮] │
├─────────────────────────────────────────────────┤
│ Number of colors: 10                            │
│ [━━━●━━━━━━━━━━━━━━] 3 ──────── 20            │
├─────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────┐ │
│ │         [🔄]                                │ │
│ │  Tap to select a different image            │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ┌─────────────────────────────────────────────┐ │
│ │                                             │ │
│ │         [Uploaded Image Preview]            │ │
│ │                                             │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ Extracted Colors                                │
│                                                 │
│ ┌──────────┐ ┌──────────┐                      │
│ │ #1  45.5%│ │ #2  22.3%│                      │
│ │          │ │          │                      │
│ │ #FF5733  │ │ #33FF57  │                      │
│ │rgb(...)  │ │rgb(...)  │                      │
│ │[HEX][RGB]│ │[HEX][RGB]│                      │
│ └──────────┘ └──────────┘                      │
│ ┌──────────┐ ┌──────────┐                      │
│ │ #3  18.2%│ │ #4  14.0%│                      │
│ └──────────┘ └──────────┘                      │
└─────────────────────────────────────────────────┘
```

### Loading State

During color extraction:

```
┌─────────────────────────────────────────────────┐
│ [🎨] Color Palette Extractor              [⋮] │
├─────────────────────────────────────────────────┤
│ Number of colors: 10                            │
│ [━━━━━━━━━━━━━━━━━━] (disabled)               │
├─────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────┐ │
│ │                                             │ │
│ │         [📷]                                │ │
│ │    Extracting colors...                     │ │
│ │                                             │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ┌─────────────────────────────────────────────┐ │
│ │         [Uploaded Image Preview]            │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│                    [⭕]                         │
│                                                 │
│            Extracting colors...                 │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Export Menu

When clicking the download button:

```
┌────────────────────────────────┐
│ [📝] Export as JSON            │
│ [🎨] Export as ACO (Adobe)     │
│ [🎨] Export as CSS             │
│ [✨] Export as SCSS            │
│ [📄] Export as Text            │
└────────────────────────────────┘
```

## Color Swatch Card - Detailed View

### Normal State
```
┌─────────────────────────────┐
│ #1                   45.5%  │  ← Index and percentage
│                             │
│ [Background: Extracted Color]
│                             │
│ #FF5733                     │  ← HEX value
│ rgb(255, 87, 51)            │  ← RGB value
│                             │
│ [HEX]  [RGB]                │  ← Copy buttons
└─────────────────────────────┘
```

### Hover State
```
┌─────────────────────────────┐
│ #1                   45.5%  │
│                             │  ← Card scales up (1.05x)
│ [Background: Extracted Color]  ← Elevation increases
│                             │
│ #FF5733                     │
│ rgb(255, 87, 51)            │
│                             │
│ [HEX]  [RGB]                │  ← Buttons highlighted
└─────────────────────────────┘
```

## Interactive Elements

### Image Upload Zone

**States:**
1. **Empty** - Neutral outline, upload icon, help text
2. **Drag Over** - Primary color outline, highlighted background
3. **Has Image** - Compact size, refresh icon, different text
4. **Disabled** - Grayed out, "Extracting colors..." text

### Color Count Slider

**Range:** 3 to 20 colors  
**Default:** 10 colors  
**Behavior:** Live updates when changed (triggers re-extraction)

### Copy Buttons

**On Click:**
1. Copies value to clipboard
2. Shows snackbar: "Copied #FF5733 to clipboard"
3. Snackbar duration: 1 second

### Export Menu

**Formats:**
- JSON: Complete color data with metadata
- ACO: Adobe Color format (binary)
- CSS: CSS custom properties
- SCSS: Sass variables
- Text: Plain HEX list

## Color Scheme

**Tool Color:** Pink (#E91E63) - Playful theme color #5  
**Icon:** Icons.palette  
**App Bar:** Pink icon with light background

## Animations

1. **Card Entrance:** Staggered fade-in (inherited from tools grid)
2. **Hover Scale:** 200ms ease-in-out, scale 1.0 → 1.05
3. **Upload Zone:** 200ms size transition when image loaded
4. **Slider:** Smooth thumb movement with haptic feedback

## Responsive Behavior

**Grid Layout:**
- 2 columns on mobile/narrow screens
- Maintains 1.2 aspect ratio for cards
- 12px gap between cards

**Image Preview:**
- Max height: 300px
- Maintains aspect ratio
- Centered horizontally

## Accessibility Features

1. **Contrast:** Text color automatically adjusts (black/white) based on swatch background
2. **Labels:** All interactive elements have tooltips
3. **Feedback:** Visual and text confirmation for all actions
4. **Error Messages:** Clear, actionable error descriptions

## Material 3 Design Elements

- **Elevation:** 2dp default, 8dp on hover
- **Corner Radius:** 12px for cards, 8px for buttons
- **Typography:** Material 3 text styles (titleMedium, bodySmall, etc.)
- **Color System:** Uses theme's colorScheme for consistency
- **Spacing:** 8px grid system throughout

## Error States

### File Too Large
```
┌────────────────────────────────────────────────┐
│ [⚠️] Image file is too large. Maximum size   │
│      is 10MB.                                  │
└────────────────────────────────────────────────┘
```

### Unsupported Format
```
┌────────────────────────────────────────────────┐
│ [⚠️] Failed to load image: Unsupported format │
└────────────────────────────────────────────────┘
```

### Extraction Failed
```
┌────────────────────────────────────────────────┐
│ [⚠️] Failed to extract colors: [error details]│
└────────────────────────────────────────────────┘
```

## Success Feedback

### Copy Success
```
┌────────────────────────────────┐
│ ✓ Copied #FF5733 to clipboard │
└────────────────────────────────┘
```

### Export Success
```
┌────────────────────────────────┐
│ ✓ Exported as palette.json     │
└────────────────────────────────┘
```

## Performance Indicators

- **Extraction Time:** Typically 0.5-2 seconds
- **UI Responsiveness:** 60fps maintained throughout
- **Memory Usage:** Optimized through pixel sampling

## Usage Flow

1. User opens Color Palette Extractor from home screen
2. Sees empty state with upload zone and instructions
3. Clicks or drags image file
4. Sees image preview and loading indicator
5. Extraction completes in 1-2 seconds
6. Color swatches appear in grid, sorted by frequency
7. User can adjust color count with slider (triggers re-extraction)
8. User hovers over swatches to see hover effects
9. User clicks swatch or copy buttons to copy colors
10. User clicks export menu to download palette in desired format

## Best Practices for Users

1. Use clear, well-lit images for best results
2. Start with 10 colors and adjust as needed
3. Images with distinct color regions work best
4. Remove busy backgrounds for product photos
5. Consider file size - compress if needed

---

**Note:** Actual UI will be rendered by Flutter and may vary slightly based on platform (web/mobile/desktop) and screen size. This guide represents the logical structure and interactive behavior.
