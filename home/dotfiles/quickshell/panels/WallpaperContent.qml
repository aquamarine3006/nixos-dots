pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    signal dismiss()

    readonly property string wallDir:    Quickshell.env("HOME") + "/nixos-dots/home/dotfiles/wallpapers"
    readonly property string wallScript: Quickshell.env("HOME") + "/nixos-dots/home/dotfiles/scripts/wallpaper.sh"
    readonly property int cols: 4
    readonly property int gap:  8

    ListModel { id: wallModel }

    Process {
        id: lister
        command: ["bash", "-c", "for f in \"" + root.wallDir + "\"/*.{jpg,jpeg,png,webp}; do [ -f \"$f\" ] && echo \"$f\"; done"]
        stdout: SplitParser { onRead: line => { const p = line.trim(); if (p.length > 0) wallModel.append({ path: p }) } }
    }

    Component.onCompleted: {
        wallModel.clear(); lister.running = true
        grid.currentIndex = 0; grid.forceActiveFocus()
    }

    GridView {
        id: grid
        anchors { fill: parent; margins: 14 }
        clip: true; model: wallModel; currentIndex: 0
        boundsBehavior: Flickable.StopAtBounds
        cellWidth:  width / root.cols; cellHeight: cellWidth
        focus: true

        Keys.onEscapePressed: { root.dismiss(); event.accepted = true }
        Keys.onReturnPressed: {
            if (grid.currentIndex >= 0 && grid.currentIndex < wallModel.count) {
                Quickshell.execDetached(["bash", root.wallScript, wallModel.get(grid.currentIndex).path])
                root.dismiss()
            }
            event.accepted = true
        }
        Keys.onLeftPressed:  { grid.moveCurrentIndexLeft();  event.accepted = true }
        Keys.onRightPressed: { grid.moveCurrentIndexRight(); event.accepted = true }
        Keys.onUpPressed:    { grid.moveCurrentIndexUp();    event.accepted = true }
        Keys.onDownPressed:  { grid.moveCurrentIndexDown();  event.accepted = true }

        delegate: Item {
            id: wrap
            required property string path
            required property int    index
            width:  GridView.view.cellWidth; height: GridView.view.cellHeight

            readonly property bool active: grid.currentIndex === wrap.index

            Rectangle {
                id: thumb
                anchors.centerIn: parent
                width:  wrap.width  - root.gap; height: wrap.height - root.gap
                radius: 8; clip: true; color: "#111111"

                border.width: wrap.active ? 2 : 0; border.color: "#ffffff"
                Behavior on border.width { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

                scale: wrap.active ? 1.05 : 1.0; transformOrigin: Item.Center
                Behavior on scale { SpringAnimation { spring: 6.5; damping: 0.78 } }

                Image {
                    anchors.fill: parent; source: "file://" + wrap.path
                    fillMode: Image.PreserveAspectCrop; asynchronous: true; cache: false
                }

                Rectangle {
                    anchors.fill: parent; color: "#000000"
                    opacity: wrap.active ? 0.0 : 0.25
                    Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                }

                MouseArea {
                    anchors.fill: parent; hoverEnabled: true
                    onEntered: grid.currentIndex = wrap.index
                    onClicked: {
                        grid.currentIndex = wrap.index
                        Quickshell.execDetached(["bash", root.wallScript, wrap.path])
                        root.dismiss()
                    }
                }
            }
        }
    }
}
