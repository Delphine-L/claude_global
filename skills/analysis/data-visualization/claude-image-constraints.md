# Image Size Constraints for Claude API

**CRITICAL**: When generating images to share with Claude (for review, debugging, etc.), images must not exceed **8000 pixels** in either dimension.

## Check Image Size Before Opening

Always verify image dimensions before trying to display them in Claude:

```python
from PIL import Image

# Check dimensions
img = Image.open('figure.png')
print(f"Image size: {img.width}x{img.height}")

if img.width > 8000 or img.height > 8000:
    print(f"WARNING: Image too large for Claude API!")
    print(f"   Claude limit: 8000px max dimension")
    print(f"   Your image: {img.width}x{img.height}")
```

## Set Size Constraints When Generating Figures

**For matplotlib/seaborn figures:**

```python
import matplotlib.pyplot as plt

# Set figure size to stay under Claude's limits
# Rule of thumb: Keep figsize under (80, 80) at 100 DPI
# Or under (26, 26) at 300 DPI
fig, ax = plt.subplots(figsize=(16, 12))  # Safe: 1600x1200 at 100 DPI

# When saving, control DPI to stay under limits
# 7999px / 300 DPI = 26.6 inches max
# 7999px / 100 DPI = 79.9 inches max
plt.savefig('figure.png', dpi=300, bbox_inches='tight')  # Max ~26x26 inches

# For very large figures, use lower DPI
plt.savefig('large_figure.png', dpi=100, bbox_inches='tight')  # Max ~80x80 inches
```

**Safe figure size presets:**

```python
# Publication quality (300 DPI) - fits Claude limit
FIG_SIZES = {
    'single_column': (3.5, 4),      # 1050x1200 px
    'double_column': (7, 5),        # 2100x1500 px
    'full_page': (7, 9),            # 2100x2700 px
    'poster': (20, 15),             # 6000x4500 px - safe for Claude
    'max_claude': (26, 26),         # 7800x7800 px - maximum safe size
}

fig, ax = plt.subplots(figsize=FIG_SIZES['double_column'])
plt.savefig('figure.png', dpi=300, bbox_inches='tight')
```

## Resize Oversized Images

If you have an existing image that's too large:

```python
from PIL import Image

def resize_for_claude(image_path, max_dim=7999, output_path=None):
    """
    Resize image to fit Claude's API constraints.

    Args:
        image_path: Path to input image
        max_dim: Maximum dimension (default 7999 for safety margin)
        output_path: Output path (default: adds '_resized' to filename)
    """
    img = Image.open(image_path)

    # Check if resize needed
    if img.width <= max_dim and img.height <= max_dim:
        print(f"Image OK: {img.width}x{img.height}")
        return image_path

    # Calculate new size preserving aspect ratio
    img.thumbnail((max_dim, max_dim), Image.Resampling.LANCZOS)

    # Save
    if output_path is None:
        base = image_path.rsplit('.', 1)[0]
        ext = image_path.rsplit('.', 1)[1]
        output_path = f"{base}_resized.{ext}"

    img.save(output_path)
    print(f"Resized: {image_path}")
    print(f"  Original: {Image.open(image_path).size}")
    print(f"  New: {img.size}")
    print(f"  Saved: {output_path}")

    return output_path

# Usage
resize_for_claude('large_figure.png')
```

## Quick Checks

**Bash one-liner to check size:**
```bash
# Using ImageMagick
identify figure.png | grep -o '[0-9]*x[0-9]*'

# Check if oversized
python3 -c "from PIL import Image; img=Image.open('figure.png'); print(f'{img.width}x{img.height}'); exit(0 if img.width<=7999 and img.height<=7999 else 1)" && echo "OK" || echo "TOO LARGE"
```

**Add to notebook imports:**
```python
# Standard imports for Claude-compatible figures
import matplotlib.pyplot as plt
import seaborn as sns
from PIL import Image

# Set global figure size limit
plt.rcParams['figure.max_open_warning'] = 50
MAX_CLAUDE_DIM = 7999  # Claude API limit: 8000px, use 7999 for safety

def save_figure(filename, dpi=300, **kwargs):
    """Save figure with Claude size constraint check."""
    plt.savefig(filename, dpi=dpi, bbox_inches='tight', **kwargs)

    # Verify size
    img = Image.open(filename)
    if img.width > MAX_CLAUDE_DIM or img.height > MAX_CLAUDE_DIM:
        print(f"WARNING: {filename} exceeds Claude limit!")
        print(f"   Size: {img.width}x{img.height} (max: {MAX_CLAUDE_DIM})")
        print(f"   Resizing...")
        img.thumbnail((MAX_CLAUDE_DIM, MAX_CLAUDE_DIM), Image.Resampling.LANCZOS)
        img.save(filename)
        print(f"   Resized to: {img.width}x{img.height}")
    else:
        print(f"Saved {filename}: {img.width}x{img.height}")
```

