import QtQuick
import Quickshell
import Quickshell.Io
import "../components"

Rectangle {
    id: btCard
    property var hostShell
    property var pairedDevices: []

    width: 340
    height: 310
    radius: Theme.cornerRadius + 2
    color: Theme.darkBg
    border.width: 2
    border.color: Theme.magenta

    MouseArea { anchors.fill: parent }

    Process {
        id: btListProc
        command: ["sh", "-c", "bluetoothctl devices 2>/dev/null | head -n 12"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                var rows = data.split("\n").filter(r => r.trim() !== "").map(r => {
                    var p = r.split(" ")
                    return {
                        "mac": p[1] || "",
                        "name": p.slice(2).join(" ") || "Bluetooth Device"
                    }
                })
                btCard.pairedDevices = rows
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            btCard.pairedDevices = []
            btListProc.running = true
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.popupPadding
        spacing: 10

        Text {
            text: Telemetry.btIcon + "  Bluetooth (BlueZ)"
            color: Theme.brightFg
            font.family: Theme.fontFamily
            font.pixelSize: Theme.titleSize
            font.bold: true
        }

        Row {
            spacing: 8
            BarPill {
                iconText: Telemetry.btPowered ? "󰂯" : "󰂲"
                labelText: Telemetry.btPowered ? "Power Off" : "Power On"
                iconColor: Telemetry.btPowered ? Theme.magenta : Theme.muted
                onLeftClicked: {
                    Telemetry.runCmd("~/.local/bin/tui-bluetooth --toggle")
                    Telemetry.refreshNow()
                }
            }
            BarPill {
                iconText: "󰑓"
                labelText: "Refresh Devices"
                onLeftClicked: {
                    btCard.pairedDevices = []
                    btListProc.running = true
                }
            }
        }

        ListView {
            id: btList
            width: parent.width
            height: 150
            clip: true
            spacing: 4
            model: btCard.pairedDevices

            delegate: Rectangle {
                width: btList.width
                height: 30
                radius: 4
                color: bMouse.containsMouse ? Theme.lighterBg : Theme.bg

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    spacing: 8

                    Text {
                        text: "󰂱"
                        color: Theme.magenta
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                    }

                    Text {
                        text: modelData.name + "  [" + modelData.mac + "]"
                        color: Theme.brightFg
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.bodySmallSize
                    }
                }

                MouseArea {
                    id: bMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Telemetry.runCmd("bluetoothctl connect " + modelData.mac)
                        Telemetry.refreshNow()
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 34
            radius: 5
            color: Theme.selection
            border.width: 1
            border.color: Theme.magenta

            Text {
                anchors.centerIn: parent
                text: "󰞷  Open Bluetuith / BlueTUI Controller"
                color: Theme.brightFg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.bodySmallSize
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    hostShell.closeSurface()
                    Telemetry.runCmd("~/.local/bin/tui-bluetooth")
                }
            }
        }
    }
}
