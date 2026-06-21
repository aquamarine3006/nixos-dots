import Quickshell
import Quickshell.Wayland
import QtQuick
import "../singletons"

Item {
    id: root
    required property var screen

    PanelWindow {
        screen: root.screen
        exclusiveZone: 48
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "quickshell:pill-reserve"
        anchors { top: true; left: true; right: true }
        margins.top: 0
        implicitHeight: 48
        color: "transparent"
        mask: Region {}
    }

    PanelWindow {
        screen: root.screen
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell:pill"
        WlrLayershell.keyboardFocus: Flags.activePanel !== "" && Flags.activePanel !== "osd" ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        exclusiveZone: -1
        anchors { top: true; left: true; right: true }
        margins.top: 0
        implicitHeight: Flags.activePanel !== "" && Flags.activePanel !== "osd" ? 520 : 48
        color: "transparent"

        MouseArea {
            anchors.fill: parent
            onClicked: if (Flags.activePanel !== "") Flags.close()
            z: -1
        }

        Pill {
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
