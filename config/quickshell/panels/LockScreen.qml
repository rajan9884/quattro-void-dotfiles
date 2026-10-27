import QtQuick
import Quickshell
import Quickshell.Wayland
import "../components"

Scope {
    id: lockScope
    property var hostShell
    property string clockStr: ""
    property string dateStr: ""

    Timer {
        interval: 1000
        running: hostShell && hostShell.sessionLocked
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date()
            lockScope.clockStr = Qt.formatDateTime(now, "HH:mm")
            lockScope.dateStr = Qt.formatDateTime(now, "dddd, dd MMMM yyyy")
        }
    }

    WlSessionLock {
        id: sessionLock
        locked: hostShell ? hostShell.sessionLocked : false

        WlSessionLockSurface {
            Rectangle {
                anchors.fill: parent
                color: Theme.darkerBg

                Column {
                    anchors.centerIn: parent
                    spacing: 18

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: lockScope.clockStr
                        color: Theme.brightFg
                        font.family: Theme.fontFamily
                        font.pixelSize: 78
                        font.bold: true
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: lockScope.dateStr
                        color: Theme.accent
                        font.family: Theme.fontFamily
                        font.pixelSize: 16
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰌾  rajan@void — Press Enter to unlock session"
                        color: Theme.muted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.baseFontSize
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 280
                        height: 46
                        radius: 8
                        color: Theme.bg
                        border.width: 2
                        border.color: Theme.accent

                        TextInput {
                            id: passField
                            anchors.fill: parent
                            anchors.margins: 12
                            color: Theme.brightFg
                            font.family: Theme.fontFamily
                            font.pixelSize: 14
                            echoMode: TextInput.Password
                            focus: true
                            onAccepted: {
                                passField.text = ""
                                hostShell.sessionLocked = false
                            }
                        }
                    }
                }
            }
        }
    }
}
