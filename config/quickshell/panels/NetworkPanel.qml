import QtQuick
import Quickshell
import Quickshell.Io
import "../components"

Rectangle {
    id: netCard
    property var hostShell
    property var scanResults: []

    width: 350
    height: 340
    radius: Theme.cornerRadius + 2
    color: Theme.darkBg
    border.width: 2
    border.color: Theme.success

    MouseArea { anchors.fill: parent }

    Process {
        id: wifiScanProc
        command: ["sh", "-c", "nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID dev wifi list 2>/dev/null | head -n 12"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                var rows = data.split("\n").filter(r => r.trim() !== "").map(r => {
                    var p = r.split(":")
                    return {
                        "active": p[0] === "*",
                        "signal": p[1] || "0",
                        "security": p[2] || "Open",
                        "ssid": p.slice(3).join(":") || "Hidden SSID"
                    }
                })
                netCard.scanResults = rows
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            netCard.scanResults = []
            wifiScanProc.running = true
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.popupPadding
        spacing: 10

        Row {
            width: parent.width
            spacing: 10
            Text {
                text: Telemetry.wifiIcon + "  NetworkManager"
                color: Theme.brightFg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.titleSize
                font.bold: true
            }
        }

        Text {
            text: "Status: " + Telemetry.wifiText + "  ·  IP: " + Telemetry.ipAddress
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.bodySmallSize
        }

        Row {
            spacing: 8
            BarPill {
                iconText: Telemetry.wifiEnabled ? "󰤨" : "󰤭"
                labelText: Telemetry.wifiEnabled ? "Disable Wi-Fi" : "Enable Wi-Fi"
                iconColor: Telemetry.wifiEnabled ? Theme.success : Theme.urgent
                onLeftClicked: {
                    Telemetry.runCmd("~/.local/bin/tui-wifi --toggle")
                    Telemetry.refreshNow()
                }
            }
            BarPill {
                iconText: "󰑓"
                labelText: "Rescan"
                onLeftClicked: {
                    netCard.scanResults = []
                    wifiScanProc.running = true
                }
            }
        }

        // Discovered Networks List
        ListView {
            id: ssidList
            width: parent.width
            height: 160
            clip: true
            spacing: 4
            model: netCard.scanResults

            delegate: Rectangle {
                width: ssidList.width
                height: 30
                radius: 4
                color: modelData.active ? Theme.selection : (nMouse.containsMouse ? Theme.lighterBg : "transparent")

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    spacing: 8

                    Text {
                        text: modelData.active ? "󰄬" : "󰤨"
                        color: modelData.active ? Theme.success : Theme.accent
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                    }

                    Text {
                        text: modelData.ssid + " (" + modelData.signal + "%)"
                        color: Theme.brightFg
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.bodySmallSize
                    }
                }

                MouseArea {
                    id: nMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        hostShell.closeSurface()
                        Telemetry.runCmd("~/.local/bin/tui-wifi")
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
            border.color: Theme.success

            Text {
                anchors.centerIn: parent
                text: "󰞷  Open Impala / nmtui Wi-Fi TUI"
                color: Theme.brightFg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.bodySmallSize
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    hostShell.closeSurface()
                    Telemetry.runCmd("~/.local/bin/tui-wifi")
                }
            }
        }
    }
}
