# Firebase Storage Security Rules

## Overview

This document describes the Firebase Storage security rules implemented for the Toolspace application, with focus on the File Merger tool's storage patterns.

## Storage Structure

```
bucket/
├── users/{userId}/           # User-specific data storage
├── uploads/{userId}/         # Temporary file uploads (File Merger)
├── merged/{userId}/          # Merged output files (File Merger)
└── public/                   # Public read-only assets
```

## Security Rules

### User Data (`/users/{userId}/`)

**Purpose**: General user-owned storage for various tools

**Rules**:
- Read: Allowed if authenticated user matches `userId`
- Write: Allowed if authenticated user matches `userId`

**Use Cases**: Profile pictures, user-generated content, tool-specific data

### Upload Folder (`/uploads/{userId}/`)

**Purpose**: Temporary storage for files being uploaded to File Merger before processing

**Rules**:
- **Write**: 
  - Authenticated user must match `userId`
  - File size limited to 10 MB
  - Content type must be PDF or image (PNG/JPEG)
- **Read**: Authenticated user must match `userId`
- **Delete**: Authenticated user must match `userId`

**Validation**:
```javascript
allow write: if request.auth != null 
             && request.auth.uid == userId
             && request.resource.size <= 10 * 1024 * 1024
             && request.resource.contentType.matches('(application/pdf|image/(png|jpeg))');
```

**Use Cases**: User uploads files before calling `mergePdfs` function

**Lifecycle**: Files are typically short-lived; cleaned up after merge or on error

### Merged Folder (`/merged/{userId}/`)

**Purpose**: Storage for merged PDF output files

**Rules**:
- **Read**: Authenticated user must match `userId`
- **Write**: Denied (only backend functions can write)
- **Delete**: Denied (managed via lifecycle rules)

**Security Rationale**:
- Users can only read their own merged files
- Backend has elevated permissions to create merged files
- Prevents tampering or unauthorized file creation
- Download access via signed URLs with 7-day expiration

**Use Cases**: 
- Backend writes merged PDF after processing
- User downloads via signed URL
- User regenerates signed URL via `getSignedUrl` function

**Lifecycle**: Configured via Firebase Storage lifecycle rules (automatic deletion after 30 days)

### Public Assets (`/public/`)

**Purpose**: Static assets like logos, icons, help images

**Rules**:
- **Read**: Allowed for all users (authenticated or not)
- **Write**: Denied

**Use Cases**: Shared resources referenced in the application UI

## Signed URLs

### Purpose

Signed URLs provide temporary, secure access to files without requiring authentication headers. They are used for:
- Downloading merged PDF files
- Sharing files with external users
- Embedding in emails or notifications

### Generation

Signed URLs are generated in two scenarios:

1. **After Merge**: The `mergePdfs` function automatically generates a signed URL
2. **On Demand**: The `getSignedUrl` function regenerates URLs for existing files

### Security Features

- **Time-Limited**: Valid for 7 days from generation
- **Path Validation**: Only works for files in the user's `merged/` folder
- **One-Time Generation**: Each call generates a unique URL
- **No Token Reuse**: URLs cannot be modified or extended

### Implementation

```typescript
// Generate signed URL valid for 7 days
const [signedUrl] = await file.getSignedUrl({
  action: "read",
  expires: Date.now() + 7 * 24 * 60 * 60 * 1000, // 7 days
});
```

## Backend Functions

### mergePdfs

**Permissions**: 
- Reads from `uploads/{userId}/`
- Writes to `merged/{userId}/`

**Authentication**: Requires authenticated user

**Validation**: 
- Verifies uploaded files exist
- Checks file ownership
- Enforces quota limits

### getSignedUrl

**Permissions**: 
- Reads metadata from `merged/{userId}/`

**Authentication**: Requires authenticated user

**Validation**:
- Verifies file exists
- Checks file ownership (path must start with `merged/{userId}/`)
- Returns error if file not found or unauthorized

**Security**: Prevents users from generating signed URLs for other users' files

## Best Practices

### For Developers

1. **Always validate user ownership** before accessing storage
2. **Use signed URLs** for download links, not direct storage paths
3. **Clean up temporary files** after processing
4. **Set appropriate content types** when uploading
5. **Validate file sizes** on both client and server

### For Users

1. **Download files promptly** (links expire after 7 days)
2. **Don't share signed URLs publicly** (they provide direct access)
3. **Regenerate URLs if expired** using the `getSignedUrl` function

## Testing

### Rules Testing

Use Firebase Emulator Suite to test storage rules:

```bash
firebase emulators:start --only storage
```

### Test Cases

1. **User isolation**: Verify user A cannot access user B's files
2. **File size limits**: Verify files over 10 MB are rejected
3. **Content type validation**: Verify only PDF/images are accepted
4. **Backend-only writes**: Verify users cannot write to `merged/` folder
5. **Signed URL expiration**: Verify URLs expire after 7 days

## Monitoring

### Metrics to Track

- Failed upload attempts (permission denied)
- Large file rejections (size limit)
- Invalid content type rejections
- Signed URL generation rate
- Storage usage per user

### Alerts

- Unusual access patterns (possible security breach)
- High failure rates (misconfiguration)
- Storage quota approaching limits

## Future Enhancements

1. **Lifecycle Rules**: Auto-delete old files from `uploads/` and `merged/`
2. **Rate Limiting**: Prevent abuse of signed URL generation
3. **Extended Expiration**: Pro users get 30-day signed URLs
4. **Audit Logging**: Track all file access for compliance
5. **Encryption**: Add customer-managed encryption keys (CMEK)

## References

- [Firebase Storage Security Rules Documentation](https://firebase.google.com/docs/storage/security)
- [Signed URL Best Practices](https://cloud.google.com/storage/docs/access-control/signed-urls)
- [File Merger Tool Documentation](../tools/file_merger.md)
- [Backend Architecture Overview](./README.md)
