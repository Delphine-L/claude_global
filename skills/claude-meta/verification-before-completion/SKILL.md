---
name: verification-before-completion
description: Enforces evidence-based completion claims. Use before claiming work is done, tests pass, or bugs are fixed. Requires running verification commands and confirming output before any success claims.
version: 1.0.0
allowed-tools: Read, Grep, Glob, Bash
---

# Verification Before Completion

## Overview

**Core principle:** Evidence before claims, always.

## The Gate

```
BEFORE claiming any status:

1. IDENTIFY: What command proves this claim?
2. RUN: Execute the command (fresh, complete)
3. READ: Full output, check exit code
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence
   - If YES: State claim WITH evidence
5. ONLY THEN: Make the claim
```

## Common Failures

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | Test command output: 0 failures | Previous run, "should pass" |
| Linter clean | Linter output: 0 errors | Partial check |
| Build succeeds | Build command: exit 0 | "Looks good" |
| Bug fixed | Original symptom: gone | Code changed, assumed fixed |
| Pipeline complete | Output files exist and are valid | Tool reported success |
| Notebook runs | All cells executed without error | Some cells ran |

## Red Flags — STOP

If you catch yourself:
- Using "should", "probably", "seems to"
- Expressing satisfaction before verification ("Great!", "Done!")
- About to commit without running tests
- Relying on partial verification
- Trusting a tool's success report without checking output

## Rationalizations

| Excuse | Reality |
|--------|---------|
| "Should work now" | RUN the verification |
| "I'm confident" | Confidence != evidence |
| "Just this once" | No exceptions |
| "Tool said success" | Verify independently |
| "Partial check is enough" | Partial proves nothing |

## Key Patterns

**Tests:**
```
CORRECT: [Run test] → [See: 34/34 pass] → "All tests pass"
WRONG:   "Should pass now" / "Looks correct"
```

**Pipeline output:**
```
CORRECT: [Check output file exists] → [Verify size/format] → "Pipeline produced valid output"
WRONG:   "Galaxy shows green" (without checking actual data)
```

**Notebook:**
```
CORRECT: [Restart kernel] → [Run All] → [Check no errors] → "Notebook runs cleanly"
WRONG:   "I updated the cell" (without re-running)
```

## The Bottom Line

Run the command. Read the output. THEN claim the result.

## Attribution

Adapted from [obra/superpowers](https://github.com/obra/superpowers/) verification-before-completion skill.
