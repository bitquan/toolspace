# File Merger Tool

**Status**: ✅ Live
**Version**: 1.0
**Last Updated**: October 6, 2025

## Overview

The File Merger tool allows you to combine multiple PDF documents and images (PNG, JPG) into a single PDF file. It's perfect for consolidating documents, creating reports, or organizing scattered files.

## Features

### Core Functionality

- **Multi-format Support**: Merge PDFs, PNG, and JPG files
- **Drag & Drop Interface**: Easy file selection with visual feedback
- **File Reordering**: Arrange files in your preferred sequence before merging
- **Progress Tracking**: Real-time upload and merge progress indicators
- **Secure Processing**: Files are processed securely in the cloud
- **Download Links**: Get shareable download links valid for 7 days

### User Experience

- **Empty State Guidance**: Clear instructions when no files are selected
- **File Validation**: Automatic checking for supported formats and size limits
- **Error Handling**: Friendly error messages for common issues
- **Responsive Design**: Works seamlessly on desktop and mobile devices

### Quota System

- **Free Tier**: 3 merges per user account
- **Pro Upgrade Path**: Unlimited merges with premium features (coming soon)
- **Usage Tracking**: Clear display of remaining quota
- **Upgrade Prompts**: Non-blocking notifications when quota is exceeded

## How to Use

### Basic Workflow

1. **Access the Tool**

   - Navigate to the Toolspace homepage
   - Click on the "File Merger" tool card

2. **Upload Files**

   - Click the upload zone or drag and drop files
   - Select PDF, PNG, or JPG files (up to 20 files)
   - Files are automatically validated

3. **Arrange Files**

   - Drag files to reorder them in the list
   - Use the remove button to delete unwanted files
   - Check the sequence numbers to confirm order

4. **Merge Files**
   - Click "Merge Files" to start the process
   - Wait for upload and merge completion
   - Download the merged PDF or copy the link

### File Requirements

| Requirement     | Limit               | Notes                            |
| --------------- | ------------------- | -------------------------------- |
| **File Types**  | PDF, PNG, JPG, JPEG | Other formats are rejected       |
| **File Size**   | 10 MB per file      | Larger files show error message  |
| **Total Files** | 20 files max        | No limit on total combined size  |
| **File Names**  | Any valid filename  | Special characters are sanitized |

### Authentication

- **Required**: You must be signed in to merge files
- **Quota Tracking**: Usage is tracked per user account
- **Security**: Files are uploaded to your private storage space

## Privacy & Security

### Data Handling

- **Temporary Storage**: Uploaded files are stored temporarily during processing
- **Automatic Cleanup**: Source files are cleaned up after merge completion
- **No Permanent Storage**: We don't retain your original files
- **Secure Processing**: All operations use encrypted connections

### File Access

- **Private Upload Space**: Files are uploaded to user-specific storage with strict access controls
- **Signed URLs**: Download links are time-limited and secure (7 days validity)
- **No Public Access**: Your files are never publicly accessible
- **Link Expiration**: Download links expire after 7 days but can be regenerated
- **Storage Rules**: Enforced security rules ensure only you can access your files:
  - Upload folder (`uploads/{userId}/`): Read/write only by file owner
  - Merged folder (`merged/{userId}/`): Read-only by owner, write-only by backend
  - File size validation: 10 MB limit enforced at storage level
  - Content type validation: Only PDF and image types accepted

### Compliance

- **GDPR Compliant**: No personal data is stored in merged files
- **Minimal Metadata**: Only essential processing metadata is retained
- **User Control**: You control file access and sharing
- **Data Deletion**: Source files are automatically deleted post-processing

## Limits & Pricing

### Free Tier

- **3 merges per account**: Perfect for occasional use
- **All core features**: Full functionality available
- **10 MB per file**: Suitable for most document types
- **7-day download links**: Plenty of time to access files

### Pro Tier (Coming Soon)

- **Unlimited merges**: No monthly limits
- **Larger files**: Up to 50 MB per file
- **Priority processing**: Faster merge times
- **Extended links**: 30-day download link validity
- **Premium support**: Priority customer service

### Technical Limits

- **Maximum 20 files**: Per merge operation
- **File size validation**: Enforced client and server-side
- **Processing timeout**: 5 minutes per merge operation
- **Concurrent operations**: One merge per user at a time

## Troubleshooting

### Common Issues

#### "File too large" Error

- **Cause**: File exceeds 10 MB limit
- **Solution**: Compress or split large files before uploading
- **Alternative**: Upgrade to Pro for 50 MB limit (coming soon)

#### "Invalid file type" Error

