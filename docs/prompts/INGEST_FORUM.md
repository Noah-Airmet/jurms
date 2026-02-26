# Prompt Template: Ingest Forum Submission

Use this prompt with Cursor/Codex after running extraction.

---
You are ingesting one Forum submission for this Jekyll site.

Inputs:
- Extracted source markdown: `<PATH_TO_SOURCE_MD>`
- Metadata hints: `<PATH_TO_META_YML>`
- Rules: `docs/INGESTION_PLAYBOOK.md`

Required run metadata from editor:
- `date` (YYYY-MM-DD)
- `author` (exact preferred display name)
- Optional `subtitle`, `affiliation`, `tags` overrides

Tasks:
1. Read `docs/INGESTION_PLAYBOOK.md` and follow it strictly.
2. Convert source into polished Markdown while preserving author voice and argument.
3. Generate valid Forum frontmatter:
   - `layout: board_post`
   - `title`, `author`, `date`, `excerpt`, `tags`
   - optional `subtitle`, `affiliation`
4. Create excerpt (1-2 sentences, 20-35 words).
5. Write final file to `_board_posts/` using filename `YYYY-MM-slug.md`.
   - If collision, append `-v2`, `-v3`, etc.
6. Return QA notes:
   - uncertain metadata
   - any conversion issues
   - any citation/footnote concerns
7. Footnote ordering rule:
   - If you include `## Footnotes`, keep note content directly under it.
   - Do not place `## About the Author` (or any other heading) between a Footnotes heading and its note content.
   - For endnote-style source lists without inline note markers, use a plain numbered list instead of `[^1]:` definitions.

Hard constraints:
- Do not fabricate facts or citations.
- Do not include placeholder text.
- Do not add inline custom CSS.
---
