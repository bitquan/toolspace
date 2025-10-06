# Agent Guide

This file helps coding agents work effectively in this repository. It defines conventions, how to run/validate code locally and in CI, and the expectations for changes.

Scope: Entire repo.

## Quick Start

- Prerequisites (choose what matches the project):
  - Flutter: install Flutter stable; ensure `flutter`, `dart` on PATH.
  - Dart only: install Dart SDK (latest stable); ensure `dart` on PATH.
- Install deps:
  - Flutter: `flutter pub get`
  - Dart: `dart pub get`
- Validate locally (both Flutter and Dart):
  - Format: `dart format .`
  - Analyze: `flutter analyze` (Flutter) or `dart analyze` (Dart)
  - Test: `flutter test` (Flutter) or `dart test` (Dart)

## Conventions

- Formatting: Keep code formatted with `dart format .` (CI enforces).
- Lints: Keep the code analyzer clean (treat warnings as work items).
- Naming: Use descriptive names; avoid one-letter identifiers.
- Docs: Use `///` doc comments for public APIs; add brief comments for non-obvious logic.
- Structure: Prefer small, focused units. Keep UI separate from business logic where applicable.
- Tests: Put tests under `test/` mirroring source structure. Favor fast, deterministic unit tests.

## What CI Runs

A GitHub Actions workflow validates:
- Formatting check (diff-free).
- Static analysis (`flutter analyze` or `dart analyze`).
- Tests (unit tests, no emulators/devices).
- Test coverage is uploaded as an artifact if produced.

If there is an existing workflow, this one is additive. We can merge/deduplicate once we confirm the current setup.

## Working Notes for Agents

- Make minimal, surgical changes focused on the task. Avoid drive-by refactors.
- Match existing style and structure.
- Prefer pure functions for utility logic; keep I/O at the edges.
- When adding files, include brief top-of-file description if helpful.
- Validate locally (format/analyze/test) before proposing changes when possible.

## Local Commands (copy/paste)

Flutter projects:
```
flutter pub get
dart format .
flutter analyze
flutter test --coverage
```

Dart packages:
```
dart pub get
dart format .
dart analyze
dart test --coverage
```

## Follow-ups

- If this repo is Dart-only and not Flutter, we can switch CI to use `dart-lang/setup-dart` for a lighter setup.
- If there’s an existing workflow (e.g., `.github/workflows/ci.yml`), share it and we’ll unify them.
