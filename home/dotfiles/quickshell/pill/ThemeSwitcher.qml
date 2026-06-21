import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../singletons"

Item {
    anchors.fill: parent
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 16
        Text { text: "Theme Mode"; color: Colors.colorOnSurface; font.pixelSize: 16; Layout.alignment: Qt.AlignHCenter }
        Row {
            spacing: 12
            Layout.alignment: Qt.AlignHCenter
            Rectangle {
                width: 100; height: 40; radius: 8; color: Colors.surfaceVariant
                Text { anchors.centerIn: parent; text: "Dark"; color: Colors.colorOnSurface }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        applyProc.command = ["bash","-c","WALL=$(cat ~/.cache/current-wallpaper); ~/scripts/wallpaper.sh \"$WALL\" dark"]
                        applyProc.running = true; Flags.close()
                    }
                }
            }
            Rectangle {
                width: 100; height: 40; radius: 8; color: Colors.surfaceVariant
                Text { anchors.centerIn: parent; text: "Light"; color: Colors.colorOnSurface }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        applyProc.command = ["bash","-c","WALL=$(cat ~/.cache/current-wallpaper); ~/scripts/wallpaper.sh \"$WALL\" light"]
                        applyProc.running = true; Flags.close()
                    }
                }
            }
        }
    }
    Process { id: applyProc }
}
