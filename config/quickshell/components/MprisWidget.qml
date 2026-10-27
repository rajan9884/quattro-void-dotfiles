import QtQuick

Row {
    id: mprisRow
    property var hostShell
    spacing: 4

    // Active State Indicators (DND / NightLight)
    BarPill {
        visible: Telemetry.dndEnabled || Telemetry.nightLightActive
        iconText: Telemetry.dndEnabled ? "󰂛" : "󰖔"
        iconColor: Telemetry.dndEnabled ? Theme.urgent : Theme.warning
        onLeftClicked: {
            if (Telemetry.dndEnabled) Telemetry.dndEnabled = false
            else Telemetry.runCmd("~/.local/bin/toggle-nightlight")
        }
    }

    // MPRIS Now Playing
    BarPill {
        visible: Telemetry.mediaTitle !== ""
        iconText: Telemetry.mediaStatus === "Playing" ? "󰐊" : "󰏤"
        labelText: Telemetry.mediaTitle
        iconColor: Theme.magenta
        onLeftClicked: Telemetry.runCmd("playerctl play-pause")
        onMiddleClicked: Telemetry.runCmd("playerctl next")
        onRightClicked: Telemetry.runCmd("playerctl previous")
    }
}
