import QtQuick
import "../components"

Rectangle {
    id: ncCard
    property var hostShell

    width: 360
    height: 380
    radius: Theme.cornerRadius + 2
    color: Theme.darkBg
    border.width: 2
    border.color: Theme.accent

    MouseArea { anchors.fill: parent }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.popupPadding
        spacing: 10

        Row {
            width: parent.width
            spacing: 10

            Text {
                text: "󰂚  Notifications (" + Telemetry.notificationsList.length + ")"
                color: Theme.brightFg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.titleSize
                font.bold: true
            }

            BarPill {
                iconText: Telemetry.dndEnabled ? "󰂛" : "󰂜"
                labelText: Telemetry.dndEnabled ? "DND On" : "DND Off"
                iconColor: Telemetry.dndEnabled ? Theme.urgent : Theme.fg
                onLeftClicked: Telemetry.dndEnabled = !Telemetry.dndEnabled
            }

            BarPill {
                labelText: "Clear"
                onLeftClicked: Telemetry.clearNotifications()
            }
        }

        ListView {
            id: histList
            width: parent.width
            height: parent.height - 54
            clip: true
            spacing: 6
            model: Telemetry.notificationsList

            delegate: Rectangle {
                width: histList.width
                height: 58
                radius: 5
                color: Theme.bg
                border.width: 1
                border.color: Theme.selection

                Column {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 3

                    Text {
                        text: "[" + modelData.time + "] " + modelData.app + ": " + modelData.summary
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
            }
        }
    }
}
