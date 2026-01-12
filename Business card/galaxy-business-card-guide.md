# Galaxy Project Business Card Generator

This guide will help you generate your own Galaxy Project business cards.

## Requirements

### Python packages
```bash
pip install pillow qrcode
```

### Required files
- `transparent_400x400.png` - Galaxy logo (transparent background)
- `iwc_logo.png` - IWC Workflows logo
- `GTNStarBars300.png` - GTN Training logo
- Exo font family (extract `Exo.zip` to get the font files)

## File Structure

```
your_folder/
├── logos/
│   ├── transparent_400x400.png
│   ├── iwc_logo.png
│   └── GTNStarBars300.png
├── fonts/
│   └── static/
│       ├── Exo-Bold.ttf
│       ├── Exo-SemiBold.ttf
│       ├── Exo-Medium.ttf
│       ├── Exo-Regular.ttf
│       └── Exo-Light.ttf
├── create_card_front.py
└── create_card_back.py
```

---

## Front Card Script

Create a file called `create_card_front.py`:

```python
#!/usr/bin/env python3
"""
Galaxy Project Business Card - Front Side
"""

from PIL import Image, ImageDraw, ImageFont
import qrcode

# Card dimensions (3.5" x 2" at 300 DPI)
CARD_WIDTH = 1050
CARD_HEIGHT = 600

# Colors
WHITE = (255, 255, 255)
GRAY_DARK = (88, 89, 91)  # Galaxy brand gray
GRAY_LIGHT = (150, 150, 150)
GOLD = (206, 184, 36)  # Galaxy brand gold


def generate_qr(url, size=150):
    """Generate a QR code image"""
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_M,
        box_size=10,
        border=0,
    )
    qr.add_data(url)
    qr.make(fit=True)
    
    qr_img = qr.make_image(fill_color=GRAY_DARK, back_color='white')
    qr_img = qr_img.resize((size, size), Image.Resampling.LANCZOS)
    
    return qr_img


def load_and_resize_logo(path, max_size):
    """Load a logo and resize it maintaining aspect ratio"""
    logo = Image.open(path)
    
    if logo.mode != 'RGBA':
        logo = logo.convert('RGBA')
    
    ratio = min(max_size / logo.width, max_size / logo.height)
    new_size = (int(logo.width * ratio), int(logo.height * ratio))
    
    logo = logo.resize(new_size, Image.Resampling.LANCZOS)
    return logo


def paste_with_transparency(base, overlay, position):
    """Paste an image with transparency support"""
    if overlay.mode == 'RGBA':
        temp = Image.new('RGBA', base.size, (255, 255, 255, 255))
        temp.paste(base.convert('RGBA'), (0, 0))
        temp.paste(overlay, position, overlay)
        return temp.convert('RGB')
    else:
        base.paste(overlay, position)
        return base


def create_business_card_front():
    """Main function to create the business card front"""
    
    # Create white background
    img = Image.new('RGB', (CARD_WIDTH, CARD_HEIGHT), WHITE)
    draw = ImageDraw.Draw(img)
    
    # =====================
    # FONT PATHS - UPDATE THESE
    # =====================
    exo_bold = "fonts/static/Exo-Bold.ttf"
    exo_semibold = "fonts/static/Exo-SemiBold.ttf"
    exo_regular = "fonts/static/Exo-Regular.ttf"
    exo_light = "fonts/static/Exo-Light.ttf"
    
    try:
        title_font = ImageFont.truetype(exo_bold, 52)
        subtitle_font = ImageFont.truetype(exo_light, 20)
        label_font = ImageFont.truetype(exo_semibold, 23)
        footer_font = ImageFont.truetype(exo_regular, 21)
    except:
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
        label_font = ImageFont.load_default()
        footer_font = ImageFont.load_default()
    
    # =====================
    # LOGO PATHS - UPDATE THESE
    # =====================
    galaxy_logo = load_and_resize_logo("logos/transparent_400x400.png", 130)
    iwc_logo = load_and_resize_logo("logos/iwc_logo.png", 77)
    gtn_logo = load_and_resize_logo("logos/GTNStarBars300.png", 77)
    hub_logo = load_and_resize_logo("logos/transparent_400x400.png", 77)
    
    # Header section
    header_y = 30
    logo_x = 50
    img = paste_with_transparency(img, galaxy_logo, (logo_x, header_y))
    draw = ImageDraw.Draw(img)
    
    text_x = logo_x + galaxy_logo.width + 25
    draw.text((text_x, header_y + 10), "GALAXY", fill=GRAY_DARK, font=title_font)
    draw.text((text_x, header_y + 68), "Data intensive science for everyone", 
              fill=GRAY_LIGHT, font=subtitle_font)
    
    # Gold accent line
    draw.rectangle([text_x, header_y + 98, text_x + 220, header_y + 102], fill=GOLD)
    
    # QR codes section
    header_height = 160
    footer_height = 60
    label_height = 45
    logo_height = 90
    
    available_height = CARD_HEIGHT - header_height - footer_height - label_height - logo_height
    available_width_per_qr = (CARD_WIDTH - 100) // 3 - 20
    
    max_qr_size = min(available_height, available_width_per_qr)
    qr_size = int(max_qr_size * 0.64)
    
    footer_start = CARD_HEIGHT - footer_height
    available_vertical = footer_start - header_height
    qr_block_height = qr_size + logo_height + label_height
    qr_y = header_height + (available_vertical - qr_block_height) // 2
    
    # QR code data
    qr_data = [
        ("https://iwc.galaxyproject.org/", "Workflows", iwc_logo),
        ("https://galaxyproject.org", "Galaxy Project", hub_logo),
        ("https://training.galaxyproject.org", "Training Material", gtn_logo),
    ]
    
    total_qr_width = 3 * qr_size
    total_gap = CARD_WIDTH - 100 - total_qr_width
    gap = total_gap // 4
    start_x = 50 + gap
    
    for i, (url, label, small_logo) in enumerate(qr_data):
        x = start_x + i * (qr_size + gap)
        
        qr_img = generate_qr(url, qr_size)
        
        # Light border
        border_padding = 6
        draw.rectangle(
            [x - border_padding, qr_y - border_padding, 
             x + qr_size + border_padding, qr_y + qr_size + border_padding],
            outline=(210, 210, 210), width=2
        )
        
        img.paste(qr_img, (x, qr_y))
        
        # Logo under QR code
        logo_x = x + (qr_size - small_logo.width) // 2
        logo_y = qr_y + qr_size + 12
        img = paste_with_transparency(img, small_logo, (logo_x, logo_y))
        draw = ImageDraw.Draw(img)
        
        # Label
        if label:
            label_bbox = draw.textbbox((0, 0), label, font=label_font)
            label_width = label_bbox[2] - label_bbox[0]
            label_x = x + (qr_size - label_width) // 2
            label_y = qr_y + qr_size + 12 + 77 + 5
            draw.text((label_x, label_y), label, fill=GRAY_DARK, font=label_font)
    
    # Footer
    footer_y = CARD_HEIGHT - 45
    draw.text((50, footer_y), "galaxyproject.org", fill=GRAY_LIGHT, font=footer_font)
    draw.line([(270, footer_y + 12), (CARD_WIDTH - 340, footer_y + 12)], fill=(220, 220, 220), width=1)
    
    motto = "Open Source  •  Open Science"
    motto_bbox = draw.textbbox((0, 0), motto, font=footer_font)
    motto_width = motto_bbox[2] - motto_bbox[0]
    draw.text((CARD_WIDTH - motto_width - 50, footer_y), motto, fill=GRAY_LIGHT, font=footer_font)
    
    # Save
    output_path = "galaxy-business-card-front.png"
    img.save(output_path, "PNG", quality=100)
    print(f"Saved to {output_path}")
    
    return output_path


if __name__ == "__main__":
    create_business_card_front()
```

