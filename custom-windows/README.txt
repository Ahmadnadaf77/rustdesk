⚠️⚠️⚠️ WARNING: THIS .EXE FILE WILL NOT WORK ALONE! ⚠️⚠️⚠️

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    ❌ INCOMPLETE BUILD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The rustdesk-windows.exe file in this folder is INCOMPLETE and cannot run.

CURRENT STATUS:
  Size: 23 MB (only 9% complete)
  Missing: 227 MB of required files (91% missing!)
  Can Execute: NO
  
WHEN YOU CLICK IT:
  Result: NOTHING HAPPENS (program exits silently)

WHY IT DOESN'T WORK:
====================

RustDesk uses Flutter for its user interface. The .exe file REQUIRES:
  - flutter_windows.dll (Flutter engine)
  - librustdesk.dll (RustDesk core library)
  - data/ folder (UI assets and resources)

These files are MISSING from this folder!


HOW TO GET A WORKING BUILD:
============================

Option 1: Use GitHub Actions (EASIEST - RECOMMENDED)
-----------------------------------------------------
1. Push your code to GitHub
2. Go to: Actions → "Build Windows Release" → "Run workflow"
3. Download the complete build artifact when finished
4. Extract and run!

See: QUICK_FIX_WINDOWS.md for detailed instructions


Option 2: Build on Windows Machine
-----------------------------------
Requirements:
  - Windows 10/11 (64-bit)
  - Visual Studio 2022 (C++ tools)
  - Rust from https://rustup.rs
  - Flutter SDK 3.35.6+
  - vcpkg package manager

Build commands (PowerShell):
  # Setup vcpkg
  git clone https://github.com/microsoft/vcpkg C:\vcpkg
  cd C:\vcpkg
  .\bootstrap-vcpkg.bat
  .\vcpkg install libvpx:x64-windows-static libyuv:x64-windows-static opus:x64-windows-static

  # Build RustDesk
  cd \path\to\rustdesk
  $env:VCPKG_ROOT = "C:\vcpkg"
  cargo build --release
  cd flutter
  flutter pub get
  flutter build windows --release

  # Complete build location:
  # flutter\build\windows\x64\runner\Release\

See: BUILD_WINDOWS.md for full build guide


QUICK CHECK:
============

Run this script to verify your build status:
  ./create_windows_package.sh

This will check if you have a complete Windows build and create
a proper package if everything is present.


MORE INFORMATION:
=================

- QUICK_FIX_WINDOWS.md - Step-by-step solutions
- WINDOWS_EXE_FIX.md - Detailed explanation
- BUILD_WINDOWS_GUIDE.md - Complete build instructions
- .github/workflows/build-windows.yml - Automated build workflow


SUMMARY:
========

❌ Single rustdesk.exe file DOES NOT WORK
✅ Complete Release folder with all DLLs and data/ DOES WORK
✅ Use GitHub Actions for easiest automated build

For help: See QUICK_FIX_WINDOWS.md

