import QtQuick

Rectangle {
    id: barSurface
    property var hostShell

    color: Qt.rgba(Theme.bg.r, Theme.bg.g, Theme.bg.b, Theme.barAlpha)

    // Bottom subtle border line when opaque/glassy
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: Theme.selection
        visible: Theme.barBackgroundMode !== "clear"
    }

    // Double-left-click empty bar space cycles background from opaque -> glassy -> clear (Authentic Quattro gesture!)
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onDoubleClicked: Theme.cycleBarTransparency()
    }

    // LEFT SECTION: Quattro Unified Menu Launcher + 12px Spacer + Hyprland Workspaces
    Row {
        id: leftSection
        anchors {
            left: parent.left
            leftMargin: 8
            verticalCenter: parent.verticalCenter
        }
        spacing: 6

        BarPill {
            iconText: "󰍜"
            labelText: "quattro"
            iconColor: Theme.accent
            isSelected: hostShell && (hostShell.activeSurface === "menu" || hostShell.activeSurface === "apps")
            onLeftClicked: if (hostShell) hostShell.toggleSurface("menu")
            onRightClicked: Telemetry.runCmd("~/.local/bin/launch-term")
            onMiddleClicked: if (hostShell) hostShell.toggleSurface("apps")
        }

        Item { width: 6; height: 1 }

        WorkspacesWidget {
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // CENTER-BEGIN, CENTER, CENTER-END (Quattro Centered Box Architecture)
    Row {
        id: centerCluster
        anchors.centerIn: parent
        spacing: 8

        MprisWidget {
            hostShell: barSurface.hostShell
            anchors.verticalCenter: parent.verticalCenter
        }

        ClockWidget {
            hostShell: barSurface.hostShell
            anchors.verticalCenter: parent.verticalCenter
        }

        // CenterEnd: CPU/Memory quick TUI pill (clicks into btop TUI)
        BarPill {
            iconText: "󰍛"
            labelText: Telemetry.cpuLoad
            iconColor: Theme.success
            onLeftClicked: Telemetry.runCmd("~/.local/bin/launch-tui-float btop")
        }
    }

    // RIGHT SECTION: Clipboard, Mic, Audio, Network, Bluetooth, Monitor, Notifications, Power
    SystemStatusWidget {
        id: rightSection
        hostShell: barSurface.hostShell
        anchors {
            right: parent.right
            rightMargin: 8
            verticalCenter: parent.verticalCenter
        }
    }
}
