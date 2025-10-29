# Why rustdesk.exe Doesn't Show Anything on Windows

## The Problem

The `rustdesk.exe` file alone **cannot run** because:

1. **RustDesk uses Flutter** for the UI
2. The .exe needs Flutter runtime DLLs and data files
3. When built with `windows_subsystem = "windows"`, errors are silent

## Quick Fix: Download Official Build

The easiest solution is to download the official pre-built release:

```
https://github.com/rustdesk/rustdesk/releases
```

Download `rustdesk-1.x.x-x86_64.exe` (the installer version)

## If You Must Build from Source

### Option 1: Use GitHub Actions (Recommended)

The repository has a GitHub Actions workflow that builds everything correctly:

1. Push your code to GitHub
2. Go to Actions tab
3. Run "Build Windows Release"
4. Download the artifact with all required files

### Option 2: Build Locally on Windows

**Requirements:**

- Windows 10/11 x64
- Visual Studio 2022 (with C++ tools)
- Rust (from rustup.rs)
- Flutter SDK
- Python 3
- vcpkg

**Build commands:**

```powershell
# 1. Set up vcpkg
git clone https://github.com/microsoft/vcpkg C:\vcpkg
cd C:\vcpkg
.\bootstrap-vcpkg.bat
.\vcpkg install libvpx:x64-windows-static libyuv:x64-windows-static opus:x64-windows-static aom:x64-windows-static

# 2. Set environment
$env:VCPKG_ROOT = "C:\vcpkg"

# 3. Build RustDesk
cd \path\to\rustdesk
cargo build --features flutter --lib --release
cd flutter
flutter build windows --release

# 4. Your working app is at:
# flutter\build\windows\x64\runner\Release\rustdesk.exe
# (with all DLLs and data folder)
```

## Why Your Single .exe Doesn't Work

When you run just `rustdesk.exe`, it's missing:

```
Required Files:
├── rustdesk.exe               ← The main executable
├── flutter_windows.dll         ← Flutter engine (REQUIRED!)
├── data\                       ← Flutter assets (REQUIRED!)
│   ├── icudtl.dat
│   └── app.so
└── librustdesk.dll            ← RustDesk library (REQUIRED!)
```

## Quick Test

If you have a `rustdesk.exe` that doesn't work:

```powershell
# Try running it from command line to see errors:
cmd /c rustdesk.exe

# OR with console output:
$env:RUST_BACKTRACE = "1"
.\rustdesk.exe
```

## Creating a Working Package

If you built locally:

```powershell
# Copy the entire Release directory
$source = "flutter\build\windows\x64\runner\Release"
$dest = "rustdesk-portable"

Copy-Item -Recurse $source $dest

# Now you can zip and distribute the entire folder
Compress-Archive -Path $dest -DestinationPath rustdesk-portable.zip
```

## For Developers: Build Process

The correct build process creates:

1. **Rust Library** (`librustdesk.dll`) - Core functionality
2. **Flutter App** (UI + executable + engine)
3. **Portable Package** (bundles everything together)

See `build.py` for the full build script.

## TL;DR

❌ **Won't work:** Single `rustdesk.exe` file
✅ **Will work:** Entire `flutter\build\windows\x64\runner\Release\` folder
✅ **Best option:** Download official release from GitHub

## Need More Help?

1. Check the official docs: https://rustdesk.com/docs
2. GitHub issues: https://github.com/rustdesk/rustdesk/issues
3. Build from scratch: See BUILD_WINDOWS_GUIDE.md
