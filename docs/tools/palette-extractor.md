# Color Palette Extractor Tool

Extract dominant colors from images using advanced k-means clustering algorithms.

## Overview

The Color Palette Extractor analyzes images and identifies the most prominent colors, making it perfect for designers, developers, and anyone needing to extract color schemes from images.

**Route**: `/tools/palette-extractor`  
**Backend Required**: No (client-side processing)

## Features

### Core Functionality

- **Image Upload**: Support for PNG, JPG, and WebP formats (up to 10MB)
- **K-Means Clustering**: Advanced color quantization algorithm for accurate extraction
- **Customizable Color Count**: Extract 3-20 colors from any image
- **Color Analysis**: View each color's frequency and percentage
- **Multiple Export Formats**: JSON, Adobe Color (.aco), CSS, SCSS, and plain text

### User Experience

- **Drag & Drop**: Easy image selection with visual feedback
- **Live Preview**: See your image before extraction
- **Interactive Swatches**: Hover effects with Material 3 animations
- **One-Click Copy**: Copy HEX or RGB values instantly
- **Progress Indication**: Loading state during color extraction
- **Error Handling**: Clear feedback for unsupported formats or issues

### Export Options

1. **JSON** - Structured data with HEX, RGB, and individual component values
2. **Adobe Color (.aco)** - Industry-standard format for Photoshop and other Adobe tools
3. **CSS Variables** - Ready-to-use CSS custom properties
4. **SCSS Variables** - Sass variables for your stylesheets
5. **Plain Text** - Simple list of HEX codes

## How to Use

### Basic Workflow

1. **Upload an Image**
   - Click the upload zone or drag and drop an image file
   - Supported formats: PNG, JPG, JPEG, WebP
   - Maximum file size: 10MB

2. **Adjust Settings**
   - Use the slider to set the number of colors (3-20)
   - The extraction will automatically re-run when you change the setting

3. **View Results**
   - Color swatches display in order of frequency (most common first)
   - Each swatch shows:
     - Color number and percentage
     - HEX value (e.g., #FF5733)
     - RGB value (e.g., rgb(255, 87, 51))

4. **Copy Colors**
   - Click a swatch to copy its HEX value
   - Use the HEX or RGB buttons for specific format copying
   - Receive instant feedback via snackbar notifications

5. **Export Palette**
   - Click the export button in the app bar
   - Choose your preferred format
   - Download the palette file

### Tips for Best Results

- **High-Quality Images**: Use clear, well-lit images for better color extraction
- **Simple Compositions**: Images with distinct color regions work best
- **Appropriate Color Count**: Start with 10 colors and adjust based on your image complexity
- **Remove Backgrounds**: For product photos, images without busy backgrounds yield cleaner palettes

## Technical Implementation

### K-Means Clustering Algorithm

The tool uses a sophisticated k-means clustering algorithm with several optimizations:

1. **K-Means++ Initialization**: Smart centroid placement for faster convergence
2. **Iterative Refinement**: Up to 50 iterations for optimal color grouping
3. **Convergence Detection**: Automatic stopping when results stabilize
4. **Pixel Sampling**: Performance optimization for large images (samples up to 10,000 pixels)
5. **Isolate Computing**: Background processing for smooth UI experience

### Color Space

All colors are processed in RGB color space, which provides:
- Direct mapping to screen colors
- Efficient distance calculations
- Wide compatibility with export formats

### Performance

- **Fast Processing**: Most images process in under 2 seconds
- **Non-Blocking**: Runs in separate isolate to keep UI responsive
- **Memory Efficient**: Automatic pixel sampling for large images
- **Smooth Animations**: 60fps animations for interactive elements

## Color Format Reference

### HEX Format
```
#RRGGBB
Example: #FF5733
```

### RGB Format
```
rgb(R, G, B)
Example: rgb(255, 87, 51)
```

### JSON Export Structure
```json
{
  "name": "Extracted Palette",
  "colors": [
    {
      "hex": "#FF5733",
      "rgb": "rgb(255, 87, 51)",
      "r": 255,
      "g": 87,
      "b": 51
    }
  ],
  "count": 10
}
```

### CSS Export Example
```css
:root {
  --color-1: #FF5733;
  --color-2: #33FF57;
  --color-3: #3357FF;
}
```

### SCSS Export Example
```scss
$color-1: #FF5733;
$color-2: #33FF57;
$color-3: #3357FF;
```

## Troubleshooting

### Common Issues

**"Image file is too large"**
- Solution: Resize your image to under 10MB before uploading
- Tools: Use image compression tools or resize the dimensions

**"Failed to extract colors"**
- Check that your image file is not corrupted
- Ensure the image format is PNG, JPG, or WebP
- Try a different image to isolate the issue

**Unexpected colors in palette**
- Increase the number of colors to get more granular results
- Check if your image has a transparent background that might affect results
- Consider removing or cropping out unwanted areas

### Browser Compatibility

The tool works best in modern browsers:
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## Use Cases

### For Designers

- Extract color schemes from inspiration images
- Create brand color palettes from logos
- Analyze competitor color usage
- Generate color documentation

### For Developers

- Extract theme colors from design mockups
- Generate CSS variables from brand assets
- Create color constants for applications
- Build consistent color systems

### For Photographers

- Analyze color grading in photos
- Extract dominant tones for editing reference
- Create cohesive color stories
- Document color profiles

## Algorithm Details

### K-Means Clustering

The k-means algorithm groups similar colors together:

1. **Initialization**: Select initial centroids using k-means++ for better starting positions
2. **Assignment**: Assign each pixel to the nearest centroid in RGB space
3. **Update**: Recalculate centroids as the mean of assigned pixels
4. **Repeat**: Continue until convergence (< 1% pixel reassignments) or max iterations
5. **Sort**: Order results by frequency for intuitive display

### Color Distance

Uses Euclidean distance in RGB space:
```
distance = sqrt((r1-r2)² + (g1-g2)² + (b1-b2)²)
```

### Frequency Calculation

Each extracted color includes its frequency (number of pixels) and percentage of total image pixels, helping identify the most dominant colors.

## Status

✅ Implemented and tested  
✅ Documentation complete  
✅ All tests passing  
✅ Material 3 playful theme applied  
✅ Multiple export formats supported

## Related Tools

- **QR Maker**: Generate QR codes with custom colors from your palette
- **File Merger**: Combine multiple design assets into one document
- **Image Tools**: (Coming soon) Additional image manipulation features

## API Reference

For developers integrating the palette extraction logic:

### `KMeansClustering.extractPalette()`

```dart
Future<PaletteResult> extractPalette(
  List<Color> pixels, {
  int k = 10,
  int? sampleSize,
})
```

**Parameters:**
- `pixels`: List of Color objects from the image
- `k`: Number of colors to extract (default: 10)
- `sampleSize`: Maximum pixels to sample for performance (optional)

**Returns:** `PaletteResult` with colors and frequencies

### `PaletteExporter`

Multiple export methods available:
- `exportJson(List<Color> colors, {String name})`
- `exportAco(List<Color> colors)`
- `exportCss(List<Color> colors, {String prefix})`
- `exportScss(List<Color> colors, {String prefix})`
- `exportPlainText(List<Color> colors)`

## Feedback & Support

Found a bug or have a feature request? Please open an issue on our GitHub repository with the label `tool:palette-extractor`.
