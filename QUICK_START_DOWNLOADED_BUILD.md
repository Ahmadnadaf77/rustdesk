# RustDesk Windows - Quick Start Guide

## You Downloaded a Build and It Won't Run? Read This!

### TL;DR - Quick Fix

**If nothing happens when you double-click `rustdesk.exe`:**

1. **Don't run `rustdesk.exe` directly yet**
2. Instead, run **`Troubleshoot.bat`** (included in the zip)
3. Read the output - it will tell you exactly what's wrong
4. Follow the specific instructions it provides

---

## Step-by-Step: First Time Setup

### 1. Extract the ZIP File

**⚠️ IMPORTANT:** Extract to a permanent location, not into your Downloads folder

```
Good locations:
✓ C:\Program Files\RustDesk\
✓ C:\Users\YourName\Applications\RustDesk\
✓ D:\Software\RustDesk\

Bad locations:
✗ Downloads\ (files might get cleaned up)
✗ Desktop\ (clutters desktop)
✗ Temp\ (will be deleted)
```

**Windows Tip:** Right-click the zip → Extract All → Choose destination

### 2. Check for Windows Security Blocks

After extraction, Windows might "block" the files:

1. Right-click on `rustdesk.exe` → Properties
2. At the bottom, if you see **"Unblock"** checkbox, check it
3. Click **Apply**
4. Repeat for `librustdesk.dll` and `flutter_windows.dll` if blocked

### 3. First Run - Use the Launcher

**✓ RECOMMENDED:** Double-click `Start RustDesk.bat`
- This checks for problems before starting
- Shows clear error messages if something is wrong
- Keeps the window open so you can read errors

**OR**

**Direct launch:** Double-click `rustdesk.exe`
- If it works, great!
- If nothing happens, see "Troubleshooting" below

---

## What Should You See?

### Successful Launch:
1. A small loading indicator (briefly)
2. RustDesk main window opens
3. Shows your connection ID

### Failed Launch - Before Our Fix:
- Nothing happens at all
- No window, no error, nothing
- Process doesn't appear in Task Manager

### Failed Launch - After Our Fix:
- **Error dialog appears** with explanation
- Tells you exactly what's missing
- Suggests how to fix it

---

## Troubleshooting

### Problem 1: Nothing Happens (Most Common)

**Likely Cause:** Missing `librustdesk.dll`

**How to Fix:**
```
1. Open the folder where you extracted RustDesk
2. Look for librustdesk.dll
3. If missing:
   - Re-download the build (download might have been incomplete)
   - Extract again (don't copy individual files)
4. If present:
   - Right-click → Properties → Unblock (if checkbox present)
   - Run Troubleshoot.bat for more details
```

### Problem 2: Error Dialog Shows

**Good news:** The fix is working! Read the error message carefully.

**Common Error Messages and Fixes:**

#### "Failed to load librustdesk.dll"
**Meaning:** The critical DLL file is missing or blocked

**Fix:**
- Re-extract the entire zip file
- Check if antivirus quarantined the file
- Unblock the DLL (Properties → Unblock)

#### "Failed to find 'rustdesk_core_main_args' function"
**Meaning:** DLL is corrupted or wrong version

**Fix:**
- Delete all files and re-extract the zip
- Re-download if problem persists
- Check that file sizes match the ones in build_stats.txt

#### "Failed to create and show the RustDesk window"
**Meaning:** Missing Flutter assets or data files

**Fix:**
- Verify the `data` folder exists
- Check that `data\flutter_assets` folder is present
- Check that `data\icudtl.dat` file exists
- Re-extract the complete zip file

### Problem 3: Application Starts Then Immediately Closes

**Likely Cause:** Antivirus or Windows Defender blocking

**How to Fix:**
```
1. Open Windows Security
2. Go to "Virus & threat protection"
3. Click "Protection history"
4. Look for recent blocked items
5. If RustDesk is listed:
   - Restore it
   - Add an exclusion for the RustDesk folder
   - Re-extract and try again
```

### Problem 4: "This app can't run on your PC"

**Meaning:** Wrong architecture or Windows version

**Fix:**
- This build requires 64-bit Windows 10 or later
- Check: Right-click This PC → Properties → System type
- Should say "64-bit operating system"
- If 32-bit, you need a different build

---

## Required Files Checklist

Your extracted folder should contain **at minimum**:

```
RustDesk/
├── rustdesk.exe              ← Main executable (15-25 MB)
├── librustdesk.dll           ← CRITICAL - Core library (30-50 MB)
├── flutter_windows.dll       ← UI framework (5-10 MB)
├── data/
│   ├── icudtl.dat           ← Required (10 MB)
│   └── flutter_assets/       ← Required folder with many files
├── Start RustDesk.bat        ← Launcher with checks
├── Troubleshoot.bat          ← Diagnostic tool
└── README.txt                ← This came with your download
```

