# RustDesk Windows x64 - Quick Start Guide

## ⚠️ IMPORTANT: Why Your .exe Doesn't Work

**Your single `rustdesk.exe` file CANNOT run alone!**

RustDesk uses Flutter for the UI, which means you need:

- `rustdesk.exe` (the executable)
- `flutter_windows.dll` (Flutter engine - REQUIRED!)
- `data/` folder (app resources - REQUIRED!)
- Other DLL files

## ✅ Solution 1: Download from GitHub Actions

1. Go to your repository on GitHub
2. Click **Actions** tab
3. Click on the latest **"Build Windows Release"** workflow run
4. Download the **"rustdesk-windows-installer"** artifact
5. Extract the ZIP file
6. Run `Start RustDesk.bat` or `rustdesk.exe`

## ✅ Solution 2: Download Official Build

https://github.com/rustdesk/rustdesk/releases

Download the `.exe` installer for Windows.

## ✅ Solution 3: Build Locally

**On Windows:**

```powershell
# 1. Install prerequisites
# - Visual Studio 2022 (with C++ tools)
# - Rust from https://rustup.rs
# - Flutter from https://flutter.dev
# - vcpkg from https://github.com/microsoft/vcpkg

# 2. Build
cd path\to\rustdesk
.\build_windows_x64.ps1

# 3. The working app will be in:
# rustdesk-windows-x64\rustdesk.exe
```

## 🔧 Troubleshooting

### Nothing happens when I run rustdesk.exe

**Problem:** You're running just the .exe file without required DLLs

**Fix:** Download the complete package from GitHub Actions (see Solution 1)

### How to see error messages

Run from Command Prompt:

```cmd
cd path\to\rustdesk\folder
rustdesk.exe
```

Any errors will appear in the console.

### "Missing DLL" error

You need the COMPLETE folder from the build, not just the .exe file.

## 📁 What You Need

```
rustdesk-folder/
├── rustdesk.exe          ← Main app
├── flutter_windows.dll    ← Required!
├── data/                  ← Required!
│   ├── icudtl.dat
│   └── app.so
└── [other DLLs]           ← Required!
```

## 🚀 Quick Commands

**Check if build exists:**

```powershell
ls flutter\build\windows\x64\runner\Release\rustdesk.exe
```

**Build using Python script:**

```powershell
python build.py --flutter --skip-portable-pack
```

**Create portable package:**

```powershell
.\build_windows_x64.ps1
```

## 📚 More Information

- Full build guide: `BUILD_WINDOWS_GUIDE.md`
- Detailed fix info: `WINDOWS_EXE_FIX.md`
- Build script: `build_windows_x64.ps1`

## 🎯 TL;DR

1. **Don't use** a single `rustdesk.exe` file - it won't work
2. **Do use** the complete folder with all DLLs and data
3. **Easy way**: Download from GitHub Actions artifacts
4. **Best way**: Use official releases from https://rustdesk.com

---

**Still having issues?** Check the full guides or open an issue on GitHub.
