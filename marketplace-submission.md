### Repository URL

https://github.com/kaaldev73/Omarchy_RustDeskPassthrough

### Category

Desktop

### Tags

hyprland

### Suggest a missing tag

remote-desktop

### Maintainer notes

RustDesk Fullscreen Passthrough is a headless Omarchy service that allows local keyboard shortcuts to reach a focused, fullscreen RustDesk remote desktop. Super+F remains local to exit fullscreen. Local shortcuts are restored when focus moves away, fullscreen ends, or the plugin is normally disabled/removed.

Plugin ID: io.github.kaaldev73.rustdesk-passthrough. Version: 0.1.0. License: MIT.

Tested on Omarchy 4.0.2-1 / Hyprland 0.56.2. The service uses Quickshell and hyprctl eval to load bundled Lua into the compositor. It observes window class/title, focus, fullscreen, and submap state; adds a dedicated submap; and registers lifecycle callbacks. It makes no network calls, records no keystrokes, requires no sudo, and does not write Hyprland configuration files. The Omarchy plugin manager manages package files and enablement settings normally.

Dependencies, installation/removal, recovery, test results, and limits are documented in README.md and TESTING.md. Lua tests, manifest validation, QML lint, real fullscreen/focus/reload checks, and normal service enable/disable/removal passed. Physical-key forwarding and a full shell restart/login remain manual release checks. Current window matching requires native RustDesk class rustdesk and the English title text Remote Desktop. Super+F is reserved locally; this does not fix underlying RustDesk Wayland limitations.

Relation to hypr-passthrough (yordan-kanchelov.passthrough): this is a deliberately minimal, RustDesk-only alternative. Super+F always stays local, so leaving a remote session is a single keypress with no pause toggle to learn. It has no bar widget or app list, writes no files, and only activates for RustDesk remote-session windows (the RustDesk home window and maximized, non-fullscreen windows are excluded). Users who want multi-app support or a bar UI should prefer hypr-passthrough.

Users of the earlier standalone Lua config must remove its require line before enabling the plugin, as described in the README.

### Submission checklist

- [x] The repository is public and contains installation and removal instructions.
- [x] I have documented the plugin license and any external dependencies.
- [x] I confirm that I own or have permission to submit this plugin and its preview assets.
- [x] The plugin does not overwrite user configuration without explicit consent.
- [x] I understand that approval is for listing and is not a security review.
