---
name: design-and-plan
description: Collaborative design and planning workflow for complex tasks. Brainstorm approaches, create a structured implementation plan, then execute. Use for new tools, analysis strategies, major refactors — anything that benefits from thinking before doing.
allowed-tools: Read, Grep, Glob, Bash, Agent, Write
---

# Design and Plan

A structured workflow for turning ideas into actionable plans. Use this when a task is complex enough to benefit from design-before-implementation.

**This is optional and on-demand** — not every task needs a full design cycle. Use your judgement.

## When to Use

- Building a new Galaxy tool or workflow from scratch
- Designing an analysis strategy for a new dataset
- Major refactoring of existing code
- Any task where the approach isn't immediately obvious
- When you want to think through trade-offs before committing

## Phase 1: Understand

Before proposing anything:

1. **Explore context** — check relevant files, docs, recent changes
2. **Ask clarifying questions** — one at a time, prefer multiple choice when possible
   - What's the goal?
   - What are the constraints?
   - What does success look like?
3. **Assess scope** — if the request covers multiple independent parts, suggest decomposing first

## Phase 2: Explore Approaches

1. **Propose 2-3 approaches** with trade-offs
2. Lead with your recommendation and explain why
3. Keep it conversational — this is a dialogue, not a document
4. Apply YAGNI: remove unnecessary features from all proposals

## Phase 3: Design

Once the approach is agreed:

1. Present the design in sections, scaled to complexity
   - Simple task: a few sentences
   - Complex task: architecture, components, data flow, error handling
2. Ask after each section if it looks right
3. Be ready to revise

**Design principles:**
- Break into units with clear purpose and well-defined interfaces
- Each unit should be understandable and testable independently
- In existing codebases, follow established patterns
- Don't propose unrelated refactoring

## Phase 4: Plan

Break the approved design into bite-sized tasks:

1. **Map files** — which files will be created or modified
2. **Define tasks** — each task is a small, self-contained unit of work
3. **Include specifics:**
   - Exact file paths
   - Key code snippets (not "add validation" — show the validation)
   - Commands to run and expected output
   - How to verify each step works

**Task template:**
```markdown
### Task N: [Description]

**Files:** create/modify `path/to/file`

- [ ] Step 1: [specific action]
- [ ] Step 2: [verify it works]
- [ ] Step 3: [commit if appropriate]
```

## Phase 5: Execute

Work through the plan step by step. After each task:
- Verify it works (run tests, check output)
- Update the user on progress
- Adjust the plan if you discover something unexpected

## Output

If the user wants the plan saved, write it to a reasonable location:
- For project work: `docs/plans/YYYY-MM-DD-<topic>.md`
- For analysis: as a section in the project's documentation

## Attribution

Inspired by [obra/superpowers](https://github.com/obra/superpowers/) brainstorming and writing-plans skills.
