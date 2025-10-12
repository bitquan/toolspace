# Billing Audit Report - Phase 4A

Generated: 2025-10-12T01:39:08.814Z

## Summary
- ✅ Aligned: 4
- ❌ Missing implementation: 11
- 📝 Undocumented implementation: 4
- ⚠️ Misaligned: 0

## ✅ Aligned Billing Features

- **audio_transcriber** (Pro): Found in functions/src/billing/webhook.ts
- **file_merger** (Pro): Found in functions/src/billing/webhook.ts
- **invoice_lite** (Pro): Found in functions/src/billing/webhook.ts
- **video_converter** (Pro): Found in functions/src/billing/webhook.ts

## ❌ Missing Implementation

- **csv_cleaner**: Tier "Free" documented but not implemented
- **md_to_pdf**: Tier "Free" documented but not implemented
- **palette_extractor**: Tier "Free" documented but not implemented
- **password_gen**: Tier "Free" documented but not implemented
- **quick_invoice**: Tier "Free" documented but not implemented
- **regex_tester**: Tier "Free" documented but not implemented
- **subtitle_maker**: Tier "Free" documented but not implemented
- **text_tools**: Tier "Free" documented but not implemented
- **time_convert**: Tier "Free" documented but not implemented
- **unit_converter**: Tier "Free" documented but not implemented
- **url_short**: Tier "Free" documented but not implemented

## 📝 Undocumented Implementation

- **functions/src/billing/createCheckoutSession.ts**: billing/createCheck
- **functions/src/billing/entitlements.ts**: Usage >= limit
- **functions/src/billing/webhook.ts**: billing profile from check, billing profile from check
- **functions/src/index.ts**: billing/createCheck

## Recommendations

### Missing Implementations

1. Implement Free tier validation for csv_cleaner
1. Implement Free tier validation for md_to_pdf
1. Implement Free tier validation for palette_extractor
1. Implement Free tier validation for password_gen
1. Implement Free tier validation for quick_invoice
1. Implement Free tier validation for regex_tester
1. Implement Free tier validation for subtitle_maker
1. Implement Free tier validation for text_tools
1. Implement Free tier validation for time_convert
1. Implement Free tier validation for unit_converter
1. Implement Free tier validation for url_short

### Undocumented Features

1. Document billing logic in functions/src/billing/createCheckoutSession.ts
1. Document billing logic in functions/src/billing/entitlements.ts
1. Document billing logic in functions/src/billing/webhook.ts
1. Document billing logic in functions/src/index.ts
