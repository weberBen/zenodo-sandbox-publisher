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
        echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
        echo "Last commit: $(git rev-parse HEAD)"

        TAG_SUFFIX=$(head -c 64 /dev/urandom | tr -dc 'a-zA-Z' | head -c 8)
        TAG_NAME="template_${TAG_SUFFIX}"
        read -r -p "Créer et pousser le tag ${TAG_NAME} ? [Enter/Y/yes pour confirmer, autre pour annuler]: " CONFIRM_TAG
        CONFIRM_TAG="${CONFIRM_TAG:-yes}"
        if [[ "$CONFIRM_TAG" =~ ^([Yy]([Ee][Ss])?|)$ ]]; then
            git tag "$TAG_NAME"
            git push origin "$TAG_NAME"
            echo "Tag créé et poussé : ${TAG_NAME}"
        fi
        LAST_COMMIT=$(git rev-parse HEAD)
        LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "(aucun tag)")
        if [[ "$LAST_TAG" != "(aucun tag)" ]]; then
            LAST_TAG_COMMIT=$(git rev-list -n 1 "$LAST_TAG")
            echo "Last tag: ${LAST_TAG} -> ${LAST_TAG_COMMIT}"
            if [[ "$LAST_TAG_COMMIT" == "$LAST_COMMIT" ]]; then
                echo "Tag pointe sur le dernier commit (HEAD)"
            else
                echo "Tag ne pointe PAS sur le dernier commit"
            fi
        else
            echo "Last tag: (aucun tag)"
        fi
    fi
fi
