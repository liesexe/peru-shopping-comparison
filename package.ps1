# Package peru-shopping-comparison skill for Claude Desktop upload

$skillName = "peru-shopping-comparison"
$outputFile = "$skillName.zip"

# Files to include (all required for full functionality)
$files = @(
    "SKILL.md"                      # Skill definition
    "make_styled_comparison.ps1"    # Excel workbook generator
    "xlsx-guidelines.md"            # Spreadsheet formatting rules
)

# Check if SKILL.md exists
if (-not (Test-Path "SKILL.md")) {
    Write-Host "✗ SKILL.md not found" -ForegroundColor Red
    exit 1
}

# Remove old package if exists
if (Test-Path $outputFile) {
    Remove-Item $outputFile -Force
    Write-Host "→ Removed old package" -ForegroundColor Yellow
}

# Create package
Write-Host "→ Packaging skill..." -ForegroundColor Cyan
$existingFiles = $files | Where-Object { Test-Path $_ }
Compress-Archive -Path $existingFiles -DestinationPath $outputFile

Write-Host "✓ Created $outputFile" -ForegroundColor Green
Write-Host ""
Write-Host "Upload to:" -ForegroundColor Cyan
Write-Host "  Claude Desktop → Settings → Customize → Skills" -ForegroundColor Gray
Write-Host ""
Write-Host "Package includes:" -ForegroundColor Cyan
$existingFiles | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
