---
name: run-codezync-pos
description: Build, launch, and screenshot codezync_pos (the Flutter POS app) as a real Windows desktop app. Use when asked to run the app, start it, build the Windows exe, take a screenshot of its UI, or verify a UI change actually renders - not just that tests pass.
---

codezync_pos is a Flutter app; this skill drives its **Windows desktop build**
(there's no Node/chromium-cli in this environment, so the web target isn't
used here). The agent path is
`.claude/skills/run-codezync-pos/driver.ps1`, a PowerShell driver that
launches the built `.exe`, finds its window via Win32, and can screenshot it
reliably. It can also attempt clicks/keystrokes, but **read Gotchas below
before trusting those** - screenshots are the verified, reliable half of this
driver.

All paths below are relative to the repo root (`codezync_pos/`).

## Prerequisites

Flutter with the Windows desktop toolchain enabled (already the case if
`flutter devices` lists a `windows` target). Nothing beyond the standard
Flutter/Visual Studio C++ toolchain needed for `flutter build windows` - no
extra packages were required in this environment.

```
flutter --version   # verified: Flutter 3.44.9, Dart 3.12.2
flutter devices     # verified to list: Windows (desktop), Chrome (web), Edge (web)
```

## Build

```
flutter pub get
flutter build windows --debug
```

