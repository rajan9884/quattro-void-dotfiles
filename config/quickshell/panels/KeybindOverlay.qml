import QtQuick
import "../components"

Rectangle {
    id: kbCard
    property var hostShell

    width: 620
    height: 430
    radius: Theme.cornerRadius + 2
    color: Theme.bg
    border.width: 2
    border.color: Theme.accent

    MouseArea { anchors.fill: parent }

    property var shortcuts: [
        { "keys": "Super + Space",            "desc": "Quickshell Unified Menu (Apps, TUIs, Style, System)" },
        { "keys": "Super + Alt + Space",      "desc": "Quickshell Applications-Only Launcher" },
        { "keys": "Super + Ctrl + V / .",     "desc": "Quickshell Clipboard History Overlay" },
        { "keys": "Super + Shift + Alt + ,",  "desc": "Quickshell Notification History Center" },
        { "keys": "Super + Ctrl + A",         "desc": "Quickshell Audio Panel (or Super+Alt+A for Wiremix TUI)" },
        { "keys": "Super + Ctrl + W / N",     "desc": "Quickshell Network Panel (or Super+Alt+N for Impala TUI)" },
        { "keys": "Super + Ctrl + B",         "desc": "Quickshell Bluetooth Panel (or Super+Alt+B for Bluetuith TUI)" },
        { "keys": "Super + Ctrl + D",         "desc": "Quickshell Display, Scale & Night Light Panel" },
        { "keys": "Super + Ctrl + P / Esc",   "desc": "Quickshell Power & Battery Panel" },
        { "keys": "Super + Ctrl + T",         "desc": "Quickshell Theme & Style Switcher" },
        { "keys": "Super + Ctrl + L / L",     "desc": "Quickshell Integrated Lock Screen" },
        { "keys": "Super + Return",           "desc": "Launch Foot / Alacritty Terminal" },
        { "keys": "Super + E / B / G",        "desc": "Launch Yazi (Files) / Btop (Monitor) / Lazygit (Git) TUIs" },
        { "keys": "Super + Alt + X",          "desc": "Launch Void Linux XBPS Interactive Package Browser TUI" },
        { "keys": "Double-Click Empty Bar",   "desc": "Cycle Bar Transparency (Opaque -> Glassy -> Clear)" }
    ]

    Column {
        anchors.fill: parent
        anchors.margins: Theme.panelPadding
        spacing: 10

        Text {
            text: "󰌌  Quattro-Void Keybindings Reference (Super + K)"
            color: Theme.accent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.headingSize
            font.bold: true
        }

        ListView {
            width: parent.width
            height: parent.height - 64
            clip: true
            spacing: 4
            model: kbCard.shortcuts

            delegate: Rectangle {
                width: parent.width
                height: 28
                radius: 4
                color: index % 2 === 0 ? Theme.darkBg : "transparent"

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    text: modelData.keys
                    color: Theme.cyan
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.bodySmallSize
                    font.bold: true
                    width: 210
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 225
                    text: modelData.desc
                    color: Theme.brightFg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.bodySmallSize
                }
            }
        }
    }
}
