<#
Driver for codezync_pos (Flutter Windows desktop build).
Usage: powershell -File driver.ps1 <command> [args]

Commands:
  launch [-Exe <path>]                 Start the app, wait for its window, save state.
  screenshot [-Path <file>]            Capture the app window to a PNG. Always reliable.
  maximize                             Maximize the window (also done automatically by launch).
  resize -W <int> -H <int>             Resize beyond the physical screen (see Gotchas in SKILL.md).
  click -X <int> -Y <int>              Click at (X,Y) relative to the window's client area.
  type -Text <string>                  Send literal text as keystrokes (focuses window first).
  key -Key <string>                    Send one SendKeys key sequence, e.g. "{TAB}", "{ENTER}", "{ESC}".
  rect                                 Print the current window rect (debugging).
  stop                                 Kill the app process.

State (pid, window handle) persists in driver_state.json next to this script.

NOTE: click/type/key correctly target the app's FLUTTERVIEW child window at
DPI-correct coordinates (verified with WindowFromPoint) but were NOT observed to
have any visible effect on the running app in this environment - see SKILL.md
Gotchas before relying on them. screenshot/launch/maximize/resize/stop are fully
verified and reliable.
#>
param(
  [Parameter(Position = 0, Mandatory = $true)]
  [ValidateSet("launch", "screenshot", "click", "type", "key", "rect", "maximize", "resize", "stop")]
  [string]$Command,

  [string]$Exe,
  [string]$Path,
  [int]$X,
  [int]$Y,
  [string]$Text,
  [string]$Key,
  [int]$W,
  [int]$H
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$StateFile = Join-Path $ScriptDir "driver_state.json"
$DefaultExe = Join-Path $ScriptDir "..\..\..\build\windows\x64\runner\Debug\codezync_pos.exe"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# powershell.exe is DPI-unaware by default. This app's window renders at 144 DPI
# (150% scale) while an unaware caller's coordinates/rects are silently virtualized
# to 96 DPI - GetClientRect/PrintWindow/SetCursorPos all still "work" and look
# internally consistent, but real clicks/keys land in the wrong physical spot and
# never reach the FLUTTERVIEW child. Declaring per-monitor-v2 awareness up front
# makes every Win32 call below operate in the same real pixel space as the app.
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class DpiAwareness {
    [DllImport("user32.dll")] public static extern bool SetProcessDpiAwarenessContext(IntPtr value);
    public static readonly IntPtr DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2 = new IntPtr(-4);
}
"@
[DpiAwareness]::SetProcessDpiAwarenessContext([DpiAwareness]::DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2) | Out-Null

Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Text;
using System.Collections.Generic;

public static class Win32 {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    [DllImport("user32.dll")] public static extern bool GetClientRect(IntPtr hWnd, out RECT lpRect);
    [DllImport("user32.dll")] public static extern bool ClientToScreen(IntPtr hWnd, ref POINT lpPoint);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern void SwitchToThisWindow(IntPtr hWnd, bool fAltTab);
    [DllImport("user32.dll")] public static extern IntPtr SetFocus(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr hWnd, IntPtr hdcBlt, uint nFlags);
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int X, int Y);
    [DllImport("user32.dll")] public static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint dwData, int dwExtraInfo);
    [DllImport("user32.dll")] public static extern bool IsWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool EnumChildWindows(IntPtr hWndParent, EnumWindowsProc lpEnumFunc, IntPtr lParam);
    [DllImport("user32.dll")] public static extern int GetClassName(IntPtr hWnd, StringBuilder lpClassName, int nMaxCount);
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
    [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint idAttach, uint idAttachTo, bool fAttach);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);
    [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();

    public struct RECT { public int Left; public int Top; public int Right; public int Bottom; }
    public struct POINT { public int X; public int Y; }

    public const uint MOUSEEVENTF_LEFTDOWN = 0x0002;
    public const uint MOUSEEVENTF_LEFTUP = 0x0004;
    public const int SW_RESTORE = 9;
    public const int SW_MAXIMIZE = 3;

    // Flutter's Windows embedder puts the actual input-receiving surface in a
    // child window of class FLUTTERVIEW, not the top-level frame - clicks/keys
    // must target that child or Flutter never sees them.
    public static IntPtr FindFlutterView(IntPtr topLevel) {
        IntPtr found = IntPtr.Zero;
        EnumWindowsProc cb = (h, l) => {
            var sb = new StringBuilder(256);
            GetClassName(h, sb, 256);
            if (sb.ToString() == "FLUTTERVIEW") { found = h; return false; }
            return true;
        };
        EnumChildWindows(topLevel, cb, IntPtr.Zero);
        return found;
    }
}
"@

