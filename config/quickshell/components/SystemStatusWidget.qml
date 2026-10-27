import QtQuick

Row {
    id: rightRow
    property var hostShell
    property bool showBatPercent: true
    spacing: 2

    // 1. Clipboard Overlay Trigger (Quickshell Native Clipboard Panel)
    BarPill {
        iconText: "󰅌"
        iconColor: Theme.cyan
        isSelected: hostShell && hostShell.activeSurface === "clipboard"
        onLeftClicked: if (hostShell) hostShell.toggleSurface("clipboard")
        onRightClicked: Telemetry.runCmd("cliphist wipe")
    }

    // 2. Microphone Widget
    BarPill {
        iconText: Telemetry.micMuted ? "󰍭" : "󰍬"
        iconColor: Telemetry.micMuted ? Theme.urgent : Theme.fg
        onLeftClicked: {
            Telemetry.runCmd("~/.local/bin/qshell-ctl osd mic-mute")
        }
        onMiddleClicked: if (hostShell) hostShell.toggleSurface("audio")
        onWheelScrolled: (delta) => {
            if (delta > 0) Telemetry.runCmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SOURCE@ 5%+ && ~/.local/bin/qshell-ctl refresh")
            else Telemetry.runCmd("wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%- && ~/.local/bin/qshell-ctl refresh")
        }
    }

    // 3. Audio Widget (Opens Quickshell AudioPanel on Left-Click)
    BarPill {
        iconText: Telemetry.audioIcon
        labelText: Telemetry.audioText
        iconColor: Telemetry.audioMuted ? Theme.urgent : Theme.accent
        isSelected: hostShell && hostShell.activeSurface === "audio"
        onLeftClicked: if (hostShell) hostShell.toggleSurface("audio")
        onRightClicked: Telemetry.runCmd("~/.local/bin/qshell-ctl osd volume-mute")
        onMiddleClicked: Telemetry.runCmd("~/.local/bin/tui-audio")
        onWheelScrolled: (delta) => {
            if (delta > 0) Telemetry.runCmd("~/.local/bin/qshell-ctl osd volume-up")
            else Telemetry.runCmd("~/.local/bin/qshell-ctl osd volume-down")
        }
    }

    // 4. Network Widget (Opens Quickshell NetworkPanel on Left-Click)
    BarPill {
        iconText: Telemetry.wifiIcon
        labelText: Telemetry.wifiText
        iconColor: Telemetry.wifiConnected ? Theme.success : Theme.muted
        isSelected: hostShell && hostShell.activeSurface === "network"
        onLeftClicked: if (hostShell) hostShell.toggleSurface("network")
        onRightClicked: Telemetry.runCmd("~/.local/bin/tui-wifi")
    }

    // 5. Bluetooth Widget (Opens Quickshell BluetoothPanel on Left-Click)
    BarPill {
        iconText: Telemetry.btIcon
        labelText: Telemetry.btText
        iconColor: Telemetry.btConnected ? Theme.magenta : (Telemetry.btPowered ? Theme.fg : Theme.muted)
        isSelected: hostShell && hostShell.activeSurface === "bluetooth"
        onLeftClicked: if (hostShell) hostShell.toggleSurface("bluetooth")
        onRightClicked: Telemetry.runCmd("~/.local/bin/tui-bluetooth --toggle")
        onMiddleClicked: Telemetry.runCmd("~/.local/bin/tui-bluetooth")
    }

    // 6. Monitor / Display Brightness Widget (Opens Quickshell MonitorPanel on Left-Click)
    BarPill {
        iconText: Telemetry.brightIcon
        labelText: Telemetry.brightText
        iconColor: Theme.warning
        isSelected: hostShell && hostShell.activeSurface === "monitor"
        onLeftClicked: if (hostShell) hostShell.toggleSurface("monitor")
        onRightClicked: Telemetry.runCmd("~/.local/bin/toggle-nightlight")
        onWheelScrolled: (delta) => {
            if (delta > 0) Telemetry.runCmd("~/.local/bin/qshell-ctl osd brightness-up")
            else Telemetry.runCmd("~/.local/bin/qshell-ctl osd brightness-down")
        }
    }

    // 7. Notification Center Bell
    BarPill {
        iconText: Telemetry.dndEnabled ? "󰂛" : (Telemetry.notificationsList.length > 0 ? "󰂚" : "󰂜")
        labelText: Telemetry.notificationsList.length > 0 ? Telemetry.notificationsList.length.toString() : ""
        iconColor: Telemetry.notificationsList.length > 0 ? Theme.accent : Theme.fg
        isSelected: hostShell && hostShell.activeSurface === "notifications"
        onLeftClicked: if (hostShell) hostShell.toggleSurface("notifications")
        onRightClicked: Telemetry.dndEnabled = !Telemetry.dndEnabled
    }

    // 8. Battery & Power Panel Widget (Opens Quickshell PowerPanel on Left-Click)
    BarPill {
        iconText: Telemetry.batIcon
        labelText: rightRow.showBatPercent ? Telemetry.batText : ""
        iconColor: Telemetry.batLow ? Theme.urgent : (Telemetry.batCharging ? Theme.success : Theme.brightFg)
        isSelected: hostShell && hostShell.activeSurface === "power"
        onLeftClicked: if (hostShell) hostShell.toggleSurface("power")
        onRightClicked: rightRow.showBatPercent = !rightRow.showBatPercent
    }
}
