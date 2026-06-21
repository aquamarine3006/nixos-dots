import QtQuick
import "../singletons"

Item {
    width: Motion.pillExpanded
    height: 460

    Rectangle {
        anchors.fill: parent
        color: Colors.surfaceAlpha
        radius: 16
        border.color: Colors.outline
        border.width: 1
    }

    Loader {
        anchors.fill: parent
        anchors.margins: 12
        source: {
            switch (Flags.activePanel) {
                case "launcher": return "Launcher.qml"
                case "wallpaper": return "Wallpaper.qml"
                case "theme": return "ThemeSwitcher.qml"
                case "power": return "Power.qml"
                case "mixer": return "Mixer.qml"
                case "media": return "MediaPanel.qml"
                case "calendar": return "Calendar.qml"
                case "notifications": return "Notifications.qml"
                case "clipboard": return "Clipboard.qml"
                case "sysmon": return "SysmonPanel.qml"
                case "network": return "Network.qml"
                default: return ""
            }
        }
    }
}
