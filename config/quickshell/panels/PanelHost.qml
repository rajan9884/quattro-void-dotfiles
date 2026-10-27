import QtQuick
import Quickshell
import Quickshell.Wayland
import "../components"

Scope {
    id: panelScope
    property var hostShell

    PanelWindow {
        id: overlayWindow
        visible: hostShell && hostShell.activeSurface !== ""
        anchors { top: true; bottom: true; left: true; right: true }
        color: Qt.rgba(0, 0, 0, 0.28)

        WlrLayershell.namespace: "quickshell-panel"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        // Click outside active card to dismiss
        MouseArea {
            anchors.fill: parent
            onClicked: hostShell.closeSurface()
        }

        Item {
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: hostShell.closeSurface()

            // 1. Unified Menu & App Launcher (Super + Space / Super + Alt + Space)
            UnifiedMenu {
                visible: hostShell.activeSurface === "menu" || hostShell.activeSurface === "apps" || hostShell.activeSurface === "themes"
                hostShell: panelScope.hostShell
                anchors.centerIn: parent
            }

            // 2. Native Quickshell Clipboard History Overlay (Super + Ctrl + V / Super + .)
            ClipboardOverlay {
                visible: hostShell.activeSurface === "clipboard"
                hostShell: panelScope.hostShell
                anchors.centerIn: parent
            }

            // 3. Keybind Cheat Sheet Overlay (Super + K)
            KeybindOverlay {
                visible: hostShell.activeSurface === "keybinds"
                hostShell: panelScope.hostShell
                anchors.centerIn: parent
            }

            // 4. Calendar & World Clock Flyout (Anchored Top-Center)
            CalendarPanel {
                visible: hostShell.activeSurface === "calendar"
                hostShell: panelScope.hostShell
                anchors {
                    top: parent.top
                    topMargin: 8
                    horizontalCenter: parent.horizontalCenter
                }
            }

            // 5. Audio Panel Flyout (Anchored Top-Right)
            AudioPanel {
                visible: hostShell.activeSurface === "audio"
                hostShell: panelScope.hostShell
                anchors {
                    top: parent.top
                    topMargin: 8
                    right: parent.right
                    rightMargin: 12
                }
            }

            // 6. Network Panel Flyout (Anchored Top-Right)
            NetworkPanel {
                visible: hostShell.activeSurface === "network"
                hostShell: panelScope.hostShell
                anchors {
                    top: parent.top
                    topMargin: 8
                    right: parent.right
                    rightMargin: 12
                }
            }

            // 7. Bluetooth Panel Flyout (Anchored Top-Right)
            BluetoothPanel {
                visible: hostShell.activeSurface === "bluetooth"
                hostShell: panelScope.hostShell
                anchors {
                    top: parent.top
                    topMargin: 8
                    right: parent.right
                    rightMargin: 12
                }
            }

            // 8. Monitor / Display Panel Flyout (Anchored Top-Right)
            MonitorPanel {
                visible: hostShell.activeSurface === "monitor"
                hostShell: panelScope.hostShell
                anchors {
                    top: parent.top
                    topMargin: 8
                    right: parent.right
                    rightMargin: 12
                }
            }

            // 9. Notification History Center Drawer (Anchored Top-Right)
            NotificationCenter {
                visible: hostShell.activeSurface === "notifications"
                hostShell: panelScope.hostShell
                anchors {
                    top: parent.top
                    topMargin: 8
                    right: parent.right
                    rightMargin: 12
                }
            }

            // 10. Power & Battery Panel Flyout (Anchored Top-Right)
            PowerPanel {
                visible: hostShell.activeSurface === "power"
                hostShell: panelScope.hostShell
                anchors {
                    top: parent.top
                    topMargin: 8
                    right: parent.right
                    rightMargin: 12
                }
            }
        }
    }
}