function Save-State($obj) {
  $obj | ConvertTo-Json | Set-Content -Encoding utf8 $StateFile
}
function Load-State() {
  if (-not (Test-Path $StateFile)) { throw "No driver_state.json - run 'launch' first." }
  return Get-Content $StateFile -Raw | ConvertFrom-Json
}
function Focus-AppWindow($hwnd, $viewHwnd) {
  # Plain SetForegroundWindow/SwitchToThisWindow from an unrelated powershell.exe
  # process is silently ignored by Windows' foreground-lock (e.g. while VS Code
  # itself has focus). AttachThreadInput temporarily joins our thread's input queue
  # to the current foreground thread's, which is the standard, reliable way to
  # steal focus from an unrelated process; SetFocus on the FLUTTERVIEW child then
  # actually takes effect too, instead of being a same-process-only no-op.
  $curForeground = [Win32]::GetForegroundWindow()
  $foregroundTid = 0
  [Win32]::GetWindowThreadProcessId($curForeground, [ref]$foregroundTid) | Out-Null
  $ourTid = [Win32]::GetCurrentThreadId()
  $attached = $false
  if ($foregroundTid -ne 0 -and $foregroundTid -ne $ourTid) {
    $attached = [Win32]::AttachThreadInput($ourTid, $foregroundTid, $true)
  }
  try {
    for ($i = 0; $i -lt 5; $i++) {
      [Win32]::SwitchToThisWindow($hwnd, $true)
      [Win32]::SetForegroundWindow($hwnd) | Out-Null
      if ($viewHwnd -and $viewHwnd -ne 0) { [Win32]::SetFocus([IntPtr]$viewHwnd) | Out-Null }
      Start-Sleep -Milliseconds 100
      if ([Win32]::GetForegroundWindow() -eq $hwnd) { break }
    }
  } finally {
    if ($attached) { [Win32]::AttachThreadInput($ourTid, $foregroundTid, $false) | Out-Null }
  }
  $front = [Win32]::GetForegroundWindow()
  if ($front -ne $hwnd) {
    Write-Warning "codezync_pos (hwnd=$hwnd) is not foreground (foreground=$front) - input may not reach it."
  }
}
function Get-AppWindowHandle($proc) {
  # Debug builds spin up before the Flutter window exists; poll MainWindowHandle.
  for ($i = 0; $i -lt 150; $i++) {
    $proc.Refresh()
    if ($proc.MainWindowHandle -ne 0) { return $proc.MainWindowHandle }
    Start-Sleep -Milliseconds 200
  }
  throw "Timed out waiting for codezync_pos main window."
}