---

## Back Card Script

Create a file called `create_card_back.py`:

```python
#!/usr/bin/env python3
"""
Galaxy Project Business Card - Back Side (Personal Info)
"""

from PIL import Image, ImageDraw, ImageFont
import qrcode

# Card dimensions (3.5" x 2" at 300 DPI)
CARD_WIDTH = 1050
CARD_HEIGHT = 600

# Colors
WHITE = (255, 255, 255)
GRAY_DARK = (88, 89, 91)  # Galaxy brand gray
GRAY_LIGHT = (150, 150, 150)
GOLD = (206, 184, 36)  # Galaxy brand gold


def generate_qr(url, size=100):
    """Generate a QR code image"""
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_M,
        box_size=10,
        border=0,
    )
    qr.add_data(url)
    qr.make(fit=True)
    
    qr_img = qr.make_image(fill_color=GRAY_DARK, back_color='white')
    qr_img = qr_img.resize((size, size), Image.Resampling.LANCZOS)
    
    return qr_img


def load_and_resize_logo(path, max_size):
    """Load a logo and resize it maintaining aspect ratio"""
    logo = Image.open(path)
    
    if logo.mode != 'RGBA':
        logo = logo.convert('RGBA')
    
    ratio = min(max_size / logo.width, max_size / logo.height)
    new_size = (int(logo.width * ratio), int(logo.height * ratio))
    
    logo = logo.resize(new_size, Image.Resampling.LANCZOS)
    return logo


def paste_with_transparency(base, overlay, position):
    """Paste an image with transparency support"""
    if overlay.mode == 'RGBA':
        temp = Image.new('RGBA', base.size, (255, 255, 255, 255))
        temp.paste(base.convert('RGBA'), (0, 0))
        temp.paste(overlay, position, overlay)
        return temp.convert('RGB')
    else:
        base.paste(overlay, position)
        return base


def create_business_card_back():
    """Main function to create the business card back"""
    
    # Create white background
    img = Image.new('RGB', (CARD_WIDTH, CARD_HEIGHT), WHITE)
    draw = ImageDraw.Draw(img)
    
    # =====================
    # FONT PATHS - UPDATE THESE
    # =====================
    exo_bold = "fonts/static/Exo-Bold.ttf"
    exo_semibold = "fonts/static/Exo-SemiBold.ttf"
    exo_medium = "fonts/static/Exo-Medium.ttf"
    exo_regular = "fonts/static/Exo-Regular.ttf"
    exo_light = "fonts/static/Exo-Light.ttf"
    
    try:
        name_font = ImageFont.truetype(exo_bold, 42)
        title_font = ImageFont.truetype(exo_medium, 26)
        info_font = ImageFont.truetype(exo_light, 24)
        contact_font = ImageFont.truetype(exo_regular, 26)
        cite_header_font = ImageFont.truetype(exo_semibold, 24)
        cite_font = ImageFont.truetype(exo_regular, 20)
    except:
        name_font = ImageFont.load_default()
        title_font = ImageFont.load_default()
        info_font = ImageFont.load_default()
        contact_font = ImageFont.load_default()
        cite_header_font = ImageFont.load_default()
        cite_font = ImageFont.load_default()
    
    # =====================
    # LOGO PATH - UPDATE THIS
    # =====================
    galaxy_logo = load_and_resize_logo("logos/transparent_400x400.png", 140)
    
    # Layout
    left_margin = 50
    top_margin = 45
    
    # Logo in top right corner
    logo_x = CARD_WIDTH - galaxy_logo.width - 50
    logo_y = top_margin
    img = paste_with_transparency(img, galaxy_logo, (logo_x, logo_y))
    draw = ImageDraw.Draw(img)
    
    # =====================
    # PERSONAL INFO - CUSTOMIZE THESE
    # =====================
    NAME = "Your Name, Ph.D."
    JOB_TITLE = "Your Job Title"
    PRONOUNS = "They/Them"  # or "She/Her", "He/Him", etc.
    LAB_TEAM = "Your Lab, Galaxy Team"
    UNIVERSITY = "Your University"
    RESEARCH_FOCUS = "Your research focus"
    GITHUB_HANDLE = "your-github"
    EMAIL = "your.email@galaxyproject.org"
    ORCID_URL = "https://orcid.org/0000-0000-0000-0000"
    # =====================
    
    # Name
    y = top_margin
    draw.text((left_margin, y), NAME, fill=GRAY_DARK, font=name_font)
    
    # Gold accent line
    y += 58
    draw.rectangle([left_margin, y, left_margin + 280, y + 4], fill=GOLD)
    
    # Job title
    y += 20
    draw.text((left_margin, y), JOB_TITLE, fill=GRAY_DARK, font=title_font)
    
    # Pronouns
    y += 32
    draw.text((left_margin, y), f"Pronouns: {PRONOUNS}", fill=GRAY_LIGHT, font=title_font)
    pronouns_end_y = y + 30
    
    # Footer - Affiliation and Research focus
    footer_y = CARD_HEIGHT - 75
    draw.text((left_margin, footer_y), f"{LAB_TEAM}  •  {UNIVERSITY}", fill=GRAY_DARK, font=cite_header_font)
    footer_y += 28
    draw.text((left_margin, footer_y), f"Research focus: {RESEARCH_FOCUS}", fill=GRAY_LIGHT, font=info_font)
    
    # Calculate vertical center for contact info
    footer_start_y = CARD_HEIGHT - 75
    available_space = footer_start_y - pronouns_end_y
    content_height = 60 + 150
    center_y = pronouns_end_y + (available_space - content_height) // 2
    
    # Contact info
    contact_y = center_y + 20
    draw.text((left_margin, contact_y), f"GitHub: {GITHUB_HANDLE}", fill=GRAY_DARK, font=contact_font)
    # Underline "GitHub"
    github_bbox = draw.textbbox((left_margin, contact_y), "GitHub", font=contact_font)
    draw.line([(github_bbox[0], github_bbox[3] + 2), (github_bbox[2], github_bbox[3] + 2)], fill=GRAY_DARK, width=1)
    
    contact_y += 35
    draw.text((left_margin, contact_y), f"Email: {EMAIL}", fill=GRAY_DARK, font=contact_font)
    # Underline "Email"
    email_bbox = draw.textbbox((left_margin, contact_y), "Email", font=contact_font)
    draw.line([(email_bbox[0], email_bbox[3] + 2), (email_bbox[2], email_bbox[3] + 2)], fill=GRAY_DARK, width=1)
    
    # ORCID QR code - bottom right
    orcid_qr = generate_qr(ORCID_URL, 120)
    qr_x = CARD_WIDTH - 120 - 50
    qr_y = CARD_HEIGHT - 120 - 50
    
    # Light border around QR
    draw.rectangle([qr_x - 6, qr_y - 6, qr_x + 120 + 6, qr_y + 120 + 6], outline=(210, 210, 210), width=2)
    img.paste(orcid_qr, (qr_x, qr_y))
    
    # ORCID label - rotated 90 degrees
    orcid_label_font = ImageFont.truetype(exo_medium, 16)
    label = "ORCID"
    
    label_bbox = draw.textbbox((0, 0), label, font=orcid_label_font)
    label_width = label_bbox[2] - label_bbox[0]
    label_height = label_bbox[3] - label_bbox[1]
    
    txt_img = Image.new('RGBA', (label_width + 10, label_height + 10), (255, 255, 255, 0))
    txt_draw = ImageDraw.Draw(txt_img)
    txt_draw.text((5, 5), label, fill=GRAY_DARK, font=orcid_label_font)
    txt_img = txt_img.rotate(-90, expand=True)
    
    label_x = qr_x + 120 + 8
    label_y = qr_y + (120 - txt_img.height) // 2
    img = img.convert('RGBA')
    img.paste(txt_img, (label_x, label_y), txt_img)
    img = img.convert('RGB')
    draw = ImageDraw.Draw(img)
    
    # Border
    draw.rectangle([0, 0, CARD_WIDTH - 1, CARD_HEIGHT - 1], outline=(230, 230, 230), width=1)
    
    # Save
    output_path = "galaxy-business-card-back.png"
    img.save(output_path, "PNG", quality=100)
    print(f"Saved to {output_path}")
    
    return output_path


if __name__ == "__main__":
    create_business_card_back()
```

