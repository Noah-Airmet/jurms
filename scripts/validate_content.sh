#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage:
  scripts/validate_content.sh <markdown-file> [--build]

Description:
  Validates frontmatter and common content issues for Forum and Article files.
  Use --build to also run 'bundle exec jekyll build' after validation.
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

FILE="$1"
shift || true
RUN_BUILD="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --build)
      RUN_BUILD="true"
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ ! -f "$FILE" ]]; then
  echo "Error: file not found: $FILE" >&2
  exit 1
fi

if ! awk 'NR==1 && $0=="---" {ok=1} END{exit ok?0:1}' "$FILE"; then
  echo "Error: file must start with YAML frontmatter delimiter (---)." >&2
  exit 1
fi

FRONTMATTER="$(awk 'BEGIN{fm=0} /^---[[:space:]]*$/ {if(fm==0){fm=1; next} else if(fm==1){exit}} fm==1{print}' "$FILE")"

if [[ -z "$FRONTMATTER" ]]; then
  echo "Error: could not parse YAML frontmatter." >&2
  exit 1
fi

get_value() {
  local key="$1"
  printf '%s\n' "$FRONTMATTER" | awk -F': *' -v k="$key" '
    $1==k{
      sub(/^"/, "", $2);
      sub(/"$/, "", $2);
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2);
      print $2;
      exit
    }'
}

has_key() {
  local key="$1"
  printf '%s\n' "$FRONTMATTER" | awk -F':' -v k="$key" '$1==k{found=1} END{exit found?0:1}'
}

has_key_nonempty() {
  local key="$1"
  local value
  value="$(get_value "$key")"
  [[ -n "${value// }" ]]
}

fail() {
  echo "Error: $1" >&2
  exit 1
}

LAYOUT="$(get_value layout)"

if [[ -z "$LAYOUT" ]]; then
  fail "frontmatter key 'layout' is required."
fi

if [[ "$LAYOUT" != "board_post" && "$LAYOUT" != "article" ]]; then
  fail "layout must be 'board_post' or 'article' (found '$LAYOUT')."
fi

if [[ "$LAYOUT" == "board_post" ]]; then
  REQUIRED_KEYS=(layout title author date excerpt tags)
else
  REQUIRED_KEYS=(layout title author affiliation issue order type date abstract tags)
fi

for k in "${REQUIRED_KEYS[@]}"; do
  has_key "$k" || fail "frontmatter key '$k' is required for layout '$LAYOUT'."
done

DATE_VALUE="$(get_value date)"
if [[ -z "$DATE_VALUE" ]]; then
  fail "date cannot be empty."
fi
if ! date -j -f "%Y-%m-%d" "$DATE_VALUE" "+%Y-%m-%d" >/dev/null 2>&1; then
  fail "date must be in YYYY-MM-DD format (found '$DATE_VALUE')."
fi

AUTHOR_VALUE="$(get_value author)"
HUMAN_DATE="$(date -j -f "%Y-%m-%d" "$DATE_VALUE" "+%B %-d, %Y" 2>/dev/null || true)"

if [[ "$LAYOUT" == "article" ]]; then
  ISSUE_VALUE="$(get_value issue)"
  ORDER_VALUE="$(get_value order)"

  [[ -n "$ISSUE_VALUE" ]] || fail "article issue cannot be empty."
  [[ "$ORDER_VALUE" =~ ^[0-9]+$ ]] || fail "article order must be a positive integer (found '$ORDER_VALUE')."

  if ! rg -n "^issue_id:\s*${ISSUE_VALUE}\s*$" _issues >/dev/null 2>&1; then
    fail "article issue '$ISSUE_VALUE' does not match any issue_id in _issues/*.md"
  fi
fi

if has_key_nonempty header_image; then
  HEADER_IMAGE_VALUE="$(get_value header_image)"
  HEADER_IMAGE_ALT_VALUE="$(get_value header_image_alt)"

  [[ "$HEADER_IMAGE_VALUE" =~ ^/ ]] || fail "header_image must be a site-relative path starting with '/' (found '$HEADER_IMAGE_VALUE')."
  [[ -n "$HEADER_IMAGE_ALT_VALUE" ]] || fail "header_image_alt is required when header_image is set."

  HEADER_IMAGE_FILE="${HEADER_IMAGE_VALUE#/}"
  if [[ "$HEADER_IMAGE_VALUE" != http://* && "$HEADER_IMAGE_VALUE" != https://* && ! -f "$HEADER_IMAGE_FILE" ]]; then
    fail "header_image file not found at '$HEADER_IMAGE_VALUE' (expected '$HEADER_IMAGE_FILE')."
  fi
fi

if rg -n "\[Your Name\]|TODO|TBD|\[Placeholder" "$FILE" >/dev/null 2>&1; then
  fail "file contains placeholder text ([Your Name], TODO, TBD, or [Placeholder)."
fi

# Guard against duplicated byline metadata in body content.
# Common bad ingestion output: "Month Day, Year / Author Name" near the top.
if [[ -n "$AUTHOR_VALUE" && -n "$HUMAN_DATE" ]]; then
  FRONTMATTER_END_LINE="$(awk 'BEGIN{fm=0;n=0} {n=NR} /^---[[:space:]]*$/ {if(fm==0){fm=1} else if(fm==1){print NR; exit}}' "$FILE")"
  BODY_HEAD="$(tail -n +"$((FRONTMATTER_END_LINE + 1))" "$FILE" | head -n 80)"

  DUP_PATTERNS=(
    "$HUMAN_DATE / $AUTHOR_VALUE"
    "$AUTHOR_VALUE / $HUMAN_DATE"
    "$HUMAN_DATE · $AUTHOR_VALUE"
    "$AUTHOR_VALUE · $HUMAN_DATE"
    "$HUMAN_DATE - $AUTHOR_VALUE"
    "$AUTHOR_VALUE - $HUMAN_DATE"
  )
  DUP_FOUND="false"
  for p in "${DUP_PATTERNS[@]}"; do
    if printf '%s\n' "$BODY_HEAD" | grep -F "$p" >/dev/null 2>&1; then
      DUP_FOUND="true"
      break
    fi
  done

  if [[ "$DUP_FOUND" == "true" ]]; then
    fail "body appears to duplicate byline metadata (date/author). Remove standalone byline text from body and keep metadata in frontmatter only."
  fi
fi

# Guard against a common ingestion issue:
# "## Footnotes" appears, but Markdown footnote definitions are auto-rendered later,
# causing another section (often "About the Author") to sit between heading and notes.
FOOTNOTES_HEADING_LINE="$(rg -n -i '^##[[:space:]]+Footnotes[[:space:]]*$' "$FILE" | head -n1 | cut -d: -f1 || true)"
FIRST_FOOTNOTE_DEF_LINE="$(rg -n '^\[\^[^]]+\]:' "$FILE" | head -n1 | cut -d: -f1 || true)"

if [[ -n "$FOOTNOTES_HEADING_LINE" && -n "$FIRST_FOOTNOTE_DEF_LINE" && "$FIRST_FOOTNOTE_DEF_LINE" -gt "$FOOTNOTES_HEADING_LINE" ]]; then
  HEADING_BETWEEN="$(awk -v s="$FOOTNOTES_HEADING_LINE" -v e="$FIRST_FOOTNOTE_DEF_LINE" 'NR>s && NR<e && /^##[[:space:]]+/ {print NR; exit}' "$FILE")"
  if [[ -n "$HEADING_BETWEEN" ]]; then
    fail "'Footnotes' heading is separated from footnote definitions by another section heading. Keep footnote definitions directly under the Footnotes heading or convert to a plain numbered list."
  fi
fi

echo "Validation passed: $FILE"

if [[ "$RUN_BUILD" == "true" ]]; then
  if [[ -f Gemfile ]]; then
    echo "Running Jekyll build..."
    bundle exec jekyll build >/tmp/jurms-jekyll-build.log 2>&1 || {
      echo "Error: Jekyll build failed. See /tmp/jurms-jekyll-build.log" >&2
      exit 1
    }
    echo "Jekyll build passed."
  else
    echo "Skipping --build: Gemfile not found."
  fi
fi
