# Setup Templates for deprecated/ Directory

Templates created when the `deprecated/` directory is first initialized.

## deprecated/README.md

```markdown
# Deprecated Files

This directory contains files that have been deprecated and are no longer actively used in the project.

## Structure

Files are organized preserving their original directory structure:
```
deprecated/
├── figures/
│   └── old_plot.png
├── notebooks/
│   └── exploratory_v1.ipynb
└── DEPRECATION_LOG.md
```

## Purpose

Deprecated files are kept for:
- Historical reference
- Audit trail
- Recovery if needed
- Understanding project evolution

## DEPRECATION_LOG.md

See `DEPRECATION_LOG.md` for detailed information about when files were deprecated and why.
```

## deprecated/DEPRECATION_LOG.md

```markdown
# Deprecation Log

Record of all files deprecated in this project.

## Format

Each entry includes:
- **Date**: When the file was deprecated
- **File**: Original path of the deprecated file
- **Reason**: Why it was deprecated
- **Dependencies**: Other files deprecated as a result
- **Deprecated By**: Who/what triggered the deprecation

---
```

## Setup Script

```bash
DEPRECATED_DIR="$PROJECT_ROOT/deprecated"
if [ ! -d "$DEPRECATED_DIR" ]; then
    echo "Creating deprecated/ directory..."
    mkdir -p "$DEPRECATED_DIR"

    # Create README (use template above)
    cat > "$DEPRECATED_DIR/README.md" << 'EOF'
    # ... (README content from above)
    EOF

    # Create deprecation log (use template above)
    cat > "$DEPRECATED_DIR/DEPRECATION_LOG.md" << 'EOF'
    # ... (DEPRECATION_LOG content from above)
    EOF
fi
```
