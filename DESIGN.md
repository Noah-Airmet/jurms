# Telos Design System

**For Sid.** This document is your entry point into the repo. It covers the design
philosophy, all tokens, and how to make changes without breaking things.

---

## Design Philosophy

The aesthetic goal is: *academic publishing meets Anthropic.com*. That means:

- **Warm, not cold.** Off-white cream backgrounds instead of pure white or gray.
- **Type-forward.** The typography does most of the work. Two-font system: a sturdy
  serif (Lora) for headings and article prose; a clean sans-serif (Inter) for all
  UI chrome (nav, labels, metadata, buttons).
- **Thin lines, generous space.** 1px borders. Lots of breathing room. No drop
  shadows on UI chrome (only on hover states for cards).
- **Restrained color.** Deep navy as the primary accent; warm terracotta as a
  secondary decoration on labels, issue tags, and back-links. Everything else is
  neutral.

---

## Your Primary File: `assets/css/tokens.css`

**All cosmetic changes start here.** This file defines CSS custom properties
(variables) consumed everywhere in `main.css`. If you change a token here, it
propagates across the entire site.

### Color Tokens

| Token | Current Value | Where Used |
|---|---|---|
| `--c-bg` | `#F8F4EF` | Page background |
| `--c-surface` | `#FFFFFF` | Cards, article panels |
| `--c-surface-alt` | `#F1EBE3` | Abstract boxes, alternate surfaces |
| `--c-text` | `#1A1714` | Primary body text |
| `--c-text-muted` | `#6B6360` | Secondary text, descriptions |
| `--c-text-faint` | `#A09890` | Metadata, dates, faint labels |
| `--c-border` | `#DDD5CB` | Standard dividing lines |
| `--c-border-light` | `#EAE3DC` | Subtle hairlines (article list) |
| `--c-accent` | `#1E3A5F` | Links, nav active, buttons, abstract border |
| `--c-accent-hover` | `#15294A` | Hover state for accent elements |
| `--c-accent-tint` | `#EBF0F7` | Very light navy background tint |
| `--c-warm` | `#A84A28` | Issue labels, back-links, section tags |
| `--c-warm-tint` | `#FAF0EB` | Light background for warm elements |

**To retheme:** Change `--c-accent` and `--c-warm` first. If you want a completely
different base (e.g., a dark mode), change `--c-bg`, `--c-surface`, and `--c-text`.

### Typography Tokens

The live Google Fonts link is in `_includes/head.html`. To swap fonts:
1. Change the `<link href="...google fonts url...">` in `_includes/head.html`
2. Update `--f-serif` and/or `--f-sans` in `tokens.css`

**Current fonts:**
- `--f-serif`: `'Lora'` — used for headings, article body, and serif UI elements
- `--f-sans`: `'Inter'` — used for navigation, labels, metadata, buttons

**Type scale** (all in `rem`):

| Token | Size | Typical use |
|---|---|---|
| `--text-2xs` | 11px | Labels, fine print |
| `--text-xs` | 12px | Metadata, tags, footer |
| `--text-sm` | 14px | Secondary body, bylines |
| `--text-base` | 16px | Body prose |
| `--text-lg` | 18px | Lead paragraphs, forewords |
| `--text-xl` | 20px | Small headings, article subtitles |
| `--text-2xl` | 24px | H3, issue card titles |
| `--text-3xl` | 30px | H2 |
| `--text-4xl` | 36px | H1, article headers |
| `--text-5xl` | 48px | Issue page title |
| `--text-6xl` | 60px | Homepage masthead |

### Spacing Tokens

The spacing scale runs `--sp-1` (4px) through `--sp-32` (128px). Use these instead
of raw pixel values when adding new components.

### Layout Tokens

| Token | Value | Use |
|---|---|---|
| `--container-narrow` | 680px | Article reading column |
| `--container-default` | 880px | Standard page width |
| `--container-wide` | 1120px | Landing, issue grids |
| `--header-height` | 60px | Sticky nav height |

---

## Logo

The current wordmark is set in Lora Bold at `--text-xl` with `letter-spacing: var(--tracking-wider)`.
This is pure text — easy to replace.