- **Cause**: Unsupported file format
- **Solution**: Convert files to PDF, PNG, or JPG
- **Tools**: Use online converters or image editing software

#### "Authentication required" Error

- **Cause**: Not signed in to account
- **Solution**: Sign in with your Google or email account
- **Note**: Anonymous usage is not supported

#### "Quota exceeded" Error

- **Cause**: Used all 3 free merges
- **Solution**: Wait for monthly reset or upgrade to Pro
- **Timeline**: Quota resets on the 1st of each month

#### Upload Fails or Stalls

- **Check**: Internet connection stability
- **Try**: Refreshing the page and trying again
- **Reduce**: Number of files or file sizes
- **Contact**: Support if issue persists

### Browser Compatibility

| Browser     | Support    | Notes                   |
| ----------- | ---------- | ----------------------- |
| **Chrome**  | ✅ Full    | Recommended browser     |
| **Firefox** | ✅ Full    | Excellent compatibility |
| **Safari**  | ✅ Full    | Works on macOS and iOS  |
| **Edge**    | ✅ Full    | Modern Edge versions    |
| **Mobile**  | ✅ Partial | File selection may vary |

### Performance Tips

- **Optimize file sizes**: Compress images before uploading
- **Stable connection**: Use reliable internet for large uploads
- **Close unused tabs**: Free up browser memory
- **Clear cache**: If experiencing persistent issues

## API Integration

For developers wanting to integrate File Merger functionality:

### Firebase Functions

#### Merge PDFs

```typescript
// Call the mergePdfs function
const result = await firebase.functions().httpsCallable("mergePdfs")({
  files: ["uploads/user-id/file1.pdf", "uploads/user-id/file2.jpg"],
});

console.log("Download URL:", result.data.downloadUrl);
console.log("File Path:", result.data.outputPath);
console.log("Merge ID:", result.data.mergeId);
```

#### Regenerate Signed URL

```typescript
// Get a new signed URL for an existing merged file
const result = await firebase.functions().httpsCallable("getSignedUrl")({
  filePath: "merged/user-id/merge-id.pdf",
});

console.log("Download URL:", result.data.downloadUrl);
console.log("Expires in:", result.data.expiresIn, "milliseconds");
console.log("File metadata:", result.data.metadata);
```

#### Quota Management

```typescript
// Check quota status
const quota = await firebase.functions().httpsCallable("getQuotaStatus")();
console.log("Merges remaining:", quota.data.mergesRemaining);
```

## Screenshots

### Main Interface

![File Merger Main Screen](../assets/file-merger-main.png)
_The main File Merger interface showing the upload zone and empty state_

### File Selection

![File Selection Dialog](../assets/file-merger-selection.png)
_File picker dialog for selecting multiple PDF and image files_

### File List

![File List with Reordering](../assets/file-merger-list.png)
_Uploaded files list with drag-and-drop reordering capability_

### Progress Indication

![Merge Progress](../assets/file-merger-progress.png)
_Upload and merge progress indicators during processing_

### Success State

![Merge Complete](../assets/file-merger-success.png)
_Successful merge with download options and link sharing_

### Quota Banner

![Quota Exceeded Banner](../assets/file-merger-quota.png)
_Quota exceeded banner with upgrade call-to-action_

## Support

### Getting Help

- **Documentation**: This guide covers most common scenarios
- **Email Support**: [support@toolspace.app](mailto:support@toolspace.app)
- **Response Time**: 24-48 hours for free users
- **Priority Support**: Available with Pro subscription

### Feature Requests

- **Feedback**: We welcome suggestions for improvements
- **Roadmap**: Check our public roadmap for planned features
- **Voting**: Upvote features you'd like to see implemented

### Bug Reports

- **Include**: Browser, file types, error messages
- **Steps**: Describe what you were trying to do
- **Screenshots**: Visual evidence helps diagnosis
- **Files**: Sample files that cause issues (if safe to share)

## Version History

### v1.0 (October 6, 2025)

- ✅ Initial release with core merge functionality
- ✅ PDF and image format support
- ✅ Drag-and-drop file selection
- ✅ File reordering and removal
- ✅ Quota system with free tier
- ✅ Progress indicators and error handling
- ✅ Secure file processing and download links

### Planned Updates

- **v1.1**: Stripe payment integration for Pro tier
- **v1.2**: Batch processing and ZIP file support
- **v1.3**: Advanced merge options (bookmarks, page ranges)
- **v1.4**: API access and webhook notifications

---

_For technical implementation details, see the [developer documentation](../dev-log/features/2025-10-06-file-merger-v1.md)._
