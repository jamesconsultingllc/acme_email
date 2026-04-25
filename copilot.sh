#!/usr/bin/env bash
# Launch GitHub Copilot CLI with this repo's scoped MCP/skill/agent config.
#
# Why: MCP servers are configured globally in ~/.copilot/mcp-config.json by
# default, which means every dev's personal global servers get loaded for this
# project too. Pointing COPILOT_HOME at the in-repo .copilot/ directory ensures
# every contributor uses the same minimal, project-relevant set of MCP servers.
#
# Usage: ./copilot.sh [args passed through to copilot]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_COPILOT_HOME="$SCRIPT_DIR/.copilot"
mkdir -p "$REPO_COPILOT_HOME"

export COPILOT_HOME="$REPO_COPILOT_HOME"
echo "COPILOT_HOME=$COPILOT_HOME" >&2

exec copilot "$@"
