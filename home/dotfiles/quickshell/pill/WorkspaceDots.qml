import QtQuick
import Quickshell.Hyprland
import "../singletons"

Row {
    spacing: 6
    Repeater {
        model: Hyprland.workspaces.values.filter(w => w.id > 0)
        Rectangle {
            width: modelData.active ? 18 : 8
            height: 8
            radius: 4
            color: modelData.active ? Colors.primary : Colors.surfaceVariant
            Behavior on width { NumberAnimation { duration: Motion.durationFast } }
            MouseArea { anchors.fill: parent; onClicked: Hyprland.dispatch("workspace " + modelData.id) }
        }
    }
}
