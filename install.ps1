# Install peru-shopping-comparison skill to Claude Code
$skillName = "peru-shopping-comparison"
$skillsDir = "$env:USERPROFILE\.claude\skills"
$targetDir = Join-Path $skillsDir $skillName
$targetFile = Join-Path $targetDir "SKILL.md"
$sourceFile = Join-Path $PSScriptRoot "SKILL.md"

# Create skills directory if doesn't exist
if (-not (Test-Path $skillsDir)) {
    New-Item -ItemType Directory -Force -Path $skillsDir | Out-Null
}

# Check if skill already installed
$isUpdate = Test-Path $targetFile

if ($isUpdate) {
    Write-Host "→ Updating existing installation..." -ForegroundColor Yellow
} else {
    Write-Host "→ Installing for first time..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
}

# Copy SKILL.md
Copy-Item -Path $sourceFile -Destination $targetFile -Force

if ($isUpdate) {
    Write-Host "✓ Updated $skillName" -ForegroundColor Green
} else {
    Write-Host "✓ Installed $skillName to $targetDir" -ForegroundColor Green
}
Write-Host ""
Write-Host "Usage:" -ForegroundColor Cyan
Write-Host "  /peru-shopping" -ForegroundColor Yellow
Write-Host "  /compare-prices" -ForegroundColor Yellow
Write-Host ""
Write-Host "Restart Claude Code to load skill" -ForegroundColor Gray