**If any file is missing:** Re-extract the complete zip file.

---

## Diagnostic Tools Included

### Troubleshoot.bat
**Use this first if you have problems!**

What it does:
- Checks all required files exist
- Shows file sizes
- Verifies folder structure
- Tests if exe can run
- Shows system information
- Gives specific fix suggestions

**How to use:**
1. Double-click `Troubleshoot.bat`
2. Read the output
3. Press any key when done
4. Follow the suggested fixes

### Start RustDesk.bat
**Use this instead of rustdesk.exe**

What it does:
- Checks files before launching
- Shows clear errors if something is wrong
- Launches RustDesk if everything is OK
- Captures error codes on exit

---

## Advanced Troubleshooting

### Check Windows Event Viewer

If the application crashes immediately:

1. Press `Win + X` → Event Viewer
2. Go to Windows Logs → Application
3. Look for errors from RustDesk
4. Note the error code and description

### Run from Command Prompt

To see detailed error messages:

1. Press `Win + R` → type `cmd` → Enter
2. Navigate to RustDesk folder:
   ```
   cd "C:\Path\To\RustDesk"
   ```
3. Run: `rustdesk.exe`
4. Any errors will be shown in the console

### Check Antivirus Logs

Most antivirus programs keep logs:

1. Open your antivirus software
2. Look for "Quarantine" or "Blocked items"
3. Check if any RustDesk files were blocked
4. Add exclusion for the RustDesk folder
5. Restore blocked files

---

## System Requirements

| Requirement | Details |
|-------------|---------|
| **OS** | Windows 10 or later |
| **Architecture** | 64-bit (x64) only |
| **RAM** | 2 GB minimum, 4 GB recommended |
| **Disk Space** | 200 MB for installation |
| **Dependencies** | None (statically linked) |

**Note:** No Visual C++ Redistributable needed - everything is included.

---

## Still Not Working?

If you've tried everything above:

### Collect Diagnostic Information:

1. Run `Troubleshoot.bat` and save the output (copy text from window)
2. Check Windows Event Viewer for crash logs
3. Note your Windows version:
   - Press `Win + R` → type `winver` → Enter
4. Check the build number from `README.txt`
5. List which files are present in your folder

### Common Misunderstandings:

❌ "I only copied rustdesk.exe" → **Won't work** - need all files
❌ "I extracted to Desktop" → Works, but not recommended
❌ "I'm on 32-bit Windows" → **Won't work** - need 64-bit
❌ "I renamed librustdesk.dll" → **Won't work** - exact name required
❌ "Files are in different folders" → **Won't work** - must be together

---

## Security Notes

### Why Does Windows Block It?

Windows may show security warnings for these reasons:
1. Downloaded from the internet (MOTW - Mark of the Web)
2. Not from Windows Store
3. Not digitally signed by a known publisher (in this build)

**This is normal for open-source builds.**

### Is It Safe?

- This is an open-source project: github.com/rustdesk/rustdesk
- You can build from source yourself
- Antivirus flags are usually false positives (remote desktop apps are often flagged)
- Always download from trusted sources

### Unblocking Files

The "Unblock" checkbox in Properties removes the MOTW (Mark of the Web):
- Safe to do if you trust the source
- Tells Windows you've verified the file
- Prevents Windows Defender from auto-quarantining

---

## Quick Reference

| Symptom | Most Likely Cause | Quick Fix |
|---------|-------------------|-----------|
| Nothing happens | Missing librustdesk.dll | Re-extract zip |
| Error dialog appears | Read the message | Follow instructions in dialog |
| Starts then closes | Antivirus blocking | Add exclusion |
| "Can't run on PC" | Wrong Windows version | Need 64-bit Win10+ |
| Security warning | Mark of the Web | Unblock files |

---

## Success! Now What?

Once RustDesk starts successfully:

1. **Note your ID** - Shown in the main window
2. **Set a password** - For secure connections
3. **Configure custom server** (if provided):
   - This build may be pre-configured
   - Check README.txt for server details
4. **Test the connection** - Try connecting from another device

---

## Feedback

If this guide helped you, or if you found issues not covered:
- Check the project GitHub for updates
- Build number is in README.txt
- Include build number in any bug reports

---

## Summary

**The Main Issue:** Windows builds would fail silently with no error message.

**The Fix:** Error dialogs now appear explaining exactly what's wrong.

**Your Action:** 
1. Extract the complete zip
2. Run `Troubleshoot.bat` if you have issues
3. Read error messages carefully
4. Follow the specific fix instructions

**Most Common Issue:** Missing `librustdesk.dll` → Solution: Re-extract the complete zip file.

