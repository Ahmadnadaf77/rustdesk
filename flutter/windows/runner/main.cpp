#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <tchar.h>
#include <uni_links_desktop/uni_links_desktop_plugin.h>
#include <windows.h>

#include <algorithm>
#include <iostream>

#include "win32_desktop.h"
#include "flutter_window.h"
#include "utils.h"

typedef char** (*FUNC_RUSTDESK_CORE_MAIN)(int*);
typedef void (*FUNC_RUSTDESK_FREE_ARGS)( char**, int);
typedef int (*FUNC_RUSTDESK_GET_APP_NAME)(wchar_t*, int);
/// Note: `--server`, `--service` are already handled in [core_main.rs].
const std::vector<std::string> parameters_white_list = {"--install", "--cm"};

const wchar_t* getWindowClassName();

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command)
{
  HINSTANCE hInstance = LoadLibraryA("librustdesk.dll");
  if (!hInstance)
  {
    DWORD error = GetLastError();
    wchar_t error_msg[512];
    swprintf_s(error_msg, 512,
               L"Failed to load librustdesk.dll\n\n"
               L"Error Code: %lu\n\n"
               L"Possible solutions:\n"
               L"1. Ensure librustdesk.dll is in the same folder as rustdesk.exe\n"
               L"2. Re-extract all files from the zip archive\n"
               L"3. Check if antivirus is blocking the DLL\n"
               L"4. Run Troubleshoot.bat for detailed diagnostics\n\n"
               L"This is a critical file required for RustDesk to run.",
               error);
    MessageBoxW(nullptr, error_msg, L"RustDesk - Critical Error", MB_ICONERROR | MB_OK);
    return EXIT_FAILURE;
  }
  FUNC_RUSTDESK_CORE_MAIN rustdesk_core_main =
      (FUNC_RUSTDESK_CORE_MAIN)GetProcAddress(hInstance, "rustdesk_core_main_args");
  if (!rustdesk_core_main)
  {
    MessageBoxW(nullptr,
                L"Failed to find 'rustdesk_core_main_args' function in librustdesk.dll\n\n"
                L"This usually means:\n"
                L"1. The DLL is corrupted\n"
                L"2. Version mismatch between exe and DLL\n"
                L"3. Incomplete installation\n\n"
                L"Please re-download and extract all files.",
                L"RustDesk - Initialization Error",
                MB_ICONERROR | MB_OK);
    return EXIT_FAILURE;
  }
  FUNC_RUSTDESK_FREE_ARGS free_c_args =
      (FUNC_RUSTDESK_FREE_ARGS)GetProcAddress(hInstance, "free_c_args");
  if (!free_c_args)
  {
    MessageBoxW(nullptr,
                L"Failed to find 'free_c_args' function in librustdesk.dll\n\n"
                L"This usually means:\n"
                L"1. The DLL is corrupted\n"
                L"2. Version mismatch between exe and DLL\n"
                L"3. Incomplete installation\n\n"
                L"Please re-download and extract all files.",
                L"RustDesk - Initialization Error",
                MB_ICONERROR | MB_OK);
    return EXIT_FAILURE;
  }
  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();
  // Remove possible trailing whitespace from command line arguments
  for (auto& argument : command_line_arguments) {
    argument.erase(argument.find_last_not_of(" \n\r\t"));
  }

  int args_len = 0;
  char** c_args = rustdesk_core_main(&args_len);
  if (!c_args)
  {
    std::string args_str = "";
    for (const auto& argument : command_line_arguments) {
      args_str += (argument + " ");
    }
    // std::cout << "RustDesk [" << args_str << "], core returns false, exiting without launching Flutter app." << std::endl;
    return EXIT_SUCCESS;
  }
  std::vector<std::string> rust_args(c_args, c_args + args_len);
  free_c_args(c_args, args_len);

  std::wstring app_name = L"RustDesk";
  FUNC_RUSTDESK_GET_APP_NAME get_rustdesk_app_name = (FUNC_RUSTDESK_GET_APP_NAME)GetProcAddress(hInstance, "get_rustdesk_app_name");
  if (get_rustdesk_app_name) {
    wchar_t app_name_buffer[512] = {0};
    if (get_rustdesk_app_name(app_name_buffer, 512) == 0) {
      app_name = std::wstring(app_name_buffer);
    }
  }

  // Uri links dispatch
  HWND hwnd = ::FindWindowW(getWindowClassName(), app_name.c_str());
  if (hwnd != NULL) {
    // Allow multiple flutter instances when being executed by parameters
    // contained in whitelists.
    bool allow_multiple_instances = false;
    for (auto& whitelist_param : parameters_white_list) {
      allow_multiple_instances =
          allow_multiple_instances ||
          std::find(command_line_arguments.begin(),
                    command_line_arguments.end(),
                    whitelist_param) != command_line_arguments.end();
    }
    if (!allow_multiple_instances) {
      if (!command_line_arguments.empty()) {
        // Dispatch command line arguments
        DispatchToUniLinksDesktop(hwnd);
      } else {
        // Not called with arguments, or just open the app shortcut on desktop.
        // So we just show the main window instead.
        ::ShowWindow(hwnd, SW_NORMAL);
        ::SetForegroundWindow(hwnd);
      }
      return EXIT_FAILURE;
    }
  }

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent())
  {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");
  // connection manager hide icon from taskbar
  bool is_cm_page = false;
  auto cmParam = std::string("--cm");
  if (!command_line_arguments.empty() && command_line_arguments.front().compare(0, cmParam.size(), cmParam.c_str()) == 0) {
    is_cm_page = true;
  }
  bool is_install_page = false;
  auto installParam = std::string("--install");
  if (!command_line_arguments.empty() && command_line_arguments.front().compare(0, installParam.size(), installParam.c_str()) == 0) {
    is_install_page = true;
  }

  command_line_arguments.insert(command_line_arguments.end(), rust_args.begin(), rust_args.end());
  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);

  // Get primary monitor's work area.
  Win32Window::Point workarea_origin(0, 0);
  Win32Window::Size workarea_size(0, 0);

  Win32Desktop::GetWorkArea(workarea_origin, workarea_size);

  // Compute window bounds for default main window position: (10, 10) x(800, 600)
  Win32Window::Point relative_origin(10, 10);

  Win32Window::Point origin(workarea_origin.x + relative_origin.x, workarea_origin.y + relative_origin.y);
  Win32Window::Size size(800u, 600u);

  // Fit the window to the monitor's work area.
  Win32Desktop::FitToWorkArea(origin, size);

  std::wstring window_title;
  if (is_cm_page) {
    window_title = app_name + L" - Connection Manager";
  } else if (is_install_page) {
    window_title = app_name + L" - Install";
  } else {
    window_title = app_name;
  }
  if (!window.CreateAndShow(window_title, origin, size, !is_cm_page)) {
      MessageBoxW(nullptr,
                  L"Failed to create and show the RustDesk window.\n\n"
                  L"This could be caused by:\n"
                  L"1. Missing or corrupted flutter_windows.dll\n"
                  L"2. Missing data folder or assets\n"
                  L"3. Insufficient system resources\n"
                  L"4. Graphics driver issues\n\n"
                  L"Please check:\n"
                  L"- All files from the zip are extracted\n"
                  L"- data/icudtl.dat exists\n"
                  L"- data/flutter_assets folder exists\n"
                  L"- Run Troubleshoot.bat for detailed diagnostics",
                  L"RustDesk - Window Creation Failed",
                  MB_ICONERROR | MB_OK);
      return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0))
  {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
