# RustDesk Windows x64 Build Script
# This script builds a working RustDesk executable for Windows

param(
    [switch]$SkipDependencies = $false,
    [switch]$CleanBuild = $false
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "RustDesk Windows x64 Build Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if a command exists
function Test-Command {
    param($CommandName)
    return [bool](Get-Command $CommandName -ErrorAction SilentlyContinue)
}

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

if (!(Test-Command cargo)) {
    Write-Error "Rust not found! Install from: https://rustup.rs/"
    exit 1
}
Write-Host "✓ Rust found" -ForegroundColor Green

if (!(Test-Command flutter)) {
    Write-Error "Flutter not found! Install from: https://flutter.dev/"
    exit 1
}
Write-Host "✓ Flutter found" -ForegroundColor Green

if (!(Test-Command python)) {
    Write-Warning "Python not found. Portable packer may not work."
} else {
    Write-Host "✓ Python found" -ForegroundColor Green
}

# Check VCPKG
if (!$env:VCPKG_ROOT) {
    Write-Warning "VCPKG_ROOT not set. Please set it to your vcpkg installation."
    Write-Warning "Example: `$env:VCPKG_ROOT = 'C:\vcpkg'"
    $vcpkgPath = Read-Host "Enter vcpkg path (or press Enter to skip)"
    if ($vcpkgPath) {
        $env:VCPKG_ROOT = $vcpkgPath
    }
}

if ($env:VCPKG_ROOT -and (Test-Path "$env:VCPKG_ROOT\vcpkg.exe")) {
    Write-Host "✓ vcpkg found at: $env:VCPKG_ROOT" -ForegroundColor Green
} else {
    Write-Warning "vcpkg not found. Build may fail if dependencies are missing."
}

Write-Host ""

# Clean build if requested
if ($CleanBuild) {
    Write-Host "Cleaning previous build..." -ForegroundColor Yellow
    if (Test-Path "target") {
        Remove-Item -Recurse -Force "target"
    }
    if (Test-Path "flutter\build") {
        Remove-Item -Recurse -Force "flutter\build"
    }
    Write-Host "✓ Clean complete" -ForegroundColor Green
    Write-Host ""
}

# Step 1: Build Rust library
Write-Host "Step 1: Building Rust library..." -ForegroundColor Yellow
Write-Host "Command: cargo build --features flutter --lib --release"
cargo build --features flutter --lib --release

if ($LASTEXITCODE -ne 0) {
    Write-Error "Rust build failed!"
    exit 1
}

# Check if DLL was created
if (!(Test-Path "target\release\librustdesk.dll")) {
    Write-Error "librustdesk.dll not found! Build may have failed."
    exit 1
}

Write-Host "✓ Rust library built successfully" -ForegroundColor Green
Write-Host ""

# Step 2: Build Flutter Windows app
Write-Host "Step 2: Building Flutter Windows app..." -ForegroundColor Yellow
Write-Host "Command: flutter build windows --release"

Set-Location flutter
flutter build windows --release

if ($LASTEXITCODE -ne 0) {
    Set-Location ..
    Write-Error "Flutter build failed!"
    exit 1
}

Set-Location ..
Write-Host "✓ Flutter app built successfully" -ForegroundColor Green
Write-Host ""

# Step 3: Check build output
$outputDir = "flutter\build\windows\x64\runner\Release"
$exePath = Join-Path $outputDir "rustdesk.exe"

if (!(Test-Path $exePath)) {
    Write-Error "rustdesk.exe not found at: $exePath"
    exit 1
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Build Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Executable location:" -ForegroundColor Yellow
Write-Host "  $exePath" -ForegroundColor White
Write-Host ""
Write-Host "Important: You need ALL files in the Release folder:" -ForegroundColor Yellow
Write-Host "  - rustdesk.exe" -ForegroundColor White
Write-Host "  - flutter_windows.dll" -ForegroundColor White
Write-Host "  - data\ folder" -ForegroundColor White
Write-Host "  - Other DLL files" -ForegroundColor White
Write-Host ""

# Step 4: Create portable package (optional)
Write-Host "Creating distributable package..." -ForegroundColor Yellow

$packageDir = "rustdesk-windows-x64"
if (Test-Path $packageDir) {
    Remove-Item -Recurse -Force $packageDir
}

# Copy all required files
Copy-Item -Recurse $outputDir $packageDir
Write-Host "✓ Package created at: $packageDir" -ForegroundColor Green
Write-Host ""

# Create zip file
$version = "1.4.3" # Get from Cargo.toml
$zipFile = "rustdesk-$version-windows-x64.zip"

if (Test-Command Compress-Archive) {
    if (Test-Path $zipFile) {
        Remove-Item $zipFile
    }
    Compress-Archive -Path $packageDir -DestinationPath $zipFile
    Write-Host "✓ Zip file created: $zipFile" -ForegroundColor Green
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Test the build:" -ForegroundColor Yellow
Write-Host "   cd $packageDir" -ForegroundColor White
Write-Host "   .\rustdesk.exe" -ForegroundColor White
Write-Host ""
Write-Host "2. Distribute the package:" -ForegroundColor Yellow
Write-Host "   - Share the entire '$packageDir' folder, OR" -ForegroundColor White
Write-Host "   - Share the '$zipFile' file" -ForegroundColor White
Write-Host ""
Write-Host "Build script completed successfully!" -ForegroundColor Green


