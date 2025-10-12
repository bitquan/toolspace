# Phase 4C — Cleanup Plan (Dry-Run)

Do not execute destructive actions until you reply: CONFIRM CLEANUP

## DELETE (safe to remove)
- Review legacy candidates that are clearly superseded and not referenced:
  - .github/ISSUE_TEMPLATE/phase3-issues.md
  - CRITICAL_IMPLEMENTATION_GAPS.md
  - FINAL_IMPLEMENTATION_STATUS.md
  - IMPLEMENTATION_STATUS.md
  - SPRINT_PROGRESS_REPORT.md
  - TEST_FIX_STRATEGY.md
  - TOOLSPACE_STATUS_SUMMARY.md
  - archive/AUTH01_IMPLEMENTATION_COMPLETE.md
  - archive/AUTH_01_EXECUTION_SUMMARY.md
  - archive/AUTH_EMAIL_VERIFICATION_FIX.md
  - archive/AUTH_SIGNIN_FIX.md
  - archive/CI_REFACTOR_SUMMARY.md
  - archive/COMPLETE_FIX_REPORT.md
  - archive/FIX_SUMMARY.md
  - archive/IMPLEMENTATION_STATUS.md
  - archive/IMPLEMENTATION_SUMMARY.md
  - archive/LANDING_PAGE_START_FIX.md
  - archive/PALETTE_EXTRACTOR_SUMMARY.md
  - archive/PHASE3A_PR_DESCRIPTION.md
  - archive/SESSION_SUMMARY.md
  - archive/SPRINT_COMPLETE.md
  - archive/SPRINT_PROGRESS.md
  - archive/SPRINT_PROGRESS_REPORT.md
  - archive/SPRINT_SETUP.md
  - archive/TEST_FIX_STRATEGY.md
  - archive/TEST_RESULTS_SUMMARY.md
  - archive/TOOLSPACE_STATUS_SUMMARY.md
  - archive/WHITE_SCREEN_FIX.md
  - dev-log/2025-10-phase4-local.md
  - dev-log/PHASE3_WRAPUP.md
  - dev-log/phase-3-2025-10-09-invoice-lite-service.md
  - dev-log/phase-4/PHASE_4B_COMPLETE_REPORT.md
  - dev-log/phase-4/PHASE_4B_TESTING_RESULTS.md
  - dev-log/phase-4/PHASE_4C_COMPLETE.md
  - docs/DOCUMENTATION_SUMMARY.md
  - docs/PROJECT_STATUS_SUMMARY.md
  - docs/epics/file-merger-v1-summary.md
  - docs/ops/CI_CONSOLIDATION_SUMMARY.md
  - docs/ops/REPO_CLEANUP_SUMMARY.md
  - docs/roadmap/phase-1.md
  - docs/roadmap/phase-3-implementation-summary.md
  - docs/tools/IMPLEMENTATION_SUMMARY.md
  - local-ci/pr-ci-summary.json
  - local-ci/summary.md
  - operations/logs/phase3a-summary.md
  - operations/logs/phase4-neo-ui-overhaul.md
  - reports/phase-4c/summary.md
  - scripts/create-phase3-issues.mjs
  - scripts/phase-4-final-validation.mjs
  - test/tools/json_doctor/IMPLEMENTATION_NOTES.md

## ARCHIVE (historical value)
- Remaining legacy candidates should be archived to archive/2025-10-12-phase4c/

## REWRITE / GENERATE DOCS
- Missing docs (create full 6-file suite, add header tag 'NEEDS-OWNER-REVIEW'):
  - docs/tools/vats/README.md (and USAGE.md, TESTS.md, CHANGELOG.md, DESIGN.md, INTEGRATION.md)
  - docs/tools/video_converter/README.md (and USAGE.md, TESTS.md, CHANGELOG.md, DESIGN.md, INTEGRATION.md)

## STUB SCREENS / ROUTES
- Tools present in docs but missing in code (add stub screen and route):
  - None

## SYNC BILLING / PRICING
- Tools missing pricing entries:
  - audio_transcriber (missing_pricing_entry)
  - id_gen (missing_pricing_entry)
  - password_gen (missing_pricing_entry)
  - subtitle_maker (missing_pricing_entry)
  - time_convert (missing_pricing_entry)
  - url_short (missing_pricing_entry)
  - vats (missing_pricing_entry)
  - video_converter (missing_pricing_entry)
  - audio_transcriber (doc_tool_missing_pricing_entry)
  - id_gen (doc_tool_missing_pricing_entry)
  - password_gen (doc_tool_missing_pricing_entry)
  - subtitle_maker (doc_tool_missing_pricing_entry)
  - time_convert (doc_tool_missing_pricing_entry)
  - url_short (doc_tool_missing_pricing_entry)

## ROUTE FIXES
- Mismatched or missing route slugs:
  - vats: expected '/tools/vats', present matches: none

## Missing Index
- docs/tools/TOOL_INDEX.md is missing — will be generated in execution phase

