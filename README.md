# Quattro-Void: Pure Quickshell + Hyprland Dotfiles for Void Linux

An authentic **Quattro (4.0)** architecture built specifically for **Void Linux (`runit` + `xbps` + `pipewire`)** and pre-configured for user **`rajan`** (`/home/rajan`).

Unlike 3.x setups that stitched together external daemons (`Waybar`, `Walker`/`Rofi`, `Mako`, `SwayOSD`, `swaybg`, `hyprlock`), **Quattro-Void** runs your entire graphical shell inside **one single long-running `quickshell` process (`quickshell -n -p ~/.config/quickshell`)**:

* **Zero Rofi / Zero Walker**: Both the **Unified Menu (`Super + Space`)** and the **Dedicated Apps-Only Launcher (`Super + Alt + Space`)** are native Quickshell QML overlays (`UnifiedMenu.qml`) with live search, category pills, and `.desktop` indexing.
* **Zero Mako / Dunst**: Notifications are handled natively by `Quickshell.Services.Notifications` (`NotificationHost.qml` + `NotificationCenter.qml` history drawer on `Super + Shift + Alt + ,`).
* **Zero SwayOSD**: Volume, microphone mute, and backlight brightness keys trigger the native Quickshell `OsdOverlay.qml` progress pill.
* **Zero Swaybg / Hyprlock**: Desktop wallpaper rendering (with 420ms theme crossfade) and `WlSessionLock` screen locking (`LockScreen.qml` on `Super + Ctrl + L`) live inside the same Quickshell process.
* **Native Quickshell Hardware Panels + TUI Deep Controls**: Clicking bar icons or pressing `Super + Ctrl + {A,W,B,D,P}` opens anchored Quickshell popout cards (`AudioPanel.qml`, `NetworkPanel.qml`, `BluetoothPanel.qml`, `MonitorPanel.qml`, `PowerPanel.qml`, `CalendarPanel.qml`), each with one-click buttons (or `Super + Alt + {A,N,B}`) to jump into full TUI controllers (`wiremix`/`pulsemixer`, `impala`/`nmtui`, `bluetuith`, `yazi`, `btop`, `lazygit`, `calcurse`).

| Desktop Surface | Pure Quickshell QML Component + TUI Integration |
| :--- | :--- |
| **Top Bar (`26px`)** | `components/Bar.qml` (`left`, `centerBegin`, `center`, `centerEnd`, `right` sections; double-click empty bar space to cycle `opaque` / `glassy` / `clear`) |
| **Unified Menu & App Grid** | `panels/UnifiedMenu.qml` (`Super + Space` unified hub · `Super + Alt + Space` apps-only launcher) |
| **Clipboard Overlay** | `panels/ClipboardOverlay.qml` (`Super + Ctrl + V` or `Super + .` — searchable `cliphist` QML overlay) |
| **Audio Flyout & TUI** | `panels/AudioPanel.qml` (`Super + Ctrl + A` — master slider, mute, mic toggle + `wiremix`/`pulsemixer` TUI button) |
| **Network Flyout & TUI** | `panels/NetworkPanel.qml` (`Super + Ctrl + W` — Wi-Fi toggle, live SSID scan + `impala`/`nmtui` TUI button) |
| **Bluetooth Flyout & TUI** | `panels/BluetoothPanel.qml` (`Super + Ctrl + B` — BlueZ power toggle, device list + `bluetuith` TUI button) |
| **Display & Scale Flyout** | `panels/MonitorPanel.qml` (`Super + Ctrl + D` — backlight slider, `1x`/`1.25x`/`1.5x`/`2x` scale, `wlsunset` Night Light, top/bottom bar edge toggle) |
| **Power & Battery Flyout** | `panels/PowerPanel.qml` (`Super + Ctrl + P` / `Super + Escape` — battery telemetry, CPU governor, Lock/Suspend/Reboot/Poweroff) |
| **Notification Server** | `panels/NotificationHost.qml` + `panels/NotificationCenter.qml` (`Super + Shift + Alt + ,` history drawer & DND toggle) |
| **OSD & Lock Screen** | `panels/OsdOverlay.qml` (volume/mic/brightness OSD) + `panels/LockScreen.qml` (`WlSessionLock` on `Super + Ctrl + L`) |
| **Keybind Cheat Sheet** | `panels/KeybindOverlay.qml` (`Super + K` shortcut overlay) |

## 1. One-Command Out-of-the-Box Installation

Extract the archive on your Void Linux machine as user `rajan` and run `install.sh`:

