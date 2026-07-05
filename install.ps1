# Install peru-shopping-comparison skill to Claude Code and/or Codex
$skillName = "peru-shopping-comparison"
$installations = @()

# Detect Claude Code
if (Test-Path "$env:USERPROFILE\.claude") {
    $installations += @{
        Name = "Claude Code"
        Path = "$env:USERPROFILE\.claude\skills"
    }
}

# Detect Codex
if (Test-Path "$env:USERPROFILE\.codex") {
    $installations += @{
        Name = "OpenAI Codex"
        Path = "$env:USERPROFILE\.codex\skills"
    }
}

if ($installations.Count -eq 0) {
    Write-Host "✗ No installations found" -ForegroundColor Red
    Write-Host "  Install Claude Code or Codex first" -ForegroundColor Gray
    exit 1
}

Write-Host "Found $($installations.Count) installation(s):" -ForegroundColor Cyan
$installations | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Gray }
Write-Host ""

# Fetch SKILL.md from GitHub (if piped) or use local
if ($PSScriptRoot) {
    # Local execution
    $sourceFile = Join-Path $PSScriptRoot "SKILL.md"
    if (-not (Test-Path $sourceFile)) {
        Write-Host "✗ SKILL.md not found at $sourceFile" -ForegroundColor Red
        exit 1
    }
} else {
    # Remote execution (piped from web)
    Write-Host "→ Downloading SKILL.md from GitHub..." -ForegroundColor Yellow
    $tempFile = Join-Path $env:TEMP "peru-shopping-comparison-SKILL.md"
    try {
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/liesexe/peru-shopping-comparison/main/SKILL.md" -OutFile $tempFile
        $sourceFile = $tempFile
    } catch {
        Write-Host "✗ Failed to download SKILL.md: $_" -ForegroundColor Red
        exit 1
    }
}

# Install to each detected installation
$installedCount = 0
foreach ($install in $installations) {
    $skillsDir = $install.Path
    $targetDir = Join-Path $skillsDir $skillName
    $targetFile = Join-Path $targetDir "SKILL.md"

    # Create skills directory if doesn't exist
    if (-not (Test-Path $skillsDir)) {
        New-Item -ItemType Directory -Force -Path $skillsDir | Out-Null
    }

    # Check if updating existing installation
    $isUpdate = Test-Path $targetFile

    if (-not $isUpdate) {
        New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
    }

    # Copy SKILL.md
    Copy-Item -Path $sourceFile -Destination $targetFile -Force

    if ($isUpdate) {
        Write-Host "✓ Updated in $($install.Name)" -ForegroundColor Green
    } else {
        Write-Host "✓ Installed to $($install.Name)" -ForegroundColor Green
    }

    $installedCount++
}

Write-Host ""
Write-Host "Installed to $installedCount installation(s)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Usage:" -ForegroundColor Cyan
Write-Host "  /peru-shopping" -ForegroundColor Yellow
Write-Host "  /compare-prices" -ForegroundColor Yellow
Write-Host ""
Write-Host "Restart Claude Code or Codex to load skill" -ForegroundColor Gray

# Cleanup temp file if remote install
if (-not $PSScriptRoot -and $tempFile -and (Test-Path $tempFile)) {
    Remove-Item $tempFile -Force
}
