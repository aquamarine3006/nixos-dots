import QtQuick
import QtQuick.Layouts
import "../singletons"

Item {
    anchors.fill: parent
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 8
        Text {
            text: new Date().toLocaleDateString(Qt.locale(), "dddd, MMMM d yyyy")
            color: Colors.colorOnSurface; font.pixelSize: 16; Layout.alignment: Qt.AlignHCenter
        }
        Text {
            text: new Date().toLocaleTimeString(Qt.locale(), "HH:mm:ss")
            color: Colors.colorOnSurface; opacity: 0.7; font.pixelSize: 24; Layout.alignment: Qt.AlignHCenter
        }
    }
}
