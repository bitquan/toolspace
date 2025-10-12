# Palette Extractor Tool

## Overview

The Palette Extractor is a powerful image analysis tool that uses advanced K-means clustering algorithms to extract the most dominant colors from any image. Perfect for designers, developers, and creative professionals who need to identify color schemes and create cohesive palettes from visual content.

**Route**: `/tools/palette-extractor`  
**Backend Required**: No (client-side processing)  
**Category**: Design & Creativity  
**Complexity**: Advanced

## Features

### Core Functionality

- **Smart Color Extraction**: Advanced K-means clustering with K-means++ initialization for optimal color identification
- **Multi-Format Support**: PNG, JPG, JPEG, and WebP image formats up to 10MB
- **Customizable Color Count**: Extract anywhere from 3-20 dominant colors based on your needs
- **Frequency Analysis**: See how much each color appears in the image with percentage breakdowns
- **Live Preview**: Real-time image preview with immediate color extraction

### User Experience

- **Drag & Drop Interface**: Intuitive file upload with visual feedback and animation
- **Interactive Color Swatches**: Hover effects with smooth Material 3 animations
- **One-Click Color Copying**: Instant HEX and RGB value copying to clipboard
- **Smart Error Handling**: Clear feedback for unsupported formats, file size limits, and processing errors
- **Progress Indication**: Visual loading states during color extraction
- **Responsive Design**: Optimized for desktop, tablet, and mobile interfaces

### Export Options

- **JSON Format**: Structured data with complete color information including HEX, RGB, and individual component values
- **Adobe Color (.aco)**: Industry-standard format compatible with Photoshop and other Adobe Creative Suite applications
- **CSS Variables**: Ready-to-use CSS custom properties for web development
- **SCSS Variables**: Sass variables for stylesheet integration
- **Plain Text**: Simple list of HEX codes for quick reference

## How to Use

### Basic Workflow

1. **Upload an Image**

   - Click the upload zone or drag and drop an image file
   - Supported formats: PNG, JPG, JPEG, WebP
   - Maximum file size: 10MB

2. **Adjust Extraction Settings**

   - Use the slider to set the number of colors (3-20)
   - The extraction automatically re-runs when you change the setting
   - Higher numbers give more nuanced palettes, lower numbers provide simpler schemes

