# ============================================================
# fix-global-path.ps1
# One-click fix for the stripped PATH in the Trae agent terminal
# (applies to the current session)
#
# Usage (in any PowerShell session):
#     & .\fix-global-path.ps1
#
# What it does:
#   1. Reads system(Machine) + user(User) env PATH from registry
#   2. Prepends common tool dirs (Miniconda first)
#   3. Sets $env:PATH for the current session
#   4. Prints resolved paths of common tools for confirmation
#
# NOTE: PowerShell env vars do NOT persist across commands.
#       Run this at the start of each new session.
#       If Trae was restarted and the terminal already inherits the
#       full PATH, running this script is optional.
# ============================================================

$ErrorActionPreference = "Stop"

# 1) Read persistent system/user PATH from registry
$machinePath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
$userPath    = [Environment]::GetEnvironmentVariable("PATH", "User")

# 2) Common tool dirs (edit this list as needed)
$extraDirs = @(
    "$env:USERPROFILE\miniconda3",
    "$env:USERPROFILE\miniconda3\Scripts",
    "$env:USERPROFILE\miniconda3\condabin",
    "$env:USERPROFILE\.local\bin",          # uv
    "E:\Program Files\Git\cmd",             # git
    "E:\Program Files\nodejs",              # node
    "E:\Programs\ffmpeg-master-latest-win64-gpl\bin",  # ffmpeg
    "C:\Windows\System32"                   # nvidia-smi etc.
)

# 3) Merge and de-duplicate, Miniconda dirs first for priority
$merged = @()
foreach ($d in ($extraDirs + $machinePath.Split(';') + $userPath.Split(';'))) {
    if ($d -ne "" -and $merged -notcontains $d) {
        $merged += $d
    }
}
$env:PATH = ($merged -join ";")

# 4) Verify
Write-Host ""
Write-Host "PATH merged. Resolved tools:"
$tools = @("python", "uv", "git", "ffmpeg", "node", "nvidia-smi")
foreach ($t in $tools) {
    $g = Get-Command $t -ErrorAction SilentlyContinue
    if ($g) {
        Write-Host ("  {0,-10} -> {1}" -f $t, $g.Source)
    } else {
        Write-Host ("  {0,-10} -> NOT FOUND" -f $t)
    }
}
Write-Host ""
Write-Host "Done."