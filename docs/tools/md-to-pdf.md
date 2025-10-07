# Markdown to PDF Tool

**Status**: ✅ Implemented
**Version**: 1.0
**Last Updated**: October 6, 2025

## Overview

The Markdown to PDF tool allows you to write or edit Markdown content and export it to a professionally formatted PDF document. With multiple theme options and customizable page settings, you can create documents that match your style requirements.

## Features

### Core Functionality

- **Split-Pane Editor**: Real-time markdown editing with live preview
- **Multiple Themes**: Choose from GitHub, Clean, or Academic styles
- **Theme Customization**: 
  - GitHub: Clean, modern style with syntax highlighting support
  - Clean: Elegant serif typography for general documents
  - Academic: Formal style for papers and reports
- **Page Configuration**:
  - Page size options (A4, Letter, Legal)
  - Custom margins (top, bottom, left, right)
  - Optional page numbers in footer
- **Cloud Export**: Secure PDF generation with Firebase Functions
- **Download Links**: 7-day valid signed URLs for generated PDFs

### User Experience

- **Responsive Layout**: 
  - Split-pane view on wide screens (>800px)
  - Tabbed interface on mobile devices
- **Real-time Preview**: See your formatted markdown as you type
- **Export Dialog**: Easy-to-use options interface
- **Progress Indication**: Visual feedback during PDF generation
- **Error Handling**: Clear error messages for issues

## How to Use

### Basic Workflow

1. **Access the Tool**
   - Navigate to the Toolspace homepage
   - Click on the "Markdown to PDF" tool card

2. **Write Your Content**
   - Use the left panel (or Edit tab on mobile) to write markdown
   - See live preview in the right panel (or Preview tab)
   - Supports all standard markdown features:
     - Headers (# H1, ## H2, etc.)
     - Bold (**text**) and italic (*text*)
     - Lists (ordered and unordered)
     - Code blocks with syntax highlighting
     - Links and images
     - Blockquotes
     - Tables

3. **Export to PDF**
   - Click "Export to PDF" in the app bar
   - Choose your preferred theme:
     - **GitHub**: Modern, developer-friendly style
     - **Clean**: Elegant, readable typography
     - **Academic**: Formal, paper-ready format
   - Select page size (A4, Letter, or Legal)
   - Adjust margins if needed (default: 20mm all sides)
   - Toggle page numbers on/off
   - Click "Export" to generate your PDF

4. **Download Your PDF**
   - Wait for the generation process (usually 5-15 seconds)
   - Click "Download" in the success dialog
   - Your PDF will open in a new tab or download automatically
   - The download link remains valid for 7 days

## Themes

### GitHub Theme
- Font: System fonts (San Francisco, Segoe UI, Helvetica)
- Style: Clean, modern, developer-friendly
- Best for: Documentation, README files, technical guides
- Features: Syntax highlighting, clear hierarchy

### Clean Theme
- Font: Georgia serif with Helvetica headings
- Style: Elegant, readable, professional
- Best for: Articles, blog posts, general documents
- Features: Generous line spacing, comfortable reading

### Academic Theme
- Font: Times New Roman
- Style: Formal, traditional, paper-ready
- Best for: Research papers, formal reports, essays
- Features: Double spacing, indented paragraphs, citations-ready

## Technical Details

### Frontend (Flutter)

**Location**: `/lib/tools/md_to_pdf/`

**Components**:
- `md_to_pdf_screen.dart`: Main screen with editor and preview
- `widgets/export_options_dialog.dart`: Export configuration UI
- `logic/pdf_exporter.dart`: Data models for export options

**Dependencies**:
- `flutter_markdown`: Markdown rendering for preview
- `markdown`: Markdown parsing
- `cloud_functions`: Backend communication
- `url_launcher`: PDF download functionality

### Backend (Firebase Functions)

**Location**: `/functions/src/tools/md_to_pdf/`

**Function**: `generatePdfFromMarkdown`

**Components**:
- `generate_pdf.ts`: Main PDF generation logic using Puppeteer
- `themes.ts`: CSS theme definitions

**Process**:
1. Validates authentication and input
2. Converts markdown to HTML using `marked`
3. Injects theme CSS
4. Renders HTML to PDF using Puppeteer
5. Uploads to Firebase Storage
6. Returns signed download URL

**Configuration**:
- Memory: 1GB
- Timeout: 120 seconds
- Content limit: 1MB markdown

### Storage

**Path**: `pdf-exports/{userId}/{pdfId}.pdf`

**Retention**: 7 days (configured in Storage rules)

**Metadata**:
- Creator user ID
- Theme used
- Page size
- Creation timestamp

## Limitations

- Maximum markdown size: 1MB
- PDF link expires after 7 days
- Requires authentication
- No offline generation (cloud-only)

## Error Handling

### Common Errors

1. **Unauthenticated**: Sign in to generate PDFs
2. **Content too large**: Reduce markdown content below 1MB
3. **Invalid theme**: Use github, clean, or academic
4. **Generation timeout**: Content too complex or server busy

### Error Messages

All errors display user-friendly messages with:
- Clear description of the problem
- Suggested actions to resolve
- Automatic retry option where applicable

## Future Enhancements

- [ ] Custom theme creation
- [ ] Table of contents generation
- [ ] Header/footer customization
- [ ] Batch export for multiple files
- [ ] Template library
- [ ] Collaborative editing
- [ ] Version history
- [ ] Export to other formats (DOCX, HTML)

## Testing

### Unit Tests
- Export options data models
- Page margins configuration
- Theme validation

### Widget Tests
- Editor input handling
- Preview rendering
- Export dialog interaction
- Error message display

### Function Tests
- Markdown to HTML conversion
- Theme CSS injection
- PDF generation with Puppeteer
- Storage and URL signing

## Related Tools

- **Text Tools**: For text formatting before markdown conversion
- **File Merger**: Combine multiple exported PDFs
- **JSON Doctor**: Parse JSON content into markdown

## Support

For issues or feature requests, please contact support or file an issue in the repository.

---

*Last updated: October 6, 2025*
