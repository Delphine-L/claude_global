# Debugging Galaxy Tool Dependency Conflicts

## The Key Lesson

**When a tool works in version N-1 but crashes in version N after adding dependencies, the crash is caused by dependency conflicts, NOT platform issues.**

## Diagnostic Tool: planemo mull

**`planemo mull` is the fastest way to diagnose dependency conflicts** because it:
- Shows actual conda solver output
- Reveals specific version incompatibilities
- Fails fast without needing a full test run
- Gives clear error messages about which packages conflict

### The macOS Testing Rule

When testing on **macOS with mulled containers**:

✅ **If `planemo mull` builds successfully** → Dependencies are correct, tool is ready
⚠️ **If container then fails to run** with exit 133/Rosetta errors → Expected platform issue, NOT a tool problem
❌ **If `planemo mull` fails to build** → Dependency version conflict, needs fixing

**Critical insight**: Don't waste time debugging runtime errors on macOS if the container *build* succeeded. The tool will work on Linux.

## Dependency Version Conflict Workflow

When you suspect dependency version conflicts:

### Step 1: Try to Build the Container
```bash
planemo mull tool.xml
```

### Step 2: Read the Conda Solver Error
Look for:
- "Could not solve for environment specs"
- "LibMambaUnsatisfiableError"
- Lines showing which packages conflict
- Required version ranges (e.g., "requires r-base >=4.4,<4.5.0a0")

Example error:
```
r-rmarkdown =2.16 would require
  └─ r-base >=4.1,<4.2.0a0
rdeval =0.0.8 requires
  └─ r-base >=4.4,<4.5.0a0
```

This tells you: r-rmarkdown 2.16 needs R 4.1, but rdeval needs R 4.4 → **Version conflict!**

### Step 3: Search for Compatible Versions
```bash
conda search -c conda-forge -c bioconda "r-rmarkdown" | grep "r44"
```

Replace `r44` with the build string matching your base requirements (e.g., `r44` for R 4.4, `r43` for R 4.3).

Look for recent versions with the correct build string:
```
r-rmarkdown  2.30  r44hc72bb7e_0  conda-forge
```

### Step 4: Update and Verify
```xml
<!-- macros.xml - BEFORE -->
<requirement type="package" version="2.16">r-rmarkdown</requirement>

<!-- macros.xml - AFTER -->
<requirement type="package" version="2.30">r-rmarkdown</requirement>
```

```bash
planemo mull tool.xml  # Should succeed now
```

## Real-World Case Studies

### Case Study 1: Shared Requirements Causing Binary Crashes
**rdeval 0.0.7 → 0.0.8**

#### Symptoms
- rdeval 0.0.7: All tests pass ✅
- Added r-cowplot dependency to macros.xml
- rdeval 0.0.8: All tests fail with exit code 133 (SIGTRAP) ❌
- Error: "Trace/breakpoint trap"

#### Initial Misdiagnosis
"Exit code 133 + Rosetta errors on macOS = Platform incompatibility issue"

#### Correct Diagnosis
The user said: **"version 0.0.7 passes tests fine though"**

This single fact proved:
- ❌ NOT a macOS/Rosetta issue (0.0.7 works on same platform)
- ❌ NOT a binary packaging issue (0.0.7 binary works)
- ✅ IS a dependency conflict (only thing that changed)

#### Root Cause

Shared requirements macro applied to ALL tools:

```xml
<!-- macros.xml -->
<xml name="requirements">
    <requirements>
        <requirement type="package" version="0.0.8">rdeval</requirement>
        <requirement type="package" version="1.2.0">r-cowplot</requirement>  <!-- ADDED -->
    </requirements>
</xml>
```

