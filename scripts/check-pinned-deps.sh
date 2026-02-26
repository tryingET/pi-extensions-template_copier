#!/usr/bin/env bash
set -euo pipefail

# Check if pinned dependencies have upstream updates
# Returns 0 if up-to-date, 1 if updates available, 2 on error

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# Pinned interview tool commit (from copier.yml default)
PINNED_SHA="e6e8e20b4fa195b11d6f8007d74530374271c254"
REPO_URL="https://github.com/ghoseb/pi-askuserquestion"

echo "Checking pinned dependencies for updates..."

updates_available=0

# Check pi-askuserquestion
echo ""
echo "== pi-askuserquestion"
echo "   Pinned:  ${PINNED_SHA}"

if command -v git >/dev/null 2>&1; then
  # Fetch latest HEAD without cloning
  latest_sha="$(git ls-remote "$REPO_URL" HEAD 2>/dev/null | cut -f1)" || true

  if [[ -n "$latest_sha" ]]; then
    echo "   Latest:  ${latest_sha}"

    if [[ "$latest_sha" != "$PINNED_SHA" ]]; then
      echo ""
      echo "   ⚠️  UPDATE AVAILABLE"
      echo ""
      echo "   The pinned commit differs from HEAD. Review changes before updating:"
      echo "   ${REPO_URL}/compare/${PINNED_SHA}...${latest_sha}"
      echo ""
      echo "   After review, update copier.yml default:"
      echo "   interview_tool_source: \"git:github.com/ghoseb/pi-askuserquestion@${latest_sha}\""
      updates_available=1
    else
      echo "   ✅ Up to date"
    fi
  else
    echo "   ⚠️  Could not fetch latest HEAD (network error?)"
  fi
else
  echo "   ⚠️  git not available for remote check"
fi

echo ""

if [[ "$updates_available" -eq 1 ]]; then
  echo "Dependency check: UPDATES AVAILABLE"
  exit 1
fi

echo "Dependency check: ALL UP TO DATE"
exit 0
