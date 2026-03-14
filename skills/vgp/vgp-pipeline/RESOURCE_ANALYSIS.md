# VGP Pipeline - Resource Analysis

> Supporting file for [SKILL.md](SKILL.md)

## Resource Analysis Insights

### VGP Workflow Canonical Names

Official VGP workflows normalized to canonical names for analysis:

| ID | Canonical Name | Description |
|----|----------------|-------------|
| VGP0 | Mitogenome Assembly (VGP0) | Mitochondrial genome assembly |
| VGP1/WF1 | K-mer Profiling (VGP1) | K-mer profiling for genome size estimation (HiFi) |
| VGP2 | K-mer Profiling Trio (VGP2) | Trio k-mer profiling |
| VGP3 | HiFi-only Assembly (VGP3) | HiFi-only assembly |
| VGP4 | HiFi-HiC Phased Assembly (VGP4) | HiFi-HiC phased assembly |
| VGP5 | HiFi-Trio Phased Assembly (VGP5) | HiFi-Trio phased assembly |
| VGP6 | Purge Duplicates (VGP6) | Purge duplicate contigs |
| VGP6b | Purge Duplicates One Haplotype (VGP6b) | Purge duplicates (haploid mode) |
| VGP7 | BioNano Scaffolding (VGP7) | BioNano optical mapping scaffolding |
| VGP8 | Hi-C Scaffolding (VGP8) | Hi-C scaffolding |
| VGP9 | Assembly Decontamination (VGP9) | Assembly decontamination |

**Note**: WF1-9 are aliases for VGP1-9 (same workflows, different naming convention).

### Official vs Non-Official Workflow Identification

When analyzing VGP workflow metrics, filter for official workflows only:

**Official workflows** (include):
- Core VGP workflows: VGP0-VGP9, WF0-WF9
- PretextMap/PreCuration workflows
- Workflows with version info (e.g., "v0.1.8", "release v0.3")
- Workflows imported from uploaded files or URLs (official sources)
- "WORKFLOW REPORT TEST" workflows (testing report generation, not execution)

**Non-official workflows** (exclude):
- Export workflows (utility workflows, e.g., "Export PretextMap Workflow")
- test1, test2, etc. (debug/retry runs with lowercase test + number)
- Attempt1, Attempt2, Fix_Attempt (retry/debug runs)
- "Copy of" workflows (user copies)
- Numbered prefixes: "1. ", "2. ", "3. " (custom project markers)
- Custom project annotations (e.g., "Used for other Columbiformes")
- Typos (e.g., "Gnome Assembly" instead of "Genome")
- "training workflow" (tutorial workflows)
- Experimental integrations (e.g., "ONT-INTEGRATED")

**Impact**: Filtering typically removes ~20-25% of data, leaving ~80% official workflow executions for accurate analysis.

## Data Analysis Troubleshooting

### Metric Availability Issues

When analyzing VGP workflow resource usage, be aware of metric availability:

**Memory Metrics**:
- `memory.max_usage_in_bytes` / `memory.limit_in_bytes` - **Only ~7% of invocations**
  - These are cgroup-based metrics from Docker/container systems
  - Only available for newer workflow runs or specific Galaxy configurations
  - Most reliable for actual memory usage data

- `galaxy_memory_mb` - **~98% of invocations**
  - Represents memory allocation/request, not actual usage
  - Much better coverage for correlation analyses
  - Use when cgroup metrics unavailable

**Runtime Metrics**:
- `runtime_seconds` - Available for most invocations
- Use sum of (cores x runtime) for "True CPU Hours" to reflect actual computational resources

**Common Data Issues**:

1. **Enrichment appears empty**: If genome characteristics show 0 species after enrichment:
   - Check if enrichment cell has been run (data only enriched in memory during notebook execution)
   - Verify species ToLIDs match between workflow data and genome metadata TSV
   - Check if genome metadata fields are populated (species may be in TSV with empty values)

