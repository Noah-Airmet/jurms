# Prompt Template: Ingest Issue Article Submission

Use this prompt with Cursor/Codex after running extraction.

---
You are ingesting one Issue article for this Jekyll site.

Inputs:
- Extracted source markdown: `<PATH_TO_SOURCE_MD>`
- Metadata hints: `<PATH_TO_META_YML>`
- Rules: `docs/INGESTION_PLAYBOOK.md`

Required run metadata from editor:
- `issue` (must match `issue_id` in `_issues/*.md`)
- `order` (integer position in issue)
- `type` (`Essay | Research Article | Response | Translation`)
- `date` (YYYY-MM-DD)
- `author`, `affiliation`
- optional `tags`, `subtitle`

Tasks:
1. Read `docs/INGESTION_PLAYBOOK.md` and follow it strictly.
2. Convert source into polished Markdown while preserving author voice and argument.
3. Keep and repair footnotes/citations where extraction damaged formatting.
4. Generate valid Article frontmatter:
   - `layout: article`
   - `title`, `author`, `affiliation`, `issue`, `order`, `type`, `date`, `abstract`, `tags`
   - optional `subtitle`, `pdf_url`, `content_type`
5. Write final file to `_articles/` using filename `YYYY-issue-slug-order-short-title.md`.
   - If collision, append `-v2`, `-v3`, etc.
6. Return QA notes:
   - citation risk flags
   - uncertain metadata
   - conversion defects needing human review
7. Footnote ordering rule:
   - If you include `## Footnotes`, keep footnote definitions directly under that heading.
   - Do not place `## About the Author` (or any other heading) between a Footnotes heading and footnote definitions.

Hard constraints:
- Do not fabricate facts, citations, or quotations.
- Do not include placeholder text.
- Do not add inline custom CSS.
---
