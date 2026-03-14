---
description: Switch to a VGP workflow directory and branch. Usage: /switch-workflow VGP8
allowed-tools: Bash, Read, Glob
---

Switch to a VGP workflow directory and ensure the correct git branch is active.

## Input

The argument is a workflow identifier. Parse it case-insensitively:

| Identifier pattern | Directory |
|---|---|
| `VGP0`, `mito` | `Mitogenome-assembly-VGP0` |
| `VGP1`, `kmer` | `kmer-profiling-hifi-VGP1` |
| `VGP2`, `trio-kmer` | `kmer-profiling-hifi-trio-VGP2` |
| `VGP3`, `hifi-only` | `Assembly-Hifi-only-VGP3` |
| `VGP4`, `hic-phasing` | `Assembly-Hifi-HiC-phasing-VGP4` |
| `VGP5`, `trio-phasing` | `Assembly-Hifi-Trio-phasing-VGP5` |
| `VGP6` | `Purge-duplicate-contigs-VGP6` |
| `VGP6b` | `Purge-duplicates-one-haplotype-VGP6b` |
| `VGP7`, `bionano` | `Scaffolding-Bionano-VGP7` |
| `VGP8`, `hic-scaffolding` | `Scaffolding-HiC-VGP8` |
| `VGP9`, `decontamination` | `Assembly-decontamination-VGP9` |
| `precuration`, `precur`, `curation` | `hi-c-contact-map-for-assembly-manual-curation` |
| `nx`, `plot` | `Plot-Nx-Size` |

If the identifier doesn't match any pattern, list available workflows and ask the user to pick one.

## Steps

### Step 1: Navigate to directory

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
WORKFLOW_DIR="$PROJECT_ROOT/workflows/VGP-assembly-v2/<matched-directory>"

# Verify it exists
if [ ! -d "$WORKFLOW_DIR" ]; then
  echo "Directory not found: $WORKFLOW_DIR"
  # List available directories as fallback
  ls -d "$PROJECT_ROOT/workflows/VGP-assembly-v2/"*/
  exit 1
fi

cd "$WORKFLOW_DIR"
```

### Step 2: Check git branch

Determine the branch keyword to search for based on the identifier:

| Identifier | Branch keyword |
|---|---|
| `VGP0` | `vgp0` |
| `VGP1` | `vgp1` |
| `VGP2` | `vgp2` |
| `VGP3` | `vgp3` |
| `VGP4` | `vgp4` |
| `VGP5` | `vgp5` |
| `VGP6` | `vgp6` |
| `VGP6b` | `vgp6b` |
| `VGP7` | `vgp7` |
| `VGP8` | `vgp8` |
| `VGP9` | `vgp9` |
| `precuration` | `precur` |
| `nx`, `plot` | `plot\|nx` |

```bash
CURRENT_BRANCH=$(git branch --show-current)
KEYWORD="<branch-keyword>"

# Check if already on a matching branch
if echo "$CURRENT_BRANCH" | grep -iq "$KEYWORD"; then
  echo "Already on branch: $CURRENT_BRANCH"
else
  # List branches matching the keyword
  MATCHING=$(git branch | grep -i "$KEYWORD" | sed 's/^[* ]*//')

  if [ -n "$MATCHING" ]; then
    echo "Current branch: $CURRENT_BRANCH"
    echo ""
    echo "Branches matching '$KEYWORD':"
    echo "$MATCHING"
  else
    echo "Current branch: $CURRENT_BRANCH"
    echo "No branches matching '$KEYWORD' found."
  fi
fi
```

### Step 3: Branch decision

Based on what was found:

**If already on a matching branch:**
- Confirm to the user: "On branch `<name>`, working in `<directory>`"
- Show a quick `git status` summary (modified files only)

**If matching branches exist but not currently checked out:**
- Present the list and ask: "Would you like to switch to one of these, or create a new branch?"
- If user picks one: `git checkout <branch-name>`
- After switching, show `git status` summary

**If no matching branches and on `main`:**
- Ask user for a branch name, suggesting: `<keyword>` (e.g., `vgp8`)
- Create: `git checkout -b <branch-name>`

**If no matching branches and NOT on `main`:**
- Warn: "You're on `<current-branch>` which doesn't match this workflow."
- Ask: "Switch to `main` first and create a new branch, or stay on current branch?"

### Step 4: Summary

After navigation and branch setup, display:

```
## Ready to work on <Workflow Name>

Directory: workflows/VGP-assembly-v2/<dir>/
Branch: <branch-name>
Status: <clean / N modified files>

Files:
- <workflow>.ga
- CHANGELOG.md
- README.md
- <workflow>-tests.yml
```

## Important

- NEVER force-checkout or discard uncommitted changes. If there are uncommitted changes and a branch switch is needed, warn the user first.
- Use `cd` to change directory - the user wants their shell CWD to change.
- After `cd`, all subsequent commands should work relative to the new directory.