Produces `build\windows\x64\runner\Debug\codezync_pos.exe` (this is the
driver's default `-Exe` path). Took about a minute on first build in this
environment. `.env` (Firebase/API config) is already present at the repo
root and gets bundled as an asset automatically - no setup needed there.

## Run (agent path)

```
powershell -ExecutionPolicy Bypass -File .claude\skills\run-codezync-pos\driver.ps1 launch
powershell -ExecutionPolicy Bypass -File .claude\skills\run-codezync-pos\driver.ps1 screenshot -Path C:\path\to\shot.png
powershell -ExecutionPolicy Bypass -File .claude\skills\run-codezync-pos\driver.ps1 stop
```

`-ExecutionPolicy Bypass` is required on this machine - see Gotchas.

`launch` starts the exe, waits for its window, maximizes it, and saves
`{pid, hwnd, viewHwnd}` to `driver_state.json` next to the script (used by
every later command). It also redirects the app's stdout/stderr to
`app.log`/`app.log.err` next to the script - check `app.log` for Dio request
logs, sync manager output, and stack traces; it's the most reliable way to
confirm what the app is actually doing.

| command | what it does |
|---|---|
| `launch [-Exe <path>]` | Start the app, wait for its window, save state. Defaults to the Debug exe above. |
| `screenshot [-Path <file>]` | Capture the window to a PNG. **Reliable - use this to verify state.** |
| `maximize` | Maximize the window (already done by `launch`). |
| `resize -W <int> -H <int>` | Resize taller/wider than the physical display - see Gotchas. |
| `rect` | Print the window's screen rect (debugging). |
| `click -X <int> -Y <int>` | Click at (X,Y) in client coordinates. **See Gotchas before relying on this.** |
| `type -Text "..."` | Type literal text. **See Gotchas.** |
| `key -Key "{TAB}"` | Send one SendKeys sequence (`{ENTER}`, `{ESC}`, etc). **See Gotchas.** |
| `stop` | Kill the process and clear `driver_state.json`. |

Example of what actually works end-to-end in this environment (re-verified
2026-08-14):

```
powershell -ExecutionPolicy Bypass -File .claude\skills\run-codezync-pos\driver.ps1 launch
# -> launched pid=10980 hwnd=10225050 viewHwnd=985276 exe=...\codezync_pos.exe
powershell -ExecutionPolicy Bypass -File .claude\skills\run-codezync-pos\driver.ps1 screenshot -Path shot.png
# -> real screenshot of the "Welcome to CODEZYNC POS" / "Activate POS
#    Terminal" pairing screen (8-digit code entry + Activate button), fully
#    rendered, with app.log showing "[SYNC] Online on startup. Checking for
#    pending orders..." from SyncManager
powershell -ExecutionPolicy Bypass -File .claude\skills\run-codezync-pos\driver.ps1 stop
# -> stopped pid=10980
```

## Run (human path)

`flutter run -d windows` from the repo root opens a normal debug window with
hot reload. Ctrl-C in the terminal to stop. Not meaningfully different from
the agent path except it doesn't background cleanly, which is why the driver
uses `Start-Process` on the built exe instead.

## Test

No test suite was exercised as part of authoring this skill - `test/` exists
but wasn't run or verified here. Don't cite it as validated.

---

## Gotchas

- **`powershell -File driver.ps1 ...` fails outright with "running scripts
  is disabled on this system"** on a default Windows install (`Get-ExecutionPolicy
  -List` shows every scope `Undefined`, which resolves to `Restricted`). Every
  invocation needs `-ExecutionPolicy Bypass` right after `powershell` - this
  only affects that one process, not the machine's persistent policy, so it's
  safe to always include. Verified on this machine.
- **DPI scaling breaks every Win32 coordinate call unless you declare
  awareness first.** `powershell.exe` is DPI-unaware by default. This
  machine's display is 150% scaled (144 DPI). An unaware process gets
  virtualized (96 DPI) results from `GetClientRect`/`GetWindowRect`/
  `PrintWindow`/`SetCursorPos` - internally consistent-looking, but wrong
  relative to the app's real pixels, and it silently clips the bottom/right
  of the window in screenshots (the "Activate" button and part of the layout
  were invisible until this was fixed). The driver calls
  `SetProcessDpiAwarenessContext(PER_MONITOR_AWARE_V2)` at the top before any
  window API - do this in any new PowerShell automation against this app, or
  every coordinate will be subtly wrong in a way that still "looks" internally
  consistent.
- **The real input surface is a child window, not the top-level frame.**
  `Process.MainWindowHandle` returns the top-level `FLUTTER_RUNNER_WIN32_WINDOW`
  frame. Flutter's actual rendering/input surface is a child of class
  `FLUTTERVIEW` that fills the client area (found via `EnumChildWindows`,
  stored as `viewHwnd` in `driver_state.json`). It has no further children -
  confirmed with `GetWindow(GW_CHILD)`.
- **click/type/key target the right window at the right pixel, but were not
  observed to affect the running app in this environment.** Verified
  extensively before concluding this:
  - `WindowFromPoint` at the exact click coordinate returns the `FLUTTERVIEW`
    hwnd (not some overlapping window) - the target is geometrically correct.
  - Tried `mouse_event`, `SendInput` (absolute-coordinate mouse +
    `KEYEVENTF_UNICODE` keys), and `PostMessage`/`WM_LBUTTONDOWN`/`WM_CHAR`
    sent directly to the `FLUTTERVIEW` child (bypassing focus entirely) - all
    four produced zero visible change and no new entry in `app.log` (e.g.
    clicking "Activate" with an empty pairing code should trigger a network
    call or validation feedback; it triggered nothing).
  - `SetForegroundWindow`/`SwitchToThisWindow`/`AttachThreadInput`-based focus
    stealing from this automation path could not reliably make the app's
    window the true foreground window (kept losing it back to the editor),
    though this shouldn't matter for `SendInput`/`mouse_event`, which route by
    cursor position, not focus.
  - UI Automation (`System.Windows.Automation`) sees only a single unnamed
    `Pane` for the whole window - Flutter's semantics tree isn't active, so
    there's no accessibility-based fallback either.
  - Best guess: an environment-specific limitation between this sandbox's
    virtual display and Flutter's DirectComposition/ANGLE presentation
    surface, not a bug in the coordinates or the script. If you're running
    this from a genuinely interactive local session (not through this kind
    of automated/remote tooling), it may well work - the DPI fix and
    `FLUTTERVIEW` targeting are still correct and necessary either way.
  - **Practical implication: treat `screenshot` + `app.log` as your source of
    truth.** Don't conclude "the click failed" or "the click succeeded" from
    a single attempt - always screenshot before and after and diff them, and
    check `app.log` for expected network/log activity.
- **Small default window clips content - and DPI, not just window size, was
  the cause.** The window's default size is small, and this display is only
  ~1280x853 (logical). The `resize` command can grow the window beyond the
  physical screen (`SetWindowPos` doesn't clamp to the monitor the way
  `ShowWindow(SW_MAXIMIZE)` does) and `PrintWindow` still captures the full
  client area since it renders directly rather than scraping the visible
  desktop - but in practice, fixing DPI awareness resolved the clipping for
  the maximized window in every screen tested here; only reach for `resize`
  if a specific screen is still taller than the maximized window.
- **The window's max track size is clamped near the physical screen size**
  regardless of what you request via `resize` (e.g. requesting 1600px tall
  only got ~871px) - there's a ceiling somewhere (Flutter's `WM_GETMINMAXINFO`
  handling or the display driver), so don't assume `resize -H <huge>` gives
  you arbitrary canvas size.
- **Debug builds are chatty and useful.** `app.log` includes full Dio
  request/response logs (URLs, headers, bodies) and `[SYNC]` messages from
  `SyncManager`. Useful for confirming what the app did, but also means real
  bearer tokens and user data can appear in that file if a session is
  cached from prior use (`flutter_secure_storage` persists across runs on
  this machine) - don't casually paste its contents somewhere public.
- **The app talks to a live backend** (`terminal.uat.swiftl.io`, a UAT
  environment per `.env`). Actions that reach the network (pairing, login)
  have real server-side effects on that UAT tenant - not a local mock.

## Troubleshooting

- **`... cannot be loaded because running scripts is disabled on this
  system`**: missing `-ExecutionPolicy Bypass` - add it right after
  `powershell` in the command (see Gotchas).
- **`Window has zero-size client area (minimized?)`**: the window got
  minimized (e.g. by an unrelated focus-stealing side effect). Run
  `maximize` then retry.
- **`Timed out waiting for codezync_pos main window`**: check
  `app.log`/`app.log.err` - likely a startup crash (missing `.env`, Firebase
  init failure, etc). Re-run `flutter build windows --debug` if the exe is
  stale relative to source changes.
- **`Could not find FLUTTERVIEW child` warning on launch**: the window
  structure changed (Flutter engine version bump?) or the window didn't
  finish initializing before the check. Re-run `launch`; if it persists,
  re-verify with the `enum_direct_children`-style `EnumChildWindows` snippet
  in this file's `Win32.FindFlutterView` before assuming click/type will work
  at all.
