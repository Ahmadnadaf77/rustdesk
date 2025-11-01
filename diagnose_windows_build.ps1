#!/usr/bin/env pwsh
# RustDesk Windows Build Diagnostic Script
# This script helps diagnose issues with Windows builds that won't run

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "RustDesk Windows Build Diagnostic Tool" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$buildPath = "flutter\build\windows\x64\runner\Release"

# Check if build directory exists
if (!(Test-Path $buildPath)) {
    Write-Host "ERROR: Build directory not found!" -ForegroundColor Red
    Write-Host "Path: $buildPath" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Have you built the project? Try running:" -ForegroundColor Yellow
    Write-Host "  cd flutter" -ForegroundColor White
    Write-Host "  flutter build windows --release" -ForegroundColor White
    exit 1
}

Write-Host "Build directory found: $buildPath" -ForegroundColor Green
Write-Host ""

# Check for required files
Write-Host "Checking required files..." -ForegroundColor Cyan
$requiredFiles = @{
    "rustdesk.exe" = "Main executable"
    "librustdesk.dll" = "Core RustDesk library (CRITICAL)"
    "flutter_windows.dll" = "Flutter UI framework"
    "data\icudtl.dat" = "ICU internationalization data"
}

$missingFiles = @()
$foundFiles = @()

foreach ($file in $requiredFiles.Keys) {
    $fullPath = Join-Path $buildPath $file
    if (Test-Path $fullPath) {
        $size = (Get-Item $fullPath).Length
        $sizeMB = [math]::Round($size / 1MB, 2)
        Write-Host "  [OK] $file ($sizeMB MB) - $($requiredFiles[$file])" -ForegroundColor Green
        $foundFiles += $file
    } else {
        Write-Host "  [FAIL] $file - MISSING - $($requiredFiles[$file])" -ForegroundColor Red
        $missingFiles += $file
    }
}

Write-Host ""

# Check for data directory
if (Test-Path (Join-Path $buildPath "data\flutter_assets")) {
    $assetCount = (Get-ChildItem (Join-Path $buildPath "data\flutter_assets") -Recurse -File).Count
    Write-Host "  [OK] Flutter assets found ($assetCount files)" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] Flutter assets directory missing" -ForegroundColor Red
    $missingFiles += "data\flutter_assets"
}

Write-Host ""

# Check Rust library build
Write-Host "Checking Rust library build..." -ForegroundColor Cyan
$rustLibPath = "target\release\librustdesk.dll"
if (Test-Path $rustLibPath) {
    $size = (Get-Item $rustLibPath).Length / 1MB
    Write-Host "  [OK] Rust library built ($([math]::Round($size, 2)) MB)" -ForegroundColor Green
    Write-Host "  Path: $rustLibPath" -ForegroundColor Gray
} else {
    Write-Host "  [FAIL] Rust library not found at: $rustLibPath" -ForegroundColor Red
    Write-Host "  This library should be copied to the Flutter build during build" -ForegroundColor Yellow
}

Write-Host ""

# Check if librustdesk.dll was copied to Flutter build
$flutterLibPath = Join-Path $buildPath "librustdesk.dll"
if (Test-Path $flutterLibPath) {
    $size = (Get-Item $flutterLibPath).Length / 1MB
    Write-Host "  [OK] librustdesk.dll copied to Flutter build ($([math]::Round($size, 2)) MB)" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] librustdesk.dll NOT copied to Flutter build!" -ForegroundColor Red
    Write-Host "  This is why the exe won't run!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Solution: Ensure CMakeLists.txt has the correct copy command" -ForegroundColor Yellow
    Write-Host "  Check: flutter/windows/CMakeLists.txt line 104-108" -ForegroundColor White
}

Write-Host ""

# Check DLL dependencies if available
Write-Host "Checking DLL dependencies..." -ForegroundColor Cyan
$dumpbinPath = where.exe dumpbin 2>$null
if ($dumpbinPath) {
    Write-Host "  dumpbin found, analyzing librustdesk.dll dependencies..." -ForegroundColor Gray
    if (Test-Path $flutterLibPath) {
        $deps = & dumpbin /dependents $flutterLibPath 2>&1 | Select-String "\.dll"
        Write-Host "  Dependencies:" -ForegroundColor Gray
        foreach ($dep in $deps) {
            Write-Host "    - $($dep.ToString().Trim())" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "  dumpbin not available (need Visual Studio)" -ForegroundColor Yellow
}

Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($missingFiles.Count -eq 0) {
    Write-Host "✓ All required files present" -ForegroundColor Green
    Write-Host ""
    Write-Host "If the application still doesn't run:" -ForegroundColor Yellow
    Write-Host "  1. Try running from Command Prompt: cd $buildPath && rustdesk.exe" -ForegroundColor White
    Write-Host "  2. Check Windows Event Viewer for crash logs" -ForegroundColor White
    Write-Host "  3. Ensure you're running on 64-bit Windows 10 or later" -ForegroundColor White
    Write-Host "  4. Temporarily disable antivirus and try again" -ForegroundColor White
    Write-Host "  5. Check if any DLL is blocked (Right-click > Properties > Unblock)" -ForegroundColor White
} else {
    Write-Host "✗ Missing files detected!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Missing files:" -ForegroundColor Red
    foreach ($file in $missingFiles) {
        Write-Host "  - $file" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "This is why the application won't run!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To fix:" -ForegroundColor Yellow
    Write-Host "  1. If librustdesk.dll is missing from Flutter build:" -ForegroundColor White
    Write-Host "     - Rebuild: cd flutter && flutter build windows --release" -ForegroundColor White
    Write-Host "     - Check CMakeLists.txt configuration" -ForegroundColor White
    Write-Host ""
    Write-Host "  2. If Rust library wasn't built:" -ForegroundColor White
    Write-Host "     - Build Rust: cargo build --release --features flutter" -ForegroundColor White
    Write-Host ""
    Write-Host "  3. If other files are missing:" -ForegroundColor White
    Write-Host "     - Complete rebuild: flutter clean && flutter build windows --release" -ForegroundColor White
}

Write-Host ""
Write-Host "Build path: $buildPath" -ForegroundColor Gray
Write-Host "Script completed." -ForegroundColor Cyan

