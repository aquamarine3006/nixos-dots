import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../singletons"

Item {
    anchors.fill: parent

    property var wallpapers: []
    property string mode: "dark"

    Component.onCompleted: scan.running = true

    Process {
        id: scan
        command: ["bash", "-c", "find $HOME/nixos-dots/home/dotfiles/wallpapers -type f \\( -name '*.jpg' -o -name '*.png' -o -name '*.webp' \\) 2>/dev/null | head -30"]
        stdout: SplitParser {
            onRead: d => {
                const p = d.trim()
                if (p) wallpapers.push(p)
                wallpapers = [...wallpapers]
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // Header with Title and Dark/Light toggle
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Wallpapers"
                color: Colors.textSurface
                font.pixelSize: 16
                font.bold: true
                Layout.fillWidth: true
            }
            Rectangle {
                width: 80; height: 28; radius: 14
                color: mode === "dark" ? Colors.primary : Colors.surfaceVariant
                Text {
                    anchors.centerIn: parent
                    text: mode === "dark" ? "Dark" : "Light"
                    color: mode === "dark" ? Colors.textPrimary : Colors.textSurface
                    font.pixelSize: 12
                    font.bold: true
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mode = mode === "dark" ? "light" : "dark"
                }
            }
        }

        // Wallpaper Grid
        GridView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            cellWidth: (width - 12) / 3
            cellHeight: cellWidth * 0.5625 // 16:9 aspect ratio
            model: wallpapers

            delegate: Rectangle {
                width: GridView.view.cellWidth - 8
                height: GridView.view.cellHeight - 8
                radius: 8
                color: Colors.surfaceVariant
                clip: true

                Image {
                    anchors.fill: parent
                    source: "file://" + modelData
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        setWall.command = ["/home/aqua/scripts/wallpaper.sh", modelData, mode]
                        setWall.running = true
                        Flags.close()
                    }
                }
            }
        }
    }

    Process { id: setWall }
}
