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

# gstack only installs globally, so install the tested version each session.
# --prefix names skills /gstack-*; --no-browser skips its Chromium download
# (blocked here) and GSTACK_CHROMIUM_PATH points it at the pre-installed one.
GSTACK_SHA="64d82101cac149125d28df888e3f2ea14a444dc5"
GSTACK_DIR="$HOME/.claude/skills/gstack"
if [ ! -x "$GSTACK_DIR/browse/dist/browse" ] && command -v bun >/dev/null 2>&1; then
  rm -rf "$GSTACK_DIR"
  git init -q "$GSTACK_DIR"
  git -C "$GSTACK_DIR" fetch -q --depth 1 https://github.com/garrytan/gstack.git "$GSTACK_SHA"
  git -C "$GSTACK_DIR" checkout -q FETCH_HEAD
  (cd "$GSTACK_DIR" && ./setup --prefix --no-browser --quiet </dev/null >/dev/null 2>&1) \
    || echo "gstack setup failed; run: cd $GSTACK_DIR && ./setup --prefix --no-browser" >&2
fi
CHROMIUM=$(ls -d /opt/pw-browsers/chromium-*/*/chrome 2>/dev/null | head -1 || true)
if [ -n "$CHROMIUM" ] && [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export GSTACK_CHROMIUM_PATH=\"$CHROMIUM\"" >> "$CLAUDE_ENV_FILE"
fi
