# Team Guide: AI Document Ingestion

This guide explains how any teammate can ingest one `.docx` or `.pdf` into publish-ready Markdown using their preferred AI agent.

## Prerequisites

- Repo cloned and dependencies installed.
- Tools on your machine:
  - `pandoc` (for `.docx` extraction)
  - `pdftotext` from Poppler (for `.pdf` extraction)
  - `rg` (ripgrep)
- Optional for final verification: `bundle exec jekyll build`

Install on macOS:

```bash
brew install pandoc poppler ripgrep
```

## Folder Workflow

- Drop incoming source file into `ingest/inbox/`.
- Run extraction to produce artifacts in `ingest/working/`.
- Ask your agent to convert and write final output into `_board_posts/` or `_articles/`.

## Exact Commands

1. Extract source:

```bash
scripts/ingest_extract.sh ingest/inbox/<file> --kind forum
# or
scripts/ingest_extract.sh ingest/inbox/<file> --kind article
```

2. Validate final output:

```bash
scripts/validate_content.sh <final-markdown-path>
# optional full site check
scripts/validate_content.sh <final-markdown-path> --build
```

## What to Paste to the Agent

### For Forum

Use this exact prompt (replace placeholders):

```text
Use this repo at the current cwd. Ingest one Forum submission.

Read and follow:
- docs/INGESTION_PLAYBOOK.md
- docs/prompts/INGEST_FORUM.md

Input files:
- Source markdown: ingest/working/<basename>.source.md
- Metadata hints: ingest/working/<basename>.meta.yml

Run metadata:
- date: YYYY-MM-DD
- author: <Author Name>
- optional subtitle: <or omit>
- optional affiliation: <or omit>
- optional tags: [tag-one, tag-two]

Do all work end-to-end:
1) produce final markdown with valid frontmatter for layout: board_post
2) write to _board_posts/YYYY-MM-slug.md (apply -v2/-v3 collision handling)
3) run scripts/validate_content.sh on the written file
4) report: output file path + validation result + any QA concerns
```

### For Issue Article

Use this exact prompt (replace placeholders):

```text
Use this repo at the current cwd. Ingest one Issue article submission.

Read and follow:
- docs/INGESTION_PLAYBOOK.md
- docs/prompts/INGEST_ARTICLE.md

Input files:
- Source markdown: ingest/working/<basename>.source.md
- Metadata hints: ingest/working/<basename>.meta.yml

Run metadata:
- issue: <must match issue_id in _issues/*.md>
- order: <integer>
- type: Essay | Research Article | Response | Translation
- date: YYYY-MM-DD
- author: <Author Name>
- affiliation: <Affiliation>
- optional subtitle: <or omit>
- optional tags: [tag-one, tag-two]

Do all work end-to-end:
1) produce final markdown with valid frontmatter for layout: article
2) write to _articles/YYYY-issue-slug-order-short-title.md (apply -v2/-v3 collision handling)
3) run scripts/validate_content.sh on the written file
4) report: output file path + validation result + citation/footnote QA concerns
```

Quick helper to find generated extraction files:

```bash
ls -1 ingest/working/*.source.md ingest/working/*.meta.yml
```

## Review Checklist Before Commit

- Frontmatter is complete and correct.
- File is in correct collection folder.
- Filename matches policy:
  - Forum: `YYYY-MM-slug.md`
  - Article: `YYYY-issue-slug-order-short-title.md`
- No placeholder text remains.
- Citations and footnotes are intact.
- Human editor approved content and tone.
- Validation script passes.

## Common Failure Modes

- `pandoc: command not found`
  - Install `pandoc`.
- `pdftotext: command not found`
  - Install `poppler`.
- Invalid `issue` in article
  - Use a value that matches `issue_id` in `_issues/*.md`.
- Date validation failure
  - Use `YYYY-MM-DD`.
- PDF text looks messy
  - Expected for some PDFs; manually correct headings/notes after extraction.
- Footnotes heading appears above About the Author but notes render later
  - Use the prompt footnote ordering rule: keep note content directly under `## Footnotes`; do not place another heading between Footnotes and note content.
- Duplicate date/author line appears in body text
  - Remove standalone byline text like `Month Day, Year / Author Name`; author/date should come from frontmatter only.
- Source had divider lines but output lost them
  - Ask the agent to preserve source divider lines as Markdown `---` between sections (only where present in the submitted document).

## Definition of Done

A document is done when:
1. Final Markdown is in `_board_posts/` or `_articles/`.
2. `scripts/validate_content.sh` passes (and `--build` when requested).
3. Human editor has approved the content.
4. Commit is ready for publish.
