import QtQuick
import QtQuick.Layouts
import "../singletons"

Item {
    anchors.fill: parent
    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            Text { text: "Notifications"; color: Colors.colorOnSurface; font.pixelSize: 14; Layout.fillWidth: true }
            Text { text: "Clear all"; color: Colors.primary; font.pixelSize: 12
                MouseArea { anchors.fill: parent; onClicked: Notifs.dismissAll() } }
        }

        ListView {
            Layout.fillWidth: true; Layout.fillHeight: true
            clip: true; spacing: 6
            model: Notifs.notifications
            delegate: Rectangle {
                width: ListView.view.width; height: 60; radius: 10; color: Colors.surfaceVariant
                Column {
                    anchors.fill: parent; anchors.margins: 10; spacing: 2
                    Text { text: modelData.summary; color: Colors.colorOnSurface; font.bold: true; font.pixelSize: 13 }
                    Text { text: modelData.body; color: Colors.colorOnSurface; opacity: 0.8; font.pixelSize: 11; elide: Text.ElideRight; width: parent.width }
                }
                MouseArea { anchors.fill: parent; onClicked: Notifs.dismiss(modelData.id) }
            }
        }
    }
}
