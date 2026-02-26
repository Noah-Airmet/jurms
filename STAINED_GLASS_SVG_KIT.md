# Stained Glass SVG Kit Guide

This guide defines exactly how to create and deliver the stained-glass SVG kit used by the About-page pilot.

## A) Purpose and Constraints

### Goal
Create a cohesive stained-glass asset kit that gives the site atmospheric ornament while preserving the clean, readable editorial look and fast rendering.

### Hard constraints
- Use transparent backgrounds for all SVG assets.
- Keep files small and composable.
- Use a consistent visual language across corners, card accents, and came bars.
- Preserve text readability; ornament must never overpower content.
- Favor vector-only exports unless a texture absolutely requires raster.

### Performance constraints
- Prefer many small SVGs over one large full-screen bitmap.
- Target small file sizes per asset (see section F).
- Keep effect rendering in CSS/JS lightweight (no WebGL required for this pilot).

## B) Complete Asset Inventory

Place all files in `assets/images/stained-glass/`.

### 1) Viewport corner assets (required)
- `corner-top-left.svg`
- `corner-top-right.svg`
- `corner-bottom-left.svg`
- `corner-bottom-right.svg`

Purpose:
- Decorative stained-glass edge treatment anchored to viewport corners.

Recommended artboard:
- `360 x 360 px`.

### 2) Card corner assets (required)
- `card-corner-a.svg` (primary motif)
- `card-corner-b.svg` (alternate motif)

Purpose:
- Corner accents for `.team-card`.

Recommended artboard:
- `128 x 128 px`.

Mirroring strategy:
- Build two motifs only.
- Let CSS mirror/alternate placements instead of exporting all permutations.

### 3) Came assets (required)
- `came-horizontal.svg`
- `came-vertical.svg`
- `came-ornament-center.svg` (section medallion)

Purpose:
- Suggest lead/came framing lines and section ornaments.

Recommended artboards:
- Horizontal: `600 x 10 px`
- Vertical: `10 x 600 px`
- Ornament: `220 x 18 px`

### 4) Texture overlay (optional but supported)
- `glass-grain-overlay.svg` (vector grain)
- Optional alternative: very light `.webp` texture if vector texture is insufficient.

Purpose:
- Subtle atmospheric grain in the edge overlay.

Recommended artboard:
- `220 x 220 px` tile.

## C) Art Direction System

Use this palette and styling baseline to keep all parts thematically consistent.

### Color palette

| Role | Hex | Notes |
|---|---|---|
| Warm amber glass | `#D8C38D` | Main luminous fill |
| Soft teal glass | `#9EB5B4` | Cool contrast pane |
| Burnt orange glass | `#B36A3A` | Warm accent pane |
| Pale gold highlight | `#EAD9A1` | Small highlight pane |
| Came base metal | `#5C4A3F` | Primary came tone |
| Came dark edge | `#43352D` | Contour/shadow |
| Came highlight | `#F4E8CE` | Subtle bevel highlight |

### Came style rules
- Visual language: aged lead/bronze, not polished chrome.
- Stroke widths:
  - Large corner linework: `4-6 px`
  - Card corner linework: `3-4 px`
  - Small ornaments: `1.5-2 px`
- Add slight tonal variation in cames to avoid flatness.

### Opacity standards
- Large edge panes: `0.28 - 0.50`
- Card panes: `0.38 - 0.60`
- Texture/grain: `0.05 - 0.14`

### Edge distress rules
- Keep distress subtle and sparse.
- Favor tiny tonal chips and slight opacity irregularity over heavy grunge.
- Do not add aggressive noise that hurts text contrast.

### "Do not" rules
- Do not use neon saturation.
- Do not use hard black outlines everywhere.
- Do not create photoreal textures that inflate file size.
- Do not introduce many one-off motifs that break cohesion.

## D) Illustrator/Figma Build Workflow

## 1) Document setup
- Use RGB color mode.
- Use pixel-aligned artboards at the sizes listed above.
- Turn on pixel preview/snapping for clean edges.

## 2) Layer naming convention
For each file:
- `GUIDES` (locked, non-export)
- `PANES_BASE`
- `PANES_DETAIL`
- `CAMES_MAIN`
- `CAMES_HIGHLIGHT`
- `TEXTURE` (optional)

## 3) Build method
- Start from simple geometric pane blocks.
- Add 2-4 intersecting came paths to define structure.
- Create depth by varying pane opacity and hue, not by adding blur-heavy effects.

## 4) Stroke expansion guidance
- Expand strokes only when necessary for reliable export.
- Keep live strokes if they remain stable in SVG output.
- If expanded, simplify paths to reduce node count.

## 5) Transparency handling
- Background must remain transparent.
- Avoid opaque bounding rectangles.
- Confirm alpha transparency in exported SVG.

## 6) Reusable symbols/components
- Build reusable pane clusters and came motifs.
- Reuse clusters across corner assets for consistency.
- Rotate/mirror responsibly; avoid obvious repetitive tiling artifacts.

