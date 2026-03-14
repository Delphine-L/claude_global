# Methodological Transparency in Figures and Statistics

## The Dual Approach Pattern

When presenting statistical analyses, you often need to balance:
- **Visual clarity**: Clean figures that communicate patterns effectively
- **Statistical rigor**: Conservative tests using all available data

**Best Practice: Explicit Documentation**

If figures show cleaned/filtered data while statistical tests use the full dataset:

1. **Figure captions must include explicit notes**:
   ```latex
   \textbf{Note}: Statistical tests in Table X use [test name] on the full
   dataset (n=XXX) for conservative assessment; this figure shows cleaned
   data (outliers removed) for visual clarity only.
   ```

2. **Methods section must explain the dual approach**:
   ```latex
   \textbf{Visualization approach}: Figures show [cleaned data description]
   for visual clarity. All statistical tests use [full dataset description]
   for conservative and robust assessment. This dual approach ensures:
   (1) clear visual communication, and (2) statistically conservative
   hypothesis testing using all available data.

   \textbf{Outlier definition}: [Specific criterion, e.g., "Points beyond
   1.5x IQR from quartiles"]. Outlier removal applied only to visualization,
   not to statistical testing.
   ```

3. **Why this matters**:
   - Prevents accusations of cherry-picking or p-hacking
   - Shows scientific integrity and transparency
   - Helps reviewers understand your methodology
   - Demonstrates you're using conservative statistical practices

## Example Use Case: Temporal Trends

**Scenario**: Scatter plots with many outliers obscure temporal trends

**Solution**:
- **Figures**: Remove outliers beyond 1.5x IQR for clean visualization
- **Statistics**: Use Spearman correlation on full dataset (all points)
- **Documentation**: Explicit notes in captions + Methods explanation

**Template**:
```latex
% In figure caption
Outliers removed for clarity (points beyond 1.5x IQR from quartiles).
\textbf{Note}: Statistical tests in Table S3 use Spearman correlation (rho)
on the full dataset for conservative assessment; this figure shows cleaned
data for visual clarity only.

% In Methods section
\textbf{Visualization approach}: Figures show scatter plots with regression
lines using cleaned data (outliers beyond 1.5x interquartile range removed)
for visual clarity. All statistical tests reported use the complete dataset
(including outliers) for conservative and robust assessment.
```

## When to Use This Pattern

**Use when**:
- Outliers obscure visual patterns but should be included in tests
- You want both clear communication and rigorous statistics
- Submitting to high-impact journals (Nature, Science, etc.)
- Anticipating reviewer questions about data filtering

**Don't use when**:
- Outliers are actual data errors (remove from both)
- Sample size is too small to justify removal
- The outliers ARE the interesting pattern
- Methods would be simpler without this complexity
