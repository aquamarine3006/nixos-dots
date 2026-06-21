import Quickshell
import Quickshell.Wayland
import QtQuick
import "../singletons"

PanelWindow {
    id: root
    required property var screen
    screen: root.screen

    anchors { bottom: true; left: true; right: true }
    margins.bottom: 100
    implicitHeight: 50
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:osd"
    visible: Flags.activePanel === "osd"

    Rectangle {
        anchors.centerIn: parent
        width: 300; height: 50
        color: Colors.surfaceAlpha
        radius: 25
        border.color: Colors.outline
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: {
                if (Flags.osdType === "volume") return "Volume: " + Math.round(Flags.osdValue) + "%"
                if (Flags.osdType === "brightness") return "Brightness: " + Math.round(Flags.osdValue) + "%"
                if (Flags.osdType === "mute") return "Muted"
                return ""
            }
            color: Colors.textSurface
            font.pixelSize: 16
            font.bold: true
        }
    }
}
