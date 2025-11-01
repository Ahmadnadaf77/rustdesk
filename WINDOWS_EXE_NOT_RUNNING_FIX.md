# Windows Executable Not Running - Complete Fix Guide

## Problem Description

When you run `rustdesk.exe` on Windows, **nothing happens**:

- No window appears
- No error messages
- No logs
- The process doesn't appear in Task Manager
- It's as if nothing was executed

## Root Cause

The executable is compiled as a **WIN32 GUI application** (not a console app), which means:

1. Error messages written to `std::cout` are **invisible** - there's no console to display them
2. If `librustdesk.dll` fails to load, the app exits silently with no feedback
3. Users have no way to know what went wrong

## The Fix

This repository now includes **three levels of fixes**:

### 1. Source Code Fix (flutter/windows/runner/main.cpp)

**Changed:** Error messages now use `MessageBox` instead of `std::cout`

**Before:**

```cpp
if (!hInstance) {
  std::cout << "Failed to load librustdesk.dll." << std::endl;  // INVISIBLE!
  return EXIT_FAILURE;
}
```

**After:**

```cpp
if (!hInstance) {
  DWORD error = GetLastError();
  wchar_t error_msg[512];
  swprintf_s(error_msg, 512,
             L"Failed to load librustdesk.dll\n\n"
             L"Error Code: %lu\n\n"
             L"Possible solutions:\n"
             L"1. Ensure librustdesk.dll is in the same folder as rustdesk.exe\n"
             L"...",
             error);
  MessageBoxW(nullptr, error_msg, L"RustDesk - Critical Error", MB_ICONERROR | MB_OK);
  return EXIT_FAILURE;
}
```

Now users will see a clear error dialog explaining:

- What went wrong
- Why it happened
- How to fix it

### 2. Build Verification (GitHub Actions Workflow)

Added automatic verification after building to catch missing files early:

```powershell
# Verify critical files exist
$requiredFiles = @("rustdesk.exe", "flutter_windows.dll", "librustdesk.dll")
foreach ($file in $requiredFiles) {
  if (!(Test-Path "$buildDir\$file")) {
    Write-Host "ERROR: Missing required files: $file"
    exit 1
  }
}
```

The build will now **fail fast** if critical files are missing, rather than producing a broken executable.

### 3. User Diagnostic Tools

#### A. Start RustDesk.bat (Launcher)

Located in the distribution zip, provides:

- File existence checks before launching
- Clear error messages if files are missing
- Capture exit codes and explain errors
- Pause to show messages

#### B. Troubleshoot.bat (Diagnostic Tool)

Comprehensive diagnostic script that checks:

- All required files and their sizes
- DLL dependencies (if tools available)
- System information
- Attempts to run the exe and captures errors
- Provides specific fix suggestions

#### C. diagnose_windows_build.ps1 (Development Tool)

For developers building from source:

- Checks build directory structure
- Verifies Rust library was built
- Confirms files were copied correctly
- Analyzes DLL dependencies
- Suggests specific fixes for common issues

## Common Issues and Solutions

### Issue 1: librustdesk.dll Missing

**Symptoms:** Nothing happens when running rustdesk.exe

**Cause:** The core Rust library wasn't copied to the Flutter build output

**Solution:**

1. **For users:** Re-extract the entire zip file - don't move individual files
2. **For developers:**
   - Check `flutter/windows/CMakeLists.txt` line 104-108
   - Rebuild: `cd flutter && flutter build windows --release`
   - Verify: `dir flutter\build\windows\x64\runner\Release\librustdesk.dll`

### Issue 2: DLL Corruption

**Symptoms:** Error: "Failed to find 'rustdesk_core_main_args' function"

**Cause:**

- Incomplete download
- Version mismatch between exe and DLL
- Antivirus corrupted the file

**Solution:**

1. Re-download the complete build
2. Check file sizes match the build statistics
3. Temporarily disable antivirus during extraction
4. Verify file hash if available

### Issue 3: Antivirus Blocking

**Symptoms:** Application starts then immediately closes, or exe won't run at all

**Cause:** Windows Defender or other antivirus quarantining the executable

**Solution:**