## Common Scenarios

**High-DPI screenshots from Retina displays:**
- Retina screenshots are 2x pixel density
- A full-screen 4K monitor screenshot can be 7680x4320 (OK)
- A 5K monitor screenshot is 10240x5760 (TOO LARGE!)
- Solution: Resize before sharing or take partial screenshots

**Multi-panel figures:**
```python
# Instead of one huge figure with many panels
fig, axes = plt.subplots(4, 4, figsize=(40, 40))  # Could be 12000x12000 px!

# Split into smaller figures
for i in range(4):
    fig, axes = plt.subplots(2, 2, figsize=(12, 12))  # 3600x3600 px - safe!
    # Plot subset of panels
    plt.savefig(f'figure_part{i}.png', dpi=300, bbox_inches='tight')
```

## Error Recovery

If you get the error:
```
API Error: 400 ... image dimensions exceed max allowed size: 8000 pixels
```

The error is stuck in conversation history. To recover:

1. **Skip the message**: "Please ignore the oversized image in the previous message"
2. **Resize and resend**: Use `resize_for_claude()` function above
3. **Use /safe-clear**: Save context and start fresh (if command available)

## Jupyter Notebook Image Size Issues

### Oversized Images from Combined Output

**Problem**: Jupyter notebook saves figures as extremely tall images (e.g., 1541 x 42,011 pixels) that exceed the 8000 pixel limit.

**Cause**: When a cell generates both a figure AND text output (print statements, statistical results), Jupyter captures both as a single tall image. The text output is rendered as image pixels below the figure, creating a massive combined image.

**Symptoms**:
- Image dimensions like 1541 x 42,011 pixels (height >> 8000)
- Figure displays fine in notebook but won't display in Claude or other tools
- Error: "image dimensions exceed max allowed size: 8000 pixels"

**Example of the problem**:
```python
# Cell that creates oversized image
fig, axes = plt.subplots(2, 3, figsize=(12, 8))

# ... plotting code ...
plt.tight_layout()
plt.savefig('figure.png', dpi=150, bbox_inches='tight')
plt.show()

# Text output after figure (PROBLEM!)
print("Statistical Results:")
print(f"Spearman correlation: rho={rho:.3f}, p={pval:.4f}")
# Multiple print statements create tall text output
# Jupyter combines this with figure into one 42K pixel tall image
```

**Solution 1: Split into multiple figures**

Instead of creating one large multi-panel figure, split into smaller figures:

```python
# GOOD: Split 2x3 grid into two 1x3 grids
# Figure 1: First 3 panels
fig1, axes1 = plt.subplots(1, 3, figsize=(10, 3.5))
# ... plot first 3 panels ...
plt.savefig('figure_part1.png', dpi=150, bbox_inches='tight')
plt.show()

# Figure 2: Second 3 panels
fig2, axes2 = plt.subplots(1, 3, figsize=(10, 3.5))
# ... plot second 3 panels ...
plt.savefig('figure_part2.png', dpi=150, bbox_inches='tight')
plt.show()
```

**Solution 2: Separate text output into different cell**

Move print statements to a separate cell after the figure:

```python
# Cell 1: Just the figure
fig, axes = plt.subplots(2, 3, figsize=(12, 8))
# ... plotting code ...
plt.savefig('figure.png', dpi=150, bbox_inches='tight')
plt.show()

# Cell 2: Text output (separate!)
print("Statistical Results:")
print(f"Spearman correlation: rho={rho:.3f}, p={pval:.4f}")
```

**Solution 3: Suppress text output in figure cell**

```python
# Capture results without printing
results = []
for category in categories:
    rho, pval = stats.spearmanr(x, y)
    results.append({'category': category, 'rho': rho, 'pval': pval})

# Create figure (no print statements!)
fig, axes = plt.subplots(2, 3, figsize=(12, 8))
# ... plotting code ...
plt.savefig('figure.png', dpi=150, bbox_inches='tight')
plt.show()

# Display results in separate cell or as DataFrame
results_df = pd.DataFrame(results)
```

**When to split figures**:
- Multi-panel figures with many subplots (3+ rows x 2+ columns)
- Any figure where dimensions approach 8000 pixels
- When cell has significant text output after figure
- When total cell output height feels very long in notebook

**Prevention**:
- Use the `save_figure()` helper from jupyter-notebook skill (auto-checks size)
- Keep figure cells focused on visualization only
- Save statistical results to CSV files instead of printing
- Use separate markdown cells for result interpretation