**When you have a logo SVG ready:**
1. Save it to `assets/images/logo.svg` (optimize with SVGO first)
2. Also save `assets/images/favicon.ico` (or a 32×32 PNG)
3. In `_includes/header.html`, replace the text wordmark block with:
   ```html
   <img src="{{ '/assets/images/logo.svg' | relative_url }}" alt="Telos" height="28">
   ```
4. Uncomment the favicon `<link>` in `_includes/head.html`

The subtitle text below the wordmark (`site.tagline`) is controlled via `_config.yml`.

---

## Component Inventory

Here's every named component in `main.css` and what it looks like:

### `.site-header` / `.site-nav`
Sticky top bar with wordmark left, nav links right. Nav links use a bottom-border
underline on hover/active (not background highlight). The subtitle text below the
wordmark hides on mobile.

### `.hero` (homepage only)
Full-width top section: large serif Telos title → subtitle → description.
Uses `clamp()` so the title scales fluidly on different screen sizes.

### `.section-header`
A small-caps label + thin bottom rule used above every major content section. The
right side optionally holds a "View all →" link. Used throughout the site for
consistent section labeling.

### `.issue-card` (homepage)
Two-column grid: left side is the issue title/theme/CTA, right side is the article list.
Collapses to single column on mobile.

### `.issue-thumb` (issues archive)
Card link in the issues grid. Has a subtle box-shadow on hover. Title in Lora Bold,
theme in Lora Italic.

### `.article-list` / `.article-list__item`
Clean list of articles separated by 1px hairlines. Each item: optional type label
(Essay / Research Article) in small-caps, title in Lora, byline in Inter.

### `.article-header`
Full article title area. Back-link → large title → optional subtitle → byline row →
optional PDF download button. Separated from body by a bottom border.

### `.article-abstract`
Left-bordered box (accent color) with "ABSTRACT" label. Used on article pages.

### `.article-body`
Lora at 18px with 1.8 line height. Consecutive paragraphs get classical text-indent.
Footnotes render via `.footnotes` (generated automatically by kramdown).

### `.foreword-callout`
White-surface bordered box used on issue pages to excerpt a professor foreword.

### `.team-card` (about page)
Simple card for each editor: name in Lora, role in small-caps terracotta, bio in Inter.

### `.tag`
Pill badge. Three variants: `--default` (neutral), `--accent` (navy tint), `--warm`
(terracotta tint). Used for article tags.

### `.btn`
Two variants: `--primary` (navy fill) and `--outline` (bordered, transparent fill).

---

## Adding New Components

1. Define any new color/spacing values as tokens in `tokens.css` if they don't exist.
2. Add the component's CSS to `main.css` under a clearly labeled comment block.
3. Update this doc.

---

## File Structure (Design-Relevant Files)

```
assets/
  css/
    tokens.css        ← YOUR PRIMARY FILE
    main.css          ← Layout + components
  images/
    logo.svg          ← Logo goes here (placeholder slot)
    favicon.ico       ← Favicon goes here
    og-image.png      ← Optional: social share image (1200×630)

_includes/
  head.html           ← Google Fonts link lives here
  header.html         ← Logo swap goes here

_layouts/
  default.html        ← Base shell (header + footer wrappers)
  home.html           ← Homepage-specific layout
  issue.html          ← Issue page layout
  article.html        ← Article page layout
```

---

## Typographic Conventions (for reference)

| Element | Font | Size | Weight | Tracking |
|---|---|---|---|---|
| Masthead (Telos) | Lora | clamp 36–60px | Bold | −0.025em |
| Issue/article title | Lora | clamp 30–48px | Bold | −0.025em |
| Article subtitle | Lora Italic | 20px | Normal | — |
| Body prose (article) | Lora | 18px | Normal | — |
| H2 in article | Inter | 24px | Semibold | −0.025em |
| Section label | Inter | 12px | Semibold | +0.1em (caps) |
| Nav links | Inter | 14px | Medium | +0.025em |
| Bylines / metadata | Inter | 14px | Normal/Medium | — |
| Tags / badges | Inter | 12px | Medium | +0.025em |

---

*Questions? Ping the editor-in-chief. This doc lives at `DESIGN.md` in the repo root
and is excluded from the Jekyll build.*
