import QtQuick
import "../components"

Rectangle {
    id: monCard
    property var hostShell

    width: 340
    height: 260
    radius: Theme.cornerRadius + 2
    color: Theme.darkBg
    border.width: 2
    border.color: Theme.warning

    MouseArea { anchors.fill: parent }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.popupPadding
        spacing: 12

        Text {
            text: "󰍹  Display & Brightness"
            color: Theme.brightFg
            font.family: Theme.fontFamily
            font.pixelSize: Theme.titleSize
            font.bold: true
        }

        // Brightness Slider
        Column {
            width: parent.width
            spacing: 6

            Text {
                text: "Backlight Brightness: " + Telemetry.brightText
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.bodySmallSize
            }

            Rectangle {
                id: brTrack
                width: parent.width
                height: 14
                radius: 7
                color: Theme.lighterBg

                Rectangle {
                    width: Math.min(1.0, Telemetry.brightPercent / 100.0) * parent.width
                    height: parent.height
                    radius: 7
                    color: Theme.warning
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: (mouse) => {
                        var pct = Math.max(5, Math.min(100, Math.round((mouse.x / brTrack.width) * 100)))
                        Telemetry.runCmd("brightnessctl set " + pct + "% && ~/.local/bin/qshell-ctl refresh")
                        Telemetry.brightPercent = pct
                        Telemetry.brightText = pct + "%"
                    }
                }
            }
        }

        // Display Scale Buttons (Hyprland live scale adjustment)
        Column {
            width: parent.width
            spacing: 6
            Text {
                text: "Hyprland Display Scale:"
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.captionSize
            }
            Row {
                spacing: 6
                Repeater {
                    model: ["1", "1.25", "1.5", "2"]
                    BarPill {
                        labelText: modelData + "x"
                        onLeftClicked: {
                            Telemetry.runCmd("hyprctl keyword monitor ,preferred,auto," + modelData)
                        }
                    }
                }
            }
        }

        // Night Light Toggle (wlsunset)
        BarPill {
            width: parent.width
            iconText: "󰖔"
            labelText: Telemetry.nightLightActive ? "Disable Night Light (6500K)" : "Enable Night Light (4200K Warm)"
            iconColor: Theme.warning
            onLeftClicked: {
                Telemetry.runCmd("~/.local/bin/toggle-nightlight")
                Telemetry.refreshNow()
            }
        }

        // Bar Edge Selector (Quattro Top / Bottom Toggle)
        BarPill {
            width: parent.width
            iconText: "󰖲"
            labelText: "Move Bar Edge (" + Theme.barPosition + ") · Click to Toggle"
            iconColor: Theme.accent
            onLeftClicked: {
                Theme.barPosition = (Theme.barPosition === "top" ? "bottom" : "top")
            }
        }
    }
}
