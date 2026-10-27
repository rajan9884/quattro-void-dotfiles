import QtQuick

Item {
    id: clockRoot
    property var hostShell
    property bool compactFormat: false
    property string timeString: ""

    implicitHeight: 22
    implicitWidth: clockPill.implicitWidth

    function updateTime() {
        var now = new Date()
        timeString = Qt.formatDateTime(now, compactFormat ? "HH:mm" : "ddd dd MMM  HH:mm")
    }

    Component.onCompleted: updateTime()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clockRoot.updateTime()
    }

    BarPill {
        id: clockPill
        anchors.centerIn: parent
        iconText: "󰥔"
        iconColor: Theme.accent
        labelText: clockRoot.timeString
        isSelected: hostShell && hostShell.activeSurface === "calendar"
        onLeftClicked: if (hostShell) hostShell.toggleSurface("calendar")
        onRightClicked: clockRoot.compactFormat = !clockRoot.compactFormat
        onMiddleClicked: Telemetry.runCmd("~/.local/bin/launch-tui-popup calcurse")
    }
}