1. Check Windows Security > Virus & threat protection > Protection history
2. If blocked, add an exception for the RustDesk folder
3. Right-click all .exe and .dll files > Properties > Unblock (if present)
4. Re-extract the files

### Issue 4: Missing Flutter Assets

**Symptoms:** Error: "Failed to create and show the RustDesk window"

**Cause:** Missing `data` folder or `flutter_assets`

**Solution:**

1. Verify `data\icudtl.dat` exists
2. Verify `data\flutter_assets\` folder exists
3. Re-extract the complete zip file
4. Don't move files - run from extracted folder

## How to Diagnose Your Issue

### For End Users:

1. **Extract the complete zip file** to a folder
2. **Run `Troubleshoot.bat`** (not the exe directly)
3. **Read the output** - it will tell you exactly what's missing
4. **Follow the suggestions** in the error messages

### For Developers:

1. **Run the diagnostic script:**

   ```powershell
   .\diagnose_windows_build.ps1
   ```

2. **Check the output** for missing files

3. **Common fixes:**

   - Rust library not built: `cargo build --release --features flutter`
   - Flutter build incomplete: `cd flutter && flutter build windows --release`
   - Files not copied: Check CMakeLists.txt configuration

4. **Verify manually:**
   ```powershell
   cd flutter\build\windows\x64\runner\Release
   dir *.exe, *.dll
   # Should show: rustdesk.exe, librustdesk.dll, flutter_windows.dll
   ```

## Testing the Fix

After applying the fixes, test with these scenarios:

### Test 1: Missing DLL

1. Rename `librustdesk.dll` to `librustdesk.dll.bak`
2. Run `rustdesk.exe`
3. **Expected:** Error dialog appears explaining the DLL is missing
4. **Before fix:** Nothing happened (silent failure)

### Test 2: Corrupted DLL

1. Replace `librustdesk.dll` with a dummy file
2. Run `rustdesk.exe`
3. **Expected:** Error dialog about missing functions
4. **Before fix:** Silent failure

### Test 3: Normal Operation

1. Ensure all files are present
2. Run `rustdesk.exe`
3. **Expected:** Application starts normally

## Build Process Changes

The GitHub Actions workflow now includes:

1. **Verification step** after Flutter build
2. **Enhanced launcher scripts** with diagnostics
3. **Troubleshooting tools** included in the zip
4. **Detailed README** with common issues

## Quick Reference

| File                   | Purpose                                |
| ---------------------- | -------------------------------------- |
| `rustdesk.exe`         | Main executable (WIN32 GUI app)        |
| `librustdesk.dll`      | **CRITICAL** - Core Rust functionality |
| `flutter_windows.dll`  | Flutter UI framework                   |
| `data/icudtl.dat`      | ICU internationalization data          |
| `data/flutter_assets/` | UI assets and resources                |
| `Start RustDesk.bat`   | Launcher with diagnostics              |
| `Troubleshoot.bat`     | Comprehensive diagnostic tool          |

## For Future Builds

### Checklist Before Distributing:

- [ ] Run `diagnose_windows_build.ps1` and verify all files present
- [ ] Test the exe on a clean Windows VM
- [ ] Verify file sizes match expected values
- [ ] Include all diagnostic scripts in the zip
- [ ] Test `Troubleshoot.bat` shows useful information
- [ ] Verify error dialogs work by renaming a DLL

### Build Command:

```powershell
# Build Rust backend
cargo build --release --features flutter

# Build Flutter app
cd flutter
flutter build windows --release

# Verify output
cd ..
.\diagnose_windows_build.ps1

# If all checks pass, create distribution package
```

## Additional Resources

- **Windows Event Viewer:** Check Application logs for crash details
- **Dependency Walker:** Tool to check DLL dependencies (advanced)
- **Process Monitor:** See what files the exe tries to load (advanced)

## Getting Help

If the exe still won't run after following this guide:

1. Run `Troubleshoot.bat` and save the output
2. Check Windows Event Viewer for crash logs
3. Note your Windows version and architecture
4. Provide the build number from the README.txt
5. Include any error messages shown

## Summary

The core issue was **silent failures** due to WIN32 subsystem not showing `std::cout` messages.

**The fix:** Use `MessageBox` for error messages + comprehensive diagnostic tools.

**Result:** Users now get clear, actionable error messages instead of silent failures.