---

## How to Customize Your Card

### Back Card (Personal Info)

Edit the following section in `create_card_back.py`:

```python
# =====================
# PERSONAL INFO - CUSTOMIZE THESE
# =====================
NAME = "Your Name, Ph.D."
JOB_TITLE = "Your Job Title"
PRONOUNS = "They/Them"  # or "She/Her", "He/Him", etc.
LAB_TEAM = "Your Lab, Galaxy Team"
UNIVERSITY = "Your University"
RESEARCH_FOCUS = "Your research focus"
GITHUB_HANDLE = "your-github"
EMAIL = "your.email@galaxyproject.org"
ORCID_URL = "https://orcid.org/0000-0000-0000-0000"
# =====================
```

### Example:

```python
NAME = "Jane Doe, Ph.D."
JOB_TITLE = "Postdoctoral Researcher"
PRONOUNS = "She/Her"
LAB_TEAM = "Nekrutenko Lab, Galaxy Team"
UNIVERSITY = "Penn State University"
RESEARCH_FOCUS = "Genomics and data visualization"
GITHUB_HANDLE = "janedoe"
EMAIL = "jane.doe@galaxyproject.org"
ORCID_URL = "https://orcid.org/0000-0001-2345-6789"
```

---

## Running the Scripts

```bash
# Generate front card
python create_card_front.py

# Generate back card
python create_card_back.py
```

This will create:
- `galaxy-business-card-front.png`
- `galaxy-business-card-back.png`

---

## Printing

The cards are generated at **300 DPI** with standard business card dimensions:
- **3.5 × 2 inches** (1050 × 600 pixels)

When printing:
1. Use a professional printing service (e.g., Vistaprint, Moo, local print shop)
2. Upload both PNG files
3. Select "standard business card" size
4. Choose double-sided printing

---

## Color Reference

| Color | Hex | RGB | Usage |
|-------|-----|-----|-------|
| Galaxy Gray (Dark) | `#58595B` | (88, 89, 91) | Main text |
| Galaxy Gray (Light) | `#969696` | (150, 150, 150) | Secondary text |
| Galaxy Gold | `#CEB824` | (206, 184, 36) | Accent line |

---

## Questions?

Contact the Galaxy Team or open an issue in the repository.
