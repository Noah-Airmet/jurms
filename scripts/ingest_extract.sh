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
  Also extracts embedded images when possible.
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
MEDIA_DIR="ingest/working/${SAFE_BASE}-media"

warn_pdf="false"
image_extract_note="none"

extract_docx() {
  if ! command -v pandoc >/dev/null 2>&1; then
    cat >&2 <<ERR
Error: pandoc is required for .docx extraction but was not found.
Install on macOS: brew install pandoc
ERR
    exit 1
  fi

  rm -rf "$MEDIA_DIR"
  mkdir -p "$MEDIA_DIR"
  pandoc "$INPUT" -t gfm --wrap=none --extract-media="$MEDIA_DIR" -o "$SOURCE_MD"
  image_extract_note="docx_media_extract"
  augment_docx_horizontal_rules "$INPUT" "$SOURCE_MD"
}

augment_docx_horizontal_rules() {
  local docx_path="$1"
  local md_path="$2"

  if ! command -v python3 >/dev/null 2>&1; then
    return 0
  fi

  # Word often stores divider lines as VML HR shapes (o:hr="t"), which pandoc may drop.
  # Recover those by inserting Markdown thematic breaks before matching headings.
  python3 - "$docx_path" "$md_path" <<'PY'
import html
import re
import sys
import zipfile
from pathlib import Path

docx_path = sys.argv[1]
md_path = sys.argv[2]

try:
    with zipfile.ZipFile(docx_path) as zf:
        xml = zf.read("word/document.xml").decode("utf-8", "ignore")
except Exception:
    raise SystemExit(0)

paragraphs = re.findall(r"<w:p\b.*?</w:p>", xml)
if not paragraphs:
    raise SystemExit(0)

markers = []
for i, para in enumerate(paragraphs[:-1]):
    if 'o:hr="t"' not in para:
        continue
    for j in range(i + 1, min(i + 8, len(paragraphs))):
        nxt = paragraphs[j]
        texts = re.findall(r"<w:t[^>]*>(.*?)</w:t>", nxt)
        if not texts:
            continue
        marker = html.unescape("".join(texts))
        marker = re.sub(r"\s+", " ", marker).strip()
        if marker:
            markers.append(marker)
            break

if not markers:
    raise SystemExit(0)

def norm(s: str) -> str:
    s = s.lower()
    s = re.sub(r"[`*_>#\[\](){}\"'“”‘’.,:;!?/\\\-]+", " ", s)
    s = re.sub(r"\s+", " ", s).strip()
    return s

marker_norms = [norm(m) for m in markers]
used = [False] * len(marker_norms)

src = Path(md_path)
lines = src.read_text(encoding="utf-8").splitlines()
out = []

def is_rule(line: str) -> bool:
    s = line.strip()
    return s in ("---", "***", "___")

for line in lines:
    line_norm = norm(line)
    is_heading = bool(re.match(r"^\s{0,3}#{1,6}\s+", line))
    should_insert_rule = False

    if is_heading and line_norm:
        for idx, marker in enumerate(marker_norms):
            if used[idx] or not marker:
                continue
            if marker in line_norm or line_norm in marker:
                should_insert_rule = True
                used[idx] = True
                break

    if should_insert_rule:
        prev_nonblank = None
        for prev in reversed(out):
            if prev.strip():
                prev_nonblank = prev
                break
        if prev_nonblank is not None and not is_rule(prev_nonblank):
            if out and out[-1].strip():
                out.append("")
            out.append("---")
            out.append("")

    out.append(line)

if out != lines:
    src.write_text("\n".join(out).rstrip() + "\n", encoding="utf-8")
PY
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

  if command -v pdfimages >/dev/null 2>&1; then
    rm -rf "$MEDIA_DIR"
    mkdir -p "$MEDIA_DIR"
    pdfimages -all "$INPUT" "$MEDIA_DIR/pdf-image" >/dev/null 2>&1 || true
    image_extract_note="pdf_media_extract"
  else
    image_extract_note="pdf_media_extract_unavailable_install_poppler"
  fi
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
IMAGE_COUNT=0
if [[ -d "$MEDIA_DIR" ]]; then
  IMAGE_COUNT="$(find "$MEDIA_DIR" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.webp' -o -iname '*.tif' -o -iname '*.tiff' -o -iname '*.bmp' -o -iname '*.svg' \) | wc -l | tr -d ' ')"
fi

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
media_dir: "$MEDIA_DIR"
extracted_image_count: $IMAGE_COUNT
image_extraction: "$image_extract_note"
YAML

echo "Created: $SOURCE_MD"
echo "Created: $META_YML"
if [[ "$warn_pdf" == "true" ]]; then
  echo "Warning: PDF extraction may contain layout noise. Review manually."
fi
if [[ "$IMAGE_COUNT" -gt 0 ]]; then
  echo "Extracted images: $IMAGE_COUNT (see $MEDIA_DIR)"
fi