## E) Export Settings

### Illustrator SVG export
- Profile: SVG 1.1 (or SVG Tiny 1.2 if your workflow requires)
- Fonts: convert to outlines if any text exists (generally avoid text in assets)
- Images: embed only if absolutely required
- Decimal precision: `2-3`
- Minify: enabled
- Responsive: disabled (explicit width/height preferred for predictable behavior)

### Figma SVG export
- Outline strokes where needed.
- Ensure IDs/classes are not bloated.
- Export selections cleanly without hidden layers.

### Naming standard
- Use lowercase kebab-case.
- Keep names stable to avoid CSS mapping churn.

## F) Optimization Pipeline

### 1) Initial export QA
- Open SVG in browser directly.
- Verify transparency, line joins, and no clipped elements.

### 2) Optimize with SVGOMG or SVGO
Suggested SVGOMG toggles:
- Remove metadata: on
- Remove editor data: on
- Cleanup IDs: on
- Convert styles to attrs: on
- Collapse groups: on (if safe)
- Precision: `2` or `3`

### 3) Post-opt QA
- Compare before/after visually at 100% and 200% zoom.
- Confirm no shape distortions from precision reduction.

### 4) Size targets
- Corner assets: `< 30 KB` each ideal, `< 45 KB` max
- Card corners: `< 12 KB` each ideal
- Came bars: `< 6 KB` each ideal
- Texture tile: `< 15 KB` ideal

## G) Integration Map (Asset -> Code Hook)

| Asset file | Used by selector(s) | Role |
|---|---|---|
| `corner-top-left.svg` | `body[data-theme="stained-glass"]::before` | Viewport edge ornament top-left |
| `corner-top-right.svg` | `body[data-theme="stained-glass"]::before` | Viewport edge ornament top-right |
| `corner-bottom-left.svg` | `body[data-theme="stained-glass"]::before` | Viewport edge ornament bottom-left |
| `corner-bottom-right.svg` | `body[data-theme="stained-glass"]::before` | Viewport edge ornament bottom-right |
| `glass-grain-overlay.svg` | `body[data-theme="stained-glass"]::before` | Subtle repeating texture layer |
| `card-corner-a.svg` | `body[data-theme="stained-glass"] .team-card::before` and alternating `::after` | Team-card corner accent |
| `card-corner-b.svg` | `body[data-theme="stained-glass"] .team-card::after` and alternating `::before` | Team-card corner accent alt |
| `came-ornament-center.svg` | `.about-glass-team .section-header::after`, `.about-glass-contact h2::after` | Section medallion ornament |
| `came-horizontal.svg` | Reserved for future came strip usage in CSS | Horizontal came utility |
| `came-vertical.svg` | Reserved for future came strip usage in CSS | Vertical came utility |

## H) Responsive Behavior Rules

### Desktop baseline
- Corner ornaments sized up to roughly `320 px` max per corner.
- Card corner ornaments at roughly `74 px`.

### Mobile adjustments
- Corner ornaments scale down to about `220 px` max.
- Card ornaments scale down to about `60 px`.
- Ornament opacity reduced to prevent visual clutter.

### Safe-area guidance
- Keep key motifs inside inset margins so they do not collide with browser UI or notch zones.
- Avoid placing high-contrast details at exact viewport edges.

## I) Accessibility and Performance Checklist

### Accessibility
- Verify body text remains readable over all decorative layers.
- Ensure decorative assets are non-interactive and non-announced.
- Confirm spotlight is disabled for reduced motion and coarse pointers.

### Performance
- Check no layout shifts from overlay assets.
- Confirm pointer tracking remains smooth on desktop.
- Keep total decorative payload modest and cacheable.

### Pre-merge test checklist
- Test `/about/` at desktop widths and on mobile simulator.
- Test reduced-motion mode.
- Test touch/coarse pointer behavior.
- Verify no regressions in nav and scrolling.

## J) Iteration Workflow

### Versioning convention
- Start with `v1` asset set.
- Subsequent updates use `v1.1`, `v1.2`, etc.
- For major stylistic shifts: `v2`.

### Swap process
1. Export revised SVGs using same filenames.
2. Optimize and validate locally.
3. Reload `/about/` and compare visuals.
4. Tune only tokens first (`tokens.css`) before changing structural CSS.

### Regression screenshot checklist
Capture before/after for:
- Full page desktop at 1440px width.
- Team grid region.
- Contact section.
- Mobile width (~390px).
- Reduced-motion and touch fallback views.

## Framework Parts This Kit Supports

This kit powers all current stained-glass framework parts in code:
- Viewport edge ornaments.
- Team card corner ornaments.
- Came ornament medallions for section headers.
- Atmospheric grain texture layer.
- Soft cursor-following spotlight (CSS/JS, not an SVG).

If you replace assets while preserving filenames, the framework updates automatically.
