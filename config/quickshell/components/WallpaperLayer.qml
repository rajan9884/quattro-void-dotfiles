import QtQuick
import Quickshell

Rectangle {
    id: wallRoot
    color: Theme.bg

    Behavior on color {
        ColorAnimation { duration: 420; easing.type: Easing.OutCubic }
    }

    // Subtle Quattro geometric grid & ambient glow rendered directly on the Background layer
    Rectangle {
        anchors.centerIn: parent
        width: parent.width * 0.55
        height: parent.height * 0.55
        radius: width / 2
        color: Theme.accent
        opacity: 0.04
        Behavior on color { ColorAnimation { duration: 420 } }
    }

    Image {
        id: wallImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        source: "file://" + Quickshell.env("HOME") + "/.local/state/quattro/current/background.png"
        visible: status === Image.Ready
        opacity: status === Image.Ready ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 420 } }
    }
}
