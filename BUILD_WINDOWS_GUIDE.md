# Building RustDesk for Windows x64

## Problem: rustdesk.exe doesn't show GUI when executed

The issue is that RustDesk requires both the Rust executable AND Flutter UI components to work properly.

## Solution: Build with Flutter

### Prerequisites on Windows:

1. **Install Rust:**

   ```powershell
   winget install Rustlang.Rustup
   # OR download from: https://rustup.rs/
   ```

2. **Install Flutter:**

   ```powershell
   # Download Flutter SDK from: https://flutter.dev/docs/get-started/install/windows
   # Extract to C:\flutter
   # Add to PATH: C:\flutter\bin
   ```

3. **Install Visual Studio 2022:**

   - Download Community Edition
   - Install "Desktop development with C++" workload
   - Install "Windows 10 SDK"

4. **Install vcpkg:**

   ```powershell
   git clone https://github.com/microsoft/vcpkg
   cd vcpkg
   .\bootstrap-vcpkg.bat
   .\vcpkg install libvpx:x64-windows-static libyuv:x64-windows-static opus:x64-windows-static aom:x64-windows-static
   ```

5. **Set Environment Variables:**
   ```powershell
   $env:VCPKG_ROOT = "C:\path\to\vcpkg"
   ```

### Build Steps:

```powershell
# 1. Clone repository
git clone https://github.com/your-repo/rustdesk.git
cd rustdesk

# 2. Build Rust library
cargo build --features flutter --lib --release

# 3. Build Flutter Windows app
cd flutter
flutter build windows --release
cd ..

# 4. Your executable will be at:
# flutter\build\windows\x64\runner\Release\rustdesk.exe
```

## Alternative: Use Pre-built Release

If building is complex, you can download pre-built releases from:

- GitHub Releases: https://github.com/rustdesk/rustdesk/releases
- Official Website: https://rustdesk.com/

## Quick Test Build Script

Save this as `build_windows.ps1`:

```powershell
# Build script for Windows x64
Write-Host "Building RustDesk for Windows x64..."

# Check prerequisites
if (!(Get-Command cargo -ErrorAction SilentlyContinue)) {
    Write-Error "Rust not found. Please install from https://rustup.rs/"
    exit 1
}

if (!(Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "Flutter not found. Please install from https://flutter.dev/"
    exit 1
}

# Build Rust library
Write-Host "Building Rust library..."
cargo build --features flutter --lib --release

if ($LASTEXITCODE -ne 0) {
    Write-Error "Rust build failed"
    exit 1
}

# Build Flutter app
Write-Host "Building Flutter Windows app..."
Set-Location flutter
flutter build windows --release

if ($LASTEXITCODE -ne 0) {
    Write-Error "Flutter build failed"
    exit 1
}

Set-Location ..

# Copy to output directory
$OutputDir = "build_output"
New-Item -ItemType Directory -Force -Path $OutputDir
Copy-Item -Recurse -Force "flutter\build\windows\x64\runner\Release\*" $OutputDir

Write-Host "Build complete! Executable is in: $OutputDir\rustdesk.exe"
Write-Host "You can now run: .\$OutputDir\rustdesk.exe"
```

## Why the exe doesn't show anything:

1. **No GUI Framework**: Rust executable alone has no UI
2. **Windows Subsystem**: Built with `windows_subsystem = "windows"` so no console appears
3. **Missing Flutter**: Flutter provides the actual user interface

## Correct Build Output Structure:

```
flutter\build\windows\x64\runner\Release\
├── rustdesk.exe          (Main executable)
├── flutter_windows.dll   (Flutter engine)
├── data\                 (Flutter assets)
│   └── icudtl.dat
└── [other DLLs]
```

All these files must be together for the app to work!

## Testing:

```powershell
# Run from the release directory
cd flutter\build\windows\x64\runner\Release
.\rustdesk.exe

# OR copy the entire Release folder to another location and run from there
```

## Common Issues:

1. **Nothing happens**: Missing Flutter DLLs - copy entire Release folder
2. **Crash on start**: Missing Visual C++ Redistributable
3. **Missing dependencies**: Install vcpkg libraries
4. **Build errors**: Ensure VCPKG_ROOT is set correctly

