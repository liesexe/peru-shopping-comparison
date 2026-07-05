# Install peru-shopping-comparison skill to Claude Code
$skillName = "peru-shopping-comparison"
$skillsDir = "$env:USERPROFILE\.claude\skills"
$targetDir = Join-Path $skillsDir $skillName
$targetFile = Join-Path $targetDir "SKILL.md"

# Check if Claude Code is installed
if (-not (Test-Path "$env:USERPROFILE\.claude")) {
    Write-Host "✗ Claude Code not found" -ForegroundColor Red
    Write-Host "  Install Claude Code first: https://claude.ai/download" -ForegroundColor Gray
    exit 1
}

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
    Write-Host "✓ Updated peru-shopping-comparison" -ForegroundColor Green
} else {
    Write-Host "✓ Installed peru-shopping-comparison to $targetDir" -ForegroundColor Green
}

Write-Host ""
Write-Host "Usage:" -ForegroundColor Cyan
Write-Host "  /peru-shopping" -ForegroundColor Yellow
Write-Host "  /compare-prices" -ForegroundColor Yellow
Write-Host ""
Write-Host "Restart Claude Code to load skill" -ForegroundColor Gray

# Cleanup temp file if remote install
if (-not $PSScriptRoot -and $tempFile -and (Test-Path $tempFile)) {
    Remove-Item $tempFile -Force
}
