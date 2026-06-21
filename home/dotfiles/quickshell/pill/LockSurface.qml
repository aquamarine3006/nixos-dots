import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import "../singletons"

WlSessionLock {
    id: lock

    IpcHandler {
        target: "lock"
        function lock() { lock.locked = true }
        function unlock() { lock.locked = false }
    }

    WlSessionLockSurface {
        Rectangle {
            anchors.fill: parent
            color: Colors.background

            Column {
                anchors.centerIn: parent
                spacing: 20

                Text {
                    text: "Locked"
                    color: Colors.colorOnSurface
                    font.pixelSize: 32
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Rectangle {
                    width: 220; height: 40
                    color: Colors.surfaceVariant
                    radius: 8
                    border.color: Colors.outline
                    border.width: 1
                    anchors.horizontalCenter: parent.horizontalCenter

                    TextInput {
                        id: passInput
                        anchors.fill: parent
                        anchors.margins: 8
                        color: Colors.colorOnSurface
                        echoMode: TextInput.Password
                        font.pixelSize: 16
                        focus: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        Keys.onReturnPressed: {
                            lock.locked = false
                            passInput.text = ""
                        }
                    }
                }
            }
        }
    }
}