```bash
tar -xzvf quattro-void-dotfiles.tar.gz
cd quattro-void-dotfiles
chmod +x install.sh
./install.sh
```

## 2. Repository Directory Structure

```text
quattro-void-dotfiles/
├── install.sh                               # Void Linux xbps + runit + pure Quickshell installer
├── README.md                                # Architecture, setup, and keybinding reference
├── config/
│   ├── hypr/
│   │   ├── hyprland.conf                    # Main entry point sourcing conf/*.conf
│   │   ├── monitors.lua                     # Quattro Hyprland 0.56+ Lua scale config reference
│   │   └── conf/
│   │       ├── theme.conf                   # Active border gradients & surface palette tokens
│   │       ├── environment.conf             # Wayland, Qt6, & user environment variables for rajan
│   │       ├── monitors.conf                # Monitor auto-detection & persistent workspaces 1..6
│   │       ├── autostart.conf               # Launches PipeWire, cliphist, and single-process Quickshell
│   │       ├── appearance.conf              # 2px gradient borders, 6px rounding, quattroOut curves
│   │       ├── input.conf                   # Caps->Compose remap, Both-Shifts CapsLock, 3-finger swipe
│   │       ├── windowrules.conf             # Centered floating TUI modals (tui-float & tui-popup)
│   │       └── keybinds.conf                # Pure Quickshell IPC keybindings (qshell-ctl) + TUIs
│   ├── quickshell/
│   │   ├── shell.qml                        # Single-process Quickshell root host + IpcHandler
│   │   ├── shell.json                       # Canonical Quattro bar layout & idle configuration
│   │   ├── colors.toml                      # Active Quattro 24-color semantic palette
│   │   ├── shell.toml                       # Active Quattro surface roles, controls, spacing, & font scale
│   │   ├── theme.json                       # Pre-parsed JSON tokens watched live by Theme.qml
│   │   ├── components/
│   │   │   ├── qmldir                       # QML singleton & component registry
│   │   │   ├── Theme.qml                    # Live-reloading palette, typography, & bar transparency engine
│   │   │   ├── Telemetry.qml                # Shared singleton state service (Audio, Net, BT, Bat, MPRIS)
│   │   │   ├── WallpaperLayer.qml           # Native WlrLayer.Background with 420ms theme crossfade
│   │   │   ├── Bar.qml                      # 26px Quattro bar (left, centerBegin, center, centerEnd, right)
│   │   │   ├── BarPill.qml                  # Shared interactive icon/label button component
│   │   │   ├── WorkspacesWidget.qml         # Hyprland workspaces 1..9 with active pill expansion
│   │   │   ├── MprisWidget.qml              # Now-playing media & DND/NightLight indicator pill
│   │   │   ├── ClockWidget.qml              # Centered clock triggering CalendarPanel
│   │   │   └── SystemStatusWidget.qml       # Right-side triggers for Clipboard, Mic, Audio, Net, BT, Display, Power
│   │   └── panels/
│   │       ├── qmldir                       # Panel module definitions
│   │       ├── PanelHost.qml                # WlrLayer.Overlay coordinator for menus & anchored flyouts
│   │       ├── UnifiedMenu.qml              # Native searchable App Launcher + System/Style/TUI menu
│   │       ├── ClipboardOverlay.qml         # Native searchable cliphist manager overlay
│   │       ├── AudioPanel.qml               # Master volume slider, mic toggle, & Wiremix TUI button
│   │       ├── NetworkPanel.qml             # Wi-Fi toggle, live SSID list, & Impala/nmtui TUI button
│   │       ├── BluetoothPanel.qml           # BlueZ power toggle, paired devices, & Bluetuith TUI button
│   │       ├── MonitorPanel.qml             # Backlight slider, display scale (1x..2x), Night Light, bar edge
│   │       ├── PowerPanel.qml               # Battery stats, CPU governor, Lock/Suspend/Reboot/Poweroff
│   │       ├── CalendarPanel.qml            # Month grid calendar + Elsewhen world clock + Calcurse trigger
│   │       ├── NotificationHost.qml         # Native NotificationServer & top-right toast popups
│   │       ├── NotificationCenter.qml       # Notification history drawer & DND toggle
│   │       ├── OsdOverlay.qml               # Volume, mic, & brightness OSD pill
│   │       ├── KeybindOverlay.qml           # Super + K interactive shortcut reference
│   │       └── LockScreen.qml               # Native WlSessionLock screen locker
│   ├── themes/
│   │   ├── tokyo-night/                     # colors.toml + shell.toml + theme.json + hypr-theme.conf
│   │   ├── catppuccin-mocha/
│   │   ├── gruvbox-material/
│   │   └── kanagawa-wave/
│   ├── foot/foot.ini                        # Primary Wayland terminal config
│   ├── alacritty/alacritty.toml             # Alternative GPU terminal config
│   ├── btop/btop.conf                       # Braille graph & Vim-keys system monitor config
│   ├── yazi/yazi.toml                       # TUI file manager config
│   ├── lazygit/config.yml                   # Git TUI config
│   ├── fastfetch/config.jsonc               # Minimal system summary layout
│   └── starship.toml                        # Fast Zsh prompt config
├── local/bin/
│   ├── qshell-ctl                           # IPC CLI driving the running Quickshell instance
│   ├── qs-app-indexer                       # Indexes .desktop files into JSON for UnifiedMenu.qml
│   ├── qs-status-json                       # Telemetry provider for Telemetry.qml
│   ├── set-theme                            # Stages colors.toml, shell.toml, theme.json, & reloads Hyprland
│   ├── tui-audio                            # Launches wiremix / pulsemixer in floating TUI window
│   ├── tui-wifi                             # Launches impala / nmtui / nmcli+fzf in floating TUI window
│   ├── tui-bluetooth                        # Launches bluetuith / bluetui / bluetoothctl+fzf
│   ├── tui-xbps                             # Interactive Void Linux xbps package search & installer
│   ├── screenshot                           # Grim + Slurp + wl-copy screenshot script
│   ├── toggle-nightlight                    # Toggles wlsunset 4200K warm filter
│   ├── void-audio-init                      # Starts PipeWire, WirePlumber, & PipeWire-Pulse
│   ├── reload-desktop                       # Restarts Quickshell & reloads Hyprland
│   ├── launch-term                          # Smart terminal launcher (foot -> alacritty -> kitty)
│   ├── launch-tui-float                     # Opens centered TUI scratchpad (940x620)
│   └── launch-tui-popup                     # Opens compact centered TUI modal (760x520)
└── zsh/
    ├── .zshrc                               # Zsh config with fzf, zoxide, eza, bat, yazi, xbps aliases
    └── .zprofile                            # Environment exports & TTY1 Hyprland auto-launcher
```

