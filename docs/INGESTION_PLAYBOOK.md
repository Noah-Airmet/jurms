# Ingestion Playbook (Forum + Issues)

Canonical rules for AI-assisted ingestion in this repo.

## 1. Scope

- `forum` output: `_board_posts/` with `layout: board_post`
- `article` output: `_articles/` with `layout: article`

## 2. Editing Mode

Use **structure-first editing** by default.

- Preserve the author's argument, voice, and claims.
- Normalize structure, headings, blockquotes, lists, footnotes, and spacing.
- Fix obvious grammar and punctuation errors only when confidence is high.
- Do not perform substantive rewrites unless explicitly requested.

## 3. Frontmatter Contracts

### Forum post (`layout: board_post`)

Required keys:

- `layout`
- `title`
- `author`
- `date` (`YYYY-MM-DD`)
- `excerpt`
- `tags`

Optional keys:

- `subtitle`
- `affiliation`
- `header_image` (site-relative path, e.g. `/assets/images/forum/my-post/header.jpg`)
- `header_image_alt`
- `header_image_caption`

### Issue article (`layout: article`)

Required keys:

- `layout`
- `title`
- `author`
- `affiliation`
- `issue` (must match `issue_id` in `_issues/*.md`)
- `order` (integer)
- `type` (`Essay | Research Article | Response | Translation`)
- `date` (`YYYY-MM-DD`)
- `abstract`
- `tags`

Optional keys:

- `subtitle`
- `pdf_url`
- `content_type` (`pdf` only when publishing PDF-only body)
- `header_image` (site-relative path, e.g. `/assets/images/articles/my-article/header.jpg`)
- `header_image_alt`
- `header_image_caption`

## 4. Citation and Footnotes

- Preserve citations and notes exactly where possible.
- Convert footnotes to kramdown-style Markdown footnotes (`[^1]`).
- If extraction damages note mapping, flag uncertainty in QA notes.
- Never invent citations, page numbers, or sources.
- If using Markdown footnote definitions (`[^1]: ...`), keep them directly under the `## Footnotes` heading with no intervening section headings.
- For Forum pieces with endnote-style source lists and no inline note references, prefer a plain numbered list under `## Footnotes` instead of Markdown footnote syntax.

## 5. Markdown Style

- Use clear heading hierarchy (`##`, `###`) only where needed.
- Keep paragraphs readable; remove hard line breaks unless semantic.
- Preserve block quotations and set off long quotations cleanly.
- Use standard Markdown lists and emphasis.
- Avoid raw HTML unless Markdown cannot represent required structure.
- Remove duplicated byline metadata in body text (for example `February 26, 2026 / Author Name`) because author/date already render from frontmatter.
- Preserve horizontal rules from source documents when they are semantically used as section separators.
- Represent horizontal rules in Markdown as `---` (or `***`), with blank lines around them.
- Do not add decorative horizontal rules that were not present in the source submission.
- Preserve inline images from source documents when present and relevant.
- For final published files, reference images from `assets/images/...` (site-relative URLs in Markdown, e.g. `![Alt text](/assets/images/forum/my-post/image-1.png)`).
- Provide meaningful alt text for each inline image and header image.

## 6. Excerpt and Abstract Rules

- Forum `excerpt`: 1-2 sentences, around 20-35 words, neutral summary.
- Article `abstract`: preserve original if provided; otherwise generate 100-200 words from source without adding new claims.

## 7. Prohibited Behaviors

- No fabricated facts, citations, quotations, or references.
- No doctrinal or argumentative alterations that change author intent.
- No placeholder text in final output (`TODO`, `[Your Name]`, `[Placeholder]`).
- No inline custom CSS in content files.

## 8. Output Paths and Naming

- Forum file name: `YYYY-MM-slug.md` in `_board_posts/`
- Article file name: `YYYY-issue-slug-order-short-title.md` in `_articles/`

Collision policy:

- If filename exists, append `-v2`, then `-v3`, etc.

## 9. Final QA Checklist (Agent Must Report)

- Frontmatter keys complete for target kind.
- `layout` is correct for target collection.
- For article: `issue` exists and `order` is numeric.
- Date format is `YYYY-MM-DD`.
- No unresolved placeholders.
- Footnotes/citations checked for extraction damage.
- Any uncertainties clearly listed.
