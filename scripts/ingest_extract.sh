#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage:
  scripts/ingest_extract.sh <input-file> --kind <forum|article>

Description:
  Extracts text from .docx or .pdf into ingest/working/ as:
    - <basename>.source.md
    - <basename>.meta.yml
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 3 ]]; then
  usage
  exit 1
fi

INPUT=""
KIND=""

INPUT="$1"
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --kind)
      KIND="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$INPUT" || -z "$KIND" ]]; then
  usage
  exit 1
fi

if [[ "$KIND" != "forum" && "$KIND" != "article" ]]; then
  echo "Error: --kind must be 'forum' or 'article'." >&2
  exit 1
fi

if [[ ! -f "$INPUT" ]]; then
  echo "Error: input file not found: $INPUT" >&2
  exit 1
fi

mkdir -p ingest/working

INPUT_ABS="$(cd "$(dirname "$INPUT")" && pwd)/$(basename "$INPUT")"
FILENAME="$(basename "$INPUT")"
EXT="${FILENAME##*.}"
EXT_LC="$(printf '%s' "$EXT" | tr '[:upper:]' '[:lower:]')"
BASENAME="${FILENAME%.*}"
SAFE_BASE="$(printf '%s' "$BASENAME" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"
[[ -z "$SAFE_BASE" ]] && SAFE_BASE="document"

SOURCE_MD="ingest/working/${SAFE_BASE}.source.md"
META_YML="ingest/working/${SAFE_BASE}.meta.yml"
TMP_TEXT="ingest/working/${SAFE_BASE}.tmp.txt"

warn_pdf="false"

extract_docx() {
  if ! command -v pandoc >/dev/null 2>&1; then
    cat >&2 <<ERR
Error: pandoc is required for .docx extraction but was not found.
Install on macOS: brew install pandoc
ERR
    exit 1
  fi

  pandoc "$INPUT" -t gfm --wrap=none -o "$SOURCE_MD"
}

extract_pdf() {
  if ! command -v pdftotext >/dev/null 2>&1; then
    cat >&2 <<ERR
Error: pdftotext is required for .pdf extraction but was not found.
Install on macOS: brew install poppler
ERR
    exit 1
  fi

  pdftotext -layout "$INPUT" "$TMP_TEXT"
  {
    echo "<!--"
    echo "WARNING: Extracted from PDF via pdftotext. Layout artifacts may be present."
    echo "Manually verify headings, quotations, footnotes, and line breaks."
    echo "-->"
    echo
    cat "$TMP_TEXT"
  } > "$SOURCE_MD"
  warn_pdf="true"
  rm -f "$TMP_TEXT"
}

case "$EXT_LC" in
  docx)
    extract_docx
    ;;
  pdf)
    extract_pdf
    ;;
  *)
    echo "Error: unsupported file type '.$EXT_LC'. Use .docx or .pdf" >&2
    exit 1
    ;;
esac

TITLE_GUESS="$(awk 'NF {print; exit}' "$SOURCE_MD" | sed -E 's/^#+\s*//; s/^\*+|\*+$//g; s/^\s+|\s+$//g')"
[[ -z "$TITLE_GUESS" ]] && TITLE_GUESS=""

WORD_COUNT="$(wc -w < "$SOURCE_MD" | tr -d ' ')"
EXTRACTED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

cat > "$META_YML" <<YAML
source_file: "$INPUT_ABS"
kind: "$KIND"
extracted_at_utc: "$EXTRACTED_AT"
source_basename: "$FILENAME"
source_extension: "$EXT_LC"
title_guess: "$TITLE_GUESS"
author_guess: ""
word_count_estimate: $WORD_COUNT
pdf_layout_warning: $warn_pdf
YAML

echo "Created: $SOURCE_MD"
echo "Created: $META_YML"
if [[ "$warn_pdf" == "true" ]]; then
  echo "Warning: PDF extraction may contain layout noise. Review manually."
fi
