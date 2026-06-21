import Quickshell
import Quickshell.Wayland
import QtQuick
import "../singletons"

PanelWindow {
    id: root
    required property var screen
    screen: root.screen

    anchors { top: true; right: true }
    margins.top: 60
    margins.right: 20

    implicitWidth: 320
    implicitHeight: 400
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell:notifs"

    ListView {
        anchors.fill: parent
        model: Notifs.notifications
        spacing: 10
        clip: true

        delegate: Rectangle {
            width: 300; height: 70; radius: 12
            color: Colors.surfaceAlpha
            border.color: Colors.outline
            border.width: 1

            Column {
                anchors.fill: parent; anchors.margins: 12; spacing: 4
                Text { text: modelData.summary; color: Colors.colorOnSurface; font.bold: true; font.pixelSize: 14; elide: Text.ElideRight; width: parent.width }
                Text { text: modelData.body; color: Colors.colorOnSurface; font.pixelSize: 12; wrapMode: Text.Wrap; width: parent.width; maximumLineCount: 2; elide: Text.ElideRight }
            }

            MouseArea { anchors.fill: parent; onClicked: Notifs.dismiss(modelData.id) }
            Timer {
                interval: modelData.expire > 0 ? modelData.expire : 5000
                running: true; repeat: false
                onTriggered: Notifs.dismiss(modelData.id)
            }
        }
    }
}
