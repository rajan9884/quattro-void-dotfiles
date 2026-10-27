//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "components"
import "panels"

ShellRoot {
    id: shellRoot

    // Active Panel / Overlay State (One popout or modal active at a time)
    property string activeSurface: ""     // "", "menu", "apps", "clipboard", "audio", "network", "bluetooth", "monitor", "power", "calendar", "notifications", "keybinds", "themes"
    property bool sessionLocked: false

    // Shared OSD state
    property bool osdVisible: false
    property string osdIcon: "󰕾"
    property string osdLabel: "Volume"
    property int osdValue: 75

    Timer {
        id: osdHideTimer
        interval: 1600
        repeat: false
        onTriggered: shellRoot.osdVisible = false
    }

    function showOsd(icon, label, val) {
        shellRoot.osdIcon = icon
        shellRoot.osdLabel = label
        shellRoot.osdValue = Math.max(0, Math.min(150, val))
        shellRoot.osdVisible = true
        osdHideTimer.restart()
    }

    function toggleSurface(name) {
        if (shellRoot.activeSurface === name) {
            shellRoot.activeSurface = ""
        } else {
            shellRoot.activeSurface = name
        }
    }

    function closeSurface() {
        shellRoot.activeSurface = ""
    }

    // 1. Native Quickshell IpcHandler (allows `quickshell ipc call shell ...`)
    IpcHandler {
        target: "shell"

        function toggle(surfaceName: string): string {
            shellRoot.toggleSurface(surfaceName)
            return "ok"
        }

        function summon(surfaceName: string): string {
            shellRoot.activeSurface = surfaceName
            return "ok"
        }

        function hide(): string {
            shellRoot.activeSurface = ""
            return "ok"
        }

        function lock(): string {
            shellRoot.activeSurface = ""
            shellRoot.sessionLocked = true
            return "ok"
        }

        function cycleBarBackground(): string {
            Theme.cycleBarTransparency()
            return "ok"
        }

        function showOsdValue(icon: string, label: string, val: int): string {
            shellRoot.showOsd(icon, label, val)
            return "ok"
        }
    }

    // 2. File-Watched IPC Bridge (/tmp/quattro-qs-ipc-rajan) for 100% compatibility across all Quickshell builds
    FileView {
        id: ipcFile
        path: "/tmp/quattro-qs-ipc-rajan"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            var raw = ipcFile.text().trim()
            if (!raw) return
            var parts = raw.split("|")
            var cmd = parts[0]
            var arg1 = parts.length > 1 ? parts[1] : ""
            var arg2 = parts.length > 2 ? parts[2] : ""
            var arg3 = parts.length > 3 ? parts[3] : "0"

            if (cmd === "toggle") shellRoot.toggleSurface(arg1)
            else if (cmd === "summon") shellRoot.activeSurface = arg1
            else if (cmd === "hide") shellRoot.activeSurface = ""
            else if (cmd === "lock") {
                shellRoot.activeSurface = ""
                shellRoot.sessionLocked = true
            } else if (cmd === "bar-bg") {
                Theme.cycleBarTransparency()
            } else if (cmd === "osd") {
                shellRoot.showOsd(arg1, arg2, parseInt(arg3) || 0)
            }
        }
    }

    // 3. Per-Monitor Wallpaper Layer + Top Bar
    Variants {
        model: Quickshell.screens

        Scope {
            property var modelData

            // Native Quickshell Wallpaper Background Layer (Replaces swaybg)
            PanelWindow {
                id: bgWindow
                screen: modelData
                anchors { top: true; bottom: true; left: true; right: true }
                color: Theme.bg
                WlrLayershell.namespace: "quickshell-wallpaper"
                WlrLayershell.layer: WlrLayer.Background
                WlrLayershell.exclusionMode: ExclusionMode.Ignore

                WallpaperLayer {
                    anchors.fill: parent
                }
            }

            // Native Quickshell Top Bar (26px Quattro Bar)
            PanelWindow {
                id: barWindow
                screen: modelData
                anchors {
                    top: Theme.barPosition === "top"
                    bottom: Theme.barPosition === "bottom"
                    left: true
                    right: true
                }
                implicitHeight: Theme.barSizeHorizontal
                color: "transparent"
                WlrLayershell.namespace: "quickshell"
                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.exclusiveZone: Theme.barSizeHorizontal

                Bar {
                    anchors.fill: parent
                    hostShell: shellRoot
                }
            }
        }
    }

    // 4. Native Quickshell Flyout Panels & Fullscreen Overlays (Unified Menu, Clipboard, Audio, Network, Bluetooth, Monitor, Power, Calendar, Notifications, Keybinds)
    PanelHost {
        hostShell: shellRoot
    }

    // 5. Native Quickshell OSD Overlay (Replaces SwayOSD)
    OsdOverlay {
        hostShell: shellRoot
    }

    // 6. Native Quickshell Notification Toasts & Server (Replaces Mako)
    NotificationHost {
        hostShell: shellRoot
    }

    // 7. Native Quickshell Session Lock Overlay (Replaces hyprlock)
    LockScreen {
        hostShell: shellRoot
    }
}
