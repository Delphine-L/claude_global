# Scientific Figure Descriptions for Publications

Templates and guidelines for writing publication-quality figure descriptions.

## Structure for Multi-Panel Figures

**Opening Sentence**: Overview + sample size + stratification
```markdown
**[Analysis type] of [N] [unit]** across [timeframe/condition], stratified by
[categories]: Category1 (n=X), Category2 (n=Y), Category3 (n=Z).
```

**Panel Descriptions**: For each panel:
```markdown
**[Metric Name]** (panel location): [Pattern observed]. [Statistical test]
(rho=[value], p=[value]) shows [interpretation]. [Biological/technical context].
```

**Closing Interpretation**: Synthesize findings
```markdown
**Interpretation:** [Overall pattern]. [Comparison across categories].
[Methodological implications]. [Connection to study goals].
```

## Example: Temporal Trends Figure

```markdown
### Figure 4. Temporal trends in assembly quality metrics for HiFi-only assemblies (2021-2025)

**Temporal analysis of six assembly quality metrics across 268 HiFi assemblies**
spanning 2021-2025, stratified by assembly and curation method: Phased+Dual
(n=101, blue), Phased+Single (n=42, orange), and Pri/alt+Single (n=125, purple).
Each panel displays individual assembly measurements (points) with linear
regression trend lines (dashed) for each category. Trend significance was
assessed using Spearman correlation (alpha=0.05).

**Key Findings:**

**Scaffold N50** (upper left): Pri/alt+Single assemblies show significant
improvement over time (rho=0.32, p=2.7x10^-4), increasing from ~100 Mb to ~700 Mb,
while Phased assemblies remain stable at ~100-200 Mb. This suggests technological
improvements in single-assembly methods during the HiFi era.

**Gap Density** (upper middle): All HiFi assemblies collectively show decreasing
gap density over time (rho=-0.17, p=0.0057), indicating improved sequence continuity.

[Additional panels...]

**Interpretation:** Temporal trends are category-specific and metric-dependent.
Pri/alt+Single assemblies show quality improvements (N50, gap density) consistent
with technological advancement during 2021-2025. Phased assemblies remain stable
across most metrics, suggesting their quality is primarily methodology-determined.
```

## Quantitative Details to Include

**Always include**:
- Sample sizes (n=X) for each group
- Statistical test used (Spearman, Mann-Whitney, etc.)
- Effect sizes (rho, r-squared, effect magnitude)
- p-values with scientific notation (p=2.7x10^-4)
- Temporal/spatial ranges (2021-2025, 100-700 Mb)
- Significance threshold (alpha=0.05)

**Avoid**:
- Vague terms ("improved", "changed") without quantification
- p-values without effect sizes
- Missing sample sizes
- Unspecified statistical methods

## Adding to Jupyter Notebooks

```python
import json

fig_description = {
    "cell_type": "markdown",
    "metadata": {},
    "source": [
        "### Figure X. [Title]\n",
        "\n",
        "**[Opening with sample sizes]**\n",
        "\n",
        "**Key Findings:**\n",
        "\n",
        "**[Metric 1]**: [Statistical result]. [Interpretation].\n",
        "\n",
        "**Interpretation:** [Synthesis]."
    ]
}

# Insert after the plotting cell
nb['cells'].insert(plot_cell_idx + 1, fig_description)
```
