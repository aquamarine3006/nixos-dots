import QtQuick
import QtQuick.Layouts
import "../singletons"

Item {
    anchors.fill: parent
    Component.onCompleted: Cliphist.load()

    ColumnLayout {
        anchors.fill: parent
        spacing: 8
        Text { text: "Clipboard History"; color: Colors.colorOnSurface; font.pixelSize: 14 }
        ListView {
            Layout.fillWidth: true; Layout.fillHeight: true
            clip: true; spacing: 4
            model: Cliphist.entries
            delegate: Rectangle {
                width: ListView.view.width; height: 36; radius: 6
                color: ma.containsMouse ? Colors.primaryAlpha : Colors.surfaceVariant
                Text {
                    anchors.left: parent.left; anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.preview; color: Colors.colorOnSurface; font.pixelSize: 12; elide: Text.ElideRight; width: parent.width - 20
                }
                MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; onClicked: Cliphist.paste(modelData) }
            }
        }
    }
}
