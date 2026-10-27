import QtQuick

Rectangle {
    id: pill
    property string iconText: ""
    property string labelText: ""
    property color iconColor: Theme.fg
    property color textColor: Theme.brightFg
    property bool isSelected: false
    signal leftClicked()
    signal rightClicked()
    signal middleClicked()
    signal wheelScrolled(int delta)

    implicitHeight: 22
    implicitWidth: contentRow.implicitWidth + 14
    radius: 4
    color: isSelected
           ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.22)
           : (mouseArea.containsMouse ? Theme.selection : "transparent")
    border.width: isSelected ? 1 : 0
    border.color: Theme.accent

    Behavior on color { ColorAnimation { duration: 100 } }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: (labelText !== "" && iconText !== "") ? 5 : 0

        Text {
            visible: pill.iconText !== ""
            text: pill.iconText
            color: pill.isSelected ? Theme.accent : pill.iconColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.iconSize
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            visible: pill.labelText !== ""
            text: pill.labelText
            color: pill.textColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.baseFontSize
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor

        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) pill.leftClicked()
            else if (mouse.button === Qt.RightButton) pill.rightClicked()
            else if (mouse.button === Qt.MiddleButton) pill.middleClicked()
        }

        onWheel: (wheel) => {
            pill.wheelScrolled(wheel.angleDelta.y)
        }
    }
}
