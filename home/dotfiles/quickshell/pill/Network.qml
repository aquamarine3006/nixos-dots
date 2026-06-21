import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../singletons"

Item {
    anchors.fill: parent
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 14
        Text { text: "Network"; color: Colors.colorOnSurface; font.pixelSize: 16; Layout.alignment: Qt.AlignHCenter }
        Text { text: "Opening impala TUI in terminal…"; color: Colors.colorOnSurface; opacity: 0.7; font.pixelSize: 12; Layout.alignment: Qt.AlignHCenter }
        Rectangle {
            width: 160; height: 40; radius: 8; color: Colors.surfaceVariant
            Layout.alignment: Qt.AlignHCenter
            Text { anchors.centerIn: parent; text: "Open impala"; color: Colors.colorOnSurface }
            MouseArea {
                anchors.fill: parent
                onClicked: { openProc.command = ["kitty", "--class", "impala", "-e", "impala"]; openProc.running = true; Flags.close() }
            }
        }
    }
    Process { id: openProc }
}
