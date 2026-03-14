# Publication Standards

## DPI Requirements
- **Screen/web**: 150 DPI
- **Print (standard)**: 300 DPI
- **High-quality print**: 600 DPI

## File Formats
- **Raster**: PNG at 300 DPI (most journals accept)
- **Vector**: PDF or SVG (preferred for line plots, smaller file size, infinite zoom)
- **Avoid**: JPG (lossy compression, poor for scientific data)

## Size Specifications
Check journal requirements:
- **Single column**: Usually 3.5 inches (89 mm) wide
- **Double column**: Usually 7 inches (178 mm) wide
- **Height**: Typically max 9-10 inches

Plan figsize accordingly:
```python
# Single column figure
fig, ax = plt.subplots(figsize=(3.5, 4))

# Double column figure
fig, axes = plt.subplots(1, 2, figsize=(7, 3.5))
```

## Color Accessibility Requirements

**Many journals now require** accessibility statements for figures, including:
- Confirmation that color schemes are colorblind-safe
- Use of validated palettes (Okabe-Ito, Paul Tol)
- Alternative distinguishing features (patterns, shapes, labels)

**Nature journals specifically recommend**:
- Okabe-Ito palette for categorical data
- Avoiding red-green combinations
- Testing figures with colorblindness simulators

**In Methods section**, document your color choices:
> "All figures use the Okabe-Ito colorblind-safe palette (Okabe & Ito, 2008) to ensure accessibility for readers with color vision deficiencies."

**Reference**: Okabe, M. and Ito, K. (2008) Color Universal Design (CUD): How to make figures and presentations that are friendly to colorblind people. https://jfly.uni-koeln.de/color/