2. **Limited correlation data**: When combining metrics with genome characteristics:
   - Species with rare metrics (like cgroup memory) may not overlap with species having genome data
   - Check actual overlap: how many species have BOTH the metric AND genome characteristics
   - Consider using more widely available metrics (galaxy_memory_mb, runtime_seconds)

3. **Debugging data availability**:
   ```python
   # Check metric availability
   species_with_metric = set()
   for inv in data_with_species:
       metrics = inv.get('metrics', [])
       for metric in metrics:
           if metric.get('name') == 'target_metric_name':
               if metric.get('raw_value'):
                   species_with_metric.add(inv.get('species_id'))

   # Check genome data availability
   species_with_genome = set()
   for inv in data_with_species:
       if inv.get('genome_size'):  # or other characteristic
           species_with_genome.add(inv.get('species_id'))

   # Find overlap
   overlap = species_with_metric.intersection(species_with_genome)
   print(f"Species with both: {len(overlap)}")
   ```

## Tool-Level Resource Optimization

### Identifying Top Resource Offender Tools

To prioritize optimization efforts, identify tools consuming most resources:

```python
# From df_jobs DataFrame (job-level metrics)
tool_cpu = df_jobs.groupby('tool_name').agg({
    'cpu_hours': ['sum', 'count', 'mean']
}).reset_index()
tool_cpu.columns = ['tool_name', 'total_cpu_hours', 'job_count', 'avg_cpu_hours']

top_cpu_tools = tool_cpu.sort_values('total_cpu_hours', ascending=False).head(3)

tool_memory = df_jobs.groupby('tool_name').agg({
    'peak_memory_gb': ['sum', 'count', 'mean', 'max']
}).reset_index()
top_memory_tools = tool_memory.sort_values('total_memory_gb', ascending=False).head(3)
```

### Correlating Tool Usage with Genome Characteristics

For each top tool, analyze how genome characteristics affect resource usage:

```python
from scipy import stats

for tool_name in top_cpu_tools['tool_name']:
    tool_jobs = df_jobs[df_jobs['tool_name'] == tool_name]

    # Aggregate by species
    species_data = {}
    for _, job in tool_jobs.iterrows():
        workflow_id = job['workflow_id']
        # Match with workflow invocation to get genome characteristics
        for inv in invocations:
            if inv['id'] == workflow_id and inv.get('species_id'):
                species_id = inv['species_id']
                genome_size = inv.get('genome_size')
                cpu_hours = job['cpu_hours']

                if species_id not in species_data:
                    species_data[species_id] = {
                        'genome_size': genome_size,
                        'cpu_hours': 0
                    }
                species_data[species_id]['cpu_hours'] += cpu_hours

    # Calculate correlation
    x = [d['genome_size'] for d in species_data.values()]
    y = [d['cpu_hours'] for d in species_data.values()]

    if len(x) >= 3:
        corr, pval = stats.pearsonr(x, y)
        sig = '***' if pval < 0.001 else '**' if pval < 0.01 else '*' if pval < 0.05 else 'ns'
        print(f'{tool_name}: r={corr:.3f}, p={pval:.2e} ({sig})')
```

### Interpretation

**High correlation + high p-value significance** -> Tool resource usage scales with genome characteristic
- **Actionable**: Optimize tool for this characteristic
- **Example**: Tool uses 2x CPU per 1 Gb genome size increase

**Low/no correlation** -> Resource usage independent of genome characteristics
- **Actionable**: Look for algorithmic inefficiencies
- **Example**: Tool has fixed overhead or inefficient implementation

**Significance levels**:
- *** (p < 0.001): Highly significant correlation
- ** (p < 0.01): Very significant
- * (p < 0.05): Significant
- ns: Not significant

### Visualization

Create separate plot for each tool showing all 5 genome characteristics:
- Genome Size, Heterozygosity, Repeat Content, Contig N50, GC Content
- Include trend line, correlation coefficient, and p-value on each subplot
- Point size proportional to number of jobs
