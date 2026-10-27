import QtQuick
import "../components"

Rectangle {
    id: audioCard
    property var hostShell

    width: 340
    height: 270
    radius: Theme.cornerRadius + 2
    color: Theme.darkBg
    border.width: 2
    border.color: Theme.accent

    MouseArea { anchors.fill: parent }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.popupPadding
        spacing: 12

        Row {
            width: parent.width
            spacing: 8
            Text {
                text: Telemetry.audioIcon + "  Audio & PipeWire"
                color: Theme.brightFg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.titleSize
                font.bold: true
            }
        }

        Text {
            text: "Output: " + Telemetry.audioSinkName
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.bodySmallSize
            elide: Text.ElideRight
            width: parent.width
        }

        // Volume Interactive Slider Bar
        Column {
            width: parent.width
            spacing: 6

            Row {
                width: parent.width
                spacing: 8
                Text {
                    text: "Master Volume: " + Telemetry.audioText
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.bodySmallSize
                }
            }

            Rectangle {
                id: volTrack
                width: parent.width
                height: 14
                radius: 7
                color: Theme.lighterBg

                Rectangle {
                    width: Math.min(1.0, Telemetry.audioVolume / 100.0) * parent.width
                    height: parent.height
                    radius: 7
                    color: Telemetry.audioMuted ? Theme.urgent : Theme.accent
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: (mouse) => {
                        var pct = Math.round((mouse.x / volTrack.width) * 100)
                        pct = Math.max(0, Math.min(100, pct))
                        Telemetry.runCmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ " + pct + "% && ~/.local/bin/qshell-ctl refresh")
                        Telemetry.audioVolume = pct
                        Telemetry.audioText = pct + "%"
                    }
                }
            }
        }

        // Quick Volume Presets & Mute Row
        Row {
            spacing: 6
            Repeater {
                model: [
                    { "label": "Mute", "cmd": "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" },
                    { "label": "25%", "cmd": "wpctl set-volume @DEFAULT_AUDIO_SINK@ 25%" },
                    { "label": "50%", "cmd": "wpctl set-volume @DEFAULT_AUDIO_SINK@ 50%" },
                    { "label": "75%", "cmd": "wpctl set-volume @DEFAULT_AUDIO_SINK@ 75%" },
                    { "label": "100%", "cmd": "wpctl set-volume @DEFAULT_AUDIO_SINK@ 100%" }
                ]
                BarPill {
                    labelText: modelData.label
                    isSelected: false
                    onLeftClicked: {
                        Telemetry.runCmd(modelData.cmd)
                        Telemetry.refreshNow()
                    }
                }
            }
        }

        // Microphone Toggle Row
        BarPill {
            width: parent.width
            iconText: Telemetry.micMuted ? "󰍭" : "󰍬"
            labelText: Telemetry.micMuted ? "Microphone Muted (Click to Unmute)" : "Microphone Active (Click to Mute)"
            iconColor: Telemetry.micMuted ? Theme.urgent : Theme.success
            onLeftClicked: {
                Telemetry.runCmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")
                Telemetry.refreshNow()
            }
        }

        // Open Full Wiremix / Pulsemixer TUI Button
        Rectangle {
            width: parent.width
            height: 34
            radius: 5
            color: Theme.selection
            border.width: 1
            border.color: Theme.accent

            Text {
                anchors.centerIn: parent
                text: "󰞷  Open Wiremix / Pulsemixer Audio TUI"
                color: Theme.brightFg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.bodySmallSize
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    hostShell.closeSurface()
                    Telemetry.runCmd("~/.local/bin/tui-audio")
                }
            }
        }
    }
}
