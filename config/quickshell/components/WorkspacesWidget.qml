import QtQuick
import Quickshell
import Quickshell.Hyprland

Item {
    id: wsRoot
    implicitHeight: 22
    implicitWidth: wsRow.implicitWidth

    Row {
        id: wsRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 3

        Repeater {
            model: 9

            Rectangle {
                id: wsBtn
                readonly property int wsId: index + 1
                readonly property bool isFocused: Hyprland.focusedMonitor && Hyprland.focusedMonitor.activeWorkspace
                    ? (Hyprland.focusedMonitor.activeWorkspace.id === wsId)
                    : (wsId === 1)

                property bool isOccupied: {
                    var list = Hyprland.workspaces.values
                    for (var i = 0; i < list.length; i++) {
                        if (list[i].id === wsId) return true
                    }
                    return false
                }

                visible: isFocused || isOccupied || wsId <= 5
                implicitHeight: 20
                implicitWidth: isFocused ? 26 : 20
                radius: 4
                color: isFocused ? Theme.accent : (wsMouse.containsMouse ? Theme.selection : (isOccupied ? Theme.lighterBg : "transparent"))

                Behavior on implicitWidth { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text: wsBtn.wsId.toString()
                    color: wsBtn.isFocused ? Theme.darkerBg : (wsBtn.isOccupied ? Theme.brightFg : Theme.muted)
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: wsBtn.isFocused
                }

                MouseArea {
                    id: wsMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("workspace " + wsBtn.wsId)
                    onWheel: (wheel) => {
                        if (wheel.angleDelta.y > 0) Hyprland.dispatch("workspace e-1")
                        else Hyprland.dispatch("workspace e+1")
                    }
                }
            }
        }
    }
}
