pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: theme

    // Foundational Quattro colors.toml tokens
    property string name: "Tokyo Night"
    property color bg: "#1a1b26"
    property color darkBg: "#16161e"
    property color darkerBg: "#101014"
    property color lighterBg: "#24283b"
    property color selection: "#292e42"
    property color muted: "#565f89"
    property color fg: "#a9b1d6"
    property color darkFg: "#565f89"
    property color lightFg: "#b4bee6"
    property color brightFg: "#c0caf5"
    property color accent: "#7aa2f7"
    property color urgent: "#f7768e"
    property color warning: "#e0af68"
    property color success: "#9ece6a"
    property color magenta: "#bb9af7"
    property color cyan: "#7dcfff"

    // Quattro shell.toml [font], [bar], and [spacing] tokens
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int baseFontSize: 12
    property int captionSize: 10
    property int bodySmallSize: 11
    property int titleSize: 14
    property int headingSize: 16
    property int displaySize: 24
    property int iconSize: 13

    property int barSizeHorizontal: 26
    property int barSizeVertical: 28
    property string barPosition: "top"
    property string barBackgroundMode: "opaque" // "opaque" | "glassy" | "clear"
    property int cornerRadius: 6
    property int panelPadding: 18
    property int popupPadding: 14

    readonly property real barAlpha: barBackgroundMode === "opaque" ? 0.96 : (barBackgroundMode === "glassy" ? 0.72 : 0.0)

    function cycleBarTransparency() {
        if (barBackgroundMode === "opaque") barBackgroundMode = "glassy"
        else if (barBackgroundMode === "glassy") barBackgroundMode = "clear"
        else barBackgroundMode = "opaque"
    }

    FileView {
        id: themeFile
        path: Quickshell.env("HOME") + "/.config/quickshell/theme.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                var d = JSON.parse(themeFile.text())
                if (d.name) theme.name = d.name
                if (d.background) theme.bg = d.background
                if (d.dark_background) theme.darkBg = d.dark_background
                if (d.darker_background) theme.darkerBg = d.darker_background
                if (d.lighter_background) theme.lighterBg = d.lighter_background
                if (d.selection) theme.selection = d.selection
                if (d.muted) theme.muted = d.muted
                if (d.foreground) theme.fg = d.foreground
                if (d.dark_foreground) theme.darkFg = d.dark_foreground
                if (d.light_foreground) theme.lightFg = d.light_foreground
                if (d.bright_foreground) theme.brightFg = d.bright_foreground
                if (d.accent) theme.accent = d.accent
                if (d.red) theme.urgent = d.red
                if (d.yellow) theme.warning = d.yellow
                if (d.green) theme.success = d.green
                if (d.magenta) theme.magenta = d.magenta
                if (d.cyan) theme.cyan = d.cyan
            } catch (e) {
                console.warn("Theme.qml JSON parse error:", e)
            }
        }
    }
}
