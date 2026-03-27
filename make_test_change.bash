#!/usr/bin/env bash
set -euo pipefail

TEX_FILE="$(git rev-parse --show-toplevel)/papers/latex/main.tex"

if [[ ! -f "$TEX_FILE" ]]; then
    echo "Error: $TEX_FILE not found" >&2
    exit 1
fi

# Find the line number range of the abstract block
START_LINE=$(grep -n '\\begin{abstract}' "$TEX_FILE" | head -1 | cut -d: -f1)
END_LINE=$(grep -n '\\end{abstract}' "$TEX_FILE" | head -1 | cut -d: -f1)

if [[ -z "$START_LINE" || -z "$END_LINE" ]]; then
    echo "Error: \\begin{abstract}...\\end{abstract} block not found in $TEX_FILE" >&2
    exit 1
fi

# Find the first line in the block that contains a number
MATCH_LINE=$(awk "NR>${START_LINE} && NR<${END_LINE} && /[0-9]+/ {print NR; exit}" "$TEX_FILE")

if [[ -z "$MATCH_LINE" ]]; then
    echo "Error: no number found inside the abstract block" >&2
    exit 1
fi

CURRENT=$(sed -n "${MATCH_LINE}p" "$TEX_FILE" | grep -oP '\d+' | tail -1)
NEXT=$((CURRENT + 1))

sed -i "${MATCH_LINE}s/\b${CURRENT}\b/${NEXT}/" "$TEX_FILE"

echo "Incremented number on line ${MATCH_LINE}: ${CURRENT} -> ${NEXT}"

# Prompt for git commit & push
read -r -p "Commit and push? [Enter/Y/yes to confirm, anything else to skip]: " CONFIRM
CONFIRM="${CONFIRM:-yes}"
if [[ "$CONFIRM" =~ ^([Yy]([Ee][Ss])?|)$ ]]; then
    COMMIT_MSG="${1:-test}"
    git add .
    git status
    read -r -p "Continuer avec le commit et le push? [Enter/Y/yes pour confirmer, autre pour annuler]: " CONFIRM2
    CONFIRM2="${CONFIRM2:-yes}"
    if [[ "$CONFIRM2" =~ ^([Yy]([Ee][Ss])?|)$ ]]; then
        git commit -m "$COMMIT_MSG"
        git push
    fi
fi
