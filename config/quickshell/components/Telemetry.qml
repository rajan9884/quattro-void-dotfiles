pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: telemetry

    // Audio & Microphone
    property string audioIcon: "󰕾"
    property string audioText: "75%"
    property int audioVolume: 75
    property bool audioMuted: false
    property string micIcon: "󰍬"
    property bool micMuted: false
    property string audioSinkName: "Default Output"
    property var audioSinks: []

    // Display & Brightness
    property string brightIcon: "󰃠"
    property string brightText: "100%"
    property int brightPercent: 100
    property bool nightLightActive: false

    // Network (NetworkManager)
    property string wifiIcon: "󰤨"
    property string wifiText: "Online"
    property bool wifiConnected: true
    property bool wifiEnabled: true
    property string wifiSsid: "Connected"
    property string ipAddress: "127.0.0.1"
    property var wifiNetworks: []

    // Bluetooth (BlueZ)
    property string btIcon: "󰂯"
    property string btText: "On"
    property bool btPowered: true
    property bool btConnected: false
    property var btDevices: []

    // Battery & Power
    property string batIcon: "󰁹"
    property string batText: "100%"
    property int batPercent: 100
    property string batStatus: "Full"
    property bool batCharging: false
    property bool batLow: false
    property string powerProfile: "balanced"
    property string cpuLoad: "4%"
    property string memUsed: "1.8G"

    // MPRIS Media
    property string mediaTitle: ""
    property string mediaStatus: "Stopped"

    // Notifications & DND
    property bool dndEnabled: false
    property var notificationsList: []

    function pushNotification(appName, summary, body, urgency) {
        var entry = {
            "id": Date.now(),
            "app": appName || "System",
            "summary": summary || "Notification",
            "body": body || "",
            "time": Qt.formatDateTime(new Date(), "HH:mm"),
            "urgent": urgency === "critical"
        }
        var updated = [entry].concat(telemetry.notificationsList.slice(0, 39))
        telemetry.notificationsList = updated
    }

    function clearNotifications() {
        telemetry.notificationsList = []
    }

    function runCmd(cmd) {
        Quickshell.execDetached(["sh", "-c", cmd])
    }

    function refreshNow() {
        statusProc.running = true
    }

    Process {
        id: statusProc
        command: ["sh", "-c", "~/.local/bin/qs-status-json"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    var o = JSON.parse(data)
                    if (o.audio_icon) telemetry.audioIcon = o.audio_icon
                    if (o.audio_text !== undefined) telemetry.audioText = o.audio_text
                    if (o.audio_vol !== undefined) telemetry.audioVolume = o.audio_vol
                    telemetry.audioMuted = !!o.audio_muted
                    if (o.mic_icon) telemetry.micIcon = o.mic_icon
                    telemetry.micMuted = !!o.mic_muted
                    if (o.audio_sink) telemetry.audioSinkName = o.audio_sink

                    if (o.bright_icon) telemetry.brightIcon = o.bright_icon
                    if (o.bright_text !== undefined) telemetry.brightText = o.bright_text
                    if (o.bright_pct !== undefined) telemetry.brightPercent = o.bright_pct
                    telemetry.nightLightActive = !!o.nightlight

                    if (o.wifi_icon) telemetry.wifiIcon = o.wifi_icon
                    if (o.wifi_text !== undefined) telemetry.wifiText = o.wifi_text
                    telemetry.wifiConnected = !!o.wifi_connected
                    telemetry.wifiEnabled = !!o.wifi_enabled
                    if (o.wifi_ssid) telemetry.wifiSsid = o.wifi_ssid
                    if (o.ip_addr) telemetry.ipAddress = o.ip_addr

                    if (o.bt_icon) telemetry.btIcon = o.bt_icon
                    if (o.bt_text !== undefined) telemetry.btText = o.bt_text
                    telemetry.btPowered = !!o.bt_powered
                    telemetry.btConnected = !!o.bt_connected

                    if (o.bat_icon) telemetry.batIcon = o.bat_icon
                    if (o.bat_text !== undefined) telemetry.batText = o.bat_text
                    if (o.bat_pct !== undefined) telemetry.batPercent = o.bat_pct
                    if (o.bat_status) telemetry.batStatus = o.bat_status
                    telemetry.batCharging = !!o.bat_charging
                    telemetry.batLow = !!o.bat_low
                    if (o.power_profile) telemetry.powerProfile = o.power_profile
                    if (o.cpu_load) telemetry.cpuLoad = o.cpu_load
                    if (o.mem_used) telemetry.memUsed = o.mem_used

                    if (o.media_title !== undefined) telemetry.mediaTitle = o.media_title
                    if (o.media_status) telemetry.mediaStatus = o.media_status
                } catch (e) {}
            }
        }
    }

    Timer {
        interval: 2500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: statusProc.running = true
    }
}
