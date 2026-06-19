# PromLight Reasonix Skill — Windows Installer
# One-line: irm https://gitee.com/.../install.ps1 | iex
param(
    [switch]$DryRun,
    [switch]$Uninstall,
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$PythonPath = "C:\Users\admin\AppData\Local\Programs\Python\Python312\python.exe"
$HookScript = "F:\PromLight\agent_hook.py"
$ReasonixHome = "$env:USERPROFILE\.reasonix"
$SkillDir = "$ReasonixHome\skills\promlight"
$SettingsFile = "$ReasonixHome\settings.json"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Step { param($msg) Write-Host "  [$([char]0x2192)] $msg" }
function Write-OK   { param($msg) Write-Host "  [$([char]0x2713)] $msg" }
function Write-Warn { param($msg) Write-Host "  [!] $msg" -ForegroundColor Yellow }

# ── Uninstall ──────────────────────────────────────────────────────────────
if ($Uninstall) {
    Write-Host "`nPromLight Reasonix Skill — Uninstaller`n"
    if ($DryRun) { Write-Host "[DRY RUN] No changes will be made.`n" }

    if (Test-Path $SkillDir) {
        Write-Step "Removing skill: $SkillDir"
        if (-not $DryRun) { Remove-Item -Recurse -Force $SkillDir }
        Write-OK "Skill removed"
    } else { Write-Warn "Skill not found: $SkillDir" }

    if (Test-Path $SettingsFile) {
        Write-Step "Removing PromLight hooks from settings.json"
        if (-not $DryRun) {
            $s = Get-Content $SettingsFile -Raw | ConvertFrom-Json
            $removed = 0
            foreach ($event in ($s.hooks | Get-Member -MemberType NoteProperty).Name) {
                $s.hooks.$event = @($s.hooks.$event | Where-Object { $_.command -notmatch 'agent_hook\.py.*reasonix' })
                if ($s.hooks.$event.Count -eq 0) { $s.hooks.PSObject.Properties.Remove($event); $removed++ }
            }
            if ($s.hooks.PSObject.Properties.Count -eq 0) {
                Remove-Item $SettingsFile
                Write-OK "settings.json removed (empty)"
            } else {
                $s | ConvertTo-Json -Depth 4 | Out-File -Encoding utf8 $SettingsFile
                Write-OK "$removed hook entries removed"
            }
        } else { Write-OK "(dry-run)" }
    } else { Write-Warn "settings.json not found" }

    Write-Host "`nUninstall complete. Restart Reasonix.`n"
    exit 0
}

# ── Install ────────────────────────────────────────────────────────────────
Write-Host "`nPromLight Reasonix Skill — Installer`n"
if ($DryRun) { Write-Host "[DRY RUN] No changes will be made.`n" }

# 1. Verify prerequisites
Write-Step "Checking Python..."
if (-not (Test-Path $PythonPath)) {
    Write-Warn "Python not found at $PythonPath. Searching..."
    $PythonPath = (Get-Command python -ErrorAction SilentlyContinue).Source
    if (-not $PythonPath) { throw "Python not found. Install Python 3.12+ first." }
}
Write-OK "Python: $PythonPath"

Write-Step "Checking agent_hook.py..."
if (-not (Test-Path $HookScript)) { throw "agent_hook.py not found: $HookScript" }
Write-OK "agent_hook.py: $HookScript"

Write-Step "Checking PromLight daemon..."
$daemonOnline = $false
try {
    $c = New-Object System.Net.Sockets.TcpClient("127.0.0.1", 47800)
    $c.Close(); $daemonOnline = $true
    Write-OK "PromLight daemon: ONLINE"
} catch { Write-Warn "PromLight daemon offline. Start PromLight.exe first." }

# 2. Install SKILL.md
Write-Step "Installing skill to $SkillDir..."
if (-not $DryRun) {
    New-Item -ItemType Directory -Force -Path "$SkillDir\references" | Out-Null
    Copy-Item "$ScriptDir\SKILL.md" "$SkillDir\SKILL.md" -Force
    if (Test-Path "$ScriptDir\references") {
        Copy-Item "$ScriptDir\references\*" "$SkillDir\references\" -Force
    }
}
Write-OK "Skill installed"

# 3. Configure hooks in settings.json
Write-Step "Configuring Reasonix hooks..."
if (-not $DryRun) {
    $hooks = @{
        SessionStart      = @(@{command="$PythonPath `"$HookScript`" --agent reasonix SessionStart"})
        UserPromptSubmit  = @(@{command="$PythonPath `"$HookScript`" --agent reasonix UserPromptSubmit"})
        PreToolUse        = @(@{command="$PythonPath `"$HookScript`" --agent reasonix PreToolUse"})
        PostToolUse       = @(@{command="$PythonPath `"$HookScript`" --agent reasonix PostToolUse"})
        PermissionRequest = @(@{command="$PythonPath `"$HookScript`" --agent reasonix PermissionRequest"})
        Stop              = @(@{command="$PythonPath `"$HookScript`" --agent reasonix Stop"})
        SessionEnd        = @(@{command="$PythonPath `"$HookScript`" --agent reasonix SessionEnd"})
        PostLLMCall       = @(@{command="$PythonPath `"$HookScript`" --agent reasonix PostLLMCall"})
        SubagentStop      = @(@{command="$PythonPath `"$HookScript`" --agent reasonix SubagentStop"})
        Notification      = @(@{command="$PythonPath `"$HookScript`" --agent reasonix Notification"})
        PreCompact        = @(@{command="$PythonPath `"$HookScript`" --agent reasonix PreCompact"})
    }
    $settings = if (Test-Path $SettingsFile) {
        Get-Content $SettingsFile -Raw | ConvertFrom-Json
    } else { @{} | Select-Object -Property hooks }
    if (-not $settings.hooks) { $settings | Add-Member -NotePropertyName hooks -NotePropertyValue @{} }
    foreach ($event in $hooks.Keys) {
        if (-not $settings.hooks.$event) { $settings.hooks | Add-Member -NotePropertyName $event -NotePropertyValue @() -Force }
        $settings.hooks.$event = @($settings.hooks.$event) + $hooks.$event
    }
    $settings | ConvertTo-Json -Depth 4 | Out-File -Encoding utf8 $SettingsFile
}
Write-OK "Hooks configured"

# 4. Test connection
if ($daemonOnline -and -not $DryRun) {
    Write-Step "Testing LED control..."
    $env:PYTHONIOENCODING = "utf-8"
    & $PythonPath -c "import socket; s=socket.create_connection(('127.0.0.1',47800),timeout=0.5); s.sendall(b'{\"cmd\":\"led all blink --count 2\"}\n'); s.close()" 2>$null
    Write-OK "Test signal sent (watch the light)"
}

# ── Summary ────────────────────────────────────────────────────────────────
Write-Host "`n=== Installation Summary ===`n"
Write-Host "  Skill  : $SkillDir\SKILL.md"
Write-Host "  Hooks  : $SettingsFile (11 events)"
Write-Host "  Daemon : $(if ($daemonOnline) {'ONLINE'} else {'OFFLINE — start PromLight.exe'})"
Write-Host "`nRestart Reasonix to activate. New sessions will sync light automatically.`n"
