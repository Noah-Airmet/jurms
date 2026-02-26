# Telos
**Journal of Undergraduate Research in Mormon Studies**
Est. 2025

---

## What This Repo Is

This repo is the source for the Telos website. It's a [Jekyll](https://jekyllrb.com/)
static site that deploys automatically to GitHub Pages on every push to `main`.

The site lives at: `https://[your-github-username].github.io/jurms`
(or a custom domain once configured)

---

## Team Roles

| Person | Role | What to read |
|---|---|---|
| You | Editor-in-Chief, Web | This whole doc |
| Sid | Design | `DESIGN.md` |
| Cade | Social Media | — |
| Christian | Operations / Meetings | — |

---

## Local Development Setup

### Prerequisites

You need Ruby 3.2+ and Bundler. macOS ships with an old Ruby that won't work —
install a fresh one via Homebrew.

**1. Install Homebrew** (if you don't have it):
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**2. Install Ruby via Homebrew:**
```bash
brew install ruby
```

**3. Add Homebrew's Ruby to your PATH** (Homebrew tells you to do this but it's easy to miss):
```bash
echo 'export PATH="/opt/homebrew/opt/ruby/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

> If you're on an Intel Mac (not M1/M2/M3), the path is `/usr/local/opt/ruby/bin` instead.

**4. Install Bundler:**
```bash
gem install bundler
```

### Running the Site Locally

```bash
# Clone the repo
git clone https://github.com/noah-airmet/jurms.git
cd jurms

# Install Jekyll and all dependencies (first time only)
bundle install

# Start local dev server
bundle exec jekyll serve --livereload
```

Site is available at **http://localhost:4000/jurms**

Changes to `.md` and `.html` files hot-reload automatically. Changes to `_config.yml`
require stopping the server (`Ctrl+C`) and restarting.

### Returning to the Project on a New Machine

Same steps as above. The `Gemfile.lock` committed in this repo pins all gem versions,
so `bundle install` will install exactly the same versions every time.

---

## Publishing a New Article

1. **Create a Markdown file** in `_articles/` following this naming convention:
   ```
   _articles/YYYY-[issue-slug]-[order]-[short-title].md
   ```
   Example: `_articles/2026-spring-02-lund-on-grace.md`

2. **Fill in the front matter** at the top of the file:
   ```yaml
   ---
   layout:      article
   title:       "Your Article Title"
   subtitle:    "Optional subtitle"       # optional
   author:      "Author Name"
   affiliation: "Brigham Young University"
   issue:       2026-spring               # must match issue_id in _issues/
   order:       2                         # position in issue (1 = first)
   type:        Essay                     # Essay | Research Article | Response | Translation
   date:        2026-03-01
   abstract: >
     Your abstract here (100–200 words).
   tags:
     - tag-one
     - tag-two
   ---

   Your article content in Markdown here...
   ```

3. **For PDF articles**: Upload the PDF to `assets/pdfs/` and set:
   ```yaml
   pdf_url:      /assets/pdfs/your-file.pdf
   content_type: pdf     # omit if you want both Markdown body AND a download link
   ```

4. **Commit and push** to `main`. GitHub Actions will build and deploy within ~2 minutes.

---

## Creating a New Issue

1. **Create a file** in `_issues/`:
   ```
   _issues/YYYY-[season].md
   ```
   Example: `_issues/2026-spring.md`

2. **Front matter**:
   ```yaml
   ---
   layout:    issue
   title:     "Issue II"
   theme:     "Your Issue Theme"
   issue_id:  2026-spring        # articles link to this
   volume:    1
   number:    2
   deadline:        2026-01-15   # when submissions are due
   publication_date: 2026-03-01  # when the issue goes live
   description: >
     A paragraph describing the issue theme.
   foreword_text:   "Quote from professor foreword (optional)"
   foreword_author: "Prof. Jane Smith"
   foreword_title:  "Department of Religious Education, BYU"
   ---
   ```

3. Make sure all articles for this issue have `issue: 2026-spring` in their front matter.

---

## GitHub Pages Deployment

Deployment is fully automatic via `.github/workflows/pages.yml`.

**One-time setup** (do this once after creating the GitHub repo):
1. Go to your repo → Settings → Pages
2. Under "Build and deployment", select **GitHub Actions** as the source
3. Push to `main` — the action will handle the rest

**Custom domain** (optional, later):
1. Buy a domain (Namecheap, Cloudflare, etc.)
2. In repo Settings → Pages, enter your custom domain
3. Add the GitHub Pages DNS records at your registrar
4. Create a `CNAME` file at the repo root containing your domain

---

## Printing / Physical Copies

For print issues, the current plan is **Amazon KDP** (Kindle Direct Publishing).
Export articles to PDF, assemble in a layout tool (InDesign, Affinity Publisher,
or even Word), then upload to KDP at kdp.amazon.com. KDP is free; authors pay per copy.

Alternative worth knowing: **Lulu.com** tends to produce more academic-feeling binding
and gives you a Lulu storefront. Slightly more expensive per copy but handles
ISSN registration more gracefully.

**Recommended print workflow:**
1. Export final articles as PDFs
2. Lay out in Affinity Publisher using a standard academic journal template
3. Generate print-ready PDF (PDF/X-1a standard)
4. Upload to KDP or Lulu

---

## Getting an ISSN

An ISSN is a free identifier for serial publications (journals, magazines). It gives
Telos credibility and makes it citable. Apply at:
- US: `https://www.loc.gov/issn/` (Library of Congress, free)
- Takes 2–4 weeks
- You'll want one ISSN for the print edition and a separate one for online

Not required to start, but worth doing before Issue II.

---

## Content Licensing

All articles are published under [Creative Commons BY 4.0](https://creativecommons.org/licenses/by/4.0/).
This means anyone can share or adapt the work with attribution. Authors retain copyright.
This is standard for open-access academic publishing. You can change it in `_includes/footer.html`.

---

## Repo Structure

```
jurms/
├── _articles/          ← One .md file per article
├── _issues/            ← One .md file per issue
├── _layouts/           ← Page templates (default, home, issue, article)
├── _includes/          ← Reusable HTML fragments (head, header, footer)
├── assets/
│   ├── css/
│   │   ├── tokens.css  ← Design tokens (Sid's file)
│   │   └── main.css    ← Component styles
│   ├── images/         ← Logo, favicon, any inline images
│   └── pdfs/           ← Uploaded PDF articles go here
├── pages/
│   ├── about.md
│   ├── issues.md
│   └── submit.md
├── .github/
│   └── workflows/
│       └── pages.yml   ← Auto-deploy to GitHub Pages
├── _config.yml         ← Site settings, journal metadata
├── Gemfile             ← Ruby dependencies
├── index.md            ← Homepage
├── DESIGN.md           ← Design system doc (for Sid)
└── README.md           ← This file
```
