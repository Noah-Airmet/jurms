# Ingestion Workspace

This folder supports one-document-at-a-time AI ingestion.

## Folders

- `ingest/inbox/`: drop raw `.docx` or `.pdf` source files here.
- `ingest/working/`: extraction artifacts (`.source.md` and `.meta.yml`).
- `ingest/out/`: optional staging area for drafts before moving into collections.

## Notes

- Keep source files and extraction outputs until a piece is published.
- Do not publish directly from this folder.
- Final published files belong in `_board_posts/` or `_articles/`.
