# ==========================================
#  RESET DEMO ENVIRONMENT
#  Cleans the victim folder and restores original files
# To execute : powershell -ExecutionPolicy Bypass -File reset_demo.ps1
# ==========================================

$targetDir = "C:\Users\Public\Documents\Legal_Files"

Write-Host "[*] Starting environment cleanup..." -ForegroundColor Cyan

# 1. Check if folder exists. If yes, empty it. If no, create it.
if (Test-Path $targetDir) {
    Write-Host " -> Deleting encrypted files and ransom notes..." -ForegroundColor Yellow
    Remove-Item -Path "$targetDir\*" -Force
} else {
    Write-Host " -> Creating target directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

# 2. Create the original "clean" files (Decoys)
# These names match the ones targeted in your ShadowVault script
Write-Host " -> Generating clean files..." -ForegroundColor Yellow

Set-Content -Path "$targetDir\Confidential_Contract.docx" -Value "THIS IS A DUMMY CONFIDENTIAL DOCUMENT."
Set-Content -Path "$targetDir\Q4_Budget_2025.xlsx" -Value "FAKE FINANCIAL DATA FOR Q4 2025."
Set-Content -Path "$targetDir\Client_Database.db" -Value "SQLITE FORMAT 3... (SIMULATED DATA)"

# 3. Show final result
Write-Host "`n[v] ENVIRONMENT SUCCESSFULLY RESTORED" -ForegroundColor Green
Write-Host "    Location: $targetDir"
Get-ChildItem -Path $targetDir | Select-Object Name, Length