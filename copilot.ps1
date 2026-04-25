# Launch Copilot CLI with a repo-scoped MCP/agent/skill config.
# Usage: .\copilot.ps1 [args passed through to copilot]
#
# Sets COPILOT_HOME to .\.copilot in this repo so only the MCP servers
# in .copilot\mcp-config.json are loaded for this session. Other Copilot
# state (sessions, plugins, logs) is also kept repo-local.

$ErrorActionPreference = 'Stop'

$repoCopilotHome = Join-Path $PSScriptRoot '.copilot'
if (-not (Test-Path $repoCopilotHome)) {
    New-Item -ItemType Directory -Path $repoCopilotHome | Out-Null
}

$env:COPILOT_HOME = $repoCopilotHome
Write-Host "COPILOT_HOME = $env:COPILOT_HOME" -ForegroundColor DarkGray

& copilot @args
