import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../components"

Rectangle {
    id: menuCard
    property var hostShell
    property string searchQuery: ""
    property int selectedIndex: 0
    property var desktopApps: []

    width: 600
    height: 460
    radius: Theme.cornerRadius + 2
    color: Theme.bg
    border.width: 2
    border.color: Theme.accent

    // Prevent clicks inside card from closing overlay
    MouseArea { anchors.fill: parent }

    // Load indexed .desktop applications from ~/.cache/quattro-apps.json
    FileView {
        id: appsFile
        path: "/tmp/quattro-apps-rajan.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                menuCard.desktopApps = JSON.parse(appsFile.text())
            } catch (e) {
                menuCard.desktopApps = []
            }
        }
    }

    property var builtInItems: [
        { "title": "Terminal (Foot)", "category": "App", "icon": "󰞷", "cmd": "~/.local/bin/launch-term" },
        { "title": "Files · Yazi TUI", "category": "TUI", "icon": "󰉋", "cmd": "~/.local/bin/launch-tui-float yazi" },
        { "title": "System Monitor · Btop TUI", "category": "TUI", "icon": "󰍛", "cmd": "~/.local/bin/launch-tui-float btop" },
        { "title": "Git Client · Lazygit TUI", "category": "TUI", "icon": "󰊢", "cmd": "~/.local/bin/launch-tui-float lazygit" },
        { "title": "Calendar & Tasks · Calcurse TUI", "category": "TUI", "icon": "󰃭", "cmd": "~/.local/bin/launch-tui-popup calcurse" },
        { "title": "Neovim Editor", "category": "TUI", "icon": "󰅩", "cmd": "~/.local/bin/launch-tui-float nvim" },
        { "title": "Void Package Browser · XBPS + FZF TUI", "category": "Void", "icon": "󰏖", "cmd": "~/.local/bin/tui-xbps" },
        { "title": "Audio Mixer · Wiremix / Pulsemixer TUI", "category": "TUI", "icon": "󰕾", "cmd": "~/.local/bin/tui-audio" },
        { "title": "Wi-Fi Scanner · Impala / Nmtui TUI", "category": "TUI", "icon": "󰤨", "cmd": "~/.local/bin/tui-wifi" },
        { "title": "Bluetooth Controller · Bluetuith TUI", "category": "TUI", "icon": "󰂯", "cmd": "~/.local/bin/tui-bluetooth" },
        { "title": "Panel · Audio Settings", "category": "Panel", "icon": "󰕾", "surface": "audio" },
        { "title": "Panel · Network & Wi-Fi", "category": "Panel", "icon": "󰤨", "surface": "network" },
        { "title": "Panel · Bluetooth Devices", "category": "Panel", "icon": "󰂯", "surface": "bluetooth" },
        { "title": "Panel · Display, Scale & Night Light", "category": "Panel", "icon": "󰍹", "surface": "monitor" },
        { "title": "Panel · Clipboard History", "category": "Panel", "icon": "󰅌", "surface": "clipboard" },
        { "title": "Panel · Keybinding Cheat Sheet", "category": "Panel", "icon": "󰌌", "surface": "keybinds" },
        { "title": "Style · Theme: Tokyo Night (Quattro Default)", "category": "Theme", "icon": "󰔎", "cmd": "~/.local/bin/set-theme tokyo-night" },
        { "title": "Style · Theme: Catppuccin Mocha", "category": "Theme", "icon": "󰔎", "cmd": "~/.local/bin/set-theme catppuccin-mocha" },
        { "title": "Style · Theme: Gruvbox Material", "category": "Theme", "icon": "󰔎", "cmd": "~/.local/bin/set-theme gruvbox-material" },
        { "title": "Style · Theme: Kanagawa Wave", "category": "Theme", "icon": "󰔎", "cmd": "~/.local/bin/set-theme kanagawa-wave" },
        { "title": "Style · Cycle Bar Background (Opaque / Glassy / Clear)", "category": "Style", "icon": "󰖲", "action": "cycle-bar" },
        { "title": "Capture · Screenshot Region (grim + slurp)", "category": "Capture", "icon": "󰄀", "cmd": "~/.local/bin/screenshot region" },
        { "title": "Capture · Screenshot Fullscreen", "category": "Capture", "icon": "󰹑", "cmd": "~/.local/bin/screenshot full" },
        { "title": "Capture · Color Picker (hyprpicker)", "category": "Capture", "icon": "󰏘", "cmd": "hyprpicker -a" },
        { "title": "System · Lock Screen", "category": "Power", "icon": "󰌾", "action": "lock" },
        { "title": "System · Suspend Session (zzz / loginctl)", "category": "Power", "icon": "󰤄", "cmd": "loginctl suspend || sudo -n zzz" },
        { "title": "System · Reload Quickshell & Hyprland", "category": "System", "icon": "󰑓", "cmd": "~/.local/bin/reload-desktop" },
        { "title": "System · Reboot Void Linux", "category": "Power", "icon": "󰜉", "cmd": "loginctl reboot || sudo -n reboot" },
        { "title": "System · Poweroff Void Linux", "category": "Power", "icon": "󰐥", "cmd": "loginctl poweroff || sudo -n poweroff" }
    ]

    property var filteredItems: {
        var mode = hostShell ? hostShell.activeSurface : "menu"
        var pool = []
        if (mode === "apps") {
            pool = menuCard.desktopApps.concat(menuCard.builtInItems.filter(i => i.category === "App" || i.category === "TUI"))
        } else if (mode === "themes") {
            pool = menuCard.builtInItems.filter(i => i.category === "Theme" || i.category === "Style")
        } else {
            pool = menuCard.builtInItems.concat(menuCard.desktopApps)
        }

        var q = menuCard.searchQuery.trim().toLowerCase()
        if (q === "") return pool
        return pool.filter(item => {
            var t = (item.title || "").toLowerCase()
            var c = (item.category || "").toLowerCase()
            return t.indexOf(q) !== -1 || c.indexOf(q) !== -1
        })
    }

    function executeSelection(idx) {
        if (idx < 0 || idx >= filteredItems.length) return
        var item = filteredItems[idx]
        if (item.surface) {
            hostShell.activeSurface = item.surface
            return
        }
        if (item.action === "lock") {
            hostShell.activeSurface = ""
            hostShell.sessionLocked = true
            return
        }
        if (item.action === "cycle-bar") {
            Theme.cycleBarTransparency()
            hostShell.closeSurface()
            return
        }
        if (item.cmd) {
            hostShell.closeSurface()
            Telemetry.runCmd(item.cmd)
        }
    }

    onVisibleChanged: {
        if (visible) {
            searchQuery = ""
            selectedIndex = 0
            searchInput.text = ""
            searchInput.forceActiveFocus()
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.panelPadding
        spacing: 12

        // Search Header Bar
        Rectangle {
            width: parent.width
            height: 44
            radius: Theme.cornerRadius
            color: Theme.darkBg
            border.width: 1
            border.color: Theme.accent

            Row {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 10

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: hostShell && hostShell.activeSurface === "apps" ? "󰀻  Apps" : (hostShell && hostShell.activeSurface === "themes" ? "󰔎  Style" : "󰍜  Quattro")
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.titleSize
                    font.bold: true
                }

                TextInput {
                    id: searchInput
                    width: parent.width - 140
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.brightFg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.titleSize
                    selectByMouse: true
                    onTextChanged: {
                        menuCard.searchQuery = text
                        menuCard.selectedIndex = 0
                    }
                    Keys.onDownPressed: {
                        if (menuCard.selectedIndex < menuCard.filteredItems.length - 1)
                            menuCard.selectedIndex++
                    }
                    Keys.onUpPressed: {
                        if (menuCard.selectedIndex > 0)
                            menuCard.selectedIndex--
                    }
                    Keys.onReturnPressed: menuCard.executeSelection(menuCard.selectedIndex)
                    Keys.onEnterPressed: menuCard.executeSelection(menuCard.selectedIndex)
                    Keys.onEscapePressed: hostShell.closeSurface()

                    Text {
                        visible: searchInput.text === ""
                        text: "Search apps, TUIs, themes, panels, or system actions..."
                        color: Theme.muted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.baseFontSize
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        // Results ListView
        ListView {
            id: listView
            width: parent.width
            height: parent.height - 86
            clip: true
            spacing: 4
            model: menuCard.filteredItems
            currentIndex: menuCard.selectedIndex

            delegate: Rectangle {
                readonly property bool isCurrent: index === menuCard.selectedIndex
                width: listView.width
                height: 38
                radius: 5
                color: isCurrent ? Theme.selection : (rowMouse.containsMouse ? Theme.lighterBg : "transparent")
                border.width: isCurrent ? 1 : 0
                border.color: Theme.accent

                // Left 4px accent bar on selected row (Authentic Quattro [menu] selected-border-width = "1 1 1 4")
                Rectangle {
                    visible: isCurrent
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 4
                    radius: 2
                    color: Theme.accent
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    spacing: 12

                    Text {
                        text: modelData.icon || "󰘔"
                        color: isCurrent ? Theme.accent : Theme.fg
                        font.family: Theme.fontFamily
                        font.pixelSize: 15
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: modelData.title || ""
                        color: isCurrent ? Theme.brightFg : Theme.fg
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.baseFontSize
                        font.bold: isCurrent
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    width: catLabel.implicitWidth + 12
                    height: 20
                    radius: 4
                    color: Theme.darkerBg

                    Text {
                        id: catLabel
                        anchors.centerIn: parent
                        text: modelData.category || "Cmd"
                        color: Theme.muted
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                    }
                }

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: menuCard.selectedIndex = index
                    onClicked: menuCard.executeSelection(index)
                }
            }
        }

        // Footer Hints
        Text {
            text: "↑/↓ Navigate  ·  Enter Launch  ·  Esc Close  ·  Super+Alt+Space Apps Only"
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.captionSize
        }
    }
}
