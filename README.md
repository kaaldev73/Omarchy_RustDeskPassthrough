# RustDesk Fullscreen Passthrough

Use your Omarchy keyboard shortcuts inside a remote RustDesk desktop. Enter fullscreen with **Super+F**, work on the remote computer, then press **Super+F** again to return to local shortcuts.

An Omarchy background service for Hyprland's Lua configuration API. No bar widget, additional window, polling daemon, or permanent Hyprland configuration edits.

| Situation | Keyboard shortcut handling |
| --- | --- |
| RustDesk remote session, windowed | Normal local Omarchy shortcuts |
| Focused RustDesk remote session, fullscreen | Shortcuts pass to RustDesk; Super+F stays local |
| Super+F while in passthrough | Exit fullscreen and restore local shortcuts |
| Focus moves away or fullscreen ends | Restore local shortcuts automatically |
| Plugin disabled or removed normally | Remove plugin bindings/listeners and restore local shortcuts |

**Super+F cannot control fullscreen on the remote computer while passthrough is active.** It is reserved as the local exit key. Mouse input continues through RustDesk normally. Remote keyboard/mouse permission must already be enabled in RustDesk.

## Requirements

- Omarchy Quattro with its running Omarchy shell and plugin manager. Tested on **Omarchy 4.0.2-1**.
- Hyprland with the Lua API. Tested on **Hyprland 0.56.2**; older `hyprland.conf` configurations are not supported by this release. Other versions are unverified.
- `hyprctl` available in the shell's PATH; Quickshell with QtQuick, Quickshell.Io and Quickshell.Hyprland (provided by the tested Omarchy installation).
- A working native RustDesk remote connection. Matching currently requires window class `rustdesk` and the text `Remote Desktop` in the window title. Other languages, window classes, and RustDesk frontends are unverified.
- Lua CLI and Python 3 are needed only for developer tests.

## Install

Run on the **local Omarchy computer with your physical keyboard**, not on the remote computer:

```bash
omarchy plugin add https://github.com/kaaldev73/Omarchy_RustDeskPassthrough --enable
```

Review and accept Omarchy's installation prompt. This follows the repository's current default branch, not an immutable release snapshot.

No manual changes to `hyprland.lua` are needed. Omarchy stores the package under `~/.config/omarchy/plugins/io.github.kaaldev73.rustdesk-passthrough/` and manages its enabled state.

### If you already installed the standalone configuration

Do this **before enabling this plugin** to avoid two independent copies managing the same submap:

1. Back up `~/.config/hypr/hyprland.lua`.
2. Remove only the line `require("hypr.rustdesk-fullscreen")` that loads the earlier standalone module.
3. Run `hyprctl reload config-only`.
4. Install/enable this plugin. The old `rustdesk-fullscreen.lua` file can remain as an inactive backup.

The package never removes an existing personal configuration automatically.

## Use

1. Open RustDesk and connect to the remote Omarchy desktop.
2. Click the remote session window and press **Super+F**.
3. Try **Super+Space**, workspace shortcuts, or other remote shortcuts.
4. Press **Super+F** again to exit fullscreen and regain local shortcut handling.

Fullscreen entered using RustDesk's own controls is also recognized if Hyprland reports the window as fullscreen. Returning focus to an already-fullscreen matching session reactivates passthrough.

## Disable, enable, update, remove

```bash
omarchy plugin disable io.github.kaaldev73.rustdesk-passthrough
omarchy plugin enable io.github.kaaldev73.rustdesk-passthrough
omarchy plugin update io.github.kaaldev73.rustdesk-passthrough
omarchy plugin remove io.github.kaaldev73.rustdesk-passthrough
```

Use one command for the action you want. Normal disabling/removal cleans up the live runtime; no reboot is needed. The plugin does not change the normal Super+F binding outside its own submap.

### Recovery

If Quickshell is forcibly killed or crashes before cleanup, open a local terminal using the mouse and run:

```bash
hyprctl dispatch 'hl.dsp.submap("reset")'
hyprctl reload config-only
```

Restart the Omarchy shell normally when ready. An enabled plugin loads again with the shell. If troubleshooting, disable it before returning to fullscreen RustDesk.

## How it works

`Service.qml` reads the bundled `runtime.lua` and sends it directly to `hyprctl eval` as one argument; it does not invoke a shell. Hyprland's window/focus events activate a dedicated `rustdesk-fullscreen` submap. That submap contains only the local Super+F exit binding.

Event handling uses a short, one-shot timer to inspect the final compositor state. There is no continuous polling. A Hyprland configuration reload discards the old Lua runtime; the service listens for `configreloaded` and loads a fresh copy. Each service instance owns a token so stale cleanup cannot remove a replacement runtime.

## Limits and privacy

- This changes local shortcut interception, not RustDesk's input implementation. It does not guarantee every hardware key, touchpad gesture, protected system shortcut, or remote keyboard layout will work.
- It does not provide remote login-screen access or fix unrelated Wayland, capture, network, or RustDesk permission problems.
- It leaves unrelated active Hyprland submaps alone. Leave those modes before using passthrough.
- The Lua runtime reads the focused window's class, title, mapped state, fullscreen state, and current submap to make its decision. It does not collect keystrokes, record the screen, or store window metadata.
- No network requests, sudo, telemetry, credential access, automatic downloads, or persistent configuration writes are performed by the plugin itself. Omarchy's plugin manager handles installation files and enablement settings.

## Development and verification

From this repository's root:

```bash
lua tests/runtime_test.lua
luac -p runtime.lua
omarchy plugin validate .
qmllint -I /usr/share/omarchy/shell Service.qml
```

For the opt-in live regression test, enable the plugin, open a RustDesk remote connection, keep a local non-RustDesk window focused, and run:

```bash
python3 tests/live_test.py --live
```

The live test temporarily focuses/fullscreens windows and reloads Hyprland configuration. It restores original focus/fullscreen states on normal completion or Python exceptions. It tests compositor state transitions; it does not simulate physical keystrokes or assert behavior inside the remote OS. See [TESTING.md](TESTING.md) for recorded results and remaining manual checks.

## Publishing

See [PUBLISHING.md](PUBLISHING.md) and the prepared [marketplace submission body](marketplace-submission.md). Repository availability does not mean marketplace acceptance; listing requires marketplace validation and maintainer approval.

## License

MIT. Maintained by [Kaaldev / kaaldev73](https://github.com/kaaldev73). This is an independent community plugin, not an official RustDesk or Omarchy product.