## 3. Authentic Quattro Hotkeys & Bar Interactions

| Shortcut / Bar Action | Quickshell Surface or TUI Action |
| :--- | :--- |
| `Super + Space` | Toggle **Quickshell Unified Menu** (Apps, TUIs, Style/Themes, Panels, Capture, System) |
| `Super + Alt + Space` | Toggle **Quickshell Dedicated Apps-Only Launcher** |
| `Super + Ctrl + V` or `Super + .` | Toggle **Quickshell Clipboard History Overlay** (`ClipboardOverlay.qml`) |
| `Super + Shift + Alt + ,` | Toggle **Quickshell Notification History Center** (`NotificationCenter.qml`) |
| `Super + K` | Toggle **Quickshell Keybinding Cheat Sheet** (`KeybindOverlay.qml`) |
| `Super + Ctrl + A` | Toggle **Quickshell Audio Flyout** (`Super + Alt + A` opens `wiremix`/`pulsemixer` TUI directly) |
| `Super + Ctrl + W` / `N` | Toggle **Quickshell Network Flyout** (`Super + Alt + N` opens `impala`/`nmtui` TUI directly) |
| `Super + Ctrl + B` | Toggle **Quickshell Bluetooth Flyout** (`Super + Alt + B` opens `bluetuith` TUI directly) |
| `Super + Ctrl + D` | Toggle **Quickshell Display, Scale & Night Light Flyout** (`MonitorPanel.qml`) |
| `Super + Ctrl + P` / `Super + Esc` | Toggle **Quickshell Power & Battery Flyout** (`PowerPanel.qml`) |
| `Super + Ctrl + T` | Toggle **Quickshell Theme Picker** (`Tokyo Night`, `Catppuccin`, `Gruvbox`, `Kanagawa`) |
| `Super + Ctrl + L` / `Super + L` | Lock session via **Quickshell Integrated Lock Screen** (`WlSessionLock`) |
| `Double-Click Empty Bar` | Cycle top bar background between `Opaque` -> `Glassy` -> `Clear` |
| `Super + Return` | Launch `foot` / `alacritty` terminal |
| `Super + E` / `B` / `G` | Launch `yazi` (Files), `btop` (System Monitor), or `lazygit` (Git) in floating TUI window |
| `Super + Alt + X` | Launch `tui-xbps` interactive Void Linux package browser |