switch ($Command) {

  "launch" {
    $exePath = if ($Exe) { $Exe } else { $DefaultExe }
    $exePath = (Resolve-Path $exePath).Path
    $logPath = Join-Path $ScriptDir "app.log"
    $proc = Start-Process -FilePath $exePath -PassThru -RedirectStandardOutput $logPath -RedirectStandardError "$logPath.err"
    $hwnd = Get-AppWindowHandle $proc
    # This POS UI targets a wide/landscape terminal - maximize so screenshots show
    # the full layout instead of the small default window size.
    [Win32]::ShowWindow($hwnd, [Win32]::SW_MAXIMIZE) | Out-Null
    [Win32]::SetForegroundWindow($hwnd) | Out-Null
    Start-Sleep -Milliseconds 500  # first frame after the window is created
    $viewHwnd = [Win32]::FindFlutterView($hwnd)
    if ($viewHwnd -eq [IntPtr]::Zero) { Write-Warning "Could not find FLUTTERVIEW child - click/type/key will not work." }
    Save-State(@{ pid = $proc.Id; hwnd = [int64]$hwnd; viewHwnd = [int64]$viewHwnd; exe = $exePath })
    Write-Output "launched pid=$($proc.Id) hwnd=$hwnd viewHwnd=$viewHwnd exe=$exePath"
  }

  "maximize" {
    $state = Load-State
    $hwnd = [IntPtr]$state.hwnd
    [Win32]::ShowWindow($hwnd, [Win32]::SW_MAXIMIZE) | Out-Null
    Write-Output "maximized hwnd=$hwnd"
  }

  "resize" {
    # Some screens (e.g. terminal pairing) render content/buttons taller than this
    # environment's ~853px-high display. SetWindowPos can size the window beyond the
    # physical screen; PrintWindow still captures the full client area (off-screen or
    # not) since it renders directly rather than scraping the visible desktop.
    $state = Load-State
    $hwnd = [IntPtr]$state.hwnd
    [Win32]::ShowWindow($hwnd, [Win32]::SW_RESTORE) | Out-Null
    [Win32]::SetWindowPos($hwnd, [IntPtr]::Zero, 0, 0, $W, $H, 0x0040) | Out-Null  # SWP_SHOWWINDOW
    Write-Output "resized hwnd=$hwnd to ${W}x${H}"
  }

  "rect" {
    $state = Load-State
    $hwnd = [IntPtr]$state.hwnd
    $rect = New-Object Win32+RECT
    [Win32]::GetWindowRect($hwnd, [ref]$rect) | Out-Null
    Write-Output "window rect: L=$($rect.Left) T=$($rect.Top) R=$($rect.Right) B=$($rect.Bottom)"
  }

  "screenshot" {
    $state = Load-State
    $hwnd = [IntPtr]$state.hwnd
    if (-not ([Win32]::IsWindow($hwnd))) { throw "Window handle is no longer valid - relaunch." }
    $rect = New-Object Win32+RECT
    [Win32]::GetClientRect($hwnd, [ref]$rect) | Out-Null
    $w = $rect.Right - $rect.Left
    $h = $rect.Bottom - $rect.Top
    if ($w -le 0 -or $h -le 0) { throw "Window has zero-size client area (minimized?)." }

    $bmp = New-Object System.Drawing.Bitmap $w, $h
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $hdc = $g.GetHdc()
    # PW_RENDERFULLCONTENT (2) - required for DirectComposition-backed windows like Flutter's ANGLE/D3D surface.
    [Win32]::PrintWindow($hwnd, $hdc, 2) | Out-Null
    $g.ReleaseHdc($hdc)
    $g.Dispose()

    $outPath = if ($Path) { $Path } else { Join-Path $ScriptDir "screenshot.png" }
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Output "screenshot saved to $outPath"
  }

  "click" {
    $state = Load-State
    $hwnd = [IntPtr]$state.hwnd
    Focus-AppWindow $hwnd $state.viewHwnd
    $pt = New-Object Win32+POINT
    $pt.X = $X; $pt.Y = $Y
    [Win32]::ClientToScreen($hwnd, [ref]$pt) | Out-Null
    [Win32]::SetCursorPos($pt.X, $pt.Y) | Out-Null
    Start-Sleep -Milliseconds 50
    [Win32]::mouse_event([Win32]::MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
    Start-Sleep -Milliseconds 50
    [Win32]::mouse_event([Win32]::MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
    Write-Output "clicked client($X,$Y) -> screen($($pt.X),$($pt.Y))"
  }

  "type" {
    $state = Load-State
    $hwnd = [IntPtr]$state.hwnd
    Focus-AppWindow $hwnd $state.viewHwnd
    # Escape SendKeys metacharacters so literal text (e.g. a PIN like "1234") types correctly.
    $escaped = $Text -replace '([{}\+\^%~\(\)])', '{$1}'
    [System.Windows.Forms.SendKeys]::SendWait($escaped)
    Write-Output "typed: $Text"
  }

  "key" {
    $state = Load-State
    $hwnd = [IntPtr]$state.hwnd
    Focus-AppWindow $hwnd $state.viewHwnd
    [System.Windows.Forms.SendKeys]::SendWait($Key)
    Write-Output "sent key: $Key"
  }

  "stop" {
    $state = Load-State
    Stop-Process -Id $state.pid -Force -ErrorAction SilentlyContinue
    Remove-Item $StateFile -ErrorAction SilentlyContinue
    Write-Output "stopped pid=$($state.pid)"
  }
}
