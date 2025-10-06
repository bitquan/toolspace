# URL Shortener Tool Documentation

## Overview

The URL Shortener is a dev-only tool that allows developers to create and manage short URLs with unique codes. It provides a simple interface for shortening long URLs, tracking clicks, and managing created short links.

**Route**: `/tools/url-short`  
**Access**: Dev-only  
**Backend**: Firebase Functions + Firestore

## Features

### Core Functionality

1. **URL Shortening**
   - Convert long URLs into short, memorable codes
   - Automatic validation of URL format
   - Unique 6-character short codes
   - Maximum URL length: 2048 characters

2. **URL Management**
   - List all user's short URLs
   - View original URL and short code
   - Copy short URLs to clipboard
   - Delete unwanted short URLs
   - See creation time for each URL

3. **Access Control**
   - Dev-only access guard
   - User-scoped URL management
   - Secure authentication required

4. **URL Redirection**
   - HTTP redirect endpoint at `/u/<code>`
   - Click tracking
   - Fast 302 redirects

## User Interface

### Input Section

- **URL Input Field**: Text field for entering long URLs
- **Validation**: Real-time URL validation with error messages
- **Shorten Button**: Creates the short URL with loading state
- **Dev Badge**: Visual indicator of dev-only access

### URL List

- **Card-based Layout**: Each short URL displayed in a card
- **Hover Effects**: Interactive hover states for better UX
- **Actions**: Copy and delete buttons for each URL
- **Time Display**: Human-readable time since creation (e.g., "2h ago")
- **Empty State**: Friendly message when no URLs exist

## Backend Architecture

### Firebase Functions

#### `createShortUrl`
- **Type**: Callable function
- **Auth**: Required
- **Input**: `{ url: string }`
- **Output**: `{ success: boolean, shortCode: string, shortUrl: string }`
- **Logic**:
  - Validates URL format
  - Generates unique 6-character code using nanoid
  - Stores in Firestore with user association
  - Returns short code

#### `getUserShortUrls`
- **Type**: Callable function
- **Auth**: Required
- **Output**: `{ success: boolean, urls: Array<ShortUrl> }`
- **Logic**:
  - Queries user's URLs from Firestore
  - Orders by creation date (newest first)
  - Limits to 100 URLs

#### `deleteShortUrl`
- **Type**: Callable function
- **Auth**: Required
- **Input**: `{ shortCode: string }`
- **Output**: `{ success: boolean }`
- **Logic**:
  - Validates ownership
  - Deletes from Firestore

#### `redirectShortUrl`
- **Type**: HTTP request handler
- **Auth**: Not required (public access)
- **Path**: `/u/:code`
- **Logic**:
  - Looks up short code in Firestore
  - Increments click counter
  - Performs 302 redirect to original URL

### Data Model

```typescript
interface ShortUrl {
  userId: string;           // Owner's user ID
  originalUrl: string;      // The full URL
  shortCode: string;        // 6-character unique code
  createdAt: Timestamp;     // Creation timestamp
  clicks: number;           // Click counter
  lastAccessedAt?: Timestamp; // Last redirect timestamp
}
```

### Firestore Structure

```
shortUrls (collection)
  ├── {shortCode} (document ID)
  │   ├── userId: string
  │   ├── originalUrl: string
  │   ├── shortCode: string
  │   ├── createdAt: timestamp
  │   ├── clicks: number
  │   └── lastAccessedAt: timestamp
```

### Firestore Indexes

Required composite index:
- Collection: `shortUrls`
- Fields: `userId` (Ascending), `createdAt` (Descending)

## Validation & Error Handling

### URL Validation

- **Format Check**: Validates URL structure using regex
- **Length Check**: Maximum 2048 characters
- **Protocol Check**: Accepts http:// and https://
- **Real-time Feedback**: Shows validation errors as user types

### Error Messages

| Error | Message | Action |
|-------|---------|--------|
| Empty URL | None | Button disabled |
| Invalid format | "Please enter a valid URL" | Prevent submission |
| Too long | "URL is too long (max 2048 characters)" | Prevent submission |
| Auth required | "Authentication required" | Redirect to auth |
| Not dev user | "Dev Access Only" | Show locked screen |
| Code generation failed | "Failed to create short URL" | Show error snackbar |
| Delete failed | "Failed to delete URL" | Show error snackbar |

## States & Loading

- **Initial Load**: Loading state while fetching user's URLs
- **Creating URL**: Button shows spinner and "Creating..." text
- **Deleting URL**: Loading overlay during delete operation
- **Success**: Snackbar with copy action
- **Error**: Error snackbar with message

## User Flows

### Creating a Short URL

1. User navigates to URL Shortener tool
2. Dev access check passes
3. User enters a long URL
4. Real-time validation occurs
5. User clicks "Shorten URL"
6. Backend generates unique code
7. Short URL created and displayed in list
8. Success snackbar appears with copy action

### Copying a Short URL

1. User clicks "Copy" button on URL card
2. Short URL copied to clipboard
3. Success snackbar confirms copy

### Deleting a Short URL

1. User clicks "Delete" button on URL card
2. Confirmation dialog appears
3. User confirms deletion
4. Backend deletes URL
5. URL removed from list
6. Success snackbar confirms deletion

### Using a Short URL

1. Anyone navigates to `/u/<code>`
2. Backend looks up original URL
3. Click counter incremented
4. User redirected to original URL

## Security Considerations

### Access Control

- **Dev-only Access**: Tool only available to developers
- **Authentication**: Required for all management operations
- **User Scoping**: Users can only manage their own URLs
- **Public Redirects**: Anyone can use short URLs (read-only)

### Data Privacy

- URLs are private to creating user
- No cross-user access to URL data
- Click tracking is anonymous

### Rate Limiting

- Consider implementing rate limits for URL creation
- Prevent abuse of redirect endpoint

## Testing

### Unit Tests

- URL validation logic
- Short code generation uniqueness
- Date formatting utility

### Widget Tests

- URL input and validation
- Create button state changes
- URL list rendering
- Copy and delete actions
- Dev access guard

### Integration Tests

- Firebase Functions execution
- Firestore CRUD operations
- Redirect endpoint functionality
- Authentication checks

## Future Enhancements

1. **Analytics**
   - Detailed click statistics
   - Geographic data
   - Referrer tracking

2. **Custom Codes**
   - Allow users to specify custom short codes
   - Validate uniqueness

3. **Expiration**
   - Set expiration dates for short URLs
   - Automatic cleanup of expired URLs

4. **QR Codes**
   - Generate QR codes for short URLs
   - Integration with QR Maker tool

5. **Batch Operations**
   - Import multiple URLs
   - Export URL list
   - Bulk delete

## Development

### Local Testing

```bash
# Start Flutter app
flutter run

# Deploy functions
cd functions
npm run build
firebase deploy --only functions:createShortUrl,functions:getUserShortUrls,functions:deleteShortUrl,functions:redirectShortUrl
```

### Environment Variables

None required for basic functionality. Future enhancements may need:
- Custom domain configuration
- Analytics API keys

## Support

For issues or feature requests, please refer to the main project documentation or contact the development team.
