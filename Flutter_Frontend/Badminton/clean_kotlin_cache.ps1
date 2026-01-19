# PowerShell script to completely clean Kotlin compilation cache
# Run this when you encounter "Storage is already registered" or "Could not close incremental caches" errors

Write-Host "`n=== Cleaning Kotlin Compilation Cache ===" -ForegroundColor Cyan
Write-Host ""

# Stop all Java and Gradle processes
Write-Host "1. Stopping Java/Gradle processes..." -ForegroundColor Yellow
Get-Process | Where-Object {
    $_.ProcessName -like "*java*" -or 
    $_.ProcessName -like "*gradle*"
} | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-Host "   ✓ Processes stopped" -ForegroundColor Green

# Clean Flutter build
Write-Host "`n2. Cleaning Flutter build..." -ForegroundColor Yellow
Set-Location "Flutter_Frontend\Badminton"
flutter clean
Write-Host "   ✓ Flutter clean completed" -ForegroundColor Green

# Clean Android build directories
Write-Host "`n3. Cleaning Android build directories..." -ForegroundColor Yellow
$buildDirs = @(
    "build",
    "android\build",
    "android\app\build",
    "android\.gradle"
)

foreach ($dir in $buildDirs) {
    if (Test-Path $dir) {
        Remove-Item -Recurse -Force $dir -ErrorAction SilentlyContinue
        Write-Host "   ✓ Removed $dir" -ForegroundColor Gray
    }
}
Write-Host "   ✓ Android build directories cleaned" -ForegroundColor Green

# Clean Kotlin daemon cache
Write-Host "`n4. Cleaning Kotlin daemon cache..." -ForegroundColor Yellow
$kotlinDaemonDir = "$env:USERPROFILE\.kotlin\daemon"
if (Test-Path $kotlinDaemonDir) {
    Remove-Item -Recurse -Force $kotlinDaemonDir -ErrorAction SilentlyContinue
    Write-Host "   ✓ Kotlin daemon cache cleaned" -ForegroundColor Green
} else {
    Write-Host "   ℹ Kotlin daemon cache not found (already clean)" -ForegroundColor Gray
}

# Clean Gradle cache (optional - only if issues persist)
Write-Host "`n5. Cleaning Gradle cache (optional)..." -ForegroundColor Yellow
$gradleCacheDir = "$env:USERPROFILE\.gradle\caches"
if (Test-Path $gradleCacheDir) {
    Write-Host "   ⚠ Gradle cache found at: $gradleCacheDir" -ForegroundColor Yellow
    Write-Host "   ℹ Skipping Gradle cache clean (too large, will slow down next build)" -ForegroundColor Gray
    Write-Host "   ℹ If issues persist, manually delete: $gradleCacheDir" -ForegroundColor Gray
} else {
    Write-Host "   ℹ Gradle cache not found" -ForegroundColor Gray
}

Write-Host "`n=== Cleanup Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Run: flutter pub get" -ForegroundColor White
Write-Host "2. Run: flutter run" -ForegroundColor White
Write-Host ""
