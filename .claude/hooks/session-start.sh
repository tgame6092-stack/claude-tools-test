#!/bin/bash
# Cloud sessions start from a fresh machine: reinstall Graphify's Python CLI.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

GRAPHIFY_VERSION="0.9.95"
if ! pip show graphifyy 2>/dev/null | grep -q "^Version: ${GRAPHIFY_VERSION}$"; then
  pip install -q --break-system-packages "graphifyy==${GRAPHIFY_VERSION}"
fi
