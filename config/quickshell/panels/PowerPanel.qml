import QtQuick
import "../components"

Rectangle {
    id: powerCard
    property var hostShell

    width: 330
    height: 290
    radius: Theme.cornerRadius + 2
    color: Theme.darkBg
    border.width: 2
    border.color: Theme.urgent

    MouseArea { anchors.fill: parent }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.popupPadding
        spacing: 12

        Text {
            text: Telemetry.batIcon + "  Power & Session (rajan@void)"
            color: Theme.brightFg
            font.family: Theme.fontFamily
            font.pixelSize: Theme.titleSize
            font.bold: true
        }

        Text {
            text: "Battery: " + Telemetry.batText + " (" + Telemetry.batStatus + ")  ·  CPU: " + Telemetry.cpuLoad + "  ·  RAM: " + Telemetry.memUsed
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.bodySmallSize
        }

        // CPU Governor / Power Profile Selector
        Column {
            spacing: 4
            Text {
                text: "Power Profile:"
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.captionSize
            }
            Row {
                spacing: 6
                BarPill {
                    iconText: "󰾆"
                    labelText: "Powersave"
                    isSelected: Telemetry.powerProfile === "powersave"
                    onLeftClicked: {
                        Telemetry.powerProfile = "powersave"
                        Telemetry.runCmd("sudo -n cpupower frequency-set -g powersave 2>/dev/null || true")
                    }
                }
                BarPill {
                    iconText: "󰓅"
                    labelText: "Performance"
                    isSelected: Telemetry.powerProfile === "performance"
                    onLeftClicked: {
                        Telemetry.powerProfile = "performance"
                        Telemetry.runCmd("sudo -n cpupower frequency-set -g performance 2>/dev/null || true")
                    }
                }
            }
        }

        // Session Action Buttons (Lock, Suspend, Logout, Reboot, Poweroff)
        Column {
            width: parent.width
            spacing: 6

            Repeater {
                model: [
                    { "icon": "󰌾", "label": "Lock Session (Quickshell Lock)", "action": "lock", "col": Theme.accent },
                    { "icon": "󰤄", "label": "Suspend System (zzz / loginctl)", "cmd": "loginctl suspend || sudo -n zzz", "col": Theme.cyan },
                    { "icon": "󰍃", "label": "Logout Hyprland", "cmd": "hyprctl dispatch exit", "col": Theme.warning },
                    { "icon": "󰜉", "label": "Reboot Void Linux", "cmd": "loginctl reboot || sudo -n reboot", "col": Theme.magenta },
                    { "icon": "󰐥", "label": "Poweroff Void Linux", "cmd": "loginctl poweroff || sudo -n poweroff", "col": Theme.urgent }
                ]

                Rectangle {
                    width: powerCard.width - (Theme.popupPadding * 2)
                    height: 30
                    radius: 5
                    color: pMouse.containsMouse ? Theme.selection : Theme.bg
                    border.width: 1
                    border.color: Theme.lighterBg

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        spacing: 10

                        Text {
                            text: modelData.icon
                            color: modelData.col
                            font.family: Theme.fontFamily
                            font.pixelSize: 13
                        }
                        Text {
                            text: modelData.label
                            color: Theme.brightFg
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.bodySmallSize
                        }
                    }

                    MouseArea {
                        id: pMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData.action === "lock") {
                                hostShell.activeSurface = ""
                                hostShell.sessionLocked = true
                            } else {
                                hostShell.closeSurface()
                                Telemetry.runCmd(modelData.cmd)
                            }
                        }
                    }
                }
            }
        }
    }
}
