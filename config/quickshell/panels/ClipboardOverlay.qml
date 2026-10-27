import QtQuick
import Quickshell
import Quickshell.Io
import "../components"

Rectangle {
    id: clipCard
    property var hostShell
    property var entries: []
    property string filterText: ""
    property int selectedIndex: 0

    width: 640
    height: 440
    radius: Theme.cornerRadius + 2
    color: Theme.bg
    border.width: 2
    border.color: Theme.cyan

    MouseArea { anchors.fill: parent }

    Process {
        id: clipListProc
        command: ["sh", "-c", "cliphist list | head -n 80"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                var lines = data.split("\n").filter(l => l.trim() !== "")
                clipCard.entries = lines
            }
        }
    }

    property var filteredEntries: {
        var q = filterText.trim().toLowerCase()
        if (q === "") return entries
        return entries.filter(line => line.toLowerCase().indexOf(q) !== -1)
    }

    function copySelected(idx) {
        if (idx < 0 || idx >= filteredEntries.length) return
        var line = filteredEntries[idx]
        var idPart = line.split("\t")[0]
        Telemetry.runCmd("cliphist decode " + idPart + " | wl-copy")
        hostShell.closeSurface()
    }

    function deleteSelected(idx) {
        if (idx < 0 || idx >= filteredEntries.length) return
        var line = filteredEntries[idx]
        var idPart = line.split("\t")[0]
        Telemetry.runCmd("cliphist list | grep '^" + idPart + "' | cliphist delete")
        clipCard.entries = []
        clipListProc.running = true
    }

    onVisibleChanged: {
        if (visible) {
            entries = []
            filterText = ""
            selectedIndex = 0
            clipSearch.text = ""
            clipListProc.running = true
            clipSearch.forceActiveFocus()
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.panelPadding
        spacing: 10

        Rectangle {
            width: parent.width
            height: 42
            radius: Theme.cornerRadius
            color: Theme.darkBg
            border.width: 1
            border.color: Theme.cyan

            Row {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰅌  Clipboard"
                    color: Theme.cyan
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.titleSize
                    font.bold: true
                }

                TextInput {
                    id: clipSearch
                    width: parent.width - 140
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.brightFg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.baseFontSize
                    onTextChanged: {
                        clipCard.filterText = text
                        clipCard.selectedIndex = 0
                    }
                    Keys.onDownPressed: {
                        if (clipCard.selectedIndex < clipCard.filteredEntries.length - 1)
                            clipCard.selectedIndex++
                    }
                    Keys.onUpPressed: {
                        if (clipCard.selectedIndex > 0)
                            clipCard.selectedIndex--
                    }
                    Keys.onReturnPressed: clipCard.copySelected(clipCard.selectedIndex)
                    Keys.onDeletePressed: clipCard.deleteSelected(clipCard.selectedIndex)
                    Keys.onEscapePressed: hostShell.closeSurface()

                    Text {
                        visible: clipSearch.text === ""
                        text: "Type to filter clipboard history..."
                        color: Theme.muted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.baseFontSize
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        ListView {
            id: clipList
            width: parent.width
            height: parent.height - 84
            clip: true
            spacing: 4
            model: clipCard.filteredEntries
            currentIndex: clipCard.selectedIndex

            delegate: Rectangle {
                readonly property bool isCurrent: index === clipCard.selectedIndex
                width: clipList.width
                height: 34
                radius: 5
                color: isCurrent ? Theme.selection : (cMouse.containsMouse ? Theme.lighterBg : "transparent")
                border.width: isCurrent ? 1 : 0
                border.color: Theme.cyan

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    text: modelData
                    elide: Text.ElideRight
                    color: isCurrent ? Theme.brightFg : Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.bodySmallSize
                }

                MouseArea {
                    id: cMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: clipCard.selectedIndex = index
                    onClicked: clipCard.copySelected(index)
                }
            }
        }

        Row {
            spacing: 16
            Text {
                text: "Enter: Copy Selection  ·  Del: Remove Entry  ·  Esc: Close"
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.captionSize
            }
            Text {
                text: "[Wipe All History]"
                color: Theme.urgent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.captionSize
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Telemetry.runCmd("cliphist wipe")
                        clipCard.entries = []
                    }
                }
            }
        }
    }
}
