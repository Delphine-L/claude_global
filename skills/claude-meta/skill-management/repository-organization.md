# Organizing the Centralized Repository

## Directory Organization Best Practices

**By domain/technology:**
```
$CLAUDE_METADATA/skills/
├── vgp-pipeline/              # VGP workflows
├── galaxy-tool-wrapping/      # Galaxy development
├── python-testing/            # Python test patterns
├── docker-workflows/          # Docker/containers
└── bioinformatics-common/     # General bioinformatics
```

**By function:**
```
$CLAUDE_METADATA/commands/
├── vgp-pipeline/              # VGP-specific commands
│   ├── check-status.md
│   └── debug-failed.md
├── git-workflows/             # Git commands
│   └── review-commits.md
└── deployment/                # Deployment commands
    └── deploy-production.md
```

## Naming Consistency

**Skills:**
- Format: `domain-subdomain` or `technology-purpose`
- Examples:
  - `galaxy-tool-wrapping` (technology-purpose)
  - `vgp-pipeline` (project-type)
  - `python-testing` (language-purpose)

**Commands:**
- Format: `verb-noun` or `verb-target`
- Examples:
  - `check-status` (verb-noun)
  - `debug-failed` (verb-state)
  - `update-skills` (verb-noun)

## Documentation Requirements

**Every skill directory should have:**
- `SKILL.md` (required) - Main skill file
- Clear frontmatter with name and description
- "When to Use This Skill" section
- `reference.md` (optional) - Detailed documentation
- `examples/` (optional) - Example code/configs

**Every command should have:**
- Frontmatter with name and description
- Clear prompt/instructions
- Examples if the command takes parameters
