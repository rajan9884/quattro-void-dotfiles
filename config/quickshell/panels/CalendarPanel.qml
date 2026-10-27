import QtQuick
import Quickshell
import Quickshell.Io
import "../components"

Rectangle {
    id: calCard
    property var hostShell
    property string calOutput: ""
    property string worldClocks: ""

    width: 320
    height: 290
    radius: Theme.cornerRadius + 2
    color: Theme.darkBg
    border.width: 2
    border.color: Theme.accent

    MouseArea { anchors.fill: parent }

    Process {
        id: calProc
        command: ["sh", "-c", "cal -m 2>/dev/null || date"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => calCard.calOutput = data
        }
    }

    Process {
        id: worldProc
        command: ["sh", "-c", "printf 'UTC:       %s\nIST (IN):  %s\nUS/East:   %s\nTokyo:     %s\n' "$(TZ=UTC date +%H:%M)" "$(TZ=Asia/Kolkata date +%H:%M)" "$(TZ=America/New_York date +%H:%M)" "$(TZ=Asia/Tokyo date +%H:%M)""]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => calCard.worldClocks = data
        }
    }

    onVisibleChanged: {
        if (visible) {
            calProc.running = true
            worldProc.running = true
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.popupPadding
        spacing: 10

        Text {
            text: "󰃭  Calendar & World Clock"
            color: Theme.accent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.titleSize
            font.bold: true
        }

        Rectangle {
            width: parent.width
            height: 135
            radius: 5
            color: Theme.bg
            Text {
                anchors.centerIn: parent
                text: calCard.calOutput
                color: Theme.brightFg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.bodySmallSize
            }
        }

        Rectangle {
            width: parent.width
            height: 72
            radius: 5
            color: Theme.bg
            Text {
                anchors.centerIn: parent
                text: calCard.worldClocks
                color: Theme.cyan
                font.family: Theme.fontFamily
                font.pixelSize: Theme.captionSize
            }
        }

        BarPill {
            width: parent.width
            iconText: "󰞷"
            labelText: "Open Calcurse TUI Agenda"
            iconColor: Theme.accent
            onLeftClicked: {
                hostShell.closeSurface()
                Telemetry.runCmd("~/.local/bin/launch-tui-popup calcurse")
            }
        }
    }
}
