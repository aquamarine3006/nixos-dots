import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../singletons"

Item {
    anchors.fill: parent
    RowLayout {
        anchors.centerIn: parent
        spacing: 16

        Repeater {
            model: [
                { label: "Lock", cmd: ["qs", "ipc", "call", "lock", "lock"] },
                { label: "Logout", cmd: ["hyprctl", "dispatch", "exit"] },
                { label: "Suspend", cmd: ["systemctl", "suspend"] },
                { label: "Reboot", cmd: ["systemctl", "reboot"] },
                { label: "Shutdown", cmd: ["systemctl", "poweroff"] }
            ]
            Rectangle {
                width: 90; height: 70; radius: 10; color: Colors.surfaceVariant
                Text { anchors.centerIn: parent; text: modelData.label; color: Colors.colorOnSurface; font.pixelSize: 12 }
                MouseArea {
                    anchors.fill: parent
                    onClicked: { actProc.command = modelData.cmd; actProc.running = true; Flags.close() }
                }
            }
        }
    }
    Process { id: actProc }
}
