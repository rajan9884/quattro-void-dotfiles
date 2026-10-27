import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import "../components"

Scope {
    id: notifScope
    property var hostShell
    property var activeToasts: []

    NotificationServer {
        id: server
        bodySupported: true
        actionsSupported: true
        onNotification: notif => {
            notif.tracked = true
            Telemetry.pushNotification(notif.appName, notif.summary, notif.body, notif.urgency === NotificationUrgency.Critical ? "critical" : "normal")
            if (!Telemetry.dndEnabled) {
                var item = {
                    "summary": notif.summary || "Notification",
                    "body": notif.body || "",
                    "app": notif.appName || "System"
                }
                notifScope.activeToasts = [item].concat(notifScope.activeToasts.slice(0, 3))
                toastTimer.restart()
            }
        }
    }

    Timer {
        id: toastTimer
        interval: 4200
        repeat: false
        onTriggered: notifScope.activeToasts = []
    }

    PanelWindow {
        visible: notifScope.activeToasts.length > 0 && !Telemetry.dndEnabled
        anchors { top: true; right: true }
        margins { top: 34; right: 12 }
        implicitWidth: 340
        implicitHeight: toastCol.implicitHeight + 12
        color: "transparent"

        WlrLayershell.namespace: "quickshell-notifications"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Ignore

        Column {
            id: toastCol
            width: 340
            spacing: 8

            Repeater {
                model: notifScope.activeToasts

                Rectangle {
                    width: 340
                    height: 68
                    radius: Theme.cornerRadius
                    color: Theme.darkBg
                    border.width: 2
                    border.color: Theme.accent

                    // Quattro 6px left edge accent bar ([notifications] border-width-left = 6)
                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 6
                        radius: 3
                        color: Theme.accent
                    }

                    Column {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 10
                        anchors.topMargin: 8
                        spacing: 4

                        Text {
                            text: modelData.app + " · " + modelData.summary
                            color: Theme.brightFg
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.bodySmallSize
                            font.bold: true
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: modelData.body
                            color: Theme.fg
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.captionSize
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: notifScope.activeToasts = []
                    }
                }
            }
        }
    }
}
