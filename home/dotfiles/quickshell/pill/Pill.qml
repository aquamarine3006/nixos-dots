import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../singletons"

Item {
    id: root
    width: Flags.activePanel !== "" && Flags.activePanel !== "osd" ? Motion.pillExpanded : Motion.pillCollapsed
    height: 42
    clip: true // Prevents contents from spilling out when expanding/collapsing

    Behavior on width { NumberAnimation { duration: Motion.duration; easing.type: Motion.decel } }

    IpcHandler {
        target: "pill"
        function launcher() { Flags.toggle("launcher") }
        function wallpaper() { Flags.toggle("wallpaper") }
        function theme() { Flags.toggle("theme") }
        function power() { Flags.toggle("power") }
        function mixer() { Flags.toggle("mixer") }
        function media() { Flags.toggle("media") }
        function calendar() { Flags.toggle("calendar") }
        function notifications() { Flags.toggle("notifications") }
        function clipboard() { Cliphist.load(); Flags.toggle("clipboard") }
        function sysmon() { Flags.toggle("sysmon") }
        function network() { Flags.toggle("network") }
        function osd(type: string) {
            const v = type === "volume" ? Audio.volume : type === "brightness" ? Bright.percent : 0
            Flags.showOsd(type === "mute" ? "mute" : type, v)
        }
        function reloadColors() {}
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.surfaceAlpha
        radius: root.height / 2
        border.color: Colors.outline
        border.width: 1
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 8
        visible: Flags.activePanel === "" || Flags.activePanel === "osd"
        clip: true

        WorkspaceDots { Layout.fillWidth: false }
        Item { Layout.fillWidth: true }
        Clock { Layout.fillWidth: false }
        Item { Layout.fillWidth: true }
        
        Row {
            spacing: 4
            Layout.fillWidth: false
            Text { text: Audio.muted ? "󰝟" : "󰕾"; font.pixelSize: 14; color: Colors.textSurface }
            Text { text: Audio.muted ? "–" : (Audio.volume + "%"); font.pixelSize: 12; color: Colors.textSurface }
        }
        Row {
            spacing: 4
            Layout.fillWidth: false
            Text { text: "󰃞"; font.pixelSize: 14; color: Colors.textSurface }
            Text { text: Bright.percent + "%"; font.pixelSize: 12; color: Colors.textSurface }
        }
        Row {
            spacing: 4
            Layout.fillWidth: false
            Text { text: Battery.charging ? "󰂄" : "󰁹"; font.pixelSize: 14; color: Battery.percent < 15 ? Colors.error : Colors.textSurface }
            Text { text: Battery.percent + "%"; font.pixelSize: 12; color: Battery.percent < 15 ? Colors.error : Colors.textSurface }
        }
    }

    Loader {
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 8
        active: Flags.activePanel !== "" && Flags.activePanel !== "osd"
        sourceComponent: PanelHost {}
    }
}
