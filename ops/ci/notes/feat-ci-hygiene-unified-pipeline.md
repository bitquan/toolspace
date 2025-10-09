# CI Hygiene - Unified Pipeline

**Branch:** `feat/ci-hygiene-unified-pipeline`  
**Issue:** #100  
**Status:** Scaffold created, planning phase

---

## Problem Summary

Multiple workflows run overlapping checks (Flutter tests in 3 places, static analysis in 3 places, etc.), causing wasted compute, slower feedback, and maintenance burden.

---

## Analysis Required

### Step 1: Map All Workflows

Create comprehensive matrix of what each workflow does:

```
pr-ci.yml:
  - Flutter: build, analyze, test
  - Functions: build, lint, test
  - Security: smoke tests

auth-security-gates.yml:
  - Flutter: test
  - Functions: test
  - Security: rules tests

quality.yml:
  - Flutter: test, lint
  - Coverage analysis
  - Bundle size

zeta-scan.yml:
  - Static analysis
  - Coverage analysis
  - Security scan
```

### Step 2: Identify Overlaps

Document exact duplication with evidence (job names, run times, failure patterns).

### Step 3: Design Unified Structure

**Proposal:**

```yaml
pr-unified.yml:
  flutter-matrix: [build, analyze, test]
  functions-matrix: [build, lint, test]
  security-composite: (specialized e2e only)

quality-deep.yml: (runs post-merge or weekly)
  coverage-report
  bundle-analysis
  performance-benchmarks

zeta-security.yml: (security-only, no duplication)
  sast-scan
  dependency-scan
  secrets-scan
```

---

## Implementation Plan

1. **Audit Phase** (Week 1)
   - [ ] Document all workflow overlaps in spreadsheet
   - [ ] Calculate compute waste (redundant minutes)
   - [ ] Survey team for "must-have" vs "nice-to-have" checks

2. **Design Phase** (Week 1-2)
   - [ ] Prototype unified pr-pipeline.yml
   - [ ] Define matrix strategy
   - [ ] Map old jobs → new jobs

3. **Testing Phase** (Week 2)
   - [ ] Test unified pipeline on feature branch
   - [ ] Compare results with current pipelines
   - [ ] Measure time savings

4. **Migration Phase** (Week 3)
   - [ ] Enable unified pipeline (parallel with old)
   - [ ] Monitor for 1 week
   - [ ] Disable old workflows incrementally
   - [ ] Update required checks config

5. **Cleanup Phase** (Week 4)
   - [ ] Archive redundant workflows
   - [ ] Update documentation
   - [ ] Retrospective

---

## Success Metrics

- Reduce PR CI time by 40%+ (from ~15min to ~8min)
- Reduce workflow files by 30%+ (from ~10 to ~7)
- Single source of truth for test/lint config

---

## Risks & Mitigations

**Risk:** Breaking required checks  
**Mitigation:** Run unified pipeline in parallel for 1 week before switching

**Risk:** Missing edge cases  
**Mitigation:** Comprehensive audit phase with team review

**Risk:** Team confusion during transition  
**Mitigation:** Clear documentation, Slack announcements, gradual rollout

---

**AUTO-DEV Ready:** Not yet - requires manual audit and design phase first. AUTO-DEV can implement after design is approved.
