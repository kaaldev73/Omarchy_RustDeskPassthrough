# Verification record — 0.1.0

Date: 2026-09-08. Tested on one Omarchy 4.0.2-1 workstation with Hyprland 0.56.2 and an existing native RustDesk remote session. This is not a claim of compatibility with every Omarchy/RustDesk version.

## Automated checks completed

| Check | Result |
| --- | --- |
| Lua behavior tests: focus, fullscreen, exit dispatcher, close, matching, other submaps | Pass |
| Lua behavior tests: replacement ownership, cleanup, disable/re-enable | Pass |
| `luac -p runtime.lua` | Pass |
| `omarchy plugin validate` | Pass |
| `qmllint -I /usr/share/omarchy/shell Service.qml` | Pass, exit 0 |
| Real Omarchy service enable/load | Pass |
| Real fullscreen enter/exit and independent fullscreen exit | Pass |
| Real focus-away / focus-return | Pass |
| Other applications keep local shortcuts in fullscreen | Pass |
| Hyprland reload while passthrough is active | Pass |
| Exactly one local Super+F binding in passthrough after reload | Pass |
| Omarchy disable, re-enable, and remove | Pass; Lua runtime unloaded on disable/remove |

The live test used Hyprland dispatchers and inspected compositor state. Physical-key forwarding, mouse gestures, clipboard, and remote application behavior were not automatically verified. The user's original standalone configuration and shell settings were restored after package lifecycle testing.

## Manual release checks

- Press physical Super+F, then Super+Space, on a local-to-remote Omarchy connection; confirm the launcher opens remotely.
- Confirm physical Super+F exits and local shortcuts work again.
- Close/disconnect the remote session while fullscreen; confirm local control. Window-close behavior has automated Lua coverage but was not tested by closing the user's live remote connection.
- Confirm behavior after a full shell restart and after login. Hyprland reload and ordinary service disable/re-enable were tested; a full shell restart/login was not performed on the user's active session.
- Test any additional RustDesk language/version before advertising support for it.

## Safe test usage

`runtime_test.lua` uses a mocked Hyprland API and does not control your desktop. `live_test.py --live` intentionally changes focus/fullscreen and reloads configuration. Run it from a local terminal with an existing remote connection, and avoid other input while it runs. No remote commands are sent.
