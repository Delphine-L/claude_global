# Writing Integrated Results from Multi-Study Analyses

**Challenge**: When you have multiple parallel analyses (e.g., same metrics across 5 different populations/clades/conditions), how to present findings coherently without overwhelming readers.

**Solution**: Organize by pattern type first, then by study

## Structure Pattern

**1. Universal Patterns Section**
- Present findings consistent across ALL studies first
- This establishes the "baseline truth" readers can rely on
- Use strong language: "consistently," "across all," "universal"
- Provide statistical evidence from multiple studies

**2. Study-Specific Patterns Section**
- Present deviations and unique findings by study
- Explicitly contrast with universal patterns
- Explain why this study differs (biological/technical context)

**3. Cross-Study Comparisons Section**
- Tables comparing effect sizes across studies
- Discussion of what drives variation
- Statistical power considerations

**Example Structure** (from clade-specific genome analysis):
```markdown
## Universal Patterns Across All Vertebrates

### Gap Density: Architecture Dominates Curation
- Finding: [Universal pattern]
- Evidence: [Stats from all 5 clades]
- Interpretation: [Why this is universal]

### Telomere Detection: Technology-Limited
- [Similar structure]

## Clade-Specific Patterns

### Mammals: Dual Curation Provides Benefits
- Finding: [Unique to this clade]
- Contrast: [How this differs from universal]
- Interpretation: [Biological context]

### Birds: No N50 Benefit from Dual Curation
- [Unique pattern and explanation]

## Cross-Clade Comparisons
- [Table of effect sizes]
- [Discussion of variation]
```

## Benefits of This Structure

1. **Readers get reliable findings first**: Universal patterns are established before introducing complexity
2. **Reduces cognitive load**: Don't jump between studies repeatedly
3. **Highlights what's generalizable**: Universal section shows what works everywhere
4. **Explains variation**: Study-specific section explains why some results differ
5. **Facilitates recommendations**: Can give universal advice plus context-specific guidance

## Writing Tips

**For Universal Patterns**:
- Lead with the finding, then provide evidence from multiple studies
- Use consistent statistical reporting across all supporting evidence
- Emphasize the consistency: "across all," "in every," "universal"

**For Study-Specific Patterns**:
- Explicitly state how this differs from universal patterns
- Provide biological/technical context for why this study is unique
- Don't just report statistics - explain the mechanism

**For Statistical Power**:
- Be explicit about which studies have sufficient power
- Note limitations in smaller studies
- Don't over-interpret null results from underpowered studies

## Common Pitfalls to Avoid

- **Don't**: Report each study sequentially (Study 1 all results, Study 2 all results...)
- **Do**: Report by finding type (Finding A across all studies, Finding B across all studies...)

- **Don't**: Hide that some patterns aren't universal
- **Do**: Explicitly highlight when a pattern is study-specific and explain why

- **Don't**: Give equal weight to all findings
- **Do**: Emphasize universal patterns; note study-specific as "interesting variations"

## Application Beyond Clade Analysis

This pattern works for any multi-study synthesis:
- Clinical trials across different populations
- Experimental treatments across multiple cell lines
- Algorithm performance across different datasets
- Policy interventions across different regions

**Key principle**: Organize by what readers need to know (universal vs specific) rather than by how you conducted the studies (study-by-study).

---

# Providing Practical Recommendations from Complex Trade-offs

**Challenge**: When different methods excel at different outcomes, how to give clear guidance?

**Pattern**: "Depends on priority" recommendations with decision tree

**Structure**:
```markdown
### For [Population/Context]

**Recommended**: [Method A]
- [Metric 1]: [Performance with stats]
- [Metric 2]: [Performance with stats]
- Use when: [Priority/constraint]

**Alternative**: [Method B]
- [Metric 1]: [Performance with stats]
- [Metric 2]: [Performance with stats]
- Use when: [Different priority/constraint]

**Note**: [Important caveat or key difference from other contexts]
```

**Example** (from avian genome assemblies):
```markdown
### For Avian Genomes
**Depends on priority**:

**For gap density minimization**: Phased assembly (dual or single curation)
- Dramatic 75-100x reduction in gaps vs Pri/alt
- Strong significance (p=1.87e-10)

**For chromosome assignment**: Pri/alt + Single curation
- Best assignment (98.93% median)
- Significantly better than phased approaches (p<0.001)

**Note**: Dual curation does NOT improve scaffold N50 in birds (p=0.378),
unlike mammals. Initial assemblies are already near-optimal due to
favorable genome characteristics.
```

**Benefits**:
- Acknowledges trade-offs honestly
- Provides clear decision criteria
- Gives actionable guidance despite complexity
- Explains when different approaches are optimal
