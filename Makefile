# Toolspace CI Make Commands
# Local equivalents of CI pipelines for faster development

.PHONY: help pr-ci nightly clean

help:
	@echo "🚀 Toolspace CI Commands"
	@echo ""
	@echo "  make pr-ci      - Run lean PR checks locally (<10 min target)"
	@echo "  make nightly    - Run heavy nightly checks locally"
	@echo "  make clean      - Clean build artifacts and caches"
	@echo ""

# Lean PR CI (matches pr-ci.yml)
pr-ci:
	@echo "🚀 Running PR CI checks locally..."
	@echo ""
	@echo "📦 1/5: Flutter Build & Analyze"
	@flutter pub get
	@flutter analyze --no-pub || true
	@flutter build web --release
	@echo ""
	@echo "🟢 2/5: Functions Build & Lint"
	@cd functions && npm ci
	@cd functions && npm run lint
	@cd functions && npx tsc --noEmit
	@echo ""
	@echo "🧪 3/5: Flutter Tests"
	@flutter test --reporter expanded
	@echo ""
	@echo "🧪 4/5: Functions Unit Tests"
	@cd functions && npm run test -- --testPathIgnorePatterns=e2e
	@echo ""
	@echo "🔐 5/5: Security Smoke Tests"
	@cd test/security && npm ci
	@cd test/security && npm run test:smoke || npm run test:rules
	@echo ""
	@echo "✅ PR CI complete!"

# Heavy Nightly CI (subset - full version in nightly-ci.yml)
nightly:
	@echo "🌙 Running nightly checks locally (subset)..."
	@echo ""
	@echo "🧪 E2E Tests (starting emulators)..."
	@firebase emulators:start --only auth,firestore,functions,storage &
	@sleep 10
	@npx playwright test
	@echo ""
	@echo "🔍 Security Scan..."
	@cd functions && npm audit --production || true
	@flutter pub outdated || true
	@echo ""
	@echo "📊 Coverage..."
	@flutter test --coverage
	@cd functions && npm run test -- --coverage
	@echo ""
	@echo "✅ Nightly checks complete!"

# Clean artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf build/
	@rm -rf coverage/
	@rm -rf functions/lib/
	@rm -rf functions/coverage/
	@rm -rf test-results/
	@rm -rf playwright-report/
	@echo "✅ Clean complete!"
