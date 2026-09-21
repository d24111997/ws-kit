---
name: project-convention-audit
description: Audit any repository (frontend, backend, or mixed) against coding conventions and project standards declared inside that repository. Use when asked to review compliance, especially for recent changes or critical modules, and generate a root-level audit report file with date and time (hour-minute) in the filename.
---

# Project Convention Audit

## Overview

Audit code based on standards defined by the project itself, not by fixed tech-stack assumptions. Derive rules from repository documents/configuration, verify code and quality gates, then emit a timestamped audit report at repository root.

## Workflow

1. Identify audit scope.
- Prefer user-specified modules/files first.
- Include recently changed files (`git status --short`, `git diff`) when relevant.
- If no scope is provided, audit the whole repository at high level and deep-dive modified/critical paths.

2. Build convention checklist from project sources.
- Discover standards from repository docs/configs before evaluating code.
- Prioritize explicit guideline files and contribution docs (examples: `AGENTS_GUIDELINE.md`, `README.md`, `CONTRIBUTING*`, `docs/**`, lint/type/test/build configs, CI workflows).
- Extract concrete, testable rules with source references (rule text + file/line).
- Do not assume framework-specific rules if the repository does not declare them.

3. Evaluate implementation against declared rules.
- Review code in scope with a findings-first mindset.
- Check architecture boundaries, typing/validation/error handling, naming/style conventions, security and secrets hygiene, and any repo-specific constraints.
- For each finding, map:
  - violated rule source,
  - code evidence (path + line),
  - impact/risk.

4. Run available quality gates.
- Execute the repository’s existing checks when possible (lint/typecheck/test/build or equivalents exposed by scripts/Makefile/task runner/CI docs).
- Record pass/fail and key errors.
- If a check cannot run, state exact blocker and residual risk.

5. Produce final audit report at repo root.
- Use filename format with hour and minute:
  - `AUDIT_REPORT_YYYY-MM-DD_HH-mm.md`
- Generate timestamp via shell date command (local timezone):
```bash
ts="$(date +%Y-%m-%d_%H-%M)"
report="AUDIT_REPORT_${ts}.md"
```
- Report must be concise and decision-ready.

## Required Report Structure

Use this structure for the root report file:

```markdown
# Audit Report

- Audit time:
- Scope:
- Standards sources:
- Overall status: PASS | PARTIAL | FAIL

## Verification Results
- lint/typecheck/test/build (or project equivalents): PASS/FAIL + short evidence

## Findings (ordered by severity)
### Critical
1. [Rule source] -> [Evidence path:line] -> [Impact]

### Major
1. ...

### Minor
1. ...

## Compliant Items
- Key checks that passed.

## Residual Risks
- Any remaining uncertainty or unverified area.

## Conclusion
- Clear go/no-go style summary.
```

## Audit Rules

- Keep findings primary; summary secondary.
- Never claim compliance without source evidence from the repository.
- Treat “no findings” explicitly as a result and still mention testing coverage gaps (if any).
- Keep the report tech-agnostic and tied to the project’s own standards so it works for both BE and FE repositories.