3. **View Color Results**

   - Color swatches display in order of frequency (most common first)
   - Each swatch shows:
     - Color index and frequency percentage
     - HEX value (e.g., #FF5733)
     - RGB value (e.g., rgb(255, 87, 51))
     - Visual color preview with hover effects

4. **Copy Colors**

   - Click any swatch to copy its HEX value
   - Use the HEX or RGB buttons for specific format copying
   - Receive instant feedback via snackbar notifications

5. **Export Palette**
   - Click the export button in the app bar
   - Choose your preferred format
   - Download the palette file for use in your projects

### Advanced Features

#### Color Analysis

- **Frequency Distribution**: See how much each color contributes to the overall image
- **Sorted by Dominance**: Colors are automatically ordered from most to least common
- **Smart Sampling**: Large images are intelligently sampled for optimal performance

#### Performance Optimization

- **Pixel Sampling**: Automatic sampling of up to 10,000 pixels for large images
- **Isolate Processing**: Color extraction runs in background isolates for smooth UI
- **Memory Management**: Efficient handling of large image files

### Tips for Best Results

- **High-Quality Images**: Use clear, well-lit images for better color extraction
- **Simple Compositions**: Images with distinct color regions work best
- **Appropriate Color Count**: Start with 10 colors and adjust based on your image complexity
- **Remove Backgrounds**: For product photos, images without busy backgrounds yield cleaner palettes
- **Consider Context**: Different images may need different color counts for optimal results

## Technical Details

### Algorithm Implementation

The Palette Extractor uses a sophisticated K-means clustering algorithm with several optimizations:

- **K-means++ Initialization**: Advanced centroid initialization for better convergence
- **Iterative Refinement**: Multiple iterations until convergence threshold is met
- **Color Space Processing**: Works in RGB color space with Euclidean distance calculations
- **Frequency Analysis**: Tracks pixel count for each cluster to determine color dominance

### Performance Characteristics

- **Processing Speed**: Most images process in under 2 seconds
- **Memory Efficiency**: Smart pixel sampling prevents memory overflow
- **Scalability**: Handles images from thumbnails to high-resolution photos
- **Cross-Platform**: Identical results across web, mobile, and desktop platforms

### File Format Details

#### JSON Export Structure

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

#### CSS Export Example

```css
:root {
  --color-1: #ff5733;
  --color-2: #33ff57;
  --color-3: #3357ff;
  /* ... */
}
```

#### SCSS Export Example

```scss
$color-1: #ff5733;
$color-2: #33ff57;
$color-3: #3357ff;
// ...
```

## Use Cases

### Design & Branding

- Extract brand colors from logos and marketing materials
- Create cohesive color schemes from inspiration images
- Analyze competitor color palettes
- Generate color documentation for style guides

### Web Development

- Create CSS color variables from design mockups
- Extract theme colors for website development
- Generate SCSS variables for component libraries
- Create color constants for JavaScript applications

### Digital Art & Photography

- Analyze color composition in photographs
- Extract color schemes for digital artwork
- Create harmonious color palettes for designs
- Study color relationships in successful compositions

### Print Design

- Generate Adobe Color swatches for print projects
- Extract colors for brand consistency across media
- Create color palettes for packaging design
- Analyze color trends in printed materials

## Integration with ShareEnvelope

### Data Sharing

- **Export to QR Maker**: Share extracted color codes as QR codes
- **Send to Text Tools**: Process color values with text manipulation tools
- **Transfer to JSON Doctor**: Format and validate exported JSON palettes
- **Integration with MD to PDF**: Include color information in generated documents

### Workflow Enhancement

- **Color Documentation**: Create comprehensive color guides combining multiple tools
- **Brand Asset Management**: Build complete brand packages with consistent color usage
- **Design System Creation**: Generate complete design tokens and documentation

## Limitations

### File Constraints

- Maximum file size: 10MB
- Supported formats: PNG, JPG, JPEG, WebP only
- RGB color space only (no CMYK support)

### Processing Limitations

- Web-based processing only (no server-side computation)
- Memory constraints on older devices
- Processing time increases with image complexity

### Export Limitations

- Adobe Color export is simplified binary format
- No persistent storage of extracted palettes
- Limited to 20 colors maximum per extraction

## Related Tools

- **QR Maker**: Generate QR codes from extracted color values
- **Text Tools**: Process and manipulate color codes and values
- **JSON Doctor**: Format and validate exported palette JSON files
- **MD to PDF**: Create color documentation and guides

## Keyboard Shortcuts

- **Ctrl/Cmd + V**: Paste image from clipboard (if supported by browser)
- **Delete**: Clear current image and results
- **Enter**: Re-extract colors with current settings
- **Ctrl/Cmd + C**: Copy currently selected color value

## Accessibility

- **Screen Reader Support**: Full ARIA labeling for all interactive elements
- **Keyboard Navigation**: Complete keyboard accessibility for all functions
- **High Contrast Mode**: Support for system high contrast settings
- **Color Blindness Friendly**: Text descriptions complement color swatches
- **Touch Accessibility**: Large touch targets for mobile devices

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

## Future Enhancements

### Planned Features

- **Color Harmony Analysis**: Complementary, triadic, and analogous color suggestions
- **Brand Kit Builder**: Logo analysis with complete brand color extraction
- **Gradient Generation**: Create CSS gradients from extracted palettes
- **Historical Gallery**: Save and manage multiple extracted palettes
- **Color Name Suggestions**: AI-powered color naming and descriptions

### Pro Features

- **Advanced Color Spaces**: HSL, HSV, and LAB color space support
- **Accessibility Analysis**: WCAG contrast ratio checking
- **Batch Processing**: Extract palettes from multiple images
- **Style Guide Generation**: Create comprehensive color documentation
- **API Integration**: Direct integration with design tools

## Feedback & Support

Found a bug or have a feature request? Please open an issue on our GitHub repository with the label `tool:palette-extractor`.

---

**Last Updated**: October 11, 2025  
**Version**: 2.1.0  
**Compatibility**: Web, iOS, Android, macOS, Windows, Linux