Used by:
- **rdeval.xml** - Binary tool (doesn't need R, r-cowplot causes crash)
- **rdeval_report.xml** - R reporting (needs r-cowplot)

#### The Fix

**Split requirements by tool type:**

```xml
<!-- macros.xml -->
<macros>
    <!-- For binary tools - minimal deps -->
    <xml name="requirements">
        <requirements>
            <requirement type="package" version="@TOOL_VERSION@">rdeval</requirement>
        </requirements>
    </xml>

    <!-- For R reporting tools - with R deps -->
    <xml name="requirements_report">
        <requirements>
            <requirement type="package" version="@TOOL_VERSION@">rdeval</requirement>
            <requirement type="package" version="1.2.0">r-cowplot</requirement>
            <requirement type="package" version="2.16">r-rmarkdown</requirement>
        </requirements>
    </xml>
</macros>
```

**Use appropriate macro in each tool:**

```xml
<!-- rdeval.xml - binary tool -->
<expand macro="requirements"/>

<!-- rdeval_report.xml - R reporting tool -->
<expand macro="requirements_report"/>
```

### Case Study 2: R Package Version Incompatibility
**r-rmarkdown 2.16 with rdeval 0.0.8**

#### Symptoms
- `planemo mull rdeval_report.xml` fails with conda solver error
- Error: "Could not solve for environment specs"
- Mentions r-base version conflicts

#### Diagnosis Process

```bash
planemo mull rdeval_report.xml
```

Output shows:
```
r-rmarkdown =2.16 would require
  └─ r-base >=4.1,<4.2.0a0
rdeval =0.0.8 requires
  └─ r-base >=4.4,<4.5.0a0
Could not solve for environment specs
```

**Analysis**: r-rmarkdown 2.16 was built for R 4.1, but rdeval 0.0.8 requires R 4.4.

#### The Fix

Search for compatible version:
```bash
conda search -c conda-forge -c bioconda "r-rmarkdown" | grep "r44"
```

Found: `r-rmarkdown 2.30 r44hc72bb7e_0`

Update macros.xml:
```xml
<!-- BEFORE -->
<requirement type="package" version="2.16">r-rmarkdown</requirement>

<!-- AFTER -->
<requirement type="package" version="2.30">r-rmarkdown</requirement>
```

Verify:
```bash
planemo mull rdeval_report.xml  # ✅ Succeeds!
```

#### Key Lesson
**If the container builds, dependencies are correct** - runtime failures on macOS are expected platform issues, not tool problems.

## Debugging Pattern

### Step 1: Identify What Changed
```
Version N-1 works → Version N fails
What's different?
→ New dependencies added
```

### Step 2: Apply the "Version Comparison Test"
```
Does the previous version work on the same platform?
YES → Dependency conflict (not platform issue)
NO → Could be platform issue
```

### Step 3: Identify Dependency Scope
```
Which tools actually need the new dependency?
Binary tool: NO
Report tool: YES

Are they sharing requirements? YES → That's the problem!
```

### Step 4: Split Requirements or Update Versions
```
Option A: Create tool-specific requirement macros
Option B: Find compatible package versions
```

## Red Flags for Dependency Conflicts

| Indicator | What It Means |
|-----------|---------------|
| Worked before, fails now | Something changed |
| Exit code 133 (SIGTRAP) | Binary compatibility issue |
| Only failed after adding deps | New dep is the culprit |
| Multiple tools share requirements | Potential for conflicts |
| Previous version works same platform | NOT a platform issue |
| `planemo mull` fails with solver error | Version incompatibility |
| "requires package X >=A,<B" conflicts | Two packages need different versions of X |

## Common Mistake: Assuming Platform Issues

**Wrong thinking:**
```
"Exit code 133 + macOS + Rosetta errors = Platform incompatibility"
→ Give up on local testing
→ Assume it'll work on Linux
```

**Correct thinking:**
```
"Exit code 133 + worked in previous version = Dependency conflict"
→ Review what changed
→ Isolate the conflicting dependency
→ Fix locally and verify with planemo mull
```

## The Golden Rules

### Rule 1: Version Comparison
**If version N-1 works but version N doesn't (same platform), ask:**
1. What dependencies were added?
2. Do all tools need them?
3. Are requirements shared inappropriately?

**Don't assume platform issues until you've ruled out dependency conflicts.**

### Rule 2: Container Build Success
**On macOS:**
- `planemo mull` succeeds = Dependencies correct ✅
- Test fails with exit 133 = Platform issue (expected) ⚠️
- `planemo mull` fails = Fix dependencies first ❌

## Prevention Strategy

### DO: Use Specific Requirement Macros

```xml
<macros>
    <!-- Base binary -->
    <xml name="requirements_base">
        <requirements>
            <requirement type="package" version="@TOOL_VERSION@">tool</requirement>
        </requirements>
    </xml>

    <!-- Python analysis -->
    <xml name="requirements_python">
        <requirements>
            <requirement type="package" version="@TOOL_VERSION@">tool</requirement>
            <requirement type="package" version="3.9">python</requirement>
            <requirement type="package" version="1.0">numpy</requirement>
        </requirements>
    </xml>

    <!-- R reporting -->
    <xml name="requirements_r">
        <requirements>
            <requirement type="package" version="@TOOL_VERSION@">tool</requirement>
            <requirement type="package" version="4.0">r-base</requirement>
            <requirement type="package" version="2.0">r-rmarkdown</requirement>
        </requirements>
    </xml>
</macros>
```

### DON'T: Share All Requirements

```xml
<!-- BAD: Everything for everyone -->
<xml name="requirements">
    <requirements>
        <requirement type="package" version="@TOOL_VERSION@">tool</requirement>
        <requirement type="package" version="3.9">python</requirement>
        <requirement type="package" version="1.0">numpy</requirement>
        <requirement type="package" version="4.0">r-base</requirement>
        <requirement type="package" version="2.0">r-rmarkdown</requirement>
    </requirements>
</xml>
```

## Testing After Dependency Changes

```bash
# After adding ANY dependency:

# 1. Build mulled container FIRST (fastest diagnostic)
planemo mull tool.xml

# 2. If mull fails with solver error:
#    - Read the conda output carefully
#    - Identify conflicting package versions
#    - Search for compatible versions
#    - Update and retry

# 3. If mull succeeds on macOS:
#    - Dependencies are correct ✅
#    - Don't worry about runtime errors (platform issue)
#    - Tool will work on Linux

# 4. Lint the tool
planemo lint tool.xml

# 5. Test ALL tools in suite (optional, for full verification)
planemo test --conda_auto_install tool1.xml tool2.xml tool3.xml
```

## Quick Fix Checklist

When tests fail after adding dependencies:

- [ ] Does `planemo mull` succeed or fail?
  - Fails → Dependency version conflict, fix versions
  - Succeeds → Dependencies correct, runtime issue is platform-related
- [ ] Did previous version work on same platform?
- [ ] What dependencies were added/changed?
- [ ] Are requirements shared across tools inappropriately?
- [ ] Do all tools need all dependencies?
- [ ] Can requirements be split by tool type?
- [ ] Have you searched for compatible package versions?

## Detailed Fix Examples

### Example 1: Version Conflict Between R Packages

**Error from `planemo mull`**:
```
r-package-a =1.0 requires r-base >=4.0,<4.1.0a0
r-package-b =2.0 requires r-base >=4.4,<4.5.0a0
Could not solve
```

**Fix**: Find version of r-package-a compatible with R 4.4:
```bash
conda search -c conda-forge "r-package-a" | grep "r44"
# Found: r-package-a 1.5 r44hc72bb7e_0
```

Update to version 1.5.

### Example 2: Conflicting Python Versions

**Error**:
```
package-x =1.0 requires python >=3.8,<3.9
package-y =2.0 requires python >=3.10,<3.11
```

**Fix**: Update package-x to newer version:
```bash
conda search -c conda-forge "package-x" | grep "py310"
```

Or use different package version of package-y compatible with Python 3.8.

## Summary

The most important debugging skills learned:

### 1. Use `planemo mull` First
**Container build success = dependencies are correct**, regardless of runtime errors on macOS.

### 2. Version Comparison Diagnostic
If version N-1 works on your platform but version N doesn't:
1. It's NOT a platform issue
2. Look at what changed (usually dependencies)
3. Check if dependencies are inappropriately shared
4. Check if dependency versions are compatible
5. Fix and verify with `planemo mull`

### 3. Read Conda Solver Output
The error messages tell you exactly which packages conflict and what versions they require.

### 4. Search for Compatible Versions
Use `conda search` with build string filters (r44, py310, etc.) to find compatible versions.

Don't waste time on platform workarounds when the real issue is dependency management.
