#!/usr/bin/env bash
set -euo pipefail

REPO_NAME="${1:-gym-planner}"
TOKEN="${GITHUB_TOKEN:-${GH_TOKEN:-}}"

if [[ -z "$TOKEN" ]]; then
  echo "Chybí GITHUB_TOKEN. Přidejte ho do secrets a spusťte znovu."
  exit 1
fi

echo "$TOKEN" | gh auth login --with-token

if gh repo view "$REPO_NAME" >/dev/null 2>&1; then
  echo "Repozitář $REPO_NAME už existuje, pushuji..."
  git remote remove origin 2>/dev/null || true
  git remote add origin "https://github.com/$(gh api user -q .login)/$REPO_NAME.git"
else
  gh repo create "$REPO_NAME" --public --source=. --remote=origin \
    --description "Plánovač posilovacích tréninků pro iPhone/iPad"
fi

git push -u origin main

echo ""
echo "Hotovo! Zapněte GitHub Pages:"
echo "  Repozitář → Settings → Pages → Build and deployment → Source: GitHub Actions"
echo ""
echo "Aplikace bude na:"
echo "  https://$(gh api user -q .login).github.io/$REPO_NAME/"
