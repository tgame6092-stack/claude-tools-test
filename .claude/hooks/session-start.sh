#!/bin/bash
# Cloud sessions start from a fresh machine: reinstall Graphify's Python CLI
# and point HyperFrames at the pre-installed headless Chromium.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

GRAPHIFY_VERSION="0.9.95"
INSTALLED=$(pip show graphifyy 2>/dev/null || true)
if ! grep -q "^Version: ${GRAPHIFY_VERSION}$" <<<"$INSTALLED"; then
  pip install -q --break-system-packages "graphifyy==${GRAPHIFY_VERSION}"
fi

HEADLESS_SHELL=$(ls -d /opt/pw-browsers/chromium_headless_shell-*/*/chrome-headless-shell 2>/dev/null | head -1 || true)
if [ -n "$HEADLESS_SHELL" ] && [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export HYPERFRAMES_BROWSER_PATH=\"$HEADLESS_SHELL\"" >> "$CLAUDE_ENV_FILE"
fi
