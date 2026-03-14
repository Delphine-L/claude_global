# Sync-Skills: Detection Logic for Project Type

**Use these indicators to recommend skills:**

```bash
# VGP pipeline ORCHESTRATION CODEBASE (not just any VGP-related project)
# Only recommend if the actual orchestration Python code exists
if [ -f "run_all.py" ] && [ -d "batch_vgp_run/" ]; then
  recommend: vgp-pipeline + VGP commands
  note: "Detected VGP pipeline orchestration codebase"
fi

# Bioconda recipes
if ls -d recipes/ 2>/dev/null | grep -q recipes; then
  recommend: conda-recipe
  note: "Detected bioconda recipes directory"
fi

# Galaxy workflows (general)
if ls *.ga 2>/dev/null | head -1; then
  recommend: galaxy-workflow-development
  note: "Detected Galaxy workflow files (.ga)"
fi

# Galaxy tools repository
if ls -d tools/ 2>/dev/null | grep -q tools; then
  recommend: galaxy-tool-wrapping
  note: "Detected Galaxy tools directory"
fi
```

**IMPORTANT for VGP-related projects:**
- Only recommend `vgp-pipeline` skill if `run_all.py` AND `batch_vgp_run/` directory exist
- If project has VGP workflows (.ga files) but NO orchestration code, recommend `galaxy-workflow-development` instead
- If project is developing VGP tools, recommend `galaxy-tool-wrapping` instead
- The `vgp-pipeline` skill is specifically for the orchestration codebase, not general VGP development
