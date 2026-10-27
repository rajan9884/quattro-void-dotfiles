import QtQuick
import Quickshell
import Quickshell.Wayland
import "../components"

Scope {
    id: osdScope
    property var hostShell

    PanelWindow {
        visible: hostShell && hostShell.osdVisible
        anchors { bottom: true }
        margins { bottom: 64 }
        implicitWidth: 260
        implicitHeight: 54
        color: "transparent"

        WlrLayershell.namespace: "quickshell-osd"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Ignore

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: Theme.darkBg
            border.width: 2
            border.color: Theme.accent

            Row {
                anchors.centerIn: parent
                spacing: 12

                Text {
                    text: hostShell ? hostShell.osdIcon : "󰕾"
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: 20
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: (hostShell ? hostShell.osdLabel : "") + "  " + (hostShell ? hostShell.osdValue : 0) + "%"
                        color: Theme.brightFg
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.bodySmallSize
                        font.bold: true
                    }

                    Rectangle {
                        width: 150
                        height: 8
                        radius: 4
                        color: Theme.lighterBg

                        Rectangle {
                            width: Math.min(1.0, (hostShell ? hostShell.osdValue : 0) / 100.0) * parent.width
                            height: parent.height
                            radius: 4
                            color: Theme.accent
                        }
                    }
                }
            }
        }
    }
}
