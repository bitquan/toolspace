# Image Resizer

Batch resize and convert images with ease. Perfect for optimizing images for web, social media, or any custom dimensions.

## Features

### Batch Processing
- Upload up to 10 images at once
- Process multiple images in one operation
- Individual download links for each resized image

### Preset Sizes
- **Thumbnail**: 150×150px - Perfect for avatars and small previews
- **Small**: 640×480px - Ideal for email attachments
- **Medium**: 1280×720px (HD) - Great for web content
- **Large**: 1920×1080px (Full HD) - High-quality display

### Custom Dimensions
- Specify exact width and/or height
- Automatic aspect ratio preservation
- Won't enlarge images (maintains quality)

### Format Conversion
- **JPG**: Standard format with good compression
- **PNG**: Lossless format with transparency support
- **WebP**: Modern format with superior compression

### File Support
- **Input formats**: PNG, JPG, JPEG, WebP, GIF, BMP
- **Max file size**: 20MB per image
- **Max files**: 10 images per batch

## Usage

### Step 1: Upload Images
1. Click the upload zone or drag and drop images
2. Select one or more images from your device
3. Preview selected images with size information

### Step 2: Configure Settings
1. Choose a preset size or select "Custom"
2. For custom, enter desired width and/or height
3. Select output format (JPG, PNG, or WebP)

### Step 3: Resize
1. Click "Resize Images" button
2. Wait for processing to complete
3. Download individual resized images

## Technical Details

### Backend
- **Function**: `resizeImages` (Cloud Functions)
- **Library**: Sharp for high-performance image processing
- **Quality**: 90% quality for all formats
- **Fit mode**: "inside" with aspect ratio preservation
- **No enlargement**: Images smaller than target won't be scaled up

### Storage
- **Upload location**: `uploads/{userId}/{timestamp}-{filename}`
- **Output location**: `resized/{userId}/{uuid}-{filename}`
- **Cleanup**: Original files deleted after processing
- **Download links**: Valid for 7 days

### Security
- Authentication required for all operations
- User-scoped file paths
- MIME type validation
- File size limits enforced
- Automatic cleanup on errors

## Error Handling

### Common Errors

**"Maximum 10 files allowed"**
- You've selected more than 10 images
- Solution: Upload in smaller batches

**"File too large. Maximum size is 20MB."**
- One or more files exceed the size limit
- Solution: Compress images before upload

**"File is not a valid image"**
- Uploaded file is not an image or corrupted
- Solution: Verify file format and integrity

**"Please sign in to resize images"**
- Not authenticated
- Solution: Sign in with your account

**"Width/Height must be between 1 and 10000 pixels"**
- Custom dimensions are out of valid range
- Solution: Use reasonable dimensions

## Best Practices

### Image Quality
- Use PNG for images requiring transparency
- Use JPG for photographs and complex images
- Use WebP for best compression with good quality

### Performance
- Resize images before uploading to web applications
- Use thumbnails for list views
- Use appropriate presets for target use case

### Batch Processing
- Group similar resize operations together
- Process up to 10 images at once for efficiency
- Download all files before starting new batch

## Use Cases

### Web Development
- Create responsive image sets
- Generate thumbnails for galleries
- Optimize images for faster page loads

### Social Media
- Prepare images for specific platform requirements
- Create profile pictures and banners
- Batch resize content for posts

### Photography
- Create web-optimized versions of photos
- Generate preview images
- Convert between formats

### E-commerce
- Product thumbnail generation
- Multi-size product images
- Banner and promotional images

## API Reference

### Request Format
```javascript
{
  files: string[],        // Storage paths
  preset?: string,        // 'thumbnail' | 'small' | 'medium' | 'large'
  customWidth?: number,   // Custom width in pixels
  customHeight?: number,  // Custom height in pixels
  format: string         // 'jpeg' | 'png' | 'webp'
}
```

### Response Format
```javascript
{
  success: true,
  results: [
    {
      originalName: string,
      downloadUrl: string,
      size: number,
      dimensions: {
        width: number,
        height: number
      }
    }
  ],
  totalFiles: number
}
```

## Limitations

- Maximum 10 images per batch
- Maximum 20MB per image file
- Custom dimensions limited to 1-10000 pixels
- Download links expire after 7 days
- Processing time varies with file size and count

## Future Enhancements

### Planned Features (v2)
- ZIP download for batch results
- Image cropping and rotation
- Quality adjustment slider
- Watermark support
- Batch rename functionality
- More output formats (TIFF, AVIF)

### Advanced Features (v3)
- Image filters and effects
- Automatic optimization
- Smart cropping
- Bulk metadata editing
- Template-based resizing
- API access for developers
