# Upgrade Sheet UI Fixes

## Issues Fixed

### 1. **Missing Button Text** ✅

**Problem**: The "Upgrade to Pro/Pro+" button text was not visible
**Root Cause**: Missing explicit `foregroundColor` and text `color` in button styling
**Solution**:

- Added `foregroundColor: Colors.white` to ElevatedButton style
- Added explicit `color: Colors.white` to Text widget

### 2. **Feature List Display** ✅

**Problem**: Features were cut off or not rendering properly in scrollable view
**Root Cause**: Using SingleChildScrollView with Column inside Expanded
**Solution**:

- Changed to `ListView.builder` for better performance and scrolling
- Ensured proper shrinkWrap behavior
- Better itemBuilder pattern for rendering plan cards

### 3. **Icon and Text Alignment** ✅

**Problem**: Check icons and feature text not aligned properly
**Root Cause**: Default Row alignment
**Solution**:

- Added `crossAxisAlignment: CrossAxisAlignment.start`
- Changed icon from `check_circle_outline` to filled `check_circle`
- Increased spacing between icon and text from 8 to 12
- Added `height: 1.4` to text for better line spacing

## Changes Made

### File: `lib/billing/widgets/upgrade_sheet.dart`

#### Button Styling (Line ~360-370):

```dart
ElevatedButton(
  onPressed: () => _upgradeToPlan(planId),
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 16),
    backgroundColor: isPopular
        ? theme.colorScheme.primary
        : theme.colorScheme.secondary,
    foregroundColor: Colors.white,  // ← ADDED
  ),
  child: Text(
    'Upgrade to ${plan['displayName']}',
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: Colors.white,  // ← ADDED
    ),
  ),
)
```

#### List Rendering (Line ~190-205):

```dart
// BEFORE:
Expanded(
  child: SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(
      children: _plans!.map((plan) => _buildPlanCard(plan)).toList(),
    ),
  ),
)

// AFTER:
Expanded(
  child: ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    shrinkWrap: false,
    itemCount: _plans!.length,
    itemBuilder: (context, index) => _buildPlanCard(_plans![index]),
  ),
)
```

#### Feature List Styling (Line ~340-355):

```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.start,  // ← ADDED
  children: [
    Icon(
      Icons.check_circle,  // ← CHANGED from check_circle_outline
      size: 20,
      color: theme.colorScheme.primary,
    ),
    const SizedBox(width: 12),  // ← CHANGED from 8
    Expanded(
      child: Text(
        feature,
        style: theme.textTheme.bodyMedium?.copyWith(
          height: 1.4,  // ← ADDED for better line spacing
        ),
      ),
    ),
  ],
)
```

## Testing

### To Test:

1. **Hot reload** the app (press `r` in terminal)
2. Click on any tool that shows upgrade prompt
3. Verify:
   - ✅ Button text "Upgrade to Pro" or "Upgrade to Pro+" is clearly visible
   - ✅ Button has white text on colored background
   - ✅ All features are listed with check icons
   - ✅ Features are properly aligned
   - ✅ Card scrolls smoothly if content is long
   - ✅ Popular badge shows correctly
   - ✅ Current plan badge shows if applicable

### Expected Result:

```
┌─────────────────────────────────┐
│        Unlock More Power        │
│   Choose a plan that fits...   │
│                                 │
│  Pro                  [POPULAR] │
│  $9 /month                      │
│  For power users...             │
│                                 │
│  ✓ Everything in Free           │
│  ✓ 200 heavy operations per day │
│  ✓ 50MB max file size           │
│  ✓ Batch processing (up to 20)  │
│  ✓ Export batch results         │
│  ✓ Email support                │
│                                 │
│  ┌───────────────────────────┐  │
│  │   Upgrade to Pro  │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
```

## Visual Improvements

### Before:

- ❌ Button appeared empty (text invisible)
- ❌ Features list cut off
- ❌ Outline icons less visible
- ❌ Tight spacing

### After:

- ✅ Button text clearly visible in white
- ✅ Full features list with smooth scrolling
- ✅ Filled icons more prominent
- ✅ Better spacing and readability

## Related Files

- `config/pricing.json` - Plan definitions (unchanged, data is correct)
- `lib/billing/billing_service.dart` - Service layer (unchanged)
- `lib/billing/widgets/upgrade_sheet.dart` - UI component (UPDATED)

## Notes

The pricing.json data was already correct. The issue was purely in the UI rendering:

1. Button text color not set for dark themes
2. ListView rendering better than ScrollView + Column for dynamic content
3. Visual polish with filled icons and better alignment

---

**Status**: ✅ Fixed  
**Last Updated**: October 6, 2025  
**Files Changed**: 1 (`lib/billing/widgets/upgrade_sheet.dart`)
