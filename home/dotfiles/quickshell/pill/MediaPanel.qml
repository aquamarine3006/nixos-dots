import QtQuick
import QtQuick.Layouts
import "../singletons"

Item {
    anchors.fill: parent
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 12
        Text { text: Media.title || "Nothing playing"; color: Colors.colorOnSurface; font.pixelSize: 16; Layout.alignment: Qt.AlignHCenter }
        Text { text: Media.artist; color: Colors.colorOnSurface; opacity: 0.7; font.pixelSize: 12; Layout.alignment: Qt.AlignHCenter }
        Row {
            spacing: 16
            Layout.alignment: Qt.AlignHCenter
            Text { text: "\uf048"; font.pixelSize: 18; color: Colors.colorOnSurface; MouseArea { anchors.fill: parent; onClicked: Media.previous() } }
            Text { text: Media.status === "Playing" ? "\uf04c" : "\uf04b"; font.pixelSize: 18; color: Colors.colorOnSurface; MouseArea { anchors.fill: parent; onClicked: Media.toggle() } }
            Text { text: "\uf051"; font.pixelSize: 18; color: Colors.colorOnSurface; MouseArea { anchors.fill: parent; onClicked: Media.next() } }
        }
    }
}
